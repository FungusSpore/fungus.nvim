-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'famiu/bufdelete.nvim',
    keys = { { '<leader>x', '<cmd>Bdelete<cr>', desc = 'Close buffer' } },
  },
  {
    -- Peek definitions/references in a preview pane instead of jumping away.
    'dnlhc/glance.nvim',
    cmd = 'Glance',
    keys = {
      { 'gpd', '<cmd>Glance definitions<cr>', desc = 'Peek definitions' },
      { 'gpr', '<cmd>Glance references<cr>', desc = 'Peek references' },
      { 'gpi', '<cmd>Glance implementations<cr>', desc = 'Peek implementations' },
      { 'gpt', '<cmd>Glance type_definitions<cr>', desc = 'Peek type definitions' },
    },
    opts = {
      border = { enable = true },
      theme = { enable = true, mode = 'auto' },
      list = { position = 'right', width = 0.4 },
      folds = { folded = false },
    },
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      {
        '<A-q>',
        function()
          require('trouble').toggle 'diagnostics'
        end,
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
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = '[G]it [D]iff' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = '[G]it file [H]istory' },
      { '<leader>gH', '<cmd>DiffviewFileHistory<cr>', desc = '[G]it repo [H]istory' },
      { '<leader>gx', '<cmd>DiffviewClose<cr>', desc = '[G]it diff close' },
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
          open_file = { resize_window = false, quit_on_open = true },
        },
        hijack_directories = {
          enable = false,
          auto_open = false,
        },
      }

      -- 2. SETUP DRAWER
      local drawer = require 'nvim-drawer'
      drawer.setup {}

      -- ==========================================
      -- DRAWER 1: FILE TREE
      -- ==========================================
      local tree_drawer = drawer.create_drawer {
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

      -- Close the drawer when nvim-tree opens a file
      vim.api.nvim_create_autocmd('User', {
        pattern = 'NvimTreeFileOpened',
        callback = function()
          tree_drawer.close()
        end,
      })
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown' },
    opts = {
      -- LSP hover buffers are filetype markdown, so this plugin renders them too.
      -- `anti_conceal` un-hides whatever line the cursor is on, and the hover
      -- cursor starts on the opening ``` — which is why the fence showed.
      anti_conceal = { enabled = false },
      win_options = {
        concealcursor = { rendered = 'nvic' },
      },
    },
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    event = 'BufEnter',
    opts = {
      open_mapping = '<A-h>',
      direction = 'float',
      -- toggleterm darkens the terminal background by default, which paints an
      -- opaque box over Ghostty's background-opacity. Leave it unpainted.
      shade_terminals = false,
      float_opts = {
        -- 'curved' uses toggleterm's own rounded corner characters
        border = 'curved',
        -- winblend blends the float against the *buffer behind it*, not against
        -- the desktop. Real transparency comes from the unpainted background
        -- below plus Ghostty's background-opacity, so keep this at 0.
        winblend = 0,
        -- width/height are the *inside* of the float; the border adds a row and
        -- column on each side, and the command line owns the bottom row. Size
        -- against what's actually left or the bottom border lands off-screen.
        width = function()
          return math.floor((vim.o.columns - 2) * 0.97)
        end,
        height = function()
          return math.floor((vim.o.lines - vim.o.cmdheight - 2) * 0.95)
        end,
        col = function()
          return math.floor((vim.o.columns - 2) * 0.015)
        end,
        row = function()
          return math.floor((vim.o.lines - vim.o.cmdheight - 2) * 0.025)
        end,
      },
      on_open = function(term)
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = 'no'
        vim.opt_local.statuscolumn = ''
        -- Session label bottom-right: shows current id and total count
        local function update_label()
          local all = require('toggleterm.terminal').get_all()
          vim.wo.statusline = '%=%#Comment#  Terminal ' .. term.id .. ' / ' .. #all .. '  %*'
        end
        update_label()
        -- Exit terminal mode with <A-h> (close) or <Esc><Esc> (normal mode, keep open)
        vim.keymap.set('t', '<A-h>', '<cmd>ToggleTerm<cr>', { buffer = term.bufnr })
        vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { buffer = term.bufnr })
      end,
    },
    config = function(_, opts)
      -- Float colours follow the active colorscheme instead of a hard-coded
      -- palette: transparent background, visible themed border.
      local function float_highlights()
        local ok, palette = pcall(function()
          return require('catppuccin.palettes').get_palette()
        end)
        return {
          NormalFloat = { guibg = 'NONE' },
          FloatBorder = { guifg = ok and palette.blue or '#8caaee', guibg = 'NONE' },
        }
      end

      opts.highlights = float_highlights()
      require('toggleterm').setup(opts)

      -- Re-theme the float when the colorscheme changes
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('toggleterm-colors', { clear = true }),
        callback = function()
          require('toggleterm').setup(vim.tbl_extend('force', opts, { highlights = float_highlights() }))
        end,
      })

      local tt = require 'toggleterm.terminal'
      local Terminal = tt.Terminal

      local function create_term()
        -- find next unused ID (include hidden terminals so we never reuse one)
        local used = {}
        for _, t in ipairs(tt.get_all(true)) do
          used[t.id] = true
        end
        local id = 1
        while used[id] do
          id = id + 1
        end
        Terminal:new({ direction = 'float', id = id }):toggle()
      end

      -- Cycle focus across ALL terminals (floats hide their siblings, so we
      -- must include hidden ones), closing the current float before opening
      -- the next.
      local function nav(dir)
        local terms = vim.tbl_values(tt.get_all(true))
        if #terms < 2 then
          return
        end
        table.sort(terms, function(a, b)
          return a.id < b.id
        end)
        local cur_id = tt.get_focused_id() or terms[1].id
        local idx = 1
        for i, t in ipairs(terms) do
          if t.id == cur_id then
            idx = i
            break
          end
        end
        local nxt = terms[((idx - 1 + dir) % #terms) + 1]
        if nxt.id == cur_id then
          return
        end
        local cur = tt.get(cur_id, true)
        if cur and cur:is_open() then
          cur:close()
        end
        nxt:open()
      end

      -- When there's no second terminal yet, create one (and focus it);
      -- once two exist, just cycle between them.
      local function next_or_create()
        if #tt.get_all(true) < 2 then
          create_term()
        else
          nav(1)
        end
      end

      vim.keymap.set('n', '<leader>tt', create_term, { desc = 'New terminal' })
      vim.keymap.set('n', '<leader>tn', next_or_create, { desc = 'Next/create terminal' })
      vim.keymap.set('n', '<leader>tp', function()
        nav(-1)
      end, { desc = 'Prev terminal' })
    end,
  },
}
