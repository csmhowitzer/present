# present.nvim

A minimalist presentation plugin for Neovim that transforms markdown files into beautiful, distraction-free slide presentations.

## Features

- **Markdown-based**: Write presentations in familiar markdown syntax
- **Minimalist design**: Clean, distraction-free floating windows
- **Responsive layout**: Automatically adapts to different screen sizes
- **Lightweight**: Simple, focused functionality without bloat
- **Easy to use**: Single command to start presenting
- **Well-tested**: Comprehensive test suite with 28+ tests

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/present.nvim",
  config = function()
    require("present").setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "your-username/present.nvim",
  config = function()
    require("present").setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'your-username/present.nvim'
```

Then add to your `init.lua`:
```lua
require("present").setup()
```

## Usage

### Basic Usage

1. **Create a markdown file** with your presentation content
2. **Use `#` headers** to separate slides
3. **Start the presentation** with `:PresentStart`
4. Use `n` and `p` and `q` to navigate slides and close the presentation

### Markdown Format

```markdown
# First Slide Title

This is the content of the first slide.
You can have multiple lines of content.

# Second Slide Title

- Bullet points work great
- For listing key points
- And organizing information

# Third Slide

Code blocks and other markdown elements
are displayed as-is in the presentation.
```

### Commands

- `:PresentStart` - Start presentation from current buffer

### Navigation

Once in presentation mode:
- The presentation displays in floating windows
- Content is automatically formatted and centered
- Window layout adapts to your screen size

## Configuration

### Setup

```lua
require("present").setup()
```

Currently, present.nvim works out of the box with minimal configuration needed.

### Customization

The plugin creates floating windows with:
- **Background window**: Full-screen backdrop
- **Header window**: Displays slide titles with rounded borders
- **Body window**: Shows slide content with proper margins
- **Footer window**: Bottom status area

Window layouts automatically adjust based on your terminal size.

## API

### Functions

```lua
-- Start presentation from current buffer
require("present").start_presentation()

-- Start presentation from specific buffer
require("present").start_presentation({ bufnr = 42 })

-- Setup function (currently minimal)
require("present").setup()
```

## Examples

### Simple Presentation

```markdown
# Welcome to My Presentation

This is the opening slide with some introductory content.

# Key Points

- Point one: Important information
- Point two: More details
- Point three: Conclusion

# Thank You

Questions and discussion time!
```

### Meeting Notes Presentation

```markdown
# Meeting Agenda

- Review last week's progress
- Discuss current challenges
- Plan next steps

# Progress Update

Completed tasks:
- Feature implementation
- Bug fixes
- Documentation updates

# Next Steps

- Code review
- Testing phase
- Deployment planning
```

## How It Works

1. **Slide Parsing**: Markdown content is parsed into slides using `#` headers as separators
2. **Window Management**: Creates layered floating windows for different presentation elements
3. **Content Display**: Renders slide titles and body content in separate, styled windows
4. **Responsive Design**: Automatically adjusts layout based on terminal dimensions

## Troubleshooting

### Common Issues

**Presentation doesn't start:**
- Ensure you're in a buffer with markdown content
- Check that headers start with `#` at the beginning of lines

**Layout issues:**
- The plugin automatically adapts to screen size
- Try resizing your terminal if layout seems off
- VimResized autocmd handles dynamic resizing

**Content not displaying correctly:**
- Verify markdown format with `#` headers separating slides
- Check that content follows headers in the expected order

### Debug Information

To check if slides are parsed correctly:
```lua
-- Get parsed slides from current buffer
local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
local slides = require("present")._parse_slides(lines)
print(vim.inspect(slides))
```
## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

The codebase follows established patterns and includes comprehensive testing.
