local M = {}
local namespace = "BookmarksNvim"
local highlight_group = "BookmarksNvimSign"
local vim = vim

-- array to store line numbers and column numbers
local bookmarks = {}

-- Define the sign for bookmarks
vim.fn.sign_define(highlight_group, { text = "⚑", texthl = highlight_group })

-- Function to add a bookmark
M.add = function()
	local buf_number = vim.api.nvim_get_current_buf()
	local path = vim.api.nvim_buf_get_name(buf_number)
	local currentPosition = vim.api.nvim_win_get_cursor(0)
	local line, col = currentPosition[1], currentPosition[2]

	-- if the id provided is zero, then a new id is generated
	local new_id = 0
	local sign_id = vim.fn.sign_place(new_id, namespace, highlight_group, buf_number, { lnum = line })

	-- Store bookmark with its full file path
	table.insert(bookmarks, { path = path, line = line, col = col, id = sign_id })
end

-- Function to remove a bookmark
M.remove = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local currentPosition = vim.api.nvim_win_get_cursor(0)
	local line = currentPosition[1]

	for i, bookmark in ipairs(bookmarks) do
		if bookmark.line == line and vim.api.nvim_buf_get_name(bufnr) == bookmark.path then
			vim.fn.sign_unplace(namespace, { buffer = bufnr, id = bookmark.id })
			table.remove(bookmarks, i)
			return
		end
	end
end

-- Function to check if the current line is bookmarked
M.is_bookmarked = function()
	local bufnr = vim.api.nvim_get_current_buf()
	local currentPath = vim.api.nvim_buf_get_name(bufnr)
	local currentPosition = vim.api.nvim_win_get_cursor(0)
	local currentLine = currentPosition[1]

	for _, bookmark in ipairs(bookmarks) do
		if bookmark.line == currentLine and bookmark.path == currentPath then
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

-- function to jump to the next bookmark
M.next = function()
	if #bookmarks == 0 then
		return
	end

	local currentPosition = vim.api.nvim_win_get_cursor(0)
	local currentLine = currentPosition[1]
	local currentFile = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	local target = nil

	-- Sort bookmarks by file and line number
	table.sort(bookmarks, function(a, b)
		return a.path < b.path or (a.path == b.path and a.line < b.line)
	end)

	-- Find the next bookmark
	for _, bookmark in ipairs(bookmarks) do
		if bookmark.path > currentFile or (bookmark.path == currentFile and bookmark.line > currentLine) then
			target = bookmark
			break
		end
	end

	-- If no bookmark is found after current line and file, loop to the first bookmark
	if not target then
		target = bookmarks[1]
	end

	-- Open the file if needed and move cursor to the next bookmark
	vim.cmd("edit " .. target.path)
	vim.api.nvim_win_set_cursor(0, { target.line, target.col })
end

-- Function to jump to the previous bookmark
M.prev = function()
	if #bookmarks == 0 then
		return
	end -- Exit if no bookmarks are set

	local currentPosition = vim.api.nvim_win_get_cursor(0)
	local currentLine = currentPosition[1]
	local currentFile = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	local target = nil

	-- Sort bookmarks by file and line number in reverse order for easy looping to previous
	table.sort(bookmarks, function(a, b)
		return a.path > b.path or (a.path == b.path and a.line > b.line)
	end)

	-- Find the previous bookmark
	for _, bookmark in ipairs(bookmarks) do
		if bookmark.path < currentFile or (bookmark.path == currentFile and bookmark.line < currentLine) then
			target = bookmark
			break
		end
	end

	-- If no bookmark is found before current line and file, loop to the last bookmark
	if not target then
		target = bookmarks[#bookmarks]
	end

	-- Open the file if needed and move cursor to the previous bookmark
	vim.cmd("edit " .. target.path)
	vim.api.nvim_win_set_cursor(0, { target.line, target.col })
end

-- Function to print the closes bookmark
M.print = function()
	if #bookmarks == 0 then
		return
	end

	local currentFile = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
	local bookmarkInCurrentFile = false
	for _, bookmark in ipairs(bookmarks) do
		if bookmark.path == currentFile then
			bookmarkInCurrentFile = true
			break
		end
	end

	if not bookmarkInCurrentFile then
		print("no bookmark in current file")
		return
	end

	local currentPosition = vim.api.nvim_win_get_cursor(0)
	local currentLine = currentPosition[1]
	local closestBookmark = bookmarks[1]
	for _, bookmark in ipairs(bookmarks) do
		local dist = math.abs(bookmark.line - currentLine)
		local closesDistance = math.abs(closestBookmark.line - currentLine)
		if dist < closesDistance then
			closestBookmark = bookmark
		end
	end

	print("line: " .. closestBookmark.line)
end

M.printAll = function()
	for i, pos in ipairs(bookmarks) do
		print("Position " .. i .. ": Row " .. pos[1] .. ", Column " .. pos[2])
	end
end

M.setup = function() end

return M
