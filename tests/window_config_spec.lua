---@diagnostic disable: undefined-field

local eq = assert.are.same

describe("present.window_configurations", function()
	local present
	local original_columns, original_lines

	before_each(function()
		-- Clear module cache for clean state
		package.loaded["present"] = nil
		present = require("present")

		-- Store original vim dimensions
		original_columns = vim.o.columns
		original_lines = vim.o.lines
	end)

	after_each(function()
		-- Restore original dimensions
		vim.o.columns = original_columns
		vim.o.lines = original_lines
	end)

	it("should create window configurations with correct structure", function()
		-- Set test dimensions
		vim.o.columns = 100
		vim.o.lines = 30

		local configs = present._create_window_configurations()

		-- Should have all required window types
		assert.is_not_nil(configs.background)
		assert.is_not_nil(configs.header)
		assert.is_not_nil(configs.body)
		assert.is_not_nil(configs.footer)

		-- All configs should have required properties
		for name, config in pairs(configs) do
			assert.is_number(config.width, name .. " should have width")
			assert.is_number(config.height, name .. " should have height")
			assert.is_number(config.col, name .. " should have col")
			assert.is_number(config.row, name .. " should have row")
			assert.is_number(config.zindex, name .. " should have zindex")
			eq("editor", config.relative, name .. " should be relative to editor")
			eq("minimal", config.style, name .. " should have minimal style")
		end
	end)

	it("should calculate background window to fill entire screen", function()
		vim.o.columns = 80
		vim.o.lines = 24

		local configs = present._create_window_configurations()

		eq({
			relative = "editor",
			width = 80,
			height = 24,
			style = "minimal",
			col = 0,
			row = 0,
			zindex = 10,
		}, configs.background)
	end)

	it("should calculate header window dimensions correctly", function()
		vim.o.columns = 100
		vim.o.lines = 30

		local configs = present._create_window_configurations()

		eq({
			relative = "editor",
			width = 100,
			height = 1,
			style = "minimal",
			border = "rounded",
			col = 0,
			row = 0,
			zindex = 20,
		}, configs.header)
	end)

	it("should calculate body window with proper margins", function()
		vim.o.columns = 100
		vim.o.lines = 30

		local configs = present._create_window_configurations()

		-- Body should be inset by 8 columns and positioned at row 4
		-- Height calculation: lines - header_height(3) - footer_height(1) - 2 - 1 = 30 - 7 = 23
		eq({
			relative = "editor",
			width = 92, -- 100 - 8
			height = 23, -- 30 - 3 - 1 - 2 - 1
			style = "minimal",
			border = { " ", " ", " ", " ", " ", " ", " ", " " },
			col = 8,
			row = 4,
			zindex = 21,
		}, configs.body)
	end)

	it("should calculate footer window at bottom", function()
		vim.o.columns = 80
		vim.o.lines = 24

		local configs = present._create_window_configurations()

		eq({
			relative = "editor",
			width = 80,
			height = 1,
			style = "minimal",
			col = 0,
			row = 23, -- lines - 1
			zindex = 22,
		}, configs.footer)
	end)

	it("should have correct z-index layering", function()
		vim.o.columns = 80
		vim.o.lines = 24

		local configs = present._create_window_configurations()

		-- Background should be lowest, footer highest
		assert.is_true(configs.background.zindex < configs.header.zindex)
		assert.is_true(configs.header.zindex < configs.body.zindex)
		assert.is_true(configs.body.zindex < configs.footer.zindex)
	end)

	it("should adapt to different screen sizes", function()
		-- Test small screen
		vim.o.columns = 40
		vim.o.lines = 10

		local small_configs = present._create_window_configurations()

		eq(40, small_configs.background.width)
		eq(10, small_configs.background.height)
		eq(32, small_configs.body.width) -- 40 - 8
		eq(3, small_configs.body.height) -- 10 - 7

		-- Test large screen
		vim.o.columns = 200
		vim.o.lines = 50

		local large_configs = present._create_window_configurations()

		eq(200, large_configs.background.width)
		eq(50, large_configs.background.height)
		eq(192, large_configs.body.width) -- 200 - 8
		eq(43, large_configs.body.height) -- 50 - 7
	end)
end)
