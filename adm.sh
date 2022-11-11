#!/usr/bin/zsh

# TODO: Split files into config, functions, logging

# Script to switch program themes based on windows theme in WSL
# Author: Sayandip Dutta

# Usage:
#   1. Without argument
#       $ source adm.sh
#         If called without argument, theme is set according to windows registry value
#
#   2. With argument (Intended to be called by AutoDarkMode)
#       $ source adm.sh 0
#      OR
#       $ source adm.sh 1
#         Valid arguments are 0 (Dark) or 1 (Light).

# pass command line argument to functions.sh
if [ $# -ne 0 ] && { [ "$1" -eq 0 ] || [ "$1" -eq 1 ]; }; then
    source $(dirname "$0")/functions.sh "$1"
else
    source $(dirname "$0")/functions.sh
fi

# CONFIG Section
# Set program connfig paths
LAZYGIT=(~/.config/lazygit/{config.yml,light.yml,dark.yml})
NVIM=(~/.config/nvim/lua/user/{colorscheme.lua,tokyonight.light.lua,tokyonight.dark.lua})
BAT=(~/.config/bat/{bat.conf,light.conf,dark.conf})
TMUX=(~/.config/tmux/{tokyonight.tmux,tokyonight_day.tmux,tokyonight_night.tmux})
GLOW=(~/.config/glow/{glow.yml,light.yml,dark.yml})
GTKTHEME=Adwaita
IPYTHON=(~/.ipython/profile_default/{ipython_config.py,light.py,dark.py})

# FUNCTION Section
# Corresponding functions are defined in ./functions.sh
softlink "${LAZYGIT[@]}"
softlink "${BAT[@]}"
softlink "${TMUX[@]}"
tmux source-file "${TMUX[1]}"
softlink "${GLOW[@]}"

hardlink "${NVIM[@]}"
set_open_nvim_theme
hardlink "${IPYTHON[@]}"

gtktheme "${GTKTHEME}"
