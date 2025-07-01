---@diagnostic disable: undefined-field

local eq = assert.are.same

describe("present.create_floating_window", function()
	local present

	before_each(function()
		-- Clear module cache for clean state
		package.loaded["present"] = nil
		present = require("present")
	end)

	it("should create floating window with buffer and window", function()
		local config = {
			relative = "editor",
			width = 50,
			height = 10,
			col = 5,
			row = 5,
			style = "minimal",
		}

		local result = present._create_floating_window(config, false)

		-- Should return table with buf and win
		assert.is_table(result)
		assert.is_number(result.buf)
		assert.is_number(result.win)

		-- Buffer should be valid
		assert.is_true(vim.api.nvim_buf_is_valid(result.buf))

		-- Window should be valid
		assert.is_true(vim.api.nvim_win_is_valid(result.win))

		-- Clean up
		pcall(vim.api.nvim_win_close, result.win, true)
	end)

	it("should create buffer with correct properties", function()
		local config = {
			relative = "editor",
			width = 30,
			height = 5,
			col = 0,
			row = 0,
			style = "minimal",
		}

		local result = present._create_floating_window(config, false)

		-- Buffer should be unlisted and scratch
		assert.is_false(vim.api.nvim_buf_get_option(result.buf, "buflisted"))
		assert.is_true(
			vim.api.nvim_buf_get_option(result.buf, "bufhidden") == "wipe"
				or vim.api.nvim_buf_get_option(result.buf, "buftype") == "nofile"
		)

		-- Clean up
		pcall(vim.api.nvim_win_close, result.win, true)
	end)

	it("should handle enter parameter correctly", function()
		local config = {
			relative = "editor",
			width = 20,
			height = 5,
			col = 0,
			row = 0,
			style = "minimal",
		}

		-- Test with enter = false (default)
		local result1 = present._create_floating_window(config, false)
		assert.is_not.equal(result1.win, vim.api.nvim_get_current_win())
		pcall(vim.api.nvim_win_close, result1.win, true)

		-- Test with enter = true
		local original_win = vim.api.nvim_get_current_win()
		local result2 = present._create_floating_window(config, true)

		-- Should have switched to the new window
		eq(result2.win, vim.api.nvim_get_current_win())

		-- Switch back and clean up
		vim.api.nvim_set_current_win(original_win)
		pcall(vim.api.nvim_win_close, result2.win, true)
	end)

	it("should handle nil enter parameter (defaults to false)", function()
		local config = {
			relative = "editor",
			width = 20,
			height = 5,
			col = 0,
			row = 0,
			style = "minimal",
		}

		local original_win = vim.api.nvim_get_current_win()
		local result = present._create_floating_window(config, nil)

		-- Should not have switched windows (enter defaults to false)
		eq(original_win, vim.api.nvim_get_current_win())

		-- Clean up
		pcall(vim.api.nvim_win_close, result.win, true)
	end)

	it("should apply window configuration correctly", function()
		local config = {
			relative = "editor",
			width = 40,
			height = 8,
			col = 10,
			row = 5,
			style = "minimal",
			border = "rounded",
		}

		local result = present._create_floating_window(config, false)

		-- Get window configuration
		local win_config = vim.api.nvim_win_get_config(result.win)

		-- Check that our config was applied
		eq("editor", win_config.relative)
		eq(40, win_config.width)
		eq(8, win_config.height)
		eq(10, win_config.col)
		eq(5, win_config.row)

		-- Clean up
		pcall(vim.api.nvim_win_close, result.win, true)
	end)

	it("should create multiple independent windows", function()
		local config1 = {
			relative = "editor",
			width = 20,
			height = 5,
			col = 0,
			row = 0,
			style = "minimal",
		}

		local config2 = {
			relative = "editor",
			width = 30,
			height = 10,
			col = 25,
			row = 10,
			style = "minimal",
		}

		local result1 = present._create_floating_window(config1, false)
		local result2 = present._create_floating_window(config2, false)

		-- Should be different windows and buffers
		assert.is_not.equal(result1.win, result2.win)
		assert.is_not.equal(result1.buf, result2.buf)

		-- Both should be valid
		assert.is_true(vim.api.nvim_win_is_valid(result1.win))
		assert.is_true(vim.api.nvim_win_is_valid(result2.win))
		assert.is_true(vim.api.nvim_buf_is_valid(result1.buf))
		assert.is_true(vim.api.nvim_buf_is_valid(result2.buf))

		-- Clean up
		pcall(vim.api.nvim_win_close, result1.win, true)
		pcall(vim.api.nvim_win_close, result2.win, true)
	end)
end)
