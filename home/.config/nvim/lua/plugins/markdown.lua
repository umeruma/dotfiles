return {
  -- markdownlint をいったん無効化（opts はテーブルだと deep merge で消えないので関数で上書き）
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.markdown = {}
    end,
  },
  -- 表だけ描画する（ほかの記号は隠さず treesitter のハイライトだけ使う）
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown.mdx" },
    opts = {
      file_types = { "markdown", "markdown.mdx" },
      heading = { enabled = false },
      paragraph = { enabled = false },
      code = { enabled = false },
      dash = { enabled = false },
      bullet = { enabled = false },
      checkbox = { enabled = false },
      quote = { enabled = false },
      link = { enabled = false },
      sign = { enabled = false },
      inline_highlight = { enabled = false },
      pipe_table = { enabled = true },
    },
  },
}
