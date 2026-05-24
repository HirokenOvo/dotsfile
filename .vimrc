" =============================================================================
" .vimrc — 远端友好的轻量配置（无插件 / 100% vim 内置能力）
" 适用：本地 macOS、远程 Linux 服务器、容器，统一一份
" =============================================================================


" ============================== 1. 基础与兼容性 ==============================
set nocompatible                    " 关闭 vi 兼容（脚本/容器里 sh 启动可能默认开启）
syntax on                           " 语法高亮
filetype plugin indent on           " 按文件类型加载插件 + 缩进规则
set background=dark                 " 暗色终端
set encoding=utf-8                  " 内部统一 utf-8
set fileencodings=utf-8,gbk,big5,latin1
set fileformats=unix,mac,dos


" ============================== 2. 编辑体验 =================================
set number                          " 显示行号
set cursorline                      " 高亮当前行
set ruler                           " 右下角显示行列
set showmatch                       " 输入括号时短暂跳到匹配项
set matchtime=2                     " 跳转停留 0.2s
set scrolloff=5                     " 光标距上下边缘至少 5 行
set sidescrolloff=8                 " 横向滚动留边
set hidden                          " buffer 切换不必先保存
set backspace=indent,eol,start      " 让退格键能跨行/缩进/插入起点
set mouse=a                         " 终端鼠标（如不喜欢可改 mouse=）
set updatetime=300                  " 各种 idle 触发更敏捷


" ============================== 3. 缩进 ======================================
set tabstop=2                       " 一个 \t 显示为 2 列
set shiftwidth=2                    " << / >> / 自动缩进的步长
" set softtabstop=2                   " 退格按一次抹掉 2 个空格
" set expandtab                       " 按 Tab 插入空格而不是 \t
set autoindent                      " 新行沿用上一行缩进
" 注：smartindent 通常被 filetype indent 接管，这里不再开启避免冲突


" ============================== 4. 搜索 ======================================
set ignorecase                      " 默认忽略大小写
set smartcase                       " 但出现大写时回到大小写敏感
set incsearch                       " 边输边搜
set hlsearch                        " 命中高亮
" <Esc><Esc> 清掉残留的搜索高亮
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>


" ============================== 5. 文件与备份 ================================
set noswapfile                      " 不生成 .swp
set nobackup                        " 不留 file~ 备份
set nowritebackup                   " 不在写入过程中产生临时备份
" 持久化撤销：跨次打开仍能 u 撤销到上次会话的改动
set undofile
set undodir=~/.vim/undo
silent !mkdir -p ~/.vim/undo


" ============================== 6. 静音 ======================================
set noerrorbells
set novisualbell
set t_vb=                           " 置空终端响铃序列


" ============================== 7. 命令行与补全 ==============================
set wildmenu                        " : 命令行 Tab 弹出可视菜单
set wildmode=longest:full,full      " 先公共前缀再循环
" 让 :find / :e Tab 补全忽略噪音目录
set wildignore+=*/.git/*,*/node_modules/*,*/dist/*,*/build/*,*.pyc,*.o,*.class
set completeopt=menuone,noinsert,noselect  " 插入模式下 <C-n>/<C-x><C-o> 行为更舒适


" ============================== 8. 文件查找（替代 fzf）======================
" 关键：path+=** 后，:find foo<Tab> 即可在整个项目模糊查到 foo*
set path=.,**


" ============================== 9. grep（项目级搜索）========================
" 优先用 ripgrep；没有就走系统 grep
if executable('rg')
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m
endif
" 用法：:grep pattern  → quickfix 列表 → :cnext / :cprev 跳转


" ============================== 10. 状态栏 ===================================
set laststatus=2                    " 永远显示 statusline
" 自定义：左边文件路径/修改/只读/帮助标记；右边类型/格式/编码/行列
set statusline=\ %<%F[%1*%M%*%n%R%H]%=\ %y\ %0(%{&fileformat}\ %{&encoding}\ Ln\ %l,\ Col\ %c/%L%)


" ============================== 11. 折叠 =====================================
set foldenable
set foldmethod=indent               " indent 比 syntax 快、跨语言更稳
set foldlevelstart=99               " 默认全展开，要折时手动折
" 空格键开/合当前折叠（注释必须独立成行，不能写在 nnoremap 同行）
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>


" ============================== 12. 重新打开回到上次光标位置 ================
augroup remember_pos
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
augroup END


" ============================== 13. 常用快捷键 ===============================
" 注：上面已用 <space> 做折叠，故不再把 <Space> 设为 mapleader
let mapleader = ","                 " 改用逗号做 leader

" 文件操作
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" 内置文件树（netrw）：左侧分屏打开/关闭
nnoremap <leader>e :Lexplore<CR>

" buffer 流（替代各种 buffer 插件）
nnoremap <leader>b :ls<CR>:b<Space>
nnoremap <leader>n :bnext<CR>
nnoremap <leader>p :bprev<CR>
nnoremap <leader>d :bdelete<CR>

" 项目内查找文件 / 内容
nnoremap <leader>f :find<Space>
nnoremap <leader>g :grep<Space>

" 取消搜索高亮（与 <Esc><Esc> 等价，给习惯 leader 的人）
nnoremap <leader>h :nohlsearch<CR>

" Alt+Shift+Up/Down  → 把当前行复制一份到上 / 下（VSCode 风格）
" 终端要求：iTerm2 → Profiles → Keys → 把 Left/Right Option Key 设为 "Esc+"，
" 否则 Alt 不会被传给 vim。
nnoremap <silent> <A-S-Up>   :t-1<CR>
nnoremap <silent> <A-S-Down> :t.<CR>
inoremap <silent> <A-S-Up>   <Esc>:t-1<CR>gi
inoremap <silent> <A-S-Down> <Esc>:t.<CR>gi
vnoremap <silent> <A-S-Up>   :t '<-1<CR>gv
vnoremap <silent> <A-S-Down> :t '><CR>gv


" ============================== 14. 系统剪贴板（macOS / SSH 转发）===========
" 仅在 vim 编译支持 +clipboard 时生效；否则保持默认（不影响其他配置）
if has('clipboard')
  set clipboard=unnamed             " yy / p 直接走系统剪贴板
endif