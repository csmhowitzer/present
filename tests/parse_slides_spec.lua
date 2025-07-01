---@diagnostic disable: undefined-field

local parse = require("present")._parse_slides
local eq = assert.are.same

describe("present.parse_slides", function()
	it("should parse an empty file", function()
		eq({
			slides = {
				{
					title = "",
					body = {},
				},
			},
		}, parse({}))
	end)

	it("should parse a file with one slide", function()
		eq({
			slides = {
				{
					title = "# This is the first slide",
					body = { "This is the body" },
				},
			},
		}, parse({ "# This is the first slide", "This is the body" }))
	end)

	it("should parse multiple slides correctly", function()
		eq({
			slides = {
				{
					title = "# First Slide",
					body = { "First content", "More first content" },
				},
				{
					title = "# Second Slide",
					body = { "Second content" },
				},
			},
		}, parse({
			"# First Slide",
			"First content",
			"More first content",
			"# Second Slide",
			"Second content"
		}))
	end)

	it("should handle slides with no body content", function()
		eq({
			slides = {
				{
					title = "# Title Only",
					body = {},
				},
			},
		}, parse({ "# Title Only" }))
	end)

	it("should handle content before first header", function()
		eq({
			slides = {
				{
					title = "",
					body = { "Content before header" },
				},
				{
					title = "# First Header",
					body = { "Content after header" },
				},
			},
		}, parse({
			"Content before header",
			"# First Header",
			"Content after header"
		}))
	end)

	it("should handle different header levels", function()
		eq({
			slides = {
				{
					title = "## Second Level",
					body = { "Content" },
				},
				{
					title = "### Third Level",
					body = {},
				},
			},
		}, parse({
			"## Second Level",
			"Content",
			"### Third Level"
		}))
	end)

	it("should handle lines that contain # but don't start with it", function()
		eq({
			slides = {
				{
					title = "# Real Header",
					body = { "This line has # in middle", "Another line" },
				},
			},
		}, parse({
			"# Real Header",
			"This line has # in middle",
			"Another line"
		}))
	end)
end)
