# Ubuntu Workstation Dotfiles

Configuration for my Ubuntu workstation.

This repository captures the parts of the system that are intentional and
reproducible, without storing application state, browser profiles, credentials,
or caches.

## Included

- Zsh configuration
- Starship prompt
- Zed settings and keymaps
- Vicinae script commands
- GNOME keyboard shortcuts
- GNOME workspace configuration
- Ubuntu Dock configuration
- Just Perfection
- Blur My Shell
- Compact Top Bar
- Vitals
- Kiwi Menu
- Dynamic Music Pill visual settings
- Package snapshots
- Service configuration notes

## Keyboard Workflow

- `Super + Space` — Vicinae command center
- `Super + Enter` — Terminal
- `Super + Q` — Close current window
- `Super + 1..4` — Switch to workspace 1–4
- `Super + Shift + 1..4` — Move current window to workspace 1–4
- `Super + K` — Cast screen
- `Alt + Tab` — Switch windows
- `Super + Tab` — Switch applications

The desktop uses four fixed GNOME workspaces.

## Terminal

Default terminal:

- Ubuntu terminal / Ptyxis

Shell:

- Zsh
- Oh My Zsh
- Starship

CLI tools:

- zoxide
- fzf
- ripgrep
- fd
- bat
- eza
- git
- curl

Development runtimes:

- uv for Python projects, virtual environments, and Python tooling
- fnm for Node.js
- Ubuntu system Python is left untouched

AI CLI tools:

- Codex
- OpenCode
- Claude Code

## Editor

Zed is the primary editor.

Tracked configuration:

- `zed/settings.json`
- `zed/keymap.json`
- `zed/tasks.json`

VS Code is also kept on the workstation but is not the primary editor.

## Vicinae

Vicinae provides the main keyboard-first command center and is opened with
`Super + Space`.

Tracked custom project commands:

- Open project in Zed
- Open project in Terminal
- Open project with Codex
- Open project with OpenCode

Only custom scripts are tracked. Vicinae indexes, clipboard data, databases,
runtime files, and caches are excluded.

## GNOME

The repository stores selected dconf configuration for:

- Interface appearance
- Window-manager keybindings
- Custom keyboard shortcuts
- Shell keybindings
- Workspace behavior
- Ubuntu Dock
- Just Perfection
- Blur My Shell
- Compact Top Bar
- Vitals
- Kiwi Menu
- Dynamic Music Pill

The current extension IDs are recorded in:

`gnome/extensions.txt`

Extension configuration files preserve settings, but the repository does not
assume that every GNOME extension is already installed.

## Desktop Philosophy

The workstation is intended to remain:

- Ubuntu-based
- GNOME-native
- keyboard-first
- visually clean
- lightweight when idle
- familiar rather than heavily customized
- reproducible without turning configuration into a maintenance project

The setup borrows useful workflow ideas from Omarchy without attempting to
reproduce Omarchy itself.

## Package Management

Preferred application/package sources:

- APT for system packages
- Flatpak for suitable desktop applications
- uv for Python runtimes and tooling
- fnm for Node.js runtimes

Snap is intentionally not part of the current setup.

Package snapshots are stored under:

- `packages/apt-manual.txt`
- `packages/flatpaks.txt`

`apt-manual.txt` is an audit snapshot and should not automatically be treated
as a list of packages that must all be installed.

A smaller curated base list is stored in:

- `packages/core-apt.txt`

## Services

Vicinae runs as an enabled user service.

Docker uses socket activation:

- `docker.socket` — enabled
- `docker.service` — disabled at boot
- `containerd.service` — disabled at boot

Running a Docker command starts Docker and containerd when needed.

Ollama is intentionally not installed.

## Restore

After cloning the repository and installing the required applications,
packages, and GNOME extensions, apply the stored configuration with:

    ./setup/apply.sh

The restore script applies configuration but intentionally does not blindly
install third-party software.

Some GNOME configuration changes may require logging out and back in.

## Repository Layout

    dotfiles/
    ├── gnome/
    │   ├── blur-my-shell.ini
    │   ├── compact-top-bar.ini
    │   ├── dash-to-dock.ini
    │   ├── dynamic-music-pill.ini
    │   ├── extensions.txt
    │   ├── interface.ini
    │   ├── just-perfection.ini
    │   ├── keybindings.ini
    │   ├── kiwimenu.ini
    │   ├── media-keys.ini
    │   ├── mutter.ini
    │   ├── shell-keybindings.ini
    │   ├── vitals.ini
    │   └── wm-preferences.ini
    ├── packages/
    │   ├── apt-manual.txt
    │   ├── core-apt.txt
    │   └── flatpaks.txt
    ├── setup/
    │   ├── apply.sh
    │   └── services.txt
    ├── shell/
    │   └── zshrc
    ├── starship/
    │   └── starship.toml
    ├── vicinae/
    │   └── scripts/
    └── zed/
        ├── keymap.json
        ├── settings.json
        └── tasks.json

## Not Tracked

The repository intentionally does not contain:

- SSH private keys
- GPG keys
- API keys or tokens
- `.env` files
- browser profiles
- browser history
- browser cookies
- AI-agent conversations or sessions
- clipboard history
- application caches
- Vicinae runtime/index data
- generated Node or Python environments
- entire copies of `~/.config`

## Legacy Configuration

The previous Ubuntu configuration snapshot is archived separately under:

`~/archives/system/ubuntu-config-legacy`

It is retained as historical reference rather than used as the active
configuration source.

## Goal

A fresh Ubuntu installation should eventually be recoverable as:

    install core software
            ↓
    clone this repository
            ↓
    run setup checks
            ↓
    apply configuration
            ↓
    log back in
            ↓
    familiar workstation restored

The repository should document deliberate choices, not every piece of state
that happens to exist on the machine.
