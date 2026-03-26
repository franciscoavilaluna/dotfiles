local opt = vim.opt
local hl = vim.api.nvim_set_hl

if os.getenv("VIM_EINK") == "1" then
	opt.background = "light"
	vim.cmd.colorscheme("quiet")

	hl(0, "Normal", { ctermbg = "White", ctermfg = "Black", bg = "White", fg = "Black" })
	hl(0, "StatusLine", { ctermbg = "Black", ctermfg = "White" })
else
	vim.cmd("syntax on")
	opt.termguicolors = true
	opt.laststatus = 1
	opt.background = "dark"
	vim.g.base16colorspace = 256

	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			hl(0, "Normal", { ctermbg = "NONE", bg = "NONE" })
			hl(0, "NormalFloat", { link = "Normal" })
			hl(0, "FloatBorder", { bg = "none", fg = "#ffffff" })
		end,
	})

	vim.cmd.colorscheme("vim")
end
