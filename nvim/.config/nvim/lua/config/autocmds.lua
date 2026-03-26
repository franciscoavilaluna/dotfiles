local au = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("PacoSQLPro", { clear = true })

au("FileType", {
	pattern = "sql",
	group = group,
	callback = function()
		local sql = require("custom.sql")
		local map = vim.keymap.set
		local opts = { buffer = true, silent = true }

		vim.api.nvim_buf_create_user_command(0, "SqlMenu", function()
			sql.main_menu()
		end, {})

		map("n", "<leader>db", "<cmd>SqlMenu<CR>", { buffer = true, desc = "Menú SQL" })
		map("n", "<F10>", "vip<esc><cmd>lua require('custom.sql').run_sql('v')<CR>", opts)
		map("v", "<F10>", function()
			sql.run_sql("v")
		end, opts)

		au("BufWinEnter", {
			pattern = "__SQL_Result__",
			group = group,
			callback = function()
				map("n", "q", "<cmd>close<CR>", { buffer = true })
			end,
		})
	end,
})
