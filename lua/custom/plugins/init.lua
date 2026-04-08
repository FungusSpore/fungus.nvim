-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      {
        '<A-q>',
        function() require('trouble').toggle 'diagnostics' end,
        desc = 'Toggle Trouble diagnostics',
      },
    },
    opts = {
      focus = true,
      win = {
        size = 10,
      },
    },
  },
  {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<cr>',            desc = '[G]it [D]iff' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>',   desc = '[G]it file [H]istory' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>',     desc = '[G]it repo [H]istory' },
      { '<leader>gx', '<cmd>DiffviewClose<cr>',           desc = '[G]it diff close' },
    },
    opts = {},
  },
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    event = 'LspAttach',
    priority = 1000,
    opts = {
      preset = 'modern',
      options = {
        multilines = {
          enabled = true,
          always_show = true,
        },
        show_source = true,
        use_icons_from_diagnostic = true,
      },
    },
  },
  -- {
  --   'mrcjkb/rustaceanvim',
  --   version = '^5', -- Recommended
  --   lazy = false, -- This plugin is already lazy
  --   config = function()
  --     local bufnr = vim.api.nvim_get_current_buf()
  --     vim.keymap.set('n', '<leader>a', function()
  --       vim.cmd.RustLsp 'codeAction'
  --     end, { silent = true, buffer = bufnr })
  --   end,
  -- },
  { -- File Explorer & Drawer Wrapper
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'mikew/nvim-drawer',
    },
    config = function()
      -- 1. SETUP NVIM-TREE ONCE (Globally)
      require('nvim-tree').setup {
        view = {
          side = 'right',
          width = 25,
          preserve_window_proportions = true,
        },
        actions = {
          open_file = { resize_window = false },
        },
        hijack_directories = {
          enable = false,
          auto_open = false,
        },
      }

      -- 2. SETUP DRAWER
      local drawer = require 'nvim-drawer'
      drawer.setup({})

      -- ==========================================
      -- DRAWER 1: FILE TREE
      -- ==========================================
      drawer.create_drawer {
        size = 25,
        position = 'right',
        should_reuse_previous_bufnr = false,
        should_close_on_bufwipeout = false,

        on_vim_enter = function(event)
          -- [FIX 1] Commented this out so it doesn't open on startup
          -- event.instance.open { focus = false }

          -- Toggle Keymap
          vim.keymap.set('n', '<A-n>', function()
            event.instance.focus_or_toggle()
          end, { desc = 'Toggle Explorer' })
        end,

        on_did_create_buffer = function()
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
        position = 'float',
        win_config = {
          width = '98%',
          height = '95%',
          border = 'rounded',
          anchor = 'CC',
          margin = 1,
        },

        does_own_buffer = function(context)
          return context.bufname:match 'term://' ~= nil
        end,

        on_vim_enter = function(event)
          -- [FIX 1] Commented this out so it doesn't open on startup
          -- event.instance.open { focus = false }

          -- Normal Mode Toggle
          vim.keymap.set('n', '<A-h>', function()
            event.instance.focus_or_toggle()
          end, { desc = 'Toggle Terminal' })

          -- [FIX 2] Terminal Mode Toggle
          -- We use a Lua function so we can use 'event.instance' directly
          vim.keymap.set('t', '<A-h>', function()
            -- 1. Exit Terminal Mode (equivalent to <C-\><C-n>)
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', false)

            -- 2. Toggle the specific drawer instance we are already configured for
            -- We wrap this in schedule to ensure the mode switch happens first
            vim.schedule(function()
              event.instance.focus_or_toggle()
            end)
          end)

          -- Terminal Controls
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

        on_did_open = function()
          vim.cmd '$'
        end,
      }
    end,
  },
}
