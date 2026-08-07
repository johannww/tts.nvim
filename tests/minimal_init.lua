-- Minimal init.lua for testing
-- Reset runtime path to avoid conflicts with installed plugins
vim.opt.runtimepath = vim.fn.getcwd() .. "/tests/plenary.nvim," .. vim.fn.getcwd()
vim.opt.packpath = ""
