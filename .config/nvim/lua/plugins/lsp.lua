return {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        'neovim/nvim-lspconfig',
    },
    config = function()
        vim.lsp.config('rust_analyzer', {
            settings = {
                ['rust-analyzer'] = {
                    cargo = {
                        buildScripts = { enable = true },
                    },
                    procMacro = { enable = true },
                    imports = {
                        granularity = { group = 'module' },
                        prefix = 'self',
                    },
                    check = { command = 'clippy' },
                },
            },
        })

        require('mason-lspconfig').setup({
            ensure_installed = { 'lua_ls', 'hls', 'rust_analyzer' },
        })
        vim.lsp.enable('rust_analyzer')

        vim.lsp.config('lua_ls', {})
        vim.lsp.config('hls', {})

        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(event)
                local opts = { buffer = event.buf }

                vim.keymap.set('n', 'K', vim.lsp.buf.hover,
                    vim.tbl_extend('force', opts, { desc = 'Documentation' }))
                vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action,
                    vim.tbl_extend('force', opts, { desc = 'LSP code action' }))
                vim.keymap.set('n', '<leader>lf', function()
                    vim.lsp.buf.format({ async = true })
                end, vim.tbl_extend('force', opts, { desc = 'LSP format' }))
                vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename,
                    vim.tbl_extend('force', opts, { desc = 'LSP rename' }))

                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client:supports_method('textDocument/inlayHint') then
                    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
                end
            end,
        })
    end
}
