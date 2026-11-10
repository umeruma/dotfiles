return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    default_component_configs = {
      name = { trailing_slash = true },
      icon = {
        folder_closed = "[]",
        folder_open = "][",
        folder_empty = "[]",
        folder_empty_open = "][",
        default = "--",
      },
    },
    -- dotfiles are not dimmed; gitignored stay dimmed and `H` still toggles them
    filesystem = { filtered_items = { visible = true, hide_dotfiles = false } },
  },
}
