local has_spec = require("fuiovim.util").has_spec

return {
	"nvim-lspconfig",
	event = { "BufReadPre", "BufReadPost", "BufNewFile" },
	cmd = {
		"LspInfo",
	},
	after = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			desc = "Configuração de ações e atalhos do LSP",
			callback = function(event)
				for _, set in pairs({
					{ "vd", vim.diagnostic.open_float, "Diagnósticos flutuantes" },
					{ "vr", vim.lsp.buf.references, "Referências do símbolo" },
					{ "rn", vim.lsp.buf.rename, "Renomear símbolo" },
					{ "ca", vim.lsp.buf.code_action, "Ações de código" },
					{ "gd", vim.lsp.buf.definition, "Ir para definição" },
					{ "gD", vim.lsp.buf.declaration, "Ir para declaração" },
					{ "gi", vim.lsp.buf.type_definition, "Ir para definição de tipo" },
					{ "gs", vim.lsp.buf.signature_help, "Ajuda de assinatura" },
				}) do
					local key, fun, desc = unpack(set)
					vim.keymap.set("n", "<leader>" .. key, fun, { buffer = event.buf, desc = desc })
				end
			end,
		})

		local servers = {}
		if has_spec("yaml") then
			table.insert(servers, "yamlls")
		end
		if has_spec("php") then
			table.insert(servers, "intelephense")
			table.insert(servers, "phpactor")
		end
		if has_spec("c_cpp") then
			table.insert(servers, "clangd")
		end
		if has_spec("python") then
			table.insert(servers, "pyright")
			table.insert(servers, "ruff")
		end
		if has_spec("web") then
			table.insert(servers, "tailwindcss")
			table.insert(servers, "cssls")
			table.insert(servers, "html")
			table.insert(servers, "jsonls")
			table.insert(servers, "ts_ls")
			table.insert(servers, "biome")
			table.insert(servers, "svelte")
		end
		if has_spec("nix") then
			table.insert(servers, "statix")
			table.insert(servers, "nixd")
		end
		if has_spec("tex") then
			table.insert(servers, "texlab")
		end
		if has_spec("lua") then
			table.insert(servers, "lua_ls")
		end
		if has_spec("csharp") then
			table.insert(servers, "omnisharp")
		end
		if has_spec("bash") then
			table.insert(servers, "bashls")
		end

		if #servers > 0 then
			vim.lsp.enable(servers)
		end
	end,
}
