local opt = vim.opt

-- 줄 번호
opt.number = true

-- 검색
opt.ignorecase = true
opt.smartcase = true

-- 클립보드 & undo
opt.clipboard = "unnamedplus"
opt.undofile = true

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.cursorline = true

-- 들여쓰기 (기본값, 언어별 override는 ftplugin에서)
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- 창 분할
opt.splitright = true
opt.splitbelow = true
