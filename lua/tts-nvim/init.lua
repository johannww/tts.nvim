M = {}

local Job = require("plenary.job")
local util = require("tts-nvim.util")

M.tts = function()
    local lines, coords = util.getVisualSelection()

    local search_string = ""
    if coords["line_start"] == coords["line_end"] then
        search_string = string.sub(lines[1], coords["column_start"], coords["column_end"])
    else
        search_string = string.sub(lines[1], coords["column_start"], -1)
        for i = 2, (#lines - 1) do
            search_string = search_string .. lines[i]
        end
        search_string = search_string .. string.sub(lines[#lines], 0, coords["column_end"])
    end

    local pythonScriptPath = debug.getinfo(1, "S").source:sub(2):gsub("lua/tts%-nvim/init%.lua", "tts.py")
    local job = Job:new({
        command = pythonScriptPath,
        args = {search_string},
        cwd = ".",
        on_stderr = function(_, data)
            if data ~= nil then
                print("stderr: ", data)
            end
        end,
    })
    job:start()
end

M.setup = function()
    vim.api.nvim_create_user_command(
        "TTS",
        function (args) M.tts() end,
        {range = true}
    )
end

return M

