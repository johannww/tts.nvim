vim.api.nvim_create_user_command("TTS", function(args)
    M.tts()
end, { range = true })

vim.api.nvim_create_user_command("TTSFile", function(args)
    M.tts_to_file()
end, { range = true })

vim.api.nvim_create_user_command("TTSSetLanguage", function(args)
    M.tts_set_language(args)
end, {
    nargs = 1,
    complete = function()
        return M.get_supported_languages()
    end,
})

vim.api.nvim_create_user_command("TTSSetBackend", function(args)
    M.tts_set_backend(args)
end, {
    nargs = 1,
    complete = function()
        return M.get_available_backends()
    end,
})

vim.api.nvim_create_augroup("TTSNvim", { clear = true })
vim.api.nvim_create_autocmd("ExitPre", {
    group = "TTSNvim",
    once = true,
    callback = function()
        M.on_exit()
    end,
})
