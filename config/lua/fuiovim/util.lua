local M = {}

local info_plugin = vim.g.nix_info_plugin_name or "nix-info"
local has_info, nix_info = pcall(require, info_plugin)

---Verifica se uma especificação está habilitada no wrapper Nix
---@param name string Nome da especificação (ex: "rust", "php", "tex", "core")
---@return boolean
function M.has_spec(name)
	if not has_info then
		return true
	end
	local val = nix_info(true, "settings", "specs", name)
	return val ~= false
end

---Verifica se um plugin foi instalado via Nix
---@param name string Nome do plugin
---@return boolean
function M.has_plugin(name)
	if not has_info then
		return true
	end
	return (nix_info(nil, "plugins", "lazy", name) or nix_info(nil, "plugins", "start", name)) ~= nil
end

return M
