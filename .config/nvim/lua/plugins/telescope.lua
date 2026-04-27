return {
  'nvim-telescope/telescope.nvim', version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- optional but recommended
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    { "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find Files (Root Dir)" },
    { "<leader>pg", "<cmd>Telescope live_grep<cr>", desc = "Grep Search" },
  }
}

