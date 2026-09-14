local M = {}

local info_plugin = vim.g.nix_info_plugin_name or "nix-info"
local has_info, nix_info = pcall(require, info_plugin)

---Check if a spec category is enabled via Nix
---@param name string Category name (e.g. "rust", "php", "tex", "core")
---@return boolean
function M.cat(name)
	if not has_info then
		return true
	end
	local val = nix_info(true, "settings", "cats", name)
	return val ~= false
end

return M
