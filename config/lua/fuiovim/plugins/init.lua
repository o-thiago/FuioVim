local info_plugin = vim.g.nix_info_plugin_name or "nix-info"
local has_info, nix_info = pcall(require, info_plugin)
local function cat(name)
	if not has_info then
		return true
	end
	local val = nix_info(true, "settings", "cats", name)
	return val ~= false
end

local plugins = {}

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

if cat("completion") then
	table.insert(plugins, { import = "fuiovim.plugins.blink_cmp" })
end

if cat("lsp") then
	table.insert(plugins, { import = "fuiovim.plugins.lsp" })
end

if cat("formatting") then
	table.insert(plugins, { import = "fuiovim.plugins.conform" })
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
