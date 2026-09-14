local has_spec = require("fuiovim.util").has_spec

return {
	"conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_fallback = true })
			end,
			desc = "Formatar buffer atual",
		},
	},
	after = function()
		local formatters = {}
		if has_spec("nix") then
			formatters.nix = { "nixfmt" }
		end
		if has_spec("c_cpp") then
			formatters.c = { "clang_format" }
			formatters.cpp = { "clang_format" }
		end
		if has_spec("web") then
			formatters.javascript = { "biome", "biome-organize-imports" }
			formatters.javascriptreact = { "biome", "biome-organize-imports" }
			formatters.typescript = { "biome", "biome-organize-imports" }
			formatters.typescriptreact = { "biome", "biome-organize-imports" }
			formatters.svelte = { "biome" }
			formatters.html = { "biome" }
			formatters.css = { "biome" }
			formatters.json = { "biome" }
		end
		if has_spec("lua") then
			formatters.lua = { "stylua" }
		end
		if has_spec("php") then
			formatters.php = { "pint", "php_cs_fixer", stop_after_first = true }
		end
		if has_spec("markdown") then
			formatters.markdown = { "biome" }
		end
		if has_spec("rust") then
			formatters.rust = { "rustfmt" }
		end
		if has_spec("python") then
			formatters.python = { "ruff_format", "ruff_organize_imports" }
		end
		if has_spec("yaml") then
			formatters.yaml = { "biome" }
		end
		if has_spec("csharp") then
			formatters.cs = { "csharpier" }
		end
		if has_spec("bash") then
			formatters.sh = { "shfmt" }
			formatters.bash = { "shfmt" }
		end

		require("conform").setup({
			format_on_save = {
				timeout_ms = 1000,
				lsp_fallback = true,
			},
			formatters_by_ft = formatters,
		})
	end,
}
