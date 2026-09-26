#!/usr/bin/env bash
# ==============================================================================
# UBUNTU MACOS-STYLE UX CONFIGURATION SCRIPT
# Run this on a local Ubuntu Desktop (GNOME) session.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. REVERSE MOUSE SCROLL DIRECTION (NATURAL SCROLLING)
# ------------------------------------------------------------------------------

# Enable Natural Scrolling (matches macOS direction):
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true

# RESET to default (Standard scrolling):
# gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false


# ------------------------------------------------------------------------------
# 2. KEY SWAP (CONTROL - OPTION - COMMAND LAYOUT)
# ------------------------------------------------------------------------------

# Swap Left Alt and Left Windows/Super key:
# Changes physical bottom row from [Ctrl - Win - Alt] to [Control - Option - Command]
gsettings set org.gnome.desktop.input-sources xkb-options "['altwin:swap_lalt_lwin']"

# RESET to default key assignments:
# gsettings reset org.gnome.desktop.input-sources xkb-options

# ------------------------------------------------------------------------------
# 3. TERMINAL COPY & PASTE SHORTCUTS (COMMAND + C / COMMAND + V)
# ------------------------------------------------------------------------------


# Option A: Via gsettings (for standard GNOME Terminal)
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy '<Super>c' 2>/dev/null
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste '<Super>v' 2>/dev/null

# Option B: Via dconf direct write (if gsettings schema isn't resolved)
dconf write /org/gnome/terminal/legacy/keybindings/copy "'<Super>c'"
dconf write /org/gnome/terminal/legacy/keybindings/paste "'<Super>v'"

# RESET Terminal shortcuts to default (Ctrl+Shift+C / Ctrl+Shift+V):
# gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy
# gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste
# dconf reset /org/gnome/terminal/legacy/keybindings/copy
# dconf reset /org/gnome/terminal/legacy/keybindings/paste
