#!/bin/bash

# 定义 dotfiles 所在目录
DOTFILES_DIR=$HOME/dotfiles

echo "🚀 开始同步配置文件..."

# 1. 链接 tmux
ln -sf $DOTFILES_DIR/tmux.conf $HOME/.tmux.conf

# 2. 链接 Ghostty
mkdir -p $HOME/.config/ghostty
ln -sf $DOTFILES_DIR/ghostty/config $HOME/.config/ghostty/config

# 3. 链接 Neovim (如果配置了)
mkdir -p $HOME/.config/nvim
ln -sf $DOTFILES_DIR/nvim $HOME/.config/nvim

echo "✅ 同步完成！请重启终端或执行 source ~/.tmux.conf"
