return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()

    -- Telescope integration with delete support
    local conf = require("telescope.config").values
    local action_state = require("telescope.actions.state")

    local function toggle_telescope(harpoon_files)
      local make_finder = function()
        local paths = {}
        -- Use pairs instead of ipairs to skip nil entries
        for idx, item in pairs(harpoon_files.items) do
          if item and item.value then
            table.insert(paths, { value = item.value, index = idx, display = idx .. ": " .. item.value })
          end
        end
        return require("telescope.finders").new_table({
          results = paths,
          entry_maker = function(entry)
            return {
              value = entry.value,
              display = entry.display,
              ordinal = entry.value,
              harpoon_index = entry.index,
            }
          end,
        })
      end

      local delete_harpoon_entry = function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection and selection.harpoon_index then
          harpoon:list():remove_at(selection.harpoon_index)
          local current_picker = action_state.get_current_picker(prompt_bufnr)
          current_picker:refresh(make_finder(), { reset_prompt = false })
        end
      end

      require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = make_finder(),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          -- Delete harpoon entry
          map("i", "<C-d>", function() delete_harpoon_entry(prompt_bufnr) end)
          map("n", "dd", function() delete_harpoon_entry(prompt_bufnr) end)
          -- macOS shortcuts are handled globally in telescope.lua
          return true
        end,
      }):find()
    end

    -- Hyperkey setup:
    -- macOS: CMD + CTRL + SHIFT + OPTION (D-C-S-M in Neovim notation) via Karabiner
    -- Linux: CTRL + SHIFT + ALT (C-S-M in Neovim notation) via keyd
    local is_mac = vim.fn.has("macunix") == 1

    -- Helper to create keybinding with correct Hyperkey for OS
    local function hyper(key)
      if is_mac then
        return "<D-C-S-M-" .. key .. ">"
      else
        return "<C-S-M-" .. key .. ">"
      end
    end

    -- Toggle file in harpoon list with notification
    vim.keymap.set("n", hyper("a"), function()
      local list = harpoon:list()
      local current_file = vim.fn.expand("%:p")
      local filename = vim.fn.fnamemodify(current_file, ":t")

      -- Get relative path from git root or current directory
      local git_root = vim.fn.system("git -C " .. vim.fn.getcwd() .. " rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
      local relative_file
      if git_root ~= "" and current_file:find(git_root) then
        relative_file = current_file:sub(#git_root + 2)
      else
        relative_file = vim.fn.fnamemodify(current_file, ":.")
      end

      -- Check if current file is already harpooned
      local is_harpooned = false
      for _, item in ipairs(list.items) do
        if item.value == relative_file then
          is_harpooned = true
          break
        end
      end

      if is_harpooned then
        -- Find and fully delete the entry from harpoon
        for idx, item in ipairs(list.items) do
          if item.value == relative_file then
            list:remove_at(idx)
            break
          end
        end
        -- Persist changes to disk
        harpoon:sync()
        Snacks.notify("📍 Harpoon: Unpinned " .. filename, { level = "info" })
      else
        -- Add current buffer to harpoon
        list:add()
        -- Persist changes to disk
        harpoon:sync()
        Snacks.notify("📍 Harpoon: Pinned " .. filename, { level = "info" })
      end
    end, { desc = "Harpoon: Toggle pin file" })

    -- Toggle Telescope harpoon menu (lowercase e)
    vim.keymap.set("n", hyper("e"), function()
      toggle_telescope(harpoon:list())
    end, { desc = "Harpoon: Telescope menu" })

    -- Toggle Telescope harpoon menu (uppercase E for when shift is held)
    vim.keymap.set("n", hyper("E"), function()
      toggle_telescope(harpoon:list())
    end, { desc = "Harpoon: Telescope menu" })

    -- Toggle default quick menu (alternative)
    vim.keymap.set("n", hyper("h"), function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon: Quick menu" })

    -- Navigate to specific files (1-4) with Hyper + number
    vim.keymap.set("n", hyper("1"), function()
      harpoon:list():select(1)
    end, { desc = "Harpoon: File 1" })

    vim.keymap.set("n", hyper("2"), function()
      harpoon:list():select(2)
    end, { desc = "Harpoon: File 2" })

    vim.keymap.set("n", hyper("3"), function()
      harpoon:list():select(3)
    end, { desc = "Harpoon: File 3" })

    vim.keymap.set("n", hyper("4"), function()
      harpoon:list():select(4)
    end, { desc = "Harpoon: File 4" })

    -- Navigate between harpoon files
    vim.keymap.set("n", hyper("p"), function()
      harpoon:list():prev()
    end, { desc = "Harpoon: Previous file" })

    vim.keymap.set("n", hyper("n"), function()
      harpoon:list():next()
    end, { desc = "Harpoon: Next file" })
  end,
}
