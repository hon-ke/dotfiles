return {
	"saghen/blink.cmp",
	version = "*",

	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	event = "VeryLazy",
	opts = {
		completion = {
            menu = {
                draw = {
                    -- We don't need label_description now because label and label_description are already
                    -- combined together in label by colorful-menu.nvim.
                    columns = { { "kind_icon" }, { "label", gap = 1 } },
                    components = {
                        label = {
                            text = function(ctx)
                                return require("colorful-menu").blink_components_text(ctx)
                            end,
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
                        },
                    },
                },
            },
			documentation = {
				auto_show = true,
			},
		},
		-- keymap
		keymap = {
			preset = "super-tab"
			-- preset = "enter",
		},
		--
		sources = {
			default = { "path", "snippets", "buffer", "lsp" },
		},
		-- cmd complet
		cmdline = {
			sources = function()
				local cmd_type = vim.fn.getcmdtype()

				if cmd_type == "/" then
					return { "buffer" }
				end

				if cmd_type == ":" then
					return { "cmdline" }
				end

				return {}
			end,

			keymap = {
				preset = "super-tab"
				-- preset = "enter",
			},

			completion = {
				menu = {
					auto_show = true,
				},
			},
		},
	},
}
