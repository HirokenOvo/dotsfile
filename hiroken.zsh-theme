# 使用 zsh 内置模块提供高精度时间，跨平台一致且无需 fork date 进程
zmodload zsh/datetime

typeset -g zsh_cmd_start_time  # 命令开始时间（浮点秒，EPOCHREALTIME）

function theme_precmd {
  # 计算命令耗时
  if [[ -n "$zsh_cmd_start_time" ]]; then
    local duration_ms=$(( (EPOCHREALTIME - zsh_cmd_start_time) * 1000 ))

    if (( duration_ms >= 1000 )); then
      zsh_cmd_duration=$(printf "⏳%.1fs " $(( duration_ms / 1000.0 )))
    elif (( duration_ms >= 10 )); then
      zsh_cmd_duration="⏳${duration_ms%.*}ms "
    else
      zsh_cmd_duration=""  # 极快命令不显示耗时
    fi
    zsh_cmd_start_time=""
  else
    zsh_cmd_duration=""
  fi

  local TERMWIDTH=$(( COLUMNS - ${ZLE_RPROMPT_INDENT:-1} ))

  PR_FILLBAR=""
  PR_PWDLEN=""

  # 用 dashes 占位估算 prompt 左侧装饰字符占用的可见宽度
  local promptsize=${#${(%):---(%n@%m:%l)---()--}}
  local pwdsize=${#${(%):-%~}}
  local venvpromptsize=${#$(virtualenv_prompt_info)}
  # ⏳ 是宽字符占 2 列，需用 (m) 标志按显示宽度计算才能正确对齐
  local zsh_cmd_duration_size=${(m)#zsh_cmd_duration}

  if (( promptsize + pwdsize + venvpromptsize + zsh_cmd_duration_size > TERMWIDTH )); then
    (( PR_PWDLEN = TERMWIDTH - promptsize ))
  else
    PR_FILLBAR="\${(l:$(( TERMWIDTH - (promptsize + pwdsize + venvpromptsize + zsh_cmd_duration_size) )):::)}"
  fi
}

function theme_preexec {
  zsh_cmd_start_time=$EPOCHREALTIME

  if [[ "$TERM" = "screen" ]]; then
    local CMD=${1[(wr)^(*=*|sudo|-*)]}
    echo -n "\ek$CMD\e\\"
  fi
}

autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd
add-zsh-hook preexec theme_preexec


# Set the prompt

# Need this so the prompt will work.
setopt prompt_subst

# See if we can use colors.
autoload zsh/terminfo
for color in red green yellow blue magenta cyan white grey; do
  typeset -g "PR_${(U)color}=%{$terminfo[bold]$fg[$color]%}"
  typeset -g "PR_LIGHT_${(U)color}=%{$fg[$color]%}"
done
PR_NO_COLOUR="%{$terminfo[sgr0]%}"

# Modify Git prompt
ZSH_THEME_GIT_PROMPT_PREFIX="on %{$fg[cyan]%} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} %{%GA%}"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%} %{%GM%}"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} %{%GD%}"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} %{%G➜%}"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[cyan]%} %{%G═%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[blue]%} %{%GU%}"

# Modify venv prompt
ZSH_THEME_VIRTUALENV_PREFIX="("
ZSH_THEME_VIRTUALENV_SUFFIX=") "

# 同时决定 titlebar 与 screen title
case $TERM in
  xterm*)
    PR_TITLEBAR=$'%{\e]0;%(!.-=*[ROOT]*=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\a%}'
    PR_STITLE=""
    ;;
  screen)
    PR_TITLEBAR=$'%{\e_screen \005 (\005t) | %(!.-=[ROOT]=- | .)%n@%m:%~ | ${COLUMNS}x${LINES} | %y\e\\%}'
    PR_STITLE=$'%{\ekzsh\e\\%}'
    ;;
  *)
    PR_TITLEBAR=""
    PR_STITLE=""
    ;;
esac

# Finally, the prompt.
PROMPT='${PR_STITLE}${(e)PR_TITLEBAR}\
$(virtualenv_prompt_info)${PR_GREEN}%(!.%SROOT%s.%n)${PR_NO_COLOUR}@%m:\
${PR_GREEN}%${PR_PWDLEN}<...<%~%<<\
${(e)PR_FILLBAR}\
${PR_NO_COLOUR}${zsh_cmd_duration}${PR_YELLOW}%D{%b%d} %D{%H:%M}\

%{$reset_color%}$(git_prompt_info)$(git_prompt_status)${PR_NO_COLOUR}❯ '
# display exitcode on the right when > 0
return_code="%(?..%{$fg[red]%}%? ↵ %{$reset_color%})"
RPROMPT=' $return_code'

PS2='${PR_NO_COLOUR}❯ '