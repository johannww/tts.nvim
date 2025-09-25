vim.api.nvim_create_user_command(
    "TTS",
    function(args) M.tts() end,
    { range = true }
)

vim.api.nvim_create_user_command(
    "TTSFile",
    function(args) M.tts_to_file() end,
    { range = true }
)
