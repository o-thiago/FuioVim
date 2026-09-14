return {
	"oil.nvim",
	cmd = { "Oil" },
	keys = {
		{
			"<Leader>pv",
			"<CMD>Oil<CR>",
			desc = "Abrir gerenciador de arquivos Oil",
		},
	},
	after = function()
		require("oil").setup({
			default_file_explorer = true,
			columns = { "icon" },
			view_options = {
				show_hidden = true,
			},
		})
	end,
}
