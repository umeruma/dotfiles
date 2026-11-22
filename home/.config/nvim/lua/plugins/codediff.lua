return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    { "<leader>gv", "<cmd>CodeDiff<cr>", desc = "Review changes (codediff)" },
    { "<leader>gV", "<cmd>CodeDiff file HEAD<cr>", desc = "Diff current file vs HEAD (codediff)" },
  },
}
