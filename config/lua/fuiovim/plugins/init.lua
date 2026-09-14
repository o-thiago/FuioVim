local has_spec = require("fuiovim.util").has_spec

local plugins = {}

if has_spec("completion") then
	table.insert(plugins, { import = "fuiovim.plugins.blink_cmp" })
end

if has_spec("lsp") then
	table.insert(plugins, { import = "fuiovim.plugins.lsp" })
end

if has_spec("formatting") then
	table.insert(plugins, { import = "fuiovim.plugins.conform" })
end

if has_spec("core") then
	table.insert(plugins, { import = "fuiovim.plugins.cord" })
	table.insert(plugins, { import = "fuiovim.plugins.oil" })
	table.insert(plugins, { import = "fuiovim.plugins.snacks" })
	table.insert(plugins, { import = "fuiovim.plugins.mini" })
	table.insert(plugins, {
		"rose-pine",
		colorscheme = "rose-pine",
	})
end

if has_spec("linting") then
	table.insert(plugins, { import = "fuiovim.plugins.nvim_lint" })
end

if has_spec("markdown") then
	table.insert(plugins, { import = "fuiovim.plugins.markdown" })
end

if has_spec("treesitter") then
	table.insert(plugins, { import = "fuiovim.plugins.treesitter" })
end

if has_spec("tex") then
	table.insert(plugins, { import = "fuiovim.plugins.vimtex" })
end

return plugins
