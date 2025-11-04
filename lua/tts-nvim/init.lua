M = {}

local Job = require("plenary.job")
local util = require("tts-nvim.util")
local config = require("tts-nvim.config")
local backends = require("tts-nvim.backends")
local nvimDataDir = vim.fn.stdpath("data") .. "/tts-nvim/"

M.tts = function()
    local lines, coords = util.getVisualSelection()
    local search_string = util.getTextFromSelection(lines, coords)
    search_string = util.processText(search_string)

    local backend = backends.get_backend(config.opts.backend)
    if not backend then
        print("Error: Unknown backend '" .. config.opts.backend .. "'. Available backends: " .. table.concat(backends.get_available_backends(), ", "))
        return
    end
    
    local valid, err = backend.validate_config(config.opts)
    if not valid then
        print("Error: " .. err)
        return
    end

    local plugin_dir = debug.getinfo(1, "S").source:sub(2):gsub("lua/tts%-nvim/init%.lua", "")
    local script_path = backend.get_script_path(plugin_dir)
    local args = backend.get_args(search_string, config.opts, nvimDataDir, nil)
    
    local job = Job:new({
        command = script_path,
        args = args,
        cwd = ".",
        on_stderr = function(_, data)
            if data ~= nil then
                print("stderr: ", data)
            end
        end,
    })
    job:start()
end

M.tts_to_file = function()
    local lines, coords = util.getVisualSelection()
    local search_string = util.getTextFromSelection(lines, coords)
    search_string = util.processText(search_string)

    local backend = backends.get_backend(config.opts.backend)
    if not backend then
        print("Error: Unknown backend '" .. config.opts.backend .. "'. Available backends: " .. table.concat(backends.get_available_backends(), ", "))
        return
    end
    
    local valid, err = backend.validate_config(config.opts)
    if not valid then
        print("Error: " .. err)
        return
    end

    local plugin_dir = debug.getinfo(1, "S").source:sub(2):gsub("lua/tts%-nvim/init%.lua", "")
    local script_path = backend.get_script_path(plugin_dir)
    local args = backend.get_args(search_string, config.opts, nvimDataDir, "tts.mp3")
    
    local job = Job:new({
        command = script_path,
        args = args,
        cwd = ".",
        on_stderr = function(_, data)
            if data ~= nil then
                print("stderr: ", data)
            end
        end,
    })
    job:start()
end

M.tts_set_language = function(args)
    local lang = args.fargs[1]
    local voice = config.opts.languages_to_voice[lang]
    if voice ~= nil then
        config.opts.voice = voice
        config.opts.language = lang
        print("TTS language set to " .. lang .. " with voice " .. voice)
    else
        print("Language " .. lang .. " not supported.")
    end
end

M.get_supported_languages = function()
    local languages = {}
    for lang, _ in pairs(config.opts.languages_to_voice) do
        table.insert(languages, lang)
    end
    return languages
end

M.setup = function(opts)
    config.setup_config(opts)
    os.execute("mkdir -p " .. nvimDataDir)
end

return M

