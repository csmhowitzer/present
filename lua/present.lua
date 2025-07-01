local M = {}

--- Setup function for present.nvim
--- Currently minimal setup, may be expanded in the future
M.setup = function() end

--- @class present.Float
--- @field buf number: Buffer number
--- @field win number: Window number

--- @class present.WindowConfig
--- @field relative string: Window positioning relative to editor
--- @field width number: Window width
--- @field height number: Window height
--- @field col number: Column position
--- @field row number: Row position
--- @field style string: Window style
--- @field zindex number: Z-index for layering
--- @field border? string|table: Border configuration

--- Create a floating window with the given configuration
--- @param config present.WindowConfig: Window configuration
--- @param enter? boolean: Whether to enter the window (default: false)
--- @return present.Float: Table with buf and win numbers
local function create_floating_window(config, enter)
	if enter == nil then
		enter = false
	end
	-- Create a buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Create the floating window
	local win = vim.api.nvim_open_win(buf, enter or false, config)

	return { buf = buf, win = win }
end

--- @class present.Slide
--- @field title string: The title of the slide (header line)
--- @field body string[]: The body content lines of the slide

--- @class present.Slides
--- @field slides present.Slide[]: Array of parsed slides

--- Parse markdown lines into slides using # headers as separators
--- @param lines string[]: The lines from the buffer
--- @return present.Slides: Parsed slides structure
local parse_slides = function(lines)
	local slides = { slides = {} }
	local current_slide = {
		title = "",
		body = {},
	}

	local separator = "^#"

	for _, line in ipairs(lines) do
		if line:find(separator) then
			if #current_slide.title > 0 or #current_slide.body > 0 then
				table.insert(slides.slides, current_slide)
			end

			current_slide = {
				title = line,
				body = {},
			}
		else
			table.insert(current_slide.body, line)
		end
	end
	table.insert(slides.slides, current_slide)
	return slides
end

--- @class present.WindowConfigurations
--- @field background present.WindowConfig: Full-screen background window
--- @field header present.WindowConfig: Header window for slide titles
--- @field body present.WindowConfig: Body window for slide content
--- @field footer present.WindowConfig: Footer window at bottom

--- Create window configurations for all presentation windows
--- Calculates positions and sizes based on current terminal dimensions
--- @return present.WindowConfigurations: Complete window configuration set
local create_window_configurations = function()
	local width = vim.o.columns
	local height = vim.o.lines

	local header_height = 1 + 2
	local footer_height = 1
	local body_height = height - header_height - footer_height - 2 - 1

	return {
		background = {
			relative = "editor",
			width = width,
			height = height,
			style = "minimal",
			col = 0,
			row = 0,
			zindex = 10,
		},
		header = {
			relative = "editor",
			width = width,
			height = 1,
			style = "minimal",
			border = "rounded",
			col = 0,
			row = 0,
			zindex = 20,
		},
		body = {
			relative = "editor",
			width = width - 8,
			height = body_height,
			style = "minimal",
			border = { " ", " ", " ", " ", " ", " ", " ", " " },
			col = 8,
			row = 4,
			zindex = 21,
		},
		footer = {
			relative = "editor",
			width = width,
			height = 1,
			style = "minimal",
			--border = "rounded",
			col = 0,
			row = height - 1,
			zindex = 22,
		},
	}
end

--- @class present.State
--- @field parsed present.Slides: Parsed slides from the buffer
--- @field current_slide number: Index of currently displayed slide
--- @field floats table<string, present.Float>: Map of window names to float objects
--- @field title string: Title of the presentation (filename)

--- Global state for the current presentation
--- @type present.State
local state = {
	parsed = {},
	current_slide = 1,
	floats = {},
	title = "",
}

--- Iterate over all floating windows and execute callback
--- @param cb fun(name: string, float: present.Float): Callback function
local foreach_float = function(cb)
	for name, float in pairs(state.floats) do
		cb(name, float)
	end
end

--- Set a keymap that only applies to the presentation body buffer
--- @param mode string: Vim mode for the keymap
--- @param key string: Key combination
--- @param callback function: Function to execute
local present_keymap = function(mode, key, callback)
	vim.keymap.set(mode, key, callback, {
		buffer = state.floats.body.buf,
	})
end

--- @class present.StartOptions
--- @field bufnr? number: Buffer number to create presentation from (default: current buffer)

--- Start a presentation from a markdown buffer
--- Creates floating windows and sets up navigation
--- @param opts? present.StartOptions: Configuration options
M.start_presentation = function(opts)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0

	local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
	state.parsed = parse_slides(lines)
	state.current_slide = 1
	state.title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(opts.bufnr), ":t")

	local windows = create_window_configurations()
	state.floats.background = create_floating_window(windows.background)
	state.floats.header = create_floating_window(windows.header)
	state.floats.footer = create_floating_window(windows.footer)
	state.floats.body = create_floating_window(windows.body, true)

	foreach_float(function(_, float)
		vim.bo[float.buf].filetype = "markdown"
	end)

	--- Set the content for a specific slide
	--- @param idx number: Slide index to display
	local set_slide_content = function(idx)
		local width = vim.o.columns
		local slide = state.parsed.slides[idx]

		local padding = string.rep(" ", (width - #slide.title) / 2)
		local title = padding .. slide.title
		vim.api.nvim_buf_set_lines(state.floats.header.buf, 0, -1, false, { title })
		vim.api.nvim_buf_set_lines(state.floats.body.buf, 0, -1, false, slide.body)

		local footer = string.format("  %d / %d | %s", state.current_slide, #state.parsed.slides, state.title)
		vim.api.nvim_buf_set_lines(state.floats.footer.buf, 0, -1, false, { footer })
	end

	present_keymap("n", "n", function()
		state.current_slide = math.min(state.current_slide + 1, #state.parsed.slides)
		set_slide_content(state.current_slide)
	end)
	present_keymap("n", "p", function()
		state.current_slide = math.max(state.current_slide - 1, 1)
		set_slide_content(state.current_slide)
	end)
	present_keymap("n", "q", function()
		vim.api.nvim_win_close(state.floats.body.win, true)
	end)

	local restore = {
		cmdheight = {
			original = vim.o.cmdheight,
			present = 0,
		},
	}

	-- Set the options we ant during the presentation
	for option, config in pairs(restore) do
		vim.opt[option] = config.present
	end

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = state.floats.body.buf,
		callback = function()
			-- Reset the values when we are done with the presentation
			for option, config in pairs(restore) do
				vim.opt[option] = config.original
			end
			foreach_float(function(_, float)
				pcall(vim.api.nvim_win_close, float.win, true)
			end)
		end,
	})

	vim.api.nvim_create_autocmd("VimResized", {
		group = vim.api.nvim_create_augroup("present-resized", {}),
		callback = function()
			if not vim.api.nvim_win_is_valid(state.floats.body.win) or state.floats.body.win == nil then
				return
			end
			local updated = create_window_configurations()
			foreach_float(function(name, _)
				vim.api.nvim_win_set_config(state.floats[name].win, updated[name])
			end)
			set_slide_content(state.current_slide)
		end,
	})

	set_slide_content(state.current_slide)
end

--M.start_presentation({ bufnr = 30 })
--M.start_presentation()

-- Expose internal functions for testing
--- @type fun(lines: string[]): present.Slides
M._parse_slides = parse_slides
--- @type fun(): present.WindowConfigurations
M._create_window_configurations = create_window_configurations
--- @type fun(config: present.WindowConfig, enter?: boolean): present.Float
M._create_floating_window = create_floating_window
--- @type fun(cb: fun(name: string, float: present.Float))
M._foreach_float = foreach_float

return M
