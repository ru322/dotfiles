bindkey '^R' history-incremental-search-backward

# Ctrl+Rで履歴検索
bindkey '^R' history-incremental-search-backward

# 入力中の文字列で始まる履歴を↑↓で検索
autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Home / End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Deleteキー
bindkey '^[[3~' delete-char

# Ctrl+左右で単語単位に移動
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

function gcd() {
  local dir
  dir="$(ghq list -p | fzf)" && cd "$dir"
}
