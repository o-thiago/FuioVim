local cat = require("fuiovim.util").cat

local plugins = {}

if cat("completion") then
	table.insert(plugins, { import = "fuiovim.plugins.blink_cmp" })
end

if cat("lsp") then
	table.insert(plugins, { import = "fuiovim.plugins.lsp" })
end

if cat("formatting") then
	table.insert(plugins, { import = "fuiovim.plugins.conform" })
end

if cat("core") then
	table.insert(plugins, { import = "fuiovim.plugins.cord" })
	table.insert(plugins, { import = "fuiovim.plugins.oil" })
	table.insert(plugins, { import = "fuiovim.plugins.snacks" })
	table.insert(plugins, { import = "fuiovim.plugins.mini" })
	table.insert(plugins, {
		"rose-pine",
		colorscheme = "rose-pine",
	})
end

if cat("linting") then
	table.insert(plugins, { import = "fuiovim.plugins.nvim_lint" })
end

if cat("markdown") then
	table.insert(plugins, { import = "fuiovim.plugins.markdown" })
end

if cat("treesitter") then
	table.insert(plugins, { import = "fuiovim.plugins.treesitter" })
end

if cat("tex") then
	table.insert(plugins, { import = "fuiovim.plugins.vimtex" })
end

return plugins
