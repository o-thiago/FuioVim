return {
	"oil.nvim",
	cmd = { "Oil" },
	keys = {
		{
			"<Leader>pv",
			"<CMD>Oil<CR>",
			desc = "Open Oil file manager",
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
