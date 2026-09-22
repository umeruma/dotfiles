return {
  -- markdownlint をいったん無効化（opts はテーブルだと deep merge で消えないので関数で上書き）
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.markdown = {}
    end,
  },
}
