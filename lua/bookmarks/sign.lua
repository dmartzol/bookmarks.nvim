local vim = vim
local highlight_group = "BookmarksSignDefault"

---@class sign
---@field icon string
---@field color? string
---@field line_bg? string

---@alias signs sign[]

---@type bookmark[]

---@param signs signs
local setup = function(signs)
	for _, mark in pairs(signs) do
		vim.fn.sign_define(highlight_group, { text = mark.icon, texthl = highlight_group })
		if mark.color then
			vim.api.nvim_set_hl(0, highlight_group, { fg = mark.color })
		end
	end
end

return {
	setup = setup,
}
