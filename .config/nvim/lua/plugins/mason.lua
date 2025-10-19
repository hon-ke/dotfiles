return {
	"williamboman/mason.nvim",
	dependencies = {
		"neovim/nvim-lspconfig", -- default config for lsp
		"williamboman/mason-lspconfig.nvim",
	},
	-- event = "VeryLazy",
	opts = {},
	config = function(_, opts)
		require("mason").setup(opts)
		local registry = require("mason-registry")

		local function setup(name, config)
			local success, package = pcall(registry.get_package, name)
			if success and not package:is_installed() then
				package:install()
			end

			local have_mason, _ = pcall(require, "mason-lspconfig")
			local lsp = ""
			if have_mason then
				lsp = require("mason-lspconfig").get_mappings().package_to_lspconfig[name]
			end

			config.capabilities = require("blink.cmp").get_lsp_capabilities()
			config.on_attach = function(client)
				client.server_capabilities.documentFormatterProvider = false
				client.server_capabilities.documentRangeFormatterProvider = false
			end
			require("lspconfig")[lsp].setup(config)
		end

		setup("lua-language-server", {})
		setup("vue-language-server", {})
		setup("pyright", {
			settings = {
				python = {
					pythonPath = "/home/clay/.venv/bin/python3", -- 必须单独设置
					analysis = {
						typeCheckingMode = "basic",
					},
				},
			},
		})
		setup("html-lsp", {})
		setup("css-lsp", {})
		setup("emmet-ls", {})

		-- default config for lsp
		vim.diagnostic.config({
			virtual_text = true,
		})
	end,
}
