# Dotfiles

个人终端开发环境配置文件，使用 [GNU Stow](https://www.gnu.org/software/stow/) 进行管理。

## 包含的配置

- **tmux**: 终端复用器，使用 Vim 风格快捷键
- **ghostty**: 现代化终端模拟器配置
- **nvim**: Neovim 编辑器，基于 LazyVim 的完整 IDE 体验

## 快速开始

### 前置要求

```bash
# 安装 GNU Stow
brew install stow  # macOS
# sudo apt install stow  # Ubuntu/Debian
# sudo pacman -S stow    # Arch Linux
```

### 安装

1. 克隆此仓库：
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. 安装所有配置：
```bash
./bootstrap.sh
```

或安装特定包：
```bash
./bootstrap.sh tmux nvim
```

### 预览更改（Dry Run）

在实际应用更改之前，可以先预览：
```bash
./bootstrap.sh --dry-run --all
```

## 管理命令

### 安装包
```bash
# 安装所有包
./bootstrap.sh --all

# 安装特定包
./bootstrap.sh tmux ghostty
```

### 卸载包
```bash
# 移除特定包
./bootstrap.sh --unstow nvim

# 移除所有包
./bootstrap.sh --unstow --all
```

### 更新包
修改仓库中的配置后，重新 stow 以更新软链接：
```bash
# 重装所有包
./bootstrap.sh --restow --all

# 重装特定包
./bootstrap.sh --restow tmux
```

### 检查状态
```bash
./bootstrap.sh --status
```

### 列出可用包
```bash
./bootstrap.sh --list
```

## 仓库结构

```
dotfiles/
├── README.md                          # 本文件
├── bootstrap.sh                       # Stow 管理脚本
├── tmux/
│   └── dot-tmux.conf                 # → ~/.tmux.conf
├── ghostty/
│   └── .config/
│       └── ghostty/
│           └── config                # → ~/.config/ghostty/config
└── nvim/
    └── .config/
        └── nvim/
            ├── init.lua
            ├── lazy-lock.json
            └── lua/                   # → ~/.config/nvim/
                ├── config/
                └── plugins/
```

## GNU Stow 工作原理

GNU Stow 会从仓库创建软链接到你的 home 目录：

- 使用 `dot-` 前缀的文件会被软链接为 `.` 前缀（通过 `--dotfiles` 选项）
- 每个包内的目录结构镜像你的 `$HOME` 目录
- 示例：`tmux/dot-tmux.conf` → `~/.tmux.conf`
- 示例：`nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`

## 配置亮点

### Tmux
- 前缀键：`Ctrl-a`（替代默认的 `Ctrl-b`）
- Vim 风格窗格导航（`h`, `j`, `k`, `l`）
- 垂直分割：`Prefix + v`
- 水平分割：`Prefix + s`
- 重载配置：`Prefix + r`

### Neovim
- 基于 [LazyVim](https://www.lazyvim.org/)
- 完整的 IDE 功能：LSP、代码补全等
- 自定义按键映射在 `lua/config/keymaps.lua`

### Ghostty
- 自定义字体和透明度设置
- 背景模糊效果，现代美学

## 修改配置

1. 编辑仓库中的文件（`~/dotfiles/`）
2. 更改会立即生效（因为是软链接！）
3. 对于 tmux：使用 `Prefix + r` 重载
4. 对于 nvim/ghostty：重启应用
5. 提交并推送更改：
   ```bash
   cd ~/dotfiles
   git add .
   git commit -m "Update configuration"
   git push
   ```

## 故障排除

### 与现有文件冲突

如果你已经有现有的 dotfiles，Stow 会警告冲突：
```
WARNING! stowing tmux would cause conflicts:
  * existing target is not owned by stow: .tmux.conf
```

**解决方案**：备份并移除现有文件：
```bash
# 备份现有配置
mv ~/.tmux.conf ~/.tmux.conf.backup

# 然后重新运行 bootstrap
./bootstrap.sh tmux
```

### 软链接问题

检查哪些文件已链接：
```bash
ls -la ~ | grep "dotfiles"
ls -la ~/.config/ | grep "dotfiles"
```

### 完全卸载

```bash
./bootstrap.sh --unstow --all
```

## 添加新包

1. 创建新目录：`mkdir -p myapp/.config/myapp`
2. 添加配置：`myapp/.config/myapp/config.conf`
3. 更新 `bootstrap.sh` 中的 `AVAILABLE_PACKAGES`
4. Stow 它：`./bootstrap.sh myapp`

## 许可证

MIT License - 查看各包文件中的许可证信息。

## 参考资料

- [GNU Stow 官方网站](https://www.gnu.org/software/stow/)
- [LazyVim 文档](https://www.lazyvim.org/)
- [Tmux 文档](https://github.com/tmux/tmux/wiki)
