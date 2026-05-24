#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — 一键拉取并安装本仓库 dotsfile + 全部依赖
#
# 远端用法：
#   curl -fsSL https://raw.githubusercontent.com/HirokenOvo/dotsfile/main/bootstrap.sh | bash
#
# 本地用法（已 git clone 仓库）：
#   bash bootstrap.sh
#
# 行为：
#   1. 装齐系统依赖（zsh / git / vim / tmux / curl / fzf / ripgrep）
#   2. 装 oh-my-zsh（若缺）
#   3. 装 3 个 zsh 插件 + TPM
#   4. 把仓库 clone 到 ~/.dotsfile，再用 symlink 覆盖到 $HOME
#   5. 把 hiroken.zsh-theme 链接到 $ZSH_CUSTOM/themes/
#   6. 已有文件统一备份到 ~/.dotsfile.backup.<时间戳>/
#   7. 自动 chsh 切到 zsh（若当前不是）
# =============================================================================
set -euo pipefail

REPO_URL="${DOTSFILE_REPO:-https://github.com/HirokenOvo/dotsfile.git}"
DOTS_DIR="${DOTSFILE_DIR:-$HOME/.dotsfile}"
BACKUP_DIR="$HOME/.dotsfile.backup.$(date +%Y%m%d_%H%M%S)"

# ----- 输出辅助 ---------------------------------------------------------------
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# ============================== 1. 系统依赖 ==================================
install_pkg() {
  # 用法: install_pkg <bin> <pkg-name>
  local bin="$1"; local pkg="${2:-$1}"
  command -v "$bin" >/dev/null 2>&1 && return 0
  log "安装 $pkg ..."
  case "$(uname -s)" in
    Darwin)
      command -v brew >/dev/null 2>&1 || die "请先安装 Homebrew: https://brew.sh"
      brew install "$pkg" ;;
    Linux)
      if   command -v apt-get >/dev/null 2>&1; then sudo apt-get update -qq && sudo apt-get install -y "$pkg"
      elif command -v dnf     >/dev/null 2>&1; then sudo dnf install -y "$pkg"
      elif command -v yum     >/dev/null 2>&1; then sudo yum install -y "$pkg"
      elif command -v pacman  >/dev/null 2>&1; then sudo pacman -S --noconfirm "$pkg"
      elif command -v apk     >/dev/null 2>&1; then sudo apk add --no-cache "$pkg"
      else die "未识别的 Linux 包管理器，请手动安装 $pkg"
      fi ;;
    *) die "未支持的系统：$(uname -s)" ;;
  esac
}

log "检查并安装系统依赖"
install_pkg git
install_pkg curl
install_pkg zsh
install_pkg vim
install_pkg tmux
install_pkg fzf
# ripgrep 在不同发行版包名为 ripgrep，可执行文件 rg
install_pkg rg ripgrep || true   # 容器里偶尔无 root，失败不致命

# ============================== 2. clone 仓库 ================================
if [ -d "$DOTS_DIR/.git" ]; then
  log "更新已存在的仓库 $DOTS_DIR"
  git -C "$DOTS_DIR" pull --ff-only || warn "git pull 失败，继续用本地版本"
else
  log "clone $REPO_URL -> $DOTS_DIR"
  git clone --depth=1 "$REPO_URL" "$DOTS_DIR"
fi

# ============================== 3. oh-my-zsh =================================
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
if [ ! -d "$ZSH" ]; then
  log "安装 oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"

# ============================== 4. zsh 插件 ==================================
clone_or_pull() {
  # 用法: clone_or_pull <repo-url> <dest>
  local url="$1"; local dest="$2"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --ff-only --quiet || warn "更新 $dest 失败"
  else
    log "clone $(basename "$dest")"
    git clone --depth=1 --quiet "$url" "$dest"
  fi
}

clone_or_pull https://github.com/zsh-users/zsh-autosuggestions      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_pull https://github.com/zsh-users/zsh-completions          "$ZSH_CUSTOM/plugins/zsh-completions"
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# ============================== 5. tmux TPM ==================================
TPM_DIR="$HOME/.tmux/plugins/tpm"
clone_or_pull https://github.com/tmux-plugins/tpm "$TPM_DIR"

# ============================== 6. symlink 配置文件 ==========================
mkdir -p "$BACKUP_DIR"
link() {
  # 用法: link <src> <dest>
  local src="$1"; local dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      return 0
    fi
    log "备份 $dest -> $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  log "link $dest -> $src"
}

link "$DOTS_DIR/.zshrc"     "$HOME/.zshrc"
link "$DOTS_DIR/.vimrc"     "$HOME/.vimrc"
link "$DOTS_DIR/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTS_DIR/hiroken.zsh-theme" "$ZSH_CUSTOM/themes/hiroken.zsh-theme"

# 备份目录若空则删
rmdir "$BACKUP_DIR" 2>/dev/null || log "已存在文件备份至 $BACKUP_DIR"

# ============================== 7. 安装 tmux 插件 ============================
if [ -x "$TPM_DIR/bin/install_plugins" ]; then
  log "安装 tmux 插件（首次较慢）"
  "$TPM_DIR/bin/install_plugins" >/dev/null || warn "tmux 插件安装失败，可在 tmux 内按 prefix+I 重试"
fi

# ============================== 8. 切换默认 shell 到 zsh =====================
ZSH_BIN="$(command -v zsh)"
if [ -n "${SHELL:-}" ] && [ "$SHELL" != "$ZSH_BIN" ]; then
  if grep -q "^$ZSH_BIN$" /etc/shells 2>/dev/null || sudo -n true 2>/dev/null && echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null; then
    log "把默认 shell 切到 $ZSH_BIN"
    chsh -s "$ZSH_BIN" || warn "chsh 失败，请手动执行：chsh -s $ZSH_BIN"
  else
    warn "未把 zsh 加入 /etc/shells，跳过 chsh。手动执行：chsh -s $ZSH_BIN"
  fi
fi

log "全部完成 ✅"
log "现在 exec zsh 或重开终端即可生效"