local M = {}

local function update_colors()
	local sl_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
	local sl_bg = sl_hl.bg

	local function set_clean_hl(name, fg_group)
		local target = vim.api.nvim_get_hl(0, { name = fg_group, link = false })

		vim.api.nvim_set_hl(0, name, {
			fg = target.fg,
			bg = sl_bg,
			ctermbg = nil,
			bold = true,
		})
	end

	set_clean_hl("StatusLineFile", "String")
	set_clean_hl("StatusLineUser", "Special")
end

update_colors()
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.schedule(update_colors)
	end,
})

function M.active()
	local sections = {
		"%#StatusLineFile# %f ",
		"%#StatusLine# %m%r%h%w ",
		"%=",
		require("custom.sql").statusline(),
		" %#StatusLineMedium# %y ",
		"%#StatusLine# %l:%c ",
		"%#StatusLineFile# %P ",
	}
	return table.concat(sections)
end

vim.o.laststatus = 3
vim.o.statusline = "%!v:lua.require('custom.statusline').active()"

return M
