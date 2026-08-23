local opt = vim.opt

-- 줄 번호
opt.number = true

-- 검색
opt.ignorecase = true
opt.smartcase = true

-- 클립보드 & undo
opt.clipboard = "unnamedplus"
opt.undofile = true

-- SSH 세션에서 yank는 OSC 52로 클라이언트 머신 클립보드에도, pbcopy로 이
-- 머신 클립보드에도 복사한다. paste를 OSC 52로 하지 않는 이유: 터미널
-- 클립보드 읽기는 보안상 매번 허용 팝업이 떠서, 내부 레지스터 폴백으로 두고
-- 로컬→원격 붙여넣기는 터미널 paste(cmd+V)에 맡긴다.
if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function copy_both(reg)
    local osc52_copy = osc52.copy(reg)
    return function(lines)
      osc52_copy(lines)
      vim.fn.system("pbcopy", table.concat(lines, "\n"))
    end
  end
  local function paste_from_register()
    return { vim.fn.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') }
  end
  vim.g.clipboard = {
    name = "OSC 52 + pbcopy",
    copy = { ["+"] = copy_both("+"), ["*"] = copy_both("*") },
    paste = { ["+"] = paste_from_register, ["*"] = paste_from_register },
  }
end

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
