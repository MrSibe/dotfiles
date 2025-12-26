#!/usr/bin/env bash
#
# bootstrap.sh - GNU Stow dotfiles management script
# Usage: ./bootstrap.sh [OPTIONS] [PACKAGES...]
#

set -e

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
STOW_DIR="$DOTFILES_DIR"
TARGET_DIR="$HOME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Available packages (subdirectories in dotfiles)
AVAILABLE_PACKAGES=("tmux" "ghostty" "nvim")

# Function to print colored messages
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if stow is installed
check_stow() {
    if ! command -v stow &> /dev/null; then
        error "GNU Stow is not installed!"
        echo ""
        echo "Install it with:"
        echo "  macOS:   brew install stow"
        echo "  Ubuntu:  sudo apt install stow"
        echo "  Arch:    sudo pacman -S stow"
        exit 1
    fi
}

# Function to validate package exists
validate_package() {
    local pkg="$1"
    if [[ ! -d "$STOW_DIR/$pkg" ]]; then
        error "Package '$pkg' not found in $STOW_DIR"
        return 1
    fi
    return 0
}

# Function to stow a package
stow_package() {
    local pkg="$1"
    local dry_run="$2"

    if ! validate_package "$pkg"; then
        return 1
    fi

    local stow_cmd="stow --dotfiles -d \"$STOW_DIR\" -t \"$TARGET_DIR\""

    if [[ "$dry_run" == "true" ]]; then
        stow_cmd="$stow_cmd --no"
        info "DRY RUN: Would stow package '$pkg'"
    else
        info "Stowing package '$pkg'..."
    fi

    if eval "$stow_cmd \"$pkg\"" 2>&1; then
        if [[ "$dry_run" != "true" ]]; then
            success "Package '$pkg' stowed successfully"
        fi
        return 0
    else
        error "Failed to stow package '$pkg'"
        return 1
    fi
}

# Function to unstow a package
unstow_package() {
    local pkg="$1"
    local dry_run="$2"

    if ! validate_package "$pkg"; then
        return 1
    fi

    local stow_cmd="stow --dotfiles -D -d \"$STOW_DIR\" -t \"$TARGET_DIR\""

    if [[ "$dry_run" == "true" ]]; then
        stow_cmd="$stow_cmd --no"
        info "DRY RUN: Would unstow package '$pkg'"
    else
        info "Unstowing package '$pkg'..."
    fi

    if eval "$stow_cmd \"$pkg\"" 2>&1; then
        if [[ "$dry_run" != "true" ]]; then
            success "Package '$pkg' unstowed successfully"
        fi
        return 0
    else
        error "Failed to unstow package '$pkg'"
        return 1
    fi
}

# Function to restow a package (useful after updates)
restow_package() {
    local pkg="$1"
    local dry_run="$2"

    if ! validate_package "$pkg"; then
        return 1
    fi

    local stow_cmd="stow --dotfiles -R -d \"$STOW_DIR\" -t \"$TARGET_DIR\""

    if [[ "$dry_run" == "true" ]]; then
        stow_cmd="$stow_cmd --no"
        info "DRY RUN: Would restow package '$pkg'"
    else
        info "Restowing package '$pkg'..."
    fi

    if eval "$stow_cmd \"$pkg\"" 2>&1; then
        if [[ "$dry_run" != "true" ]]; then
            success "Package '$pkg' restowed successfully"
        fi
        return 0
    else
        error "Failed to restow package '$pkg'"
        return 1
    fi
}

# Function to list available packages
list_packages() {
    echo ""
    echo "Available packages:"
    for pkg in "${AVAILABLE_PACKAGES[@]}"; do
        if [[ -d "$STOW_DIR/$pkg" ]]; then
            echo "  - $pkg"
        fi
    done
    echo ""
}

# Function to show status of stowed packages
show_status() {
    echo ""
    info "Checking package status..."
    echo ""

    for pkg in "${AVAILABLE_PACKAGES[@]}"; do
        if [[ ! -d "$STOW_DIR/$pkg" ]]; then
            continue
        fi

        echo "Package: $pkg"

        # Check if package is stowed by looking for symlinks
        local is_stowed=false

        case "$pkg" in
            tmux)
                if [[ -L "$HOME/.tmux.conf" ]] && [[ "$(readlink "$HOME/.tmux.conf")" == *"dotfiles/tmux"* ]]; then
                    is_stowed=true
                fi
                ;;
            ghostty)
                if [[ -L "$HOME/.config/ghostty/config" ]] && [[ "$(readlink "$HOME/.config/ghostty/config")" == *"dotfiles/ghostty"* ]]; then
                    is_stowed=true
                fi
                ;;
            nvim)
                if [[ -L "$HOME/.config/nvim" ]] && [[ "$(readlink "$HOME/.config/nvim")" == *"dotfiles/nvim"* ]]; then
                    is_stowed=true
                fi
                ;;
        esac

        if [[ "$is_stowed" == "true" ]]; then
            echo -e "  Status: ${GREEN}STOWED${NC}"
        else
            echo -e "  Status: ${YELLOW}NOT STOWED${NC}"
        fi
        echo ""
    done
}

# Function to display usage
usage() {
    cat << EOF
Usage: ./bootstrap.sh [OPTIONS] [PACKAGES...]

Manage dotfiles using GNU Stow.

OPTIONS:
    -h, --help          Show this help message
    -l, --list          List available packages
    -s, --status        Show status of all packages
    -d, --dry-run       Perform a dry run (no actual changes)
    -u, --unstow        Unstow packages instead of stowing
    -r, --restow        Restow packages (remove and re-add)
    -a, --all           Apply action to all packages

PACKAGES:
    One or more package names to operate on (tmux, ghostty, nvim)
    If no packages specified and --all not used, all packages are processed

EXAMPLES:
    # Install all packages
    ./bootstrap.sh --all
    or
    ./bootstrap.sh

    # Install specific packages
    ./bootstrap.sh tmux nvim

    # Dry run to preview changes
    ./bootstrap.sh --dry-run --all

    # Unstow a package
    ./bootstrap.sh --unstow ghostty

    # Restow all packages (useful after updates)
    ./bootstrap.sh --restow --all

    # Check status
    ./bootstrap.sh --status

EOF
}

# Main function
main() {
    local action="stow"
    local dry_run="false"
    local packages=()
    local all_packages="false"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -l|--list)
                list_packages
                exit 0
                ;;
            -s|--status)
                show_status
                exit 0
                ;;
            -d|--dry-run)
                dry_run="true"
                shift
                ;;
            -u|--unstow)
                action="unstow"
                shift
                ;;
            -r|--restow)
                action="restow"
                shift
                ;;
            -a|--all)
                all_packages="true"
                shift
                ;;
            -*)
                error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                packages+=("$1")
                shift
                ;;
        esac
    done

    # Check if stow is installed
    check_stow

    # Determine which packages to process
    if [[ "$all_packages" == "true" ]] || [[ ${#packages[@]} -eq 0 ]]; then
        packages=("${AVAILABLE_PACKAGES[@]}")
    fi

    # Display header
    echo ""
    echo "=================================="
    echo "  Dotfiles Management (Stow)"
    echo "=================================="
    echo ""

    if [[ "$dry_run" == "true" ]]; then
        warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    # Process packages
    local success_count=0
    local fail_count=0

    for pkg in "${packages[@]}"; do
        case "$action" in
            stow)
                if stow_package "$pkg" "$dry_run"; then
                    ((success_count++))
                else
                    ((fail_count++))
                fi
                ;;
            unstow)
                if unstow_package "$pkg" "$dry_run"; then
                    ((success_count++))
                else
                    ((fail_count++))
                fi
                ;;
            restow)
                if restow_package "$pkg" "$dry_run"; then
                    ((success_count++))
                else
                    ((fail_count++))
                fi
                ;;
        esac
    done

    # Summary
    echo ""
    echo "=================================="
    echo "Summary:"
    echo "  Success: $success_count"
    echo "  Failed:  $fail_count"
    echo "=================================="
    echo ""

    if [[ "$fail_count" -eq 0 ]]; then
        success "All operations completed successfully!"

        if [[ "$action" == "stow" ]] && [[ "$dry_run" != "true" ]]; then
            echo ""
            info "Your dotfiles are now managed with GNU Stow"
            info "To reload configurations:"
            echo "  - tmux: Press Prefix + r (Ctrl-a r) in tmux"
            echo "  - nvim: Restart Neovim"
            echo "  - ghostty: Restart Ghostty terminal"
        fi
    else
        warn "Some operations failed. Please check the errors above."
        exit 1
    fi
}

# Run main function
main "$@"
