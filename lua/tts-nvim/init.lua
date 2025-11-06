M = {}

local Job = require("plenary.job")
local backends = require("tts-nvim.backends")
local config = require("tts-nvim.config")
local util = require("tts-nvim.util")
local nvimDataDir = vim.fn.stdpath("data") .. "/tts-nvim/"

M.is_running = false
M.job = nil

M.tts = function()
    local text = util.getAndProcessText()

    -- S for stream
    local EOF = "S\x1A"
    M.job:send(text .. EOF)
end

M.tts_to_file = function()
    local text = util.getAndProcessText()

    -- F for file
    local EOF = "F\x1A"
    M.job:send(text .. EOF)
end

M.tts_set_language = function(args)
    local lang = args.fargs[1]
    local backend_name = config.opts.backend

    -- Check if language is supported in the current backend
    local voice
    if config.opts.languages_to_voice and config.opts.languages_to_voice[backend_name] then
        voice = config.opts.languages_to_voice[backend_name][lang]
    elseif config.opts.languages_to_voice then
        -- Fallback to flat structure for backward compatibility
        voice = config.opts.languages_to_voice[lang]
    end

    if voice then
        config.opts.language = lang
        print(
            "TTS language set to " .. lang .. " (" .. backend_name .. " backend: " .. voice .. ")"
        )
    else
        config.opts.language = lang
        print(
            "TTS language set to "
                .. lang
                .. " (no specific voice mapping for "
                .. backend_name
                .. " backend)"
        )
    end
end

M.tts_set_backend = function(args)
    local backend_name = args.fargs[1]
    local backend = backends.get_backend(backend_name)
    if backend then
        config.opts.backend = backend_name
        print("TTS backend set to " .. backend_name)
    else
        print(
            "Error: Unknown backend '"
                .. backend_name
                .. "'. Available backends: "
                .. table.concat(backends.get_available_backends(), ", ")
        )
    end

    local valid, err = backend.validate_config(config.opts)
    if not valid then
        print("Error: " .. err)
        return
    end

    M.on_exit()

    local plugin_dir = debug.getinfo(1, "S").source:sub(2):gsub("lua/tts%-nvim/init%.lua", "")
    local script_path = backend.get_script_path(plugin_dir)
    local args = backend.get_args(config.opts, nvimDataDir, "tts.mp3")

    M.job = Job:new({
        command = script_path,
        args = args,
        cwd = ".",
        on_start = function()
            M.is_running = true
        end,
        on_exit = function()
            M.is_running = false
        end,
        on_stderr = function(_, data)
            if data ~= nil then
                print("stderr: ", data)
            end
        end,
    })
    M.job:start()
end

M.get_available_backends = function()
    return backends.get_available_backends()
end

M.get_supported_languages = function()
    local languages = {}
    local seen = {}

    -- Collect languages from current backend
    local backend_name = config.opts.backend
    if config.opts.languages_to_voice and config.opts.languages_to_voice[backend_name] then
        for lang, _ in pairs(config.opts.languages_to_voice[backend_name]) do
            if not seen[lang] then
                table.insert(languages, lang)
                seen[lang] = true
            end
        end
    end

    -- Also add languages from flat structure for backward compatibility
    if config.opts.languages_to_voice then
        for lang, voice in pairs(config.opts.languages_to_voice) do
            if type(voice) == "string" and not seen[lang] then
                table.insert(languages, lang)
                seen[lang] = true
            end
        end
    end

    return languages
end

M.setup = function(opts)
    config.setup_config(opts)
    os.execute("mkdir -p " .. nvimDataDir)
    M.tts_set_backend({ fargs = { config.opts.backend } })
end

M.on_exit = function()
    if M.is_running then
        os.execute("kill -9 " .. M.job.pid)
        M.job:shutdown()
        M.is_running = false
    end
end

return M
