local info_plugin = vim.g.nix_info_plugin_name or "nix-info"
local has_info, nix_info = pcall(require, info_plugin)
local function cat(name)
	if not has_info then
		return true
	end
	local val = nix_info(true, "settings", "cats", name)
	return val ~= false
end

vim.g.mapleader = " "
vim.cmd("runtime lua/fuiovim/set.vim")

local lze = require("lze")
lze.load("fuiovim.plugins")

if cat("core") then
	pcall(vim.cmd, "colorscheme rose-pine")
end

if cat("rust") then
	vim.g.rustaceanvim = {
		server = {
			on_attach = function(_, bufnr)
				vim.lsp.inlay_hint.enable(true, { bufnr })
			end,
		},
		tools = {
			enable_clippy = true,
		},
	}
end

if vim.g.neovide then
	vim.g.neovide_opacity = 0.9
	vim.o.guifont = "JetBrainsMono Nerd Font:h12"
else
	local use_cli_transparency = true
	if use_cli_transparency then
		local alphahls = { "Normal", "NormalFloat" }
		for _, hi in pairs(alphahls) do
			vim.api.nvim_set_hl(0, hi, { bg = "none" })
		end
	end
end
