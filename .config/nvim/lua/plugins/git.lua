return {
  'tpope/vim-fugitive',
  keys = {
    {
      "<leader>gs",
      function()
        vim.cmd("topleft vertical Git")
        vim.cmd("vertical resize " .. math.floor(vim.o.columns * 0.2))
      end,
      desc = "Git Status",
    },
  }
}
