return {
	"folke/tokyonight.nvim", -- url

	opts = {
		style = "moon",
        -- transparent=true
	},

	config = function(_, opts)
		require("tokyonight").setup(opts)
		vim.cmd("colorscheme tokyonight")
	end,
}
