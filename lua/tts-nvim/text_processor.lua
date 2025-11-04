local M = {}
local Job = require("plenary.job")

-- Simple pattern-based markdown cleanup
M.process_markdown_simple = function(text)
    -- Remove HTML tags (do this first to handle <a>, <img>, etc.)
    text = text:gsub("<[^>]+>", "")
    
    -- Remove heading markers
    text = text:gsub("^#+%s+", "")
    text = text:gsub("\n#+%s+", "\n")

    -- Remove bold and italic markers
    text = text:gsub("%*%*(.-)%*%*", "%1")
    text = text:gsub("__(.-)__", "%1")
    text = text:gsub("%*(.-)%*", "%1")
    text = text:gsub("_(.-)_", "%1")

    -- Remove links but keep text
    text = text:gsub("%[(.-)%]%(.-)", "%1")

    -- Remove inline code
    text = text:gsub("`(.-)`", "%1")

    -- Remove list markers
    text = text:gsub("^%s*[%*%-+]%s+", "")
    text = text:gsub("\n%s*[%*%-+]%s+", "\n")
    text = text:gsub("^%s*%d+%.%s+", "")
    text = text:gsub("\n%s*%d+%.%s+", "\n")

    return text
end

-- Simple pattern-based LaTeX cleanup
M.process_latex_simple = function(text)
    -- Remove percent comments (must be done first to avoid processing commented commands)
    text = text:gsub("%%[^\n]*", "")

    -- Remove common LaTeX commands (with optional star and followed by space or brace)
    text = text:gsub("\\[a-zA-Z]+%*?[%s{]", " ")
    text = text:gsub("\\[a-zA-Z]+%*?$", "")

    -- Remove braces that are left over
    text = text:gsub("[{}]", "")

    -- Remove dollar signs for math mode
    text = text:gsub("%$", "")

    return text
end

-- Remove markdown syntax using pandoc
M.process_markdown_pandoc = function(text)
    local result_lines = {}
    local err_lines = {}

    local job = Job:new({
        command = "pandoc",
        args = { "-f", "markdown", "-t", "plain", "--wrap=none" },
        writer = text,
        on_stdout = function(_, data)
            table.insert(result_lines, data)
        end,
        on_stderr = function(_, data)
            table.insert(err_lines, data)
        end,
    })

    job:sync()

    if #err_lines > 0 then
        print("Error from pandoc: ", table.concat(err_lines, "\n"))
    end

    if #result_lines > 0 then
        return table.concat(result_lines, "\n")
    else
        print("Pandoc failed to process markdown text. Falling back to simple processing.")
        return M.process_markdown_simple(text)
    end
end

-- Remove LaTeX syntax using pandoc
M.process_latex_pandoc = function(text)
    local result_lines = {}
    local err_lines = {}

    local job = Job:new({
        command = "pandoc",
        args = { "-f", "latex", "-t", "plain", "--wrap=none" },
        writer = text,
        on_stdout = function(_, data)
            table.insert(result_lines, data)
        end,
        on_stderr = function(_, data)
            table.insert(err_lines, data)
        end,
    })

    job:sync()

    if #err_lines > 0 then
        print("Error from pandoc: ", table.concat(err_lines, "\n"))
    end

    if #result_lines > 0 then
        return table.concat(result_lines, "\n")
    else
        print("Pandoc failed to process LaTeX text. Falling back to simple processing.")
        return M.process_latex_simple(text)
    end
end

-- Process text based on filetype and configuration
M.process_text = function(text, filetype, config)
    if not config.remove_syntax then
        return text
    end

    local method = config.syntax_removal_method or "simple"

    if filetype == "markdown" then
        if method == "pandoc" then
            return M.process_markdown_pandoc(text)
        else
            return M.process_markdown_simple(text)
        end
    elseif filetype == "tex" or filetype == "latex" then
        if method == "pandoc" then
            return M.process_latex_pandoc(text)
        else
            return M.process_latex_simple(text)
        end
    end

    return text
end

return M
