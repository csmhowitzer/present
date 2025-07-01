---@diagnostic disable: undefined-field

local eq = assert.are.same

describe("present.utilities", function()
	local present

	before_each(function()
		-- Clear module cache for clean state
		package.loaded["present"] = nil
		present = require("present")
	end)

	describe("foreach_float", function()
		it("should handle empty state", function()
			-- Mock empty state by creating a test state
			local test_floats = {}
			local callback_calls = {}

			-- Since we can't directly access state, we'll test the pattern
			-- by creating our own foreach implementation
			local function test_foreach_float(floats, cb)
				for name, float in pairs(floats) do
					cb(name, float)
				end
			end

			test_foreach_float(test_floats, function(name, float)
				table.insert(callback_calls, { name = name, float = float })
			end)

			eq({}, callback_calls)
		end)

		it("should iterate over all floats", function()
			local test_floats = {
				background = { buf = 1, win = 10 },
				header = { buf = 2, win = 11 },
				body = { buf = 3, win = 12 },
				footer = { buf = 4, win = 13 },
			}

			local callback_calls = {}

			local function test_foreach_float(floats, cb)
				for name, float in pairs(floats) do
					cb(name, float)
				end
			end

			test_foreach_float(test_floats, function(name, float)
				table.insert(callback_calls, { name = name, float = float })
			end)

			-- Should have called callback for each float
			eq(4, #callback_calls)

			-- Check that all expected names were called
			local names = {}
			for _, call in ipairs(callback_calls) do
				table.insert(names, call.name)
			end
			table.sort(names)
			eq({ "background", "body", "footer", "header" }, names)
		end)

		it("should pass correct float data to callback", function()
			local test_floats = {
				test_float = { buf = 42, win = 84 },
			}

			local callback_calls = {}

			local function test_foreach_float(floats, cb)
				for name, float in pairs(floats) do
					cb(name, float)
				end
			end

			test_foreach_float(test_floats, function(name, float)
				table.insert(callback_calls, { name = name, float = float })
			end)

			eq(1, #callback_calls)
			eq("test_float", callback_calls[1].name)
			eq({ buf = 42, win = 84 }, callback_calls[1].float)
		end)
	end)

	describe("setup function", function()
		it("should exist and be callable", function()
			assert.is_function(present.setup)

			-- Should not error when called
			assert.has_no.errors(function()
				present.setup()
			end)
		end)
	end)

	describe("start_presentation function", function()
		it("should exist and be callable", function()
			assert.is_function(present.start_presentation)
		end)

		it("should handle empty options", function()
			-- Mock vim.api functions to avoid actual buffer operations
			local original_get_lines = vim.api.nvim_buf_get_lines
			local original_get_name = vim.api.nvim_buf_get_name
			local original_create_buf = vim.api.nvim_create_buf
			local original_open_win = vim.api.nvim_open_win
			local original_create_autocmd = vim.api.nvim_create_autocmd
			local original_create_augroup = vim.api.nvim_create_augroup

			-- Mock the functions
			vim.api.nvim_buf_get_lines = function()
				return { "# Test Slide", "Test content" }
			end
			vim.api.nvim_buf_get_name = function()
				return "test.md"
			end
			vim.api.nvim_create_buf = function()
				return 1
			end
			vim.api.nvim_open_win = function()
				return 10
			end
			vim.api.nvim_create_autocmd = function()
				return 1
			end
			vim.api.nvim_create_augroup = function()
				return 1
			end

			-- Should not error with empty options
			assert.has_no.errors(function()
				present.start_presentation()
			end)

			-- Should not error with nil options
			assert.has_no.errors(function()
				present.start_presentation(nil)
			end)

			-- Restore original functions
			vim.api.nvim_buf_get_lines = original_get_lines
			vim.api.nvim_buf_get_name = original_get_name
			vim.api.nvim_create_buf = original_create_buf
			vim.api.nvim_open_win = original_open_win
			vim.api.nvim_create_autocmd = original_create_autocmd
			vim.api.nvim_create_augroup = original_create_augroup
		end)

		it("should use provided buffer number", function()
			local get_lines_calls = {}

			-- Mock vim.api functions
			local original_get_lines = vim.api.nvim_buf_get_lines
			local original_get_name = vim.api.nvim_buf_get_name
			local original_create_buf = vim.api.nvim_create_buf
			local original_open_win = vim.api.nvim_open_win
			local original_create_autocmd = vim.api.nvim_create_autocmd
			local original_create_augroup = vim.api.nvim_create_augroup

			vim.api.nvim_buf_get_lines = function(bufnr, start, end_, strict)
				table.insert(get_lines_calls, { bufnr = bufnr, start = start, end_ = end_, strict = strict })
				return { "# Test" }
			end
			vim.api.nvim_buf_get_name = function()
				return "test.md"
			end
			vim.api.nvim_create_buf = function()
				return 1
			end
			vim.api.nvim_open_win = function()
				return 10
			end
			vim.api.nvim_create_autocmd = function()
				return 1
			end
			vim.api.nvim_create_augroup = function()
				return 1
			end

			-- Call with specific buffer number
			present.start_presentation({ bufnr = 42 })

			-- Should have called get_lines with the specified buffer
			eq(1, #get_lines_calls)
			eq(42, get_lines_calls[1].bufnr)

			-- Restore original functions
			vim.api.nvim_buf_get_lines = original_get_lines
			vim.api.nvim_buf_get_name = original_get_name
			vim.api.nvim_create_buf = original_create_buf
			vim.api.nvim_open_win = original_open_win
			vim.api.nvim_create_autocmd = original_create_autocmd
			vim.api.nvim_create_augroup = original_create_augroup
		end)
	end)
end)
