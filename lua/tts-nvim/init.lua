M = {}

local Job = require("plenary.job")
local util = require("tts-nvim.util")
local config = require("tts-nvim.config")

M.tts = function()
    local lines, coords = util.getVisualSelection()
    local search_string = util.getTextFromSelection(lines, coords)

    local pythonScriptPath = debug.getinfo(1, "S").source:sub(2):gsub("lua/tts%-nvim/init%.lua", "tts.py")
    local job = Job:new({
        command = pythonScriptPath,
        args = {search_string, config.opts.voice, config.opts.speed},
        cwd = ".",
        on_stderr = function(_, data)
            if data ~= nil then
                print("stderr: ", data)
            end
        end,
    })
    job:start()
end

M.setup = function(opts)
    config.setup_config(opts)
end

return M

