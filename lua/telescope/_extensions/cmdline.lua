local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

local cmdline = require('cmdline')
local action = require('cmdline.actions')
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorter = require("telescope.sorters")
local entry_display = require("telescope.pickers.entry_display")

local previewers = require("telescope.previewers")

local get_config = function()
  local config = require('cmdline.config')
  if config.values == nil or config.values == {} then
    return config.defaults
  else
    return config.values
  end
end

local displayer = entry_display.create({
  separator = " ",
  items = {
    { width = 2 },
    { remaining = true },
  },
})

local make_display = function(entry)
  local config = get_config()
  return displayer({
    { entry.icon, config.highlights.icon },
    { entry.cmd },
  })
end

local make_finder = function(config)
  return finders.new_dynamic({
    fn = cmdline.autocomplete,
    entry_maker = function(entry)
      entry.icon = config.icons[entry.type]
      entry.id = entry.index
      entry.value = entry.cmd
      entry.ordinal = entry.cmd
      entry.display = make_display
      return entry
    end,
  })
end

local make_finder_without_history = function(config)
	return finders.new_dynamic({
		fn = cmdline.autocomplete_no_history,
		entry_maker = function(entry)
			entry.icon = config.icons[entry.type]
			entry.id = entry.index
			entry.value = entry.cmd
			entry.ordinal = entry.cmd
			entry.display = make_display
			return entry
		end,
	})
end

local make_picker = function(opts)
  local config = get_config()
  return pickers.new(config.picker, {
    prompt_title = "Cmdline",
    prompt_prefix = " : ",
    finder = make_finder(config),
    sorter = sorter.get_fzy_sorter(opts),
    attach_mappings = function(_, map)
      map("i", config.mappings.complete, action.complete_input)     -- <Tab>
      map("i", config.mappings.run_input, action.run_input)         -- <CR>
      map("i", config.mappings.run_selection, action.run_selection) -- <C-CR>
      map("i", "<C-e>", action.edit)
      return true
    end,
  })
end

local make_builder_picker = function(opts)
	local config = get_config()
	return pickers.new(config.picker, {
		prompt_title = "Command builder",
		prompt_prefix = " : ",
		finder = make_finder_without_history(config),
		previewer = previewers.new_buffer_previewer({
			title = "Documentation",
			define_preview = function(self, entry, status)
				if entry.type == "command" then
					local cmd = string.lower(entry.cmd)
					local root = cmd:match("^([^%s]+)")
					local search_term = "*" .. cmd:gsub("%s", ".") .. "()\\*"

					require("telescope.config").values.buffer_previewer_maker(
						vim.api.nvim_get_runtime_file("doc/" .. root .. ".txt", false)[1],
						self.state.bufnr,
						{
							callback = function()
								vim.api.nvim_buf_call(self.state.bufnr, function()
									local line = vim.fn.search(search_term, "n")
									if line > 0 and #cmd > #root then
										vim.fn.clearmatches("Search")
										vim.fn.matchadd("Search", search_term)
										vim.api.nvim_win_set_cursor(self.state.winid, { line, 0 })
									end
								end)
							end,
						}
					)
				end
			end,
		}),
		sorter = sorter.get_fzy_sorter(opts),
		attach_mappings = function(_, map)
			map("i", "<Space>", action.complete_input) -- <Tab>
			map("i", "<CR>", action.builder_run_selection)
			map("i", "<C-e>", action.edit)
			return true
		end,
	})
end

local telescope_cmdline = function(opts)
	local picker = make_picker(opts)
	picker:find()
end

local cmdline_builder = function(opts)
	local picker = make_builder_picker(opts)
	picker:find()
end

local cmdline_visual = function(opts)
	local picker = make_picker(opts)
	picker:find()
	picker:set_prompt("'<,'> ")
end

return telescope.register_extension({
	setup = function(ext_config, config)
		require("cmdline.config").set_defaults(ext_config)
	end,
	exports = {
		cmdline = telescope_cmdline,
		visual = cmdline_visual,
		builder = cmdline_builder,
	},
})
