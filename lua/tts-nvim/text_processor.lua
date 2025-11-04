local M = {}
local Job = require("plenary.job")

-- Simple pattern-based markdown cleanup
M.process_markdown_simple = function(text)
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
    -- Remove common LaTeX commands
    text = text:gsub("\\[a-zA-Z]+%*?%s*", "")
    
    -- Remove braces that are left over
    text = text:gsub("[{}]", "")
    
    -- Remove dollar signs for math mode
    text = text:gsub("%$", "")
    
    -- Remove percent comments
    text = text:gsub("%%.-\n", "\n")
    
    return text
end

-- Remove markdown syntax using treesitter
M.process_markdown_treesitter = function(text)
    local has_ts, _ = pcall(require, "vim.treesitter")
    if not has_ts then
        return M.process_markdown_simple(text)
    end
    
    -- Create a temporary buffer to parse the text
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
    vim.bo[buf].filetype = "markdown"
    
    -- Get the parser
    local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
    if not ok or not parser then
        vim.api.nvim_buf_delete(buf, { force = true })
        return M.process_markdown_simple(text)
    end
    
    local trees = parser:parse()
    if not trees or #trees == 0 then
        vim.api.nvim_buf_delete(buf, { force = true })
        return M.process_markdown_simple(text)
    end
    
    local root = trees[1]:root()
    
    -- Extract text content, excluding markup
    local result = {}
    
    -- Try to get text nodes
    local function extract_text(node)
        local node_type = node:type()
        
        -- Skip certain node types
        if node_type == "code_fence_delimiter" or 
           node_type == "fenced_code_block_delimiter" or
           node_type == "info_string" then
            return
        end
        
        if node:child_count() == 0 then
            local text_content = vim.treesitter.get_node_text(node, buf)
            if text_content and text_content:match("%S") then
                table.insert(result, text_content)
            end
        else
            for child in node:iter_children() do
                extract_text(child)
            end
        end
    end
    
    extract_text(root)
    
    vim.api.nvim_buf_delete(buf, { force = true })
    
    if #result > 0 then
        local combined = table.concat(result, " ")
        -- Clean up extra spaces
        combined = combined:gsub("%s+", " ")
        return combined:match("^%s*(.-)%s*$") or combined
    else
        return M.process_markdown_simple(text)
    end
end

-- Remove LaTeX/TeX syntax using treesitter
M.process_latex_treesitter = function(text)
    local has_ts, _ = pcall(require, "vim.treesitter")
    if not has_ts then
        return M.process_latex_simple(text)
    end
    
    -- Create a temporary buffer to parse the text
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, "\n"))
    vim.bo[buf].filetype = "tex"
    
    -- Get the parser
    local ok, parser = pcall(vim.treesitter.get_parser, buf, "latex")
    if not ok or not parser then
        vim.api.nvim_buf_delete(buf, { force = true })
        return M.process_latex_simple(text)
    end
    
    local trees = parser:parse()
    if not trees or #trees == 0 then
        vim.api.nvim_buf_delete(buf, { force = true })
        return M.process_latex_simple(text)
    end
    
    local root = trees[1]:root()
    
    -- Extract text content, excluding commands
    local result = {}
    
    local function extract_text(node)
        local node_type = node:type()
        
        -- Focus on text content nodes
        if node_type == "text_mode" or node_type == "text" then
            local text_content = vim.treesitter.get_node_text(node, buf)
            if text_content and text_content:match("%S") then
                table.insert(result, text_content)
            end
        elseif node:child_count() > 0 then
            for child in node:iter_children() do
                extract_text(child)
            end
        end
    end
    
    extract_text(root)
    
    vim.api.nvim_buf_delete(buf, { force = true })
    
    if #result > 0 then
        local combined = table.concat(result, " ")
        -- Clean up extra spaces
        combined = combined:gsub("%s+", " ")
        return combined:match("^%s*(.-)%s*$") or combined
    else
        return M.process_latex_simple(text)
    end
end

-- Remove markdown syntax using pandoc
M.process_markdown_pandoc = function(text)
    local result_lines = {}
    
    local job = Job:new({
        command = "pandoc",
        args = { "-f", "markdown", "-t", "plain", "--wrap=none" },
        writer = text,
        on_stdout = function(_, data)
            table.insert(result_lines, data)
        end,
        on_stderr = function(_, data)
            -- Ignore stderr
        end,
    })
    
    job:sync()
    
    if #result_lines > 0 then
        return table.concat(result_lines, "\n")
    else
        return M.process_markdown_simple(text)
    end
end

-- Remove LaTeX syntax using pandoc
M.process_latex_pandoc = function(text)
    local result_lines = {}
    
    local job = Job:new({
        command = "pandoc",
        args = { "-f", "latex", "-t", "plain", "--wrap=none" },
        writer = text,
        on_stdout = function(_, data)
            table.insert(result_lines, data)
        end,
        on_stderr = function(_, data)
            -- Ignore stderr
        end,
    })
    
    job:sync()
    
    if #result_lines > 0 then
        return table.concat(result_lines, "\n")
    else
        return M.process_latex_simple(text)
    end
end

-- Process text based on filetype and configuration
M.process_text = function(text, filetype, config)
    if not config.remove_syntax then
        return text
    end
    
    local method = config.syntax_removal_method or "treesitter"
    
    if filetype == "markdown" then
        if method == "pandoc" then
            return M.process_markdown_pandoc(text)
        else
            return M.process_markdown_treesitter(text)
        end
    elseif filetype == "tex" or filetype == "latex" then
        if method == "pandoc" then
            return M.process_latex_pandoc(text)
        else
            return M.process_latex_treesitter(text)
        end
    end
    
    return text
end

return M
