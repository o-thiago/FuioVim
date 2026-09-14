local cat = require("fuiovim.util").cat

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
		},
	},
	after = function()
		local formatters = {}
		if cat("nix") then
			formatters.nix = { "nixfmt" }
		end
		if cat("c_cpp") then
			formatters.c = { "clang_format" }
			formatters.cpp = { "clang_format" }
		end
		if cat("web") then
			formatters.javascript = { "biome", "biome-organize-imports" }
			formatters.javascriptreact = { "biome", "biome-organize-imports" }
			formatters.typescript = { "biome", "biome-organize-imports" }
			formatters.typescriptreact = { "biome", "biome-organize-imports" }
			formatters.svelte = { "biome" }
			formatters.html = { "biome" }
			formatters.css = { "biome" }
			formatters.json = { "biome" }
		end
		if cat("lua") then
			formatters.lua = { "stylua" }
		end
		if cat("php") then
			formatters.php = { "pint", "php_cs_fixer", stop_after_first = true }
		end
		if cat("markdown") then
			formatters.markdown = { "biome" }
		end
		if cat("rust") then
			formatters.rust = { "rustfmt" }
		end
		if cat("python") then
			formatters.python = { "ruff_format", "ruff_organize_imports" }
		end
		if cat("yaml") then
			formatters.yaml = { "biome" }
		end
		if cat("csharp") then
			formatters.cs = { "csharpier" }
		end
		if cat("bash") then
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
