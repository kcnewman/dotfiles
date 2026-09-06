#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Applying dotfiles from: $ROOT"

# ------------------------------------------------------------
# Directories
# ------------------------------------------------------------

mkdir -p \
  "$HOME/.config" \
  "$HOME/.config/zed" \
  "$HOME/.local/bin" \
  "$HOME/.local/share/vicinae/scripts"

# ------------------------------------------------------------
# Shell
# ------------------------------------------------------------

cp "$ROOT/shell/zshrc" "$HOME/.zshrc"
cp "$ROOT/starship/starship.toml" "$HOME/.config/starship.toml"

if [[ -f "$ROOT/bin/localsend-share" ]]; then
  cp "$ROOT/bin/localsend-share" \
    "$HOME/.local/bin/localsend-share"

  chmod +x "$HOME/.local/bin/localsend-share"
fi

# Ubuntu command-name compatibility
if command -v batcat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if command -v fdfind >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# ------------------------------------------------------------
# Zed
# ------------------------------------------------------------

cp "$ROOT/zed/settings.json" "$HOME/.config/zed/settings.json"
cp "$ROOT/zed/keymap.json" "$HOME/.config/zed/keymap.json"
cp "$ROOT/zed/tasks.json" "$HOME/.config/zed/tasks.json"

# ------------------------------------------------------------
# Vicinae scripts
# ------------------------------------------------------------

cp -a "$ROOT/vicinae/scripts/." \
  "$HOME/.local/share/vicinae/scripts/"

find "$HOME/.local/share/vicinae/scripts" \
  -type f -exec chmod +x {} +

# ------------------------------------------------------------
# GNOME
# ------------------------------------------------------------

if command -v dconf >/dev/null 2>&1; then
  dconf load /org/gnome/desktop/interface/ \
    < "$ROOT/gnome/interface.ini"

  dconf load /org/gnome/desktop/wm/keybindings/ \
    < "$ROOT/gnome/keybindings.ini"

  dconf load /org/gnome/settings-daemon/plugins/media-keys/ \
    < "$ROOT/gnome/media-keys.ini"

  dconf load /org/gnome/shell/keybindings/ \
    < "$ROOT/gnome/shell-keybindings.ini"

  dconf load /org/gnome/mutter/ \
    < "$ROOT/gnome/mutter.ini"

  dconf load /org/gnome/desktop/wm/preferences/ \
    < "$ROOT/gnome/wm-preferences.ini"

  dconf load /org/gnome/shell/extensions/dash-to-dock/ \
    < "$ROOT/gnome/dash-to-dock.ini"

  dconf load /org/gnome/shell/extensions/just-perfection/ \
    < "$ROOT/gnome/just-perfection.ini"

  dconf load /org/gnome/shell/extensions/blur-my-shell/ \
    < "$ROOT/gnome/blur-my-shell.ini"

  dconf load /org/gnome/shell/extensions/compact-top-bar/ \
    < "$ROOT/gnome/compact-top-bar.ini"

  dconf load /org/gnome/shell/extensions/vitals/ \
    < "$ROOT/gnome/vitals.ini"

  dconf load /org/gnome/shell/extensions/kiwimenu/ \
    < "$ROOT/gnome/kiwimenu.ini"

  if [[ -f "$ROOT/gnome/dynamic-music-pill.ini" ]]; then
    dconf load /org/gnome/shell/extensions/dynamic-music-pill/ \
      < "$ROOT/gnome/dynamic-music-pill.ini"
  fi
fi

# Freeby
if command -v dconf >/dev/null 2>&1 && [[ -f "$ROOT/gnome/freeby.ini" ]]; then
  dconf load /org/gnome/shell/extensions/freeby/     < "$ROOT/gnome/freeby.ini"
fi

# ------------------------------------------------------------
# Services
# ------------------------------------------------------------

if systemctl --user list-unit-files vicinae.service \
    >/dev/null 2>&1; then
  systemctl --user enable vicinae.service
fi

if systemctl list-unit-files docker.socket \
    >/dev/null 2>&1; then
  sudo systemctl disable docker.service containerd.service || true
  sudo systemctl enable docker.socket
fi

echo
echo "Configuration applied."
echo "Log out and back in for all GNOME changes to take effect."

# Git defaults
mkdir -p "$HOME/.config/git"
cp "$ROOT/git/config" "$HOME/.config/git/config"

# ------------------------------------------------------------
# Git
# ------------------------------------------------------------

mkdir -p "$HOME/.config/git"
cp "$ROOT/git/config" "$HOME/.config/git/config"

# ------------------------------------------------------------
# Ptyxis
# ------------------------------------------------------------

mkdir -p "$HOME/.local/share/org.gnome.Ptyxis/palettes"

if [[ -f "$ROOT/ptyxis/palettes/omarchy.palette" ]]; then
  cp "$ROOT/ptyxis/palettes/omarchy.palette" \
    "$HOME/.local/share/org.gnome.Ptyxis/palettes/omarchy.palette"
fi

# ------------------------------------------------------------
# Application overrides
# ------------------------------------------------------------

mkdir -p "$HOME/.local/share/applications"

if [[ -f "$ROOT/applications/org.localsend.localsend_app.desktop" ]]; then
  cp "$ROOT/applications/org.localsend.localsend_app.desktop" \
    "$HOME/.local/share/applications/"
fi

if [[ -f "$ROOT/applications/localsend_app.desktop" ]]; then
  cp "$ROOT/applications/localsend_app.desktop" \
    "$HOME/.local/share/applications/"
fi

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" || true
fi

echo
echo "Configuration applied."
echo "Log out and back in for all GNOME changes to take effect."
