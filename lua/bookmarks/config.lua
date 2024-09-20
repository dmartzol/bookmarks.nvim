local vim = vim

local vscode_blue = "#3B7CF3"

local default_config = {
	signs = {
		mark = { icon = "󰃁", color = vscode_blue },
	},
}

local setup = function()
	require("bookmarks.sign").setup(default_config.signs)
end

return {
	setup = setup,
	default_config = default_config,
}
