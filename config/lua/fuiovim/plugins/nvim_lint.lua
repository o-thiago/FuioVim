local cat = require("fuiovim.util").cat

return {
	"nvim-lint",
	event = { "BufReadPost", "BufWritePost" },
	after = function()
		local lint = require("lint")

		lint.linters.cppcheck.args = vim.list_extend({ "--check-level=exhaustive" }, lint.linters.cppcheck.args)

		local linters = {}
		if cat("rust") then
			linters.rust = { "clippy" }
		end
		if cat("c_cpp") then
			linters.c = { "clangtidy", "cppcheck" }
			linters.cpp = { "clangtidy", "cppcheck" }
		end
		if cat("python") then
			linters.python = { "ruff" }
		end
		if cat("php") then
			linters.php = { "phpstan" }
		end
		if cat("yaml") then
			linters.yaml = { "yamllint" }
		end
		if cat("bash") then
			linters.sh = { "shellcheck" }
			linters.bash = { "shellcheck" }
		end
		if cat("nix") then
			linters.nix = { "statix" }
		end

		lint.linters_by_ft = linters

		vim.api.nvim_create_autocmd({ "BufWritePost" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
