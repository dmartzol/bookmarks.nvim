local M = {}

-- array to store line numbers and column numbers
local bookmarks = {}

-- Define the sign for bookmarks
vim.fn.sign_define("Explosion", { text = "💥", texthl = "SignColumn" })
vim.fn.sign_define("Bookmark", { text = "⭕", texthl = "SignColumn" })

-- Function to add a bookmark
M.add = function()
	local currentPosition = vim.api.nvim_win_get_cursor(0)
	local line, col = currentPosition[1], currentPosition[2]
	-- let Neovim assign a unique ID automatically
	local sign_id = vim.fn.sign_place(0, "bookmark", "Bookmark", 0, { lnum = line, priority = 10 })
	-- store bookmark with its automatically assigned ID
	table.insert(bookmarks, { line, col, id = sign_id })
end

-- Function to remove a bookmark
M.remove = function()
	local currentPosition = vim.api.nvim_win_get_cursor(0)
	local line = currentPosition[1]
	for i, bookmark in ipairs(bookmarks) do
		if bookmark[1] == line then
			-- Remove the sign using its stored unique ID
			vim.fn.sign_unplace("bookmark", { buffer = 0, id = bookmark.id })
			-- Remove the bookmark from the array
			table.remove(bookmarks, i)
			return
		end
	end
end

M.is_bookmarked = function()
	local currentPosition = vim.api.nvim_win_get_cursor(0)
	local line = currentPosition[1]
	for _, pos in ipairs(bookmarks) do
		if pos[1] == line then
			return true
		end
	end
	return false
end

M.toggle = function()
	if M.is_bookmarked() then
		M.remove()
	else
		M.add()
	end
end

M.print_all = function()
	for i, pos in ipairs(bookmarks) do
		print("Position " .. i .. ": Row " .. pos[1] .. ", Column " .. pos[2])
	end
end

M.setup = function() end

return M
