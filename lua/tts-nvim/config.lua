M = {}

M.opts = {
    voice = "en-GB-SoniaNeural",
    speed = 1.0,
}

M.setup_config = function(opts)
    opts = opts or {}
    M.opts = vim.tbl_deep_extend("force", M.opts, opts)
end

return M
