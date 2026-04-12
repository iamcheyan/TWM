-- Neovim Configuration (Zellij/Nord Style)

-- 基础设置 (Options)
local opt = vim.opt
opt.number = true              -- 显示行号
opt.relativenumber = true      -- 相对行号
opt.shiftwidth = 4             -- 缩进宽度
opt.tabstop = 4                -- Tab 宽度
opt.expandtab = true           -- 将 Tab 转换为空格
opt.smartindent = true         -- 智能缩进
opt.cursorline = true          -- 高亮当前行
opt.termguicolors = true       -- 启用真彩色
opt.ignorecase = true          -- 搜索忽略大小写
opt.smartcase = true           -- 智能大小写
opt.mouse = 'a'                -- 启用鼠标

-- 自动保存 (响应你的 :wa:w 需求)
-- 开启后，在失去焦点或文本改变时自动保存
opt.autowrite = true
opt.autowriteall = true

-- 快捷键映射 (Keymaps)
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- jk 快速回到 Normal 模式
map('i', 'jk', '<Esc>', opts)

-- 快速保存 (Win + s 风格)
map('n', '<leader>s', ':wa<CR>', opts)

-- 颜色方案 (Nord)
-- 注意：这里假设你使用的是带 Nord 基础色的终端 (如 Kitty)
-- 如果需要更完整的插件支持，可以使用 lazy.nvim
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight LineNr guifg=#4c566a
  highlight CursorLineNr guifg=#88c0d0
]])

-- 状态栏简洁设置
vim.opt.laststatus = 2
vim.opt.statusline = " %f %y %m %= %l:%c "

print("NeoVim Config Loaded: Nord Style")
