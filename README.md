# Hiroken's Dotsfile

一套轻量、跨平台、远端/容器友好的终端配置。

## 目录

-   [快速部署](#快速部署)
-   [文件说明](#文件说明)
-   [功能详解](#功能详解)
    -   [Zsh / Oh-My-Zsh](#zsh--oh-my-zsh)
    -   [Tmux](#tmux)
    -   [Vim](#vim)

---

## 快速部署

```bash
curl -fsSL https://raw.githubusercontent.com/HirokenOvo/dotsfile/main/bootstrap.sh | bash
```

脚本会自动做：

1. 装系统依赖（`zsh`/`git`/`vim`/`tmux`/`fzf`/`ripgrep`）
2. 装 oh-my-zsh
3. 装所需 zsh/tmux 插件
4. symlink 配置到 `$HOME`（旧文件自动备份到 `~/.dotsfile.backup.<时间戳>/`）
5. 切默认 shell 到 zsh

本地已 clone 仓库时直接：

```bash
bash bootstrap.sh
```

---

## 文件说明

| 文件                | 作用                                |
| ------------------- | ----------------------------------- |
| `.zshrc`            | zsh + oh-my-zsh 配置                |
| `.zsh_aliases`      | 你自己的别名（可选择性 `git add`）  |
| `.zshrc.local`      | 机器私有配置（建议加 `.gitignore`） |
| `.tmux.conf`        | tmux 配置 + catppuccin 主题         |
| `.vimrc`            | 纯内置、无插件、远端友好 vim        |
| `hiroken.zsh-theme` | 自定义 zsh 主题                     |
| `VIM_CHEATSHEET.md` | Vim 完整速查卡                      |
| `bootstrap.sh`      | 一键部署脚本                        |

---

## 功能详解

### Zsh / Oh-My-Zsh

#### 主题与 Prompt

-   `ZSH_THEME=hiroken`：轻量自定义主题，含 git 分支、命令执行耗时、虚拟环境标记
-   `⏱️ <时间>`：上一条命令耗时（跨平台兼容 `zmodload zsh/datetime`）
-   无宽字符依赖，终端通用

#### 插件与功能

-   `git`：git 别名（`gst`/`gco`/`gp`/`gl`…）
-   `virtualenv`：prompt 显示当前 venv 名
-   `z`：`z foo` 智能跳到最近常去的含 `foo` 的目录
-   `extract`：`x file.tar.gz` 一键解压所有格式
-   `colored-man-pages`：man 页面彩色显示
-   `sudo`：双击 `Esc` 在当前命令前加 `sudo`
-   `copypath`：`copypath` 把当前路径复制到剪贴板
-   `copyfile`：`copyfile <file>` 复制文件内容到剪贴板
-   `copybuffer`：`Ctrl+O` 复制当前命令行
-   `dirhistory`：`Alt+←`/`Alt+→` 浏览 cd 历史栈
-   `fzf`：`Ctrl+R` 模糊搜历史，`Ctrl+T` 模糊选文件
-   `zsh-completions`：扩展命令补全
-   `zsh-autosuggestions`：历史灰字补全
-   `zsh-syntax-highlighting`：实时语法高亮（错误命令立红）

#### 键位

| 键                | 作用                                  |
| ----------------- | ------------------------------------- |
| `Ctrl+Space`      | 接受完整 autosuggest                  |
| `Alt+→` / `Alt+f` | 接受 autosuggest 下一个词             |
| `→`               | 仅移动光标（保留默认行为）            |
| `Esc Esc`         | 清搜索高亮（zsh-syntax-highlighting） |

#### 目录跳转与历史

| 功能                                   | 说明                        |
| -------------------------------------- | --------------------------- |
| `AUTO_CD`                              | 直接打目录名就 cd 进去      |
| `AUTO_PUSHD`                           | cd 自动入栈，`dirs -v` 查看 |
| `HISTSIZE=100000` / `SAVEHIST=100000`  | 大历史量                    |
| `SHARE_HISTORY` + `INC_APPEND_HISTORY` | 多终端实时共享              |
| `HIST_IGNORE_SPACE`                    | 行首空格的命令不入历史      |
| `ENABLE_CORRECTION`                    | 拼错命令时问 [n/y/a/e]      |

#### 语法高亮配色

| 类型                                   | 颜色                    |
| -------------------------------------- | ----------------------- |
| `builtin`/`command`/`function`/`alias` | 蓝                      |
| `path`                                 | 青 + 下划线             |
| `unknown-token`                        | 红 + 粗（错误命令立显） |
| `comment`                              | 暗灰（fg=240）          |

---

### Tmux

#### Prefix

-   `Prefix = Ctrl+a`
-   `Prefix r`：热重载配置

#### 窗口（Window）

| 键             | 作用                 |
| -------------- | -------------------- |
| `Prefix c`     | 新建窗口             |
| `Prefix 1`…`9` | 跳到第 n 个窗口      |
| `Prefix w`     | 窗口列表（树状选择） |
| `Prefix ,`     | 重命名窗口           |
| `Prefix &`     | 关闭当前窗口         |
| `Prefix Tab`   | 在前后两窗口间切换   |

#### 面板（Pane）

| 键                       | 作用                       |
| ------------------------ | -------------------------- |
| `Prefix -` / `Prefix \|` | 横 / 竖分屏                |
| `Prefix h/j/k/l`         | 移动到面板                 |
| `Prefix H/J/K/L`         | 调整面板大小               |
| `Prefix z`               | 最大化/恢复当前面板        |
| `Prefix x`               | 关闭当前面板               |
| `Prefix o`               | 在面板间轮询               |
| `Prefix q`               | 显示面板编号               |
| `Prefix [`               | 进入 copy-mode（选字复制） |

#### Copy-Mode（`Prefix [`）

-   按 `vi` 模式移动，`Space` 开始选，`Enter` 复制（自动到系统剪贴板）
-   `o`：打开 URL（需 `tmux-open`）
-   `y`：复制到系统剪贴板（需 `tmux-yank`）

#### 主题与状态栏

-   主题：`catppuccin/tmux#v2.3.0`（mocha flavor）
-   位置：底部（`status-position bottom`）
-   左侧：仅 `session` 名
-   右侧：`directory` + `date_time`（`%Y-%m-%d %H:%M`）
-   `connect_separator=yes`：圆角模块连为一条，避免裁剪

#### TPM 插件

-   `tmux-plugins/tpm`：插件管理器
-   `tmux-plugins/tmux-resurrect`：`Prefix Ctrl-s` 保存，`Prefix Ctrl-r` 恢复会话
-   `tmux-plugins/tmux-continuum`：自动定时保存/恢复
-   `tmux-plugins/tmux-yank`：copy-mode 复制到系统剪贴板
-   `tmux-plugins/tmux-open`：copy-mode `o` 开 URL
-   `sainnhe/tmux-fzf`：`Prefix f` 用 fzf 选 window/pane/session/…

---

### Vim

详见独立文件 [VIM_CHEATSHEET.md](./VIM_CHEATSHEET.md)，带 ★ 是本配置自定义。

#### 核心原则

-   **纯内置，零插件**：容器/远端开箱即用，无 `vim-plug` 等依赖
-   用 `path=.,**` + `:find` + `:grep` + `ripgrep` 实现项目级查找

#### 自定义键位（高频）

| 键                            | 作用                                    |
| ----------------------------- | --------------------------------------- |
| `Space`                       | 当前折叠块开/合                         |
| `,f`                          | `:find ` 全项目找文件（Tab 补全）       |
| `,g`                          | `:grep ` 全项目搜内容（自动用 ripgrep） |
| `,e`                          | `:Lex` 左侧文件树开关                   |
| `,b`                          | `:ls` buffer 列表                       |
| `,n` / `,p`                   | 下 / 上一个 buffer                      |
| `,d`                          | 关当前 buffer                           |
| `,w` / `,q`                   | 保存 / 退出                             |
| `Esc Esc` / `,h`              | 清搜索高亮                              |
| `Alt+Shift+↑` / `Alt+Shift+↓` | 往上/下复制一行                         |

#### 远端友好的设置

| 选项                              | 作用                         |
| --------------------------------- | ---------------------------- |
| `set undofile`                    | 持久撤销（关了再开还能 `u`） |
| `set clipboard=unnamed`           | `y/p` 自动通系统剪贴板       |
| `set path=.,**`                   | `:find` 搜全项目             |
| `set wildmenu`                    | `:` 后按 Tab 可视补全菜单    |
| `set nobackup` / `set noswapfile` | 不生成乱七八糟的文件         |
| `autochdir`                       | 自动切到当前文件目录         |
| `filetype plugin indent on`       | 按文件类型加载插件/缩进      |
