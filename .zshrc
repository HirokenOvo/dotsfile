# =============================================================================
# .zshrc — oh-my-zsh + 自定义增强
# =============================================================================


# ============================== 1. oh-my-zsh 基础 ============================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="hiroken"

# 关闭 omz 自身更新检查（容器/受限网络下避免每次启动卡顿）
zstyle ':omz:update' mode disabled

# 补全大小写敏感（要求精确匹配）
CASE_SENSITIVE="true"

# 命令拼错时建议纠正（执行前会问 [n,y,a,e]）
# n no, y yes, a all, e edit
ENABLE_CORRECTION="true"

# 大仓库里不把 untracked 文件计入 dirty —— git 状态计算极快
DISABLE_UNTRACKED_FILES_DIRTY="true"

# 粘贴 URL/特殊字符时不被自动转义（防止粘贴乱码）
DISABLE_MAGIC_FUNCTIONS="true"

# history 命令输出附带时间戳
HIST_STAMPS="yyyy-mm-dd"


# ============================== 2. 插件 ======================================
# 顺序很重要：
#   1) zsh-completions 必须在 source omz 之前注入 fpath（见下面第 3 块）
#   2) zsh-syntax-highlighting 必须放在 plugins 列表最末，否则高亮失效
plugins=(
  # ----- omz 自带 -----
  git                    # git 别名（gst/gco/gp...）+ 补全
  virtualenv             # 在 prompt 显示当前 venv（hiroken 主题用得到）
  z                      # 智能 cd：z foo 跳到最近常去的含 foo 的目录
  extract                # x file.tar.gz 一键解压所有压缩格式
  colored-man-pages      # man 页面彩色显示
  sudo                   # 双击 Esc 在当前命令前加 sudo
  copypath               # copypath 把当前路径复制到剪贴板
  copyfile               # copyfile <file> 把文件内容复制到剪贴板
  copybuffer             # Ctrl+O 把当前命令行复制到剪贴板
  dirhistory             # Alt+← / Alt+→ 浏览 cd 历史栈
  fzf                    # 启用 Ctrl-R / Ctrl-T fzf 模糊搜索（需 brew install fzf）

  # ----- 第三方（需 clone 到 ~/.oh-my-zsh/custom/plugins/）-----
  zsh-completions        # 扩展更多命令补全
  zsh-autosuggestions    # 历史灰字补全
  zsh-syntax-highlighting  # 实时语法高亮（必须最后）
)


# ============================== 3. 加载 omz ==================================
# zsh-completions 要求在 compinit 之前把它的 src 注入 fpath
fpath+=${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src
source $ZSH/oh-my-zsh.sh


# ============================== 4. 历史记录 ==================================
HISTFILE=~/.zsh_history
HISTSIZE=100000                       # 内存中保留多少条
SAVEHIST=100000                       # 写入文件多少条
setopt HIST_IGNORE_DUPS               # 连续重复的命令只记一次
setopt HIST_IGNORE_ALL_DUPS           # 旧的同名命令也清掉
setopt HIST_IGNORE_SPACE              # 行首带空格的命令不入历史（敲密码方便）
setopt HIST_REDUCE_BLANKS             # 写入前压缩多余空格
setopt SHARE_HISTORY                  # 多终端实时共享历史
setopt INC_APPEND_HISTORY             # 命令一执行就写历史，而非退出时


# ============================== 5. 目录跳转 ==================================
setopt AUTO_CD                        # 直接打目录名就 cd 进去
setopt AUTO_PUSHD                     # cd 自动入栈，dirs -v 查看
setopt PUSHD_IGNORE_DUPS              # 栈内去重


# ============================== 6. 键位绑定 ==================================
# autosuggestion 接受策略：右箭头保留为光标移动，避免冲突
bindkey '^ '   autosuggest-accept     # Ctrl+Space  接受全部建议
bindkey '^[[1;3C' forward-word        # Alt+→       接受下一个词（iTerm2 默认序列）
bindkey '^[f'  forward-word           # Alt+f       同上（兜底，部分终端用此序列）


# ============================== 7. 语法高亮配色 ==============================
# 必须在 source omz 之后；shell 启动后立即生效
ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue'
ZSH_HIGHLIGHT_STYLES[command]='fg=blue'
ZSH_HIGHLIGHT_STYLES[function]='fg=blue'
ZSH_HIGHLIGHT_STYLES[alias]='fg=blue'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'   # 找不到的命令立刻变红
ZSH_HIGHLIGHT_STYLES[comment]='fg=240'              # # 注释暗灰，不抢眼


# ============================== 8. 默认编辑器 ================================
export EDITOR='vim'
export VISUAL='vim'


# ============================== 9. 拆分配置文件 ==============================
# 公用别名（同步到所有机器）
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
# 机器私有配置（公司/容器各异；同步时用 .gitignore 排除）
[ -f ~/.zshrc.local ] && source ~/.zshrc.local