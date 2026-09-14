local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<leader>ca", function()
	vim.cmd.RustLsp("codeAction")
end, {
	buffer = bufnr,
	desc = "Ações de código (Rust)",
	silent = true,
})

vim.keymap.set("n", "K", function()
	vim.cmd.RustLsp({ "hover", "actions" })
end, {
	buffer = bufnr,
	desc = "Ações de hover (Rust)",
	silent = true,
})
