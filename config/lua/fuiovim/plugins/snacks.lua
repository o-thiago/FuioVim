local function s()
	return require("snacks")
end

return {
	"snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{
			"<leader>lg",
			function()
				s().lazygit()
			end,
			desc = "Abrir LazyGit",
		},
		{
			"<leader>pf",
			function()
				s().picker.files()
			end,
			desc = "Localizar arquivos",
		},
		{
			"<leader>ps",
			function()
				s().picker.grep()
			end,
			desc = "Buscar texto (grep)",
		},
		{
			"<leader>pw",
			function()
				s().picker.grep_word()
			end,
			desc = "Buscar palavra sob o cursor",
		},
	},
	after = function()
		local opts = {
			bigfile = { enabled = true },
			indent = { enabled = true },
			input = { enabled = true },
			notify = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			notifier = { enabled = true },
			dashboard = {
				enabled = true,
				sections = {
					{
						section = "terminal",
						cmd = "figlet -f slant 'FuioVim' && echo '      Editor Soberano Brasileiro • Nix-Powered'",
						height = 8,
						padding = 1,
						ttl = 5 * 60,
						indent = 2,
					},
					{ section = "keys", gap = 1, padding = 1 },
					{ section = "startup" },
				},
				preset = {
					keys = {
						{ icon = " ", key = "f", desc = "Buscar Arquivos", action = ":lua Snacks.dashboard.pick('files')" },
						{ icon = " ", key = "n", desc = "Novo Arquivo", action = ":ene | startinsert" },
						{ icon = " ", key = "g", desc = "Buscar Texto", action = ":lua Snacks.dashboard.pick('live_grep')" },
						{ icon = " ", key = "r", desc = "Arquivos Recentes", action = ":lua Snacks.dashboard.pick('oldfiles')" },
						{ icon = " ", key = "c", desc = "Configuração", action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })" },
						{ icon = " ", key = "q", desc = "Sair", action = ":qa" },
					},
				},
			},
			picker = {
				enabled = true,
				win = {
					input = {
						keys = {
							["<c-k>"] = { "history_back", mode = { "i", "n" } },
							["<c-j>"] = { "history_forward", mode = { "i", "n" } },
						},
					},
				},
			},
		}

		if not vim.g.neovide then
			opts.scroll = { enabled = true }
			opts.animate = { enabled = true }
		end

		local count = 0
		local has_info, nix_info = pcall(require, "nix-info")
		if has_info then
			local lazy_pkgs = nix_info(nil, "plugins", "lazy") or {}
			local start_pkgs = nix_info(nil, "plugins", "start") or {}
			for _ in pairs(lazy_pkgs) do
				count = count + 1
			end
			for k in pairs(start_pkgs) do
				if k ~= "COLLATED_TS_GRAMMARS" then
					count = count + 1
				end
			end
		end

		s().dashboard.sections.startup = function(item)
			local icon = (item and item.icon) or "⚡ "
			local text = {
				{ icon .. "FuioVim pronto • ", hl = "footer" },
			}
			if count > 0 then
				table.insert(text, { tostring(count), hl = "special" })
				table.insert(text, { " plugins gerenciados via Nix", hl = "footer" })
			else
				table.insert(text, { "Nix-Powered", hl = "special" })
			end
			return {
				align = "center",
				text = text,
			}
		end

		s().setup(opts)
		vim.api.nvim_create_autocmd("LspProgress", {
			desc = "Notificação de progresso do LSP",
			callback = function(ev)
				local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
				vim.notify(vim.lsp.status(), "info", {
					id = "lsp_progress",
					title = "Progresso do LSP",
					opts = function(notif)
						notif.icon = ev.data.params.value.kind == "end" and " "
							or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
					end,
				})
			end,
		})
	end,
}
