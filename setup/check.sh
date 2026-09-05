#!/usr/bin/env bash

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ok()   { printf '  ✓ %s\n' "$1"; }
miss() { printf '  ✗ %s\n' "$1"; }
warn() { printf '  ! %s\n' "$1"; }

command_check() {
  local cmd="$1"
  local label="${2:-$1}"

  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$label"
  else
    miss "$label"
  fi
}

echo
echo "Ubuntu Workstation Check"
echo "========================"

# ------------------------------------------------------------
# Shell
# ------------------------------------------------------------

echo
echo "Shell"

command_check zsh
command_check starship
command_check zoxide
command_check fzf
command_check rg "ripgrep"
command_check eza
command_check bat
command_check fd

if [[ "${SHELL:-}" == */zsh ]]; then
  ok "Zsh is default shell"
else
  warn "Default shell is ${SHELL:-unknown}"
fi

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  ok "Oh My Zsh"
else
  miss "Oh My Zsh"
fi

# ------------------------------------------------------------
# Runtime managers
# ------------------------------------------------------------

echo
echo "Runtime Managers"

command_check uv
command_check fnm

# ------------------------------------------------------------
# Development / AI tools
# ------------------------------------------------------------

echo
echo "Development Tools"

command_check git
command_check docker
command_check zed
command_check codex
command_check opencode
command_check claude "Claude Code"

# ------------------------------------------------------------
# Desktop applications
# ------------------------------------------------------------

echo
echo "Desktop"

if command -v vicinae >/dev/null 2>&1 ||
   [[ -x /usr/local/bin/vicinae ]] ||
   [[ -d /usr/local/lib/vicinae ]]; then
  ok "Vicinae"
else
  miss "Vicinae"
fi

command_check flatpak

# ------------------------------------------------------------
# Flatpaks
# ------------------------------------------------------------

echo
echo "Flatpak Applications"

if command -v flatpak >/dev/null 2>&1 &&
   [[ -f "$ROOT/packages/flatpaks.txt" ]]; then

  while IFS= read -r app; do
    [[ -z "$app" ]] && continue

    if flatpak info "$app" >/dev/null 2>&1; then
      ok "$app"
    else
      miss "$app"
    fi
  done < "$ROOT/packages/flatpaks.txt"

else
  warn "Flatpak unavailable or flatpaks.txt missing"
fi

# ------------------------------------------------------------
# GNOME extensions
# ------------------------------------------------------------

echo
echo "GNOME Extensions"

if command -v gnome-extensions >/dev/null 2>&1 &&
   [[ -f "$ROOT/gnome/extensions.txt" ]]; then

  installed_extensions="$(gnome-extensions list 2>/dev/null || true)"

  while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue

    if grep -Fxq "$ext" <<< "$installed_extensions"; then
      if gnome-extensions info "$ext" 2>/dev/null |
           grep -q 'State: ACTIVE'; then
        ok "$ext"
      else
        warn "$ext installed but not active"
      fi
    else
      miss "$ext"
    fi
  done < "$ROOT/gnome/extensions.txt"

else
  warn "GNOME extension tooling unavailable"
fi

# ------------------------------------------------------------
# Configuration files
# ------------------------------------------------------------

echo
echo "Configuration"

[[ -f "$HOME/.zshrc" ]] &&
  ok "~/.zshrc" ||
  miss "~/.zshrc"

[[ -f "$HOME/.config/starship.toml" ]] &&
  ok "~/.config/starship.toml" ||
  miss "~/.config/starship.toml"

[[ -f "$HOME/.config/zed/settings.json" ]] &&
  ok "Zed settings" ||
  miss "Zed settings"

[[ -d "$HOME/.local/share/vicinae/scripts" ]] &&
  ok "Vicinae scripts" ||
  miss "Vicinae scripts"

# ------------------------------------------------------------
# User services
# ------------------------------------------------------------

echo
echo "User Services"

if systemctl --user is-enabled vicinae.service \
     >/dev/null 2>&1; then
  ok "vicinae.service enabled"
else
  miss "vicinae.service not enabled"
fi

if systemctl --user is-active vicinae.service \
     >/dev/null 2>&1; then
  ok "vicinae.service active"
else
  warn "vicinae.service not active"
fi

# ------------------------------------------------------------
# Docker
# ------------------------------------------------------------

echo
echo "Docker"

if systemctl is-enabled docker.socket \
     >/dev/null 2>&1; then
  ok "docker.socket enabled"
else
  miss "docker.socket not enabled"
fi

if [[ "$(systemctl is-enabled docker.service 2>/dev/null)" == "disabled" ]]; then
  ok "docker.service disabled at boot"
else
  warn "docker.service is not disabled at boot"
fi

if [[ "$(systemctl is-enabled containerd.service 2>/dev/null)" == "disabled" ]]; then
  ok "containerd.service disabled at boot"
else
  warn "containerd.service is not disabled at boot"
fi

# ------------------------------------------------------------
# Workspaces / GNOME basics
# ------------------------------------------------------------

echo
echo "GNOME Workspace"

if command -v gsettings >/dev/null 2>&1; then

  dynamic="$(
    gsettings get org.gnome.mutter dynamic-workspaces \
      2>/dev/null || true
  )"

  count="$(
    gsettings get org.gnome.desktop.wm.preferences num-workspaces \
      2>/dev/null || true
  )"

  if [[ "$dynamic" == "false" ]]; then
    ok "Dynamic workspaces disabled"
  else
    warn "Dynamic workspaces enabled"
  fi

  if [[ "$count" == "4" ]]; then
    ok "4 fixed workspaces"
  else
    warn "Workspace count: ${count:-unknown}"
  fi

fi

# ------------------------------------------------------------
# Legacy / unwanted software
# ------------------------------------------------------------

echo
echo "Cleanup"

if command -v ollama >/dev/null 2>&1 ||
   systemctl status ollama.service >/dev/null 2>&1; then
  warn "Ollama still present"
else
  ok "Ollama absent"
fi

if pgrep -x ulauncher >/dev/null 2>&1; then
  warn "Ulauncher running"
else
  ok "Ulauncher absent"
fi

if pgrep -x copyq >/dev/null 2>&1; then
  warn "CopyQ running"
else
  ok "CopyQ absent"
fi

# ------------------------------------------------------------
# Resources
# ------------------------------------------------------------

echo
echo "System"

printf '  RAM:  '
free -h | awk '/^Mem:/ {
  print $3 " used / " $2 " total, " $7 " available"
}'

printf '  Disk: '
df -h / | awk 'NR==2 {
  print $3 " used / " $2 " total, " $4 " available"
}'

echo
