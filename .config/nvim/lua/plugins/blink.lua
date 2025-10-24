return {
  "saghen/blink.cmp",
  version = "*",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "L3MON4D3/LuaSnip",
    "nvim-tree/nvim-web-devicons", -- 确保图标依赖存在:cite[6]
    "onsails/lspkind.nvim", -- 确保图标类别依赖存在
  },
  event = "InsertEnter", -- 更稳妥的加载时机
  opts = {
    completion = {
      menu = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        draw = {
          columns = { { "kind_icon" }, { "label", gap = 1 } },
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx)
                local icon = ctx.kind_icon
                -- 安全地检查 source_name
                if ctx.source_name and vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local ok, devicons = pcall(require, "nvim-web-devicons")
                  if ok then
                    local dev_icon, _ = devicons.get_icon(ctx.label or "")
                    if dev_icon then
                      icon = dev_icon
                    end
                  end
                else
                  local ok, lspkind = pcall(require, "lspkind")
                  if ok then
                    icon = lspkind.symbolic(ctx.kind or "Text", {
                      mode = "symbol",
                    }) or icon
                  end
                end
                return (icon or "") .. (ctx.icon_gap or "")
              end,
              highlight = function(ctx)
                local hl = "BlinkCmpKind" .. (ctx.kind or "Text")
                if ctx.source_name and vim.tbl_contains({ "Path" }, ctx.source_name) then
                  local ok, devicons = pcall(require, "nvim-web-devicons")
                  if ok then
                    local dev_icon, dev_hl = devicons.get_icon(ctx.label or "")
                    if dev_icon then
                      hl = dev_hl or hl
                    end
                  end
                end
                return hl
              end,
            },
            -- 移除了 colorful-menu 相关的 label 组件自定义
            -- 使用 blink.cmp 默认的 label 渲染
          },
        },
      },
      documentation = {
        auto_show = true,
        window = {
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
      },
    },
    keymap = {
      preset = "super-tab",
    },
    sources = {
      default = { "path", "snippets", "buffer", "lsp" },
      snippets = {
        priority = 1000,
        max_items = 10,
      },
      lsp = {
        priority = 900,
      },
    },
    snippet = {
      expand = function(args)
        local ok, luasnip = pcall(require, "luasnip")
        if ok then
          luasnip.lsp_expand(args.body)
        end
      end,
    },
    matching = {
      fuzzy = true,
      exact = true,
      case_sensitive = false,
    },
    sorting = {
      comparators = {
        -- 使用安全的 require 方式
        function(...)
          local ok, comparators = pcall(require, "blink.cmp.completion.comparators")
          if ok then
            return comparators.score(...)
          end
          return nil
        end,
        function(...)
          local ok, comparators = pcall(require, "blink.cmp.completion.comparators")
          if ok then
            return comparators.recently_used(...)
          end
          return nil
        end,
        function(...)
          local ok, comparators = pcall(require, "blink.cmp.completion.comparators")
          if ok then
            return comparators.kind(...)
          end
          return nil
        end,
        function(...)
          local ok, comparators = pcall(require, "blink.cmp.completion.comparators")
          if ok then
            return comparators.length(...)
          end
          return nil
        end,
      },
    },
  },
  config = function(_, opts)
    -- 先设置 LuaSnip
    local ok_luasnip, luasnip = pcall(require, "luasnip")
    if ok_luasnip then
      -- 加载 friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- 设置 snippet 键映射
      vim.keymap.set({"i", "s"}, "<C-l>", function()
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        end
      end, { silent = true })

      vim.keymap.set({"i", "s"}, "<C-h>", function()
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        end
      end, { silent = true })
    end

    -- 最后设置 blink.cmp
    local ok_blink, blink = pcall(require, "blink.cmp")
    if ok_blink then
      blink.setup(opts)
    else
      vim.notify("blink.cmp not found", vim.log.levels.ERROR)
    end
  end,
}
