return {
  "ibhagwan/fzf-lua",
  -- optional for icon support
  -- dependencies = { "nvim-tree/nvim-web-devicons" },
  -- or if using mini.icons/mini.nvim
  dependencies = { "echasnovski/mini.icons" },
  opts = {},
  keys = {
    {"<leader>ff", 
      function() require('fzf-lua').files() end,
      desc = "find files in project directory"
    },
    {"<leader>fg", 
      function() require('fzf-lua').live_grep() end,
      desc = "find by grepping project directory" 
    },
    {"<leader>fc", 
      function() require('fzf-lua').files({cwd=vim.fn.stdpath("config")}) end,
      desc = "find in neovim configuration"
    },
    {"<leader>fb", 
      function() require('fzf-lua').builtin() end,
      desc = "find in fzf builtin"
    },
    {"<leader>fw", 
      function() require('fzf-lua').grep_cword() end,
      desc = "find current word"
    },
    {"<leader>fW", 
      function() require('fzf-lua').grep_cWORD() end,
      desc = "find current WORD"
    },
    {"<leader>fk", 
      function() require('fzf-lua').keymaps() end,
      desc = "find keymaps"
    },
    {"<leader>fr", 
      function() require('fzf-lua').resume() end,
      desc = "find resume"
    },
    {"<leader>fo", 
      function() require('fzf-lua').oldfile() end,
      desc = "find oldfile"
    },
    {"<leader><leader>", 
      function() require('fzf-lua').buffers() end,
      desc = "find existing buffers"
    },
    {"<leader>/", 
      function() require('fzf-lua').lgrep_curbuf() end,
      desc = "live grep the current buffer"
    }
  }
}
