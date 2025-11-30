-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  { -- File Explorer & Drawer Wrapper
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'mikew/nvim-drawer',
    },
    config = function(_, opts)
      -- 1. SETUP NVIM-TREE ONCE (Globally)
      -- We configure it here to be "dumb" so the drawer can control it.
      require('nvim-tree').setup {
        view = {
          side = 'right',
          width = 25, -- Match your drawer size
          preserve_window_proportions = true, -- Helps prevent misalignment
        },
        actions = {
          open_file = {
            resize_window = false,
          },
        },
        hijack_directories = {
          enable = false,
          auto_open = false,
        },
      }

      -- 2. SETUP DRAWER
      local drawer = require 'nvim-drawer'
      drawer.setup(opts)

      -- ==========================================
      -- DRAWER 1: FILE TREE
      -- ==========================================
      drawer.create_drawer {
        size = 25,
        position = 'right',
        should_reuse_previous_bufnr = false,
        should_close_on_bufwipeout = false,

        on_vim_enter = function(event)
          event.instance.open { focus = false }
          -- Toggle Keymap
          vim.keymap.set('n', '<A-n>', function()
            event.instance.focus_or_toggle()
          end, { desc = 'Toggle Explorer' })
        end,

        on_did_create_buffer = function()
          -- JUST open the tree. Do not run setup() here.
          require('nvim-tree.api').tree.open { current_window = true }
        end,

        on_did_open = function(ctx)
          local api = require 'nvim-tree.api'
          api.tree.reload()

          vim.api.nvim_win_set_width(ctx.winid, 25)

          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = 'no'
          vim.opt_local.statuscolumn = ''
        end,

        on_did_close = function()
          require('nvim-tree.api').tree.close()
        end,
      }

      -- ==========================================
      -- DRAWER 2: TERMINAL
      -- ==========================================
      drawer.create_drawer {
        size = 15,
        position = 'below',

        does_own_buffer = function(context)
          return context.bufname:match 'term://' ~= nil
        end,

        on_vim_enter = function(event)
          event.instance.open { focus = false }

          -- Keymaps
          vim.keymap.set('n', '<A-h>', function()
            event.instance.focus_or_toggle()
          end, { desc = 'Toggle Terminal' })
          -- Ensure this works in terminal mode too so you can toggle it closed while typing
          vim.keymap.set('t', '<A-h>', [[<C-\><C-n><cmd>lua require('nvim-drawer').get_drawer(2):focus_or_toggle()<CR>]])

          -- Terminal Controls (The "t" group)
          vim.keymap.set('n', '<leader>tt', function()
            event.instance.open { mode = 'new' }
          end, { desc = '[N]ew Terminal' })
          vim.keymap.set('n', '<leader>tn', function()
            event.instance.go(1)
          end, { desc = 'Next [T]erminal' })
          vim.keymap.set('n', '<leader>tp', function()
            event.instance.go(-1)
          end, { desc = 'Previous [T]erminal' })
          vim.keymap.set('n', '<leader>tz', function()
            event.instance.toggle_zoom()
          end, { desc = '[Z]oom Terminal' })
        end,

        on_did_create_buffer = function()
          vim.fn.termopen(os.getenv 'SHELL')
        end,

        on_did_open_buffer = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.signcolumn = 'no'
          vim.opt_local.statuscolumn = ''
        end,

        on_did_open = function(ctx)
          vim.cmd '$'
          vim.api.nvim_win_set_height(ctx.winid, 15)
        end,
      }
    end,
  },
}
