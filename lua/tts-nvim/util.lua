local M = {}

M.getVisualSelection = function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "nx", false)
    local vstart = vim.fn.getpos("'<")
    local vend = vim.fn.getpos("'>")

    local line_start = vstart[2]
    local line_end = vend[2]
    local column_start = vstart[3]
    local column_end = vend[3]
    local lines = vim.fn.getline(line_start, line_end)

    local coordinates = {
        line_start = line_start,
        line_end = line_end,
        column_start = column_start,
        column_end =
            column_end
    }
    return lines, coordinates
end

M.getTextFromSelection = function(lines, coords)
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
    return search_string
end

M.processText = function(text)
    local text_processor = require("tts-nvim.text_processor")
    local config = require("tts-nvim.config")
    local filetype = vim.bo.filetype
    
    return text_processor.process_text(text, filetype, config.opts)
end

return M
