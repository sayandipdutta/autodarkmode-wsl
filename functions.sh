#!/usr/bin/zsh

# log path
LOGPATH=$(dirname "$0")/log/admlog.log
# restrict log file to last 1000 lines
# HACK: echo $(cmd) instead of cmd, because we are trying to modify the file inplace
# Thus the output of tail command needs to be loaded in memory
echo "$(tail -n 1000 $LOGPATH)" >$LOGPATH

# Log the time
{
	echo "====================="
	date
	echo "====================="
} >>$LOGPATH

# Get current windows theme
# If theme==dark, $WINTHEME == 0, else 1

# if arg is 0 or 1 set it as WINTHEME
# Otherwise, find out wintheme value from windows registry
if [ $# -ne 0 ] && { [ "$1" -eq 0 ] || [ "$1" -eq 1 ]; }; then
	# convert command line arg to int
	WINTHEME=$(($1 + 0))
	echo "INFO: Called from AutoDarkMode with arg ${WINTHEME}" >>$LOGPATH
else
    KEY='HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 
    PROP=AppsUseLightTheme
	LIGHT=$(powershell.exe -NoProfile -Command Get-ItemPropertyValue "$KEY" -Name "$PROP" | tr -d "\r")
	WINTHEME=$((LIGHT + 0))
	echo "INFO: Called from Startup. Registry value ${WINTHEME}" >>$LOGPATH
fi

MODE=$([ "$WINTHEME" -eq 0 ] && echo "dark" || echo "light")

# If a regular (i.e. non symlink) config file does not exist
# set theme by linking with appropriate theme file based on $WINTHEME
# takes a three arguments:
#   $1 -> config path of a program
#   $2 -> corresponding light theme file
#   $3 -> corresponding dark theme file
softlink() {

	# if symlink of first arg exist, unlink
	test -L "$1" && unlink "$1"
	target=$([ "$WINTHEME" -eq 0 ] && echo "$3" || echo "$2")
	ln -s "$target" "$1"
	echo "INFO: Switched ${1} theme to ${target}" >>$LOGPATH
}

# takes a three arguments:
#   $1 -> config path of a program
#   $2 -> corresponding light theme file
#   $3 -> corresponding dark theme file
hardlink() {
	# if file exists, delete
	test -f "$1" && rm "$1"
	target=$([ "$WINTHEME" -eq 0 ] && echo "$3" || echo "$2")
	# create hard link, as lua cannot load symlink as module
	ln "$target" "$1"
	echo "INFO: Switched ${1} theme to ${target}" >>$LOGPATH
}

# look for any socket of the pattern /tmp/nvim_*/sock
# If present, remote-send set bg command
set_open_nvim_theme() {
    match=0
    # HACK: ONLY WORKS FOR ZSH (https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Qualifiers)
    # set nullglob option for single glob pattern using N
    # NOTE: POSIX generalized option: if (ls /tmp/nvim_*.sock) > /dev/null 2>&1 ; then "exists" ; fi
    for socket in /tmp/nvim_*.sock(N); do
        match=1
        nvim --server "$socket" --remote-send ":set bg=${MODE}<cr>"
    done
    [ "$match" -eq 0 ] && echo "WARNING: Neovim not running" >>$LOGPATH
}

# Takes one argument, i.e the name of the theme, e.g. `Adwaita`
# Switches flavour to light or dark
gtktheme () {
    export GTK_THEME="${1}:${MODE}"
    echo "Switched GTK_THEME to ${MODE}" >>$LOGPATH
}
