M = {}

M.opts = {
    voice = "en-GB-SoniaNeural", -- Deprecated, use 'language' instead
    language = "en",
    speed = 1.0,
    remove_syntax = false, -- Enable syntax removal for supported filetypes
    syntax_removal_method = "pandoc", -- "simple" (pattern-based) or "pandoc"
    languages_to_voice = {
        ["en"] = "en-GB-SoniaNeural",
        ["pt"] = "pt-BR-AntonioNeural",
        ["es"] = "es-ES-ElviraNeural",
        ["fr"] = "fr-FR-DeniseNeural",
        ["de"] = "de-DE-KatjaNeural",
        ["it"] = "it-IT-ElsaNeural",
        ["ja"] = "ja-JP-NanamiNeural",
        ["zh"] = "zh-CN-XiaoxiaoNeural",
    }
}

M.setup_config = function(opts)
    opts = opts or {}
    if opts.voice ~= nil then
        print("Warning: 'voice' option is deprecated. Please use 'language' option instead.")
    end
    M.opts = vim.tbl_deep_extend("force", M.opts, opts)
end

return M
