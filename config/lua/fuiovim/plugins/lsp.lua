local info_plugin = vim.g.nix_info_plugin_name or "nix-info"
local has_info, nix_info = pcall(require, info_plugin)
local function cat(name)
	if not has_info then
		return true
	end
	local val = nix_info(true, "settings", "cats", name)
	return val ~= false
end

return {
	"nvim-lspconfig",
	event = { "BufReadPre", "BufReadPost", "BufNewFile" },
	cmd = {
		"LspInfo",
	},
	after = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "LSP actions",
			callback = function(event)
				local opts = { buffer = event.buf }

				for _, set in pairs({
					{ "vd", vim.diagnostic.open_float },
					{ "vr", vim.lsp.buf.references },
					{ "rn", vim.lsp.buf.rename },
					{ "ca", vim.lsp.buf.code_action },
					{ "gd", vim.lsp.buf.definition },
					{ "gD", vim.lsp.buf.declaration },
					{ "gi", vim.lsp.buf.type_definition },
					{ "gs", vim.lsp.buf.signature_help },
				}) do
					local key, fun = unpack(set)
					vim.keymap.set("n", "<leader>" .. key, fun, opts)
				end
			end,
		})

		local servers = {}
		if cat("yaml") then
			table.insert(servers, "yamlls")
		end
		if cat("php") then
			table.insert(servers, "intelephense")
			table.insert(servers, "phpactor")
		end
		if cat("c_cpp") then
			table.insert(servers, "clangd")
		end
		if cat("python") then
			table.insert(servers, "pyright")
			table.insert(servers, "ruff")
		end
		if cat("web") then
			table.insert(servers, "tailwindcss")
			table.insert(servers, "cssls")
			table.insert(servers, "html")
			table.insert(servers, "jsonls")
			table.insert(servers, "ts_ls")
			table.insert(servers, "biome")
			table.insert(servers, "svelte")
		end
		if cat("nix") then
			table.insert(servers, "statix")
			table.insert(servers, "nixd")
		end
		if cat("tex") then
			table.insert(servers, "texlab")
		end
		if cat("lua") then
			table.insert(servers, "lua_ls")
		end
		if cat("csharp") then
			table.insert(servers, "omnisharp")
		end
		if cat("bash") then
			table.insert(servers, "bashls")
		end

		if #servers > 0 then
			vim.lsp.enable(servers)
		end
	end,
}
