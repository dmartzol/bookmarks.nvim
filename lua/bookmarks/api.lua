local vim = vim

local namespace = "BookmarksDefault"
local highlight_group = "BookmarksSignDefault"
-- array to store line numbers and column numbers
local bookmarks = {}

-- Define the sign for bookmarks
-- mark = { icon = "󰃁", color = "red", line_bg = "#572626" },
vim.fn.sign_define(highlight_group, { text = "󰃁", texthl = highlight_group })

local function gather_context()
	local bufer_number = vim.api.nvim_get_current_buf()
	local buffer_path = vim.api.nvim_buf_get_name(bufer_number)
	local current_position = vim.api.nvim_win_get_cursor(0)
	local current_line, current_column = current_position[1], current_position[2]
	return { buffer_number = bufer_number, filepath = buffer_path, line = current_line, column = current_column }
end

-- Function to add a bookmark from a context
local function add_bookmark(ctx)
	-- if the id provided is zero, then a new id is generated
	local new_id = 0
	local sign_id = vim.fn.sign_place(new_id, namespace, highlight_group, ctx.buffer_number, { lnum = ctx.line })

	-- Store bookmark with its full file path
	table.insert(bookmarks, { filepath = ctx.filepath, line = ctx.line, column = ctx.column, id = sign_id })
end

-- Function to remove a bookmark
local function remove_bookmark(ctx)
	for i, bookmark in ipairs(bookmarks) do
		if bookmark.line == ctx.line and ctx.filepath == bookmark.filepath then
			vim.fn.sign_unplace(namespace, { buffer = ctx.buffer_number, id = bookmark.id })
			table.remove(bookmarks, i)
			return
		end
	end
end

-- Function to check if the current line is bookmarked
local function is_bookmarked(ctx)
	for _, bookmark in ipairs(bookmarks) do
		if bookmark.line == ctx.line and bookmark.filepath == ctx.filepath then
			return true
		end
	end
	return false
end

local function toggle()
	local ctx = gather_context()
	if is_bookmarked(ctx) then
		remove_bookmark(ctx)
	else
		add_bookmark(ctx)
	end
end

-- function to jump to the next bookmark
local function next()
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
local function prev()
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
local function print()
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
end

local function printAll()
	for i, pos in ipairs(bookmarks) do
		print("Position " .. i .. ": Row " .. pos[1] .. ", Column " .. pos[2])
	end
end

return {
	add_bookmark = add_bookmark,
	remove_bookmark = remove_bookmark,
	is_bookmarked = is_bookmarked,
	toggle = toggle,
	next = next,
	prev = prev,
	print = print,
	printAll = printAll,
}
