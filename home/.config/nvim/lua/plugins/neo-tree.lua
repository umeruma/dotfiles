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
    -- show hidden (dotfiles / gitignored) by default; `H` still toggles
    filesystem = { filtered_items = { visible = true } },
  },
}
