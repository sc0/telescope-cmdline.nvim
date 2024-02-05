# telescope-cmdline.nvim

### This is a fork of amazing `jonarrien/telescope-cmdline.nvim`

This version adds a couple of features on top of the original plugin 
that I was missing. This includes:
- **Fuzzy search** - in this version you can actually fuzzy search for the command you're looking for [(now merged!)](https://github.com/jonarrien/telescope-cmdline.nvim/pull/13)
- **Command builder** – using `:Telescope cmdline builder` you can now trigger a window that presents only commands (not history) and that allows you to build multi-word commands and with fuzzy-search and selecting specific phrases with `<space>` you can save a lot of keystrokes.
- **Documentation preview** - in command builder there is a previewer that will show docs for the selected comment. **NOTE:** This feature is in beta and for now works only in very specific cases. This will be improved soon.

See the example usage of **Command Builder** below:
![Builder demo](.docs/builder-demo.gif)

---

# Original README

Telescope extension to use command line in a floating window, rather
than in bottom-left corner.

![Alt Text](.docs/demo.gif)

**Intended behaviour:**
- Show command history when no input is provided (to go up&down in
  history using telescope keybindings)
- Typing doesn't filter command history, it starts a new command and
  autocompletes.
- Use `<CR>` to trigger the selected command.
- Use `<C-e>` to pass selection to input field and edit it.

> NOTE: This is an alpha version done in relative short time. May need
> further improvements or customizations, but it's working pretty well
> for me and thought sharing with community.

## Installation

<details>
<summary>Packer</summary>

```lua
use { 'jonarrien/telescope-cmdline.nvim' }
```

</details>

<details>
<summary>Lazy</summary>

Install package as telescope dependency

```lua
{
  "nvim-telescope/telescope.nvim",
  tag = "0.1.3",
  config = function(_, opts)
    require("telescope").setup(opts)
    require("telescope").load_extension('cmdline')
  end,
  dependencies = {
    'jonarrien/telescope-cmdline.nvim',
  },
  keys = {
    { '<leader><leader>', '<cmd>Telescope cmdline<cr>', desc = 'Cmdline' }
  }
}
```

</details>


## Configuration

You can customise cmdline settings in telescope configuration.

```lua
require("telescope").setup({
  ...
  extensions = {
    cmdline = {
      picker = {
        layout_config = {
          width  = 120,
          height = 25,
        }
      },
      mappings    = {
        complete      = '<Tab>',
        run_selection = '<C-CR>',
        run_input     = '<CR>',
      },
    },
  }
  ...
})
```

<details>
<summary>Default configuration</summary>

See full configuration options in `lua/cmdline/config.lua` file.

</details>

## Trigger

⚠️ Make sure to load the `cmdline` extension, so that the `Telescope cmdline` command is available.

```lua
require("telescope").load_extension("cmdline")
```

Cmdline can be executed using `:Telescope cmdline<CR>`, but it doesn't
include any mapping by default.

> I aim to replace `:`, but there are some caveats and I recommend to
> use another mapping instead. If you want to give it a try, add this
> line in your config:

```lua
vim.api.nvim_set_keymap('n', '<leader><leader>', ':silent Telescope cmdline<CR>', { noremap = true, desc = "Cmdline" })
```

## Mappings

- `<CR>`  Run user input if entered, otherwise run first selection
- `<TAB>` complete current selection into input (useful for :e, :split, :vsplit, :tabnew)
- `<C-CR>`Run selection directly
- `<C-e>` edit current selection in prompt

## Notes

- [x] Support normal mode
- [ ] Support visual mode

## Acknowledgements

- Everyone who contributes in Neovim, this is getting better every day!
- Neovim team for adding lua, it really rocks!
- Telescope for facilitating extension creation 💪
