-- NOTE: A form of lazy loading. A user-friendly adjustment for when we really only want Present to be used.

vim.api.nvim_create_user_command("PresentStart", function()
	require("present").start_presentation()
end, {})
