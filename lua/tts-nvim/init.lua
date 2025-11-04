M = {}

local Job = require("plenary.job")
local util = require("tts-nvim.util")
local config = require("tts-nvim.config")
local nvimDataDir = vim.fn.stdpath("data") .. "/tts-nvim/"

M.tts = function()
    local lines, coords = util.getVisualSelection()
    local search_string = util.getTextFromSelection(lines, coords)
    search_string = util.processText(search_string)

    local pythonScriptPath = debug.getinfo(1, "S").source:sub(2):gsub("lua/tts%-nvim/init%.lua", "tts.py")
    local voice = config.opts.languages_to_voice[config.opts.language]
    local job = Job:new({
        command = pythonScriptPath,
        args = {search_string, voice, config.opts.speed, nvimDataDir},
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

    local pythonScriptPath = debug.getinfo(1, "S").source:sub(2):gsub("lua/tts%-nvim/init%.lua", "tts.py")
    local voice = config.opts.languages_to_voice[config.opts.language]
    local job = Job:new({
        command = pythonScriptPath,
        args = {search_string, voice, config.opts.speed, nvimDataDir, "tts.mp3"},
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

