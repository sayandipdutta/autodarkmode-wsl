<img src="https://img.shields.io/badge/linux-wsl2-yellow?logo=linux"></img>
<img src="https://img.shields.io/badge/zsh-5.x-brightgreen?logo=gnubash"></img>
<img src="https://img.shields.io/badge/windows-10%2F11-informational?logo=windows11"></img>
# Auto dark mode for wsl apps

Change wsl2 app themes based on Windows theme switch

## Requirements
- wsl2
- [AutoDarkMode](https://github.com/AutoDarkMode/Windows-Auto-Night-Mode)
- zsh (*recommended*)

## Usage
1. [Configure](https://github.com/AutoDarkMode/Windows-Auto-Night-Mode/wiki/How-to-add-custom-scripts) the `scripts.yaml` of AutoDarkMode:
```yaml
Enabled: true
Component:
  Scripts:
# Other scripts (if any)
  - Name: autodarkmode_wsl
    Command: powershell
    ArgsLight: [-NoProfile, -Command, wsl path/to/repo/adm.sh 1]
    ArgsDark: [-NoProfile, -Command, wsl path/to/repo/adm.sh 0]
    AllowedSources: [Any]
```

2. Put the following in `~/.zprofile` or `$ZDOTDIR/.zprofile`:
```shell
if [ -z $TMUX ]
then
    path/to/repo/adm.sh
fi
```

## Configuration
Currently the script is configured for:
- wslg
- tmux
- neovim
- lazygit
- bat
- glow

** NOTE: You need to have your own configuration files for light and dark themes for each program.**
** You can add or modify paths of the config files in `adm.sh`.**

### Adding more programs
- To add more programs, add config files for that program to `adm.sh`.
- Use existing functions if theme switch can be done using linking config file to its dark or light variant.
- Otherwise, create new functions in functions.sh
- Call the function at the end of script with newly added program variable.

#### Example - *Add iPython theme*
Assuming you have `pygments` installed, 
- Copy your `ipython` profile default theme (typically found in `~/.ipython/profile_default/`
 or `~/.ipython/profile_$USER/` directory) to a new file called `light.py` in the same directory.
- Change the following line to your preferred light theme (e.g. `'gruvbox-light'`)
```python
c.TerminalInteractiveShell.highlighting_style = 'gruvbox-light'
```
- Do the same process for dark, i.e. create dark.py and change `highlighting_style` to a dark theme.
- In `adm.sh`, add the following at the end of config section:
```shell
IPYTHON_CONFIG=(~/.ipython/profile_default/{ipython_config.py,light.py,dark.py})
```
- Now based on system theme, light.py or dark.py can be linked to `config.py`.
A symlink can be created using `linkconfig` function from `functions.sh`.
Add the following line to the end of `adm.sh`:
```shell
linkconfig "${IPYTHON_CONFIG[@]}" soft
```

## Available functions and variables
### Functions
#### linkconfig
Creates symbolic link, or hardlink, or copy based on argument
Based on `WINTHEME`, links to dark or light file.
This function takes three arguments,
- **argument 1** is the path where the config file must be put.
- **argument 2** path of the light themed configuration file.
- **argument 3** path of the dark themed configuration file.
- **argument 4** `soft` | `hard` | `copy`
    - `soft` - Creates a soft (symbolic) link to the chosen theme as config file
    - `hard` - Creates a hard link to the chosen theme as config file
    - `copy` - Creates a copy of the chosen theme file and saves as config file

#### set_open_nvim_theme
Attempts to change the background of theme in running nvim instances.
If socket files with matching pattern exist, sends remote commands to instance.
In order for this to work, `nvim` must be started with a listen address.
e.g. `nvim --listen /tmp/nvim_1234.sock`, for a stable solution an alias
could be added in `.zshrc`:
```shell
alias nvim=nvim --listen /tmp/nvim_*.sock
```

#### gtktheme
Changes wslg theme based on `WINTHEME`
Takes 1 argument:
- **argument 1:** Name of the theme (e.g. `Adwaita`)

### Variables
#### WINTHEME
*Possible values **0** or **1**.*
    0 - Dark
    1 - Light


When called without arguments, `WINTHEME` is set by checking windows registry value 
of `AppsUseLightTheme`. *NOTE: Querying the registry takes ~2 seconds.* When called
with argument, `WINTHEME` is the value of the first argument. If provided argument
is not *0* or *1*, query windows registry to set `WINTHEME`.

#### MODE
Possible values **`light`** or **`dark`**.


`MODE` can be used in cases where *light* or *dark* must be provided to change theme.
