# 🍬 candystore – dot file management (switching) framework
author: h3xkitty
project: candystore
repo: `https://github.com/h3xkitty/candystore`

candystore is a tiny theme framework for linux dotfiles. it lets you:
* keep all your **themes** in `.config`
* safely **backup** your current configs
* install a single script called `candystore`
* switch themes for:
  * hyprland
  * kitty
  * btop
  * fastfetch (config + ascii)
  * starship
  * waybar
 
## 1. requirements
* arch / arch-based distro (installer uses `pacman`)
* the following tools installed (installer can help with these):
  * `kitty`
  * `btop`
  * `fastfetch`
  * `starship`
  * `waybar`
  * `hyprland`
* git and a shell (bash/fish/zsh

## 2. install candystore
### step 1 - clone the repo
```
cd ~/Documents
git clone git@github.com:h3xkitty/candystore.git
cd candystore
```
(or use the https url if you prefer.)

### step 2 - run the installer
`./install.sh`
what the installer does:
* checks for dependencies (kitty, btop, fastfetch, starship, waybar)
* installs the candystore script into: `~/.config/candystore/candystore`
* creates all needed directories in `~/.config`
* backs up your existing configs:
  * `~/.config/hypr` → `~/.config/hypr/themes/backup` (excluding themes/)
  * `~/.config/kitty/kitty.conf` → `kitty.conf.bak`
  * `~/.config/btop/btop.conf` → `btop.conf.bak`
  * `~/.config/btop/themes/colors.theme` → `colors.theme.bak`
  * `~/.config/fastfetch/ascii.txt` → `ascii.txt.bak`
  * `~/.config/fastfetch/config.jsonc` → `config.jsonc.bak`
  * `~/.config/starship.toml` → `starship.toml.bak`
  * `~/.config/waybar` → `~/.config/waybar.bak`
* seeds configs + themes from the repo's `.config` directory (if present)
* merges themes from the repo into your ~/.config theme folders **without deleting or overwriting existing themes**

### step 3 - add candystore to your path
add this to your shell config:
**fish:**
`echo 'set -U fish_user_paths $HOME/.config/candystore $fish_user_paths' >> ~/.config/fish/config.fish`

**bash (or zsh-style):**
`echo 'export PATH="$HOME/.config/candystore:$PATH"' >> ~/.bashrc`

restart your terminal, then you should be able to run:
`candystore`

## 3. how candystore works
* `candystore` is a command that knows how to manage themes for different "elements":
* `-hypr` → hyprland
* `-kitty` → kitty terminal
* `-btop` → btop color theme
* `-fastfetch` → fastfetch config theme
* `-ascii` → fastfetch ascii logo
* `-starship` → starship prompt themes
* `-waybar` → waybar bar themes

the general usage pattern is:
```
candystore -element list       # list available themes
candystore -element random     # pick a random theme for that element
candystore -element name_here  # apply a specific theme
```
you can also combine multiple in a single command (dpending on how far you extend the script). e.g.:
`candystore -hypr hexkitty -kitty dark_pastel_rainbow -ascii lesbian_arch`

## 4. where to put themes (per element)
this is the main "how to contribute/how to create a theme" section
### 4.1 hyprland themes
**live (user) directories
  * theme root:
     `~/.config/hypr/themes/`
  * each theme has it's own folder:
      ```
      ~/.config/hypr/themes/hexkitty/
      ~/.config/hypr/themes/theme_example2/ 
      ~/.config/hypr/themes/another_theme/
      ```
inside a hyprland theme folder, you typically have:
```
hyprland.conf
env.conf
general.conf
rules.conf
colors.conf
keybinds.conf
workspaces.conf
monitors.conf
execs.conf
```
**important:**
your main `~/.config/hypr/hyprland.conf` is replaced by candystore.
each theme’s `hyprland.conf` should be the top-level file that sources all the others.

example `~/.config/hypr/themes/hexkitty/hyprland.conf`:
```
# --- hyprland.conf (hexkitty) -------------------------------------------------

# sources
source=themes/hexkitty/env.conf
source=themes/hexkitty/execs.conf
source=themes/hexkitty/general.conf
source=themes/hexkitty/rules.conf
source=themes/hexkitty/colors.conf
source=themes/hexkitty/keybinds.conf

# nwg-displays support
source=themes/hexkitty/workspaces.conf
source=themes/hexkitty/monitors.conf
```
example `~/.config/hypr/themes/anoter_theme.conf`:
```
# defaults
source=hyprland/env.conf
source=hyprland/execs.conf
source=hyprland/general.conf
source=hyprland/rules.conf
source=hyprland/colors.conf
source=hyprland/keybinds.conf

# custom
source=custom/env.conf
source=custom/execs.conf
source=custom/general.conf
source=custom/rules.conf
source=custom/keybinds.conf
source=custom/colors.conf

# nwg-displays support
source=workspaces.conf
source=monitors.conf
```

**what candystore does for hypr:**

* `candystore -hypr list`
  lists theme folders under `~/.config/hypr/themes/`
* `candystore -hypr hexkitty`
  copies `~/.config/hypr/themes/hexkitty/hyprland.conf` →
  `~/.config/hypr/hyprland.conf` and runs `hyprctl reload`
* `candystore -hypr random`
  picks a random folder under `~/.config/hypr/themes/` and does the same

## 4.2 kitty themes
** live locations: **
live locations:
* active config:
  `~/.config/kitty/kitty.conf`
* theme files:
  `~/.config/kitty/themes/*.conf`
a kitty theme is just a `.conf` file with colors and options, for example:
`~/.config/kitty/themes/dark_pastel_rainbow.conf`

**what candystore does:**
* `candystore -kitty list`
  lists all `*.conf` inside `~/.config/kitty/themes/`

* `candystore -kitty dark_pastel_rainbow`
  copies:
    ```
    ~/.config/kitty/themes/dark_pastel_rainbow.conf \
    → ~/.config/kitty/kitty.conf
  ```

* `candystore -kitty random`
  picks a random `*.conf` from `~/.config/kitty/themes/`

to contribute a kitty theme, drop a `.conf` file into:
`~/.config/kitty/themes/`


(or `.config/kitty/themes/` in the repo, which gets synced by the installer.)

