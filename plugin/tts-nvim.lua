vim.api.nvim_create_user_command(
    "TTS",
    function(args) M.tts() end,
    { range = true }
)
