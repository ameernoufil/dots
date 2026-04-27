return {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        'neovim/nvim-lspconfig',
    },
    config = function()
        require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls', 'hls' },
        })

        vim.lsp.config('lua_ls', {})
        vim.lsp.config('hls', {})

        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Documentation' })
    end
}
