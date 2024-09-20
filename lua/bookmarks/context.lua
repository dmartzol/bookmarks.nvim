local api = vim.api

---@class context
---@field buffer_number integer
---@field filepath string
---@field line integer
---@field column integer

-- Function to gather the context of the current buffer
local function gather()
	local bufer_number = api.nvim_get_current_buf()
	local buffer_path = api.nvim_buf_get_name(bufer_number)
	local current_position = api.nvim_win_get_cursor(0)
	local current_line, current_column = current_position[1], current_position[2]
	return { buffer_number = bufer_number, filepath = buffer_path, line = current_line, column = current_column }
end

return {
	gather = gather,
}
