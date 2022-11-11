# Auto dark mode for wsl apps

Change wsl2 app themes based on Windows theme switch

## Requirements
- wsl2
- zsh
- [AutoDarkMode](https://github.com/AutoDarkMode/Windows-Auto-Night-Mode)

## Usage
1. [Configure](https://github.com/AutoDarkMode/Windows-Auto-Night-Mode/wiki/How-to-add-custom-scripts) the `scripts.yaml` of AutoDarkMode:
```yaml
Enabled: true
Component:
  Scripts:
# Other scripts (if any)
  - Name: WSLUbuntuThemeSwitcher
    Command: powershell
    ArgsLight: [-NoProfile, -Command, wsl source path/to/repo/adm.sh 1]
    ArgsDark: [-NoProfile, -Command, wsl source path/to/repo/adm.sh 0]
    AllowedSources: [Any]
```

2. Put the following in `~/.zprofile` or `$ZDOTDIR/.zprofile`:
```shell
if [ -z $TMUX ]
then
    source path/to/repo/adm.sh
fi
```
