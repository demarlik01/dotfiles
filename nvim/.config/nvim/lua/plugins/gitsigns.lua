return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end
      map("n", "]c", function() gs.nav_hunk("next") end, "Next Hunk")
      map("n", "[c", function() gs.nav_hunk("prev") end, "Prev Hunk")
      map("n", "<leader>hp", gs.preview_hunk, "Preview Hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset Hunk")
      map("n", "<leader>hs", gs.stage_hunk, "Stage Hunk")
    end,
  },
}
