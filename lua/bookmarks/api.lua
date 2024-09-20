local context = require("bookmarks.context")

local vim = vim
local namespace = "BookmarksDefault"
local highlight_group = "BookmarksSignDefault"

---@class bookmark
---@field id integer
---@field filepath string
---@field line integer
---@field column integer

---@type bookmark[]
local bookmarks = {}

-- Function to add a bookmark from a context
---@param ctx context
local function add_bookmark(ctx)
	-- if the id provided is zero, then a new id is generated
	local new_id = 0
	local sign_id = vim.fn.sign_place(new_id, namespace, highlight_group, ctx.buffer_number, { lnum = ctx.line })

	-- Store bookmark with its full file path
	table.insert(bookmarks, { filepath = ctx.filepath, line = ctx.line, column = ctx.column, id = sign_id })
end

-- Function to remove a bookmark
---@param ctx context
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
	local ctx = context.gather()
	if is_bookmarked(ctx) then
		remove_bookmark(ctx)
	else
		add_bookmark(ctx)
	end
end

---@param bookmark bookmark
local function go_to_bookmark(bookmark)
	-- Open the file if needed and move cursor to the next bookmark
	vim.cmd("edit " .. bookmark.filepath)
	vim.api.nvim_win_set_cursor(0, { bookmark.line, bookmark.column })
end

-- Function to jump to the next bookmark
local function next()
	if #bookmarks == 0 then
		return
	end

	local ctx = context.gather()
	local next_bookmark = nil
	local earliest_in_current_file = nil
	local earliest_overall = bookmarks[1]

	for _, bookmark in ipairs(bookmarks) do
		-- Update earliest overall bookmark
		if
			bookmark.line < earliest_overall.line
			or (bookmark.line == earliest_overall.line and bookmark.filepath < earliest_overall.filepath)
		then
			earliest_overall = bookmark
		end

		if bookmark.filepath == ctx.filepath then
			-- Update earliest bookmark in current file
			if not earliest_in_current_file or bookmark.line < earliest_in_current_file.line then
				earliest_in_current_file = bookmark
			end

			-- Find the next bookmark in current file
			if bookmark.line > ctx.line then
				if not next_bookmark or bookmark.line < next_bookmark.line then
					next_bookmark = bookmark
				end
			end
		end
	end

	if next_bookmark then
		go_to_bookmark(next_bookmark)
	elseif earliest_in_current_file then
		go_to_bookmark(earliest_in_current_file)
	else
		go_to_bookmark(earliest_overall)
	end
end

-- Function to jump to the previous bookmark
local function prev()
	if #bookmarks == 0 then
		return
	end

	local ctx = context.gather()
	local prev_bookmark = nil
	local latest_in_current_file = nil
	local latest_overall = bookmarks[1]

	for _, bookmark in ipairs(bookmarks) do
		-- Update latest overall bookmark
		if
			bookmark.line > latest_overall.line
			or (bookmark.line == latest_overall.line and bookmark.filepath > latest_overall.filepath)
		then
			latest_overall = bookmark
		end

		if bookmark.filepath == ctx.filepath then
			-- Update latest bookmark in current file
			if not latest_in_current_file or bookmark.line > latest_in_current_file.line then
				latest_in_current_file = bookmark
			end

			-- Find the previous bookmark in current file
			if bookmark.line < ctx.line then
				if not prev_bookmark or bookmark.line > prev_bookmark.line then
					prev_bookmark = bookmark
				end
			end
		end
	end

	if prev_bookmark then
		go_to_bookmark(prev_bookmark)
	elseif latest_in_current_file then
		go_to_bookmark(latest_in_current_file)
	else
		go_to_bookmark(latest_overall)
	end
end

return {
	toggle = toggle,
	next = next,
	prev = prev,
}
