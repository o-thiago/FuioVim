local has_spec = require("fuiovim.util").has_spec

return {
	"nvim-lint",
	event = { "BufReadPost", "BufWritePost" },
	after = function()
		local lint = require("lint")

		lint.linters.cppcheck.args = vim.list_extend({ "--check-level=exhaustive" }, lint.linters.cppcheck.args)

		local linters = {}
		if has_spec("rust") then
			linters.rust = { "clippy" }
		end
		if has_spec("c_cpp") then
			linters.c = { "clangtidy", "cppcheck" }
			linters.cpp = { "clangtidy", "cppcheck" }
		end
		if has_spec("python") then
			linters.python = { "ruff" }
		end
		if has_spec("php") then
			linters.php = { "phpstan" }
		end
		if has_spec("yaml") then
			linters.yaml = { "yamllint" }
		end
		if has_spec("bash") then
			linters.sh = { "shellcheck" }
			linters.bash = { "shellcheck" }
		end
		if has_spec("nix") then
			linters.nix = { "statix" }
		end

		lint.linters_by_ft = linters

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			desc = "Executar linters ao salvar buffer",
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
