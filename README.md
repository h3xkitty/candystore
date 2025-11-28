# 🍬 candystore: a simple hyprland dotfiles manager
*author: h3xkitty*  
*repo*: `https://github.com/h3xkitty/candystore`

Candystore is a tiny, sharp, and dangerously cute tool for flipping your entire Linux aesthetic with a single command.  
Think of it less like a “theme manager” and more like a **switchblade for your dotfiles** — quick, non-destructive, and always ready.

It lives in your `.config` directory, keeps backups of everything it touches, and gives you a clean place to build, store, and share your personal themes. Hyprland setups, kitty configs, btop color palettes, fastfetch ASCII art, starship prompts, waybar bars — they all become swappable candy flavors.

This document explains exactly how Candystore works, where to put your themes, and how to make your system instantly transformable.

<p align="center">
  <img src="https://github.com/h3xkitty/candystore/blob/main/candystore.png" width="600">
</p>

---

# 🎨 1. What Candystore Actually *Does*
Candystore is a single script installed at:

```
~/.config/candystore/candystore
```

When you run:

```
candystore -kitty pastel_dream
```

or

```
candystore -hypr hexkitty
```

it knows how to locate the relevant theme file, copy it into your live configuration, and leave everything else untouched.  

There is **no deleting**, no overwriting your custom themes, no “oops I nuked my Hyprland setup.”  
Everything it replaces gets backed up as `.bak`.

Candystore is meant to be:

- **non-invasive** (it never destroys anything)
- **predictable** (same folder structure for everything)
- **shareable** (multiple users, same layout)
- **hackable** (edit themes freely)
- **fun** (obviously)

---

# 🗂️ 2. The Folder Structure (Your Candy Rack)
Everything Candystore does revolves around a single idea:

> **Every element has a “live file” and a “theme library.”**

The theme library always lives inside the application's folder under `.config`.  
The live file is what the system is currently using.

Candystore only ever copies a file *from* the theme library *to* the live location.

Below is the structure Candystore expects.

---

## 🍓 Hyprland Themes
Hyprland themes live here:

```
~/.config/hypr/themes/
```

Each theme gets its own folder:

```
~/.config/hypr/themes/hexkitty/
~/.config/hypr/themes/illogical_impulse/
```

Inside each folder, you place:

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

Your main Hyprland config file always lives at:

```
~/.config/hypr/hyprland.conf
```

Candystore replaces that file with the theme’s `hyprland.conf`, which then sources the rest.  
Example:

```
candystore -hypr hexkitty
```

You can think of Hyprland themes as little modular “bundles” — each complete and self-contained.

---

## 🐱 Kitty Themes
Kitty themes are dead simple.  
Your “live” kitty config is:

```
~/.config/kitty/kitty.conf
```

All kitty theme files go here:

```
~/.config/kitty/themes/
```

Every theme is just a single `.conf` file like:

```
pastel_dream.conf
dark_pastel_rainbow.conf
cyber_girl.conf
```

When you run:

```
candystore -kitty dark_pastel_rainbow
```

Candystore copies:

```
~/.config/kitty/themes/dark_pastel_rainbow.conf → ~/.config/kitty/kitty.conf
```

Instant vibe change.

---

## ⚙️ Btop Themes
Btop has two important pieces:

**1. The active theme file:**
```
~/.config/btop/themes/colors.theme
```

**2. Your library of theme files:**
```
~/.config/btop/themes/colors/*.txt
```

Example themes:
```
pastel.txt
gruv_rainbow.txt
hacker_wireframe.txt
```

Applying a theme is as simple as:

```
candystore -btop pastel
```

Which copies:

```
colors/pastel.txt → colors.theme
```

No destruction, only swapping.

---

## ⌨️ Fastfetch Themes (Config)
Fastfetch config themes live here:

```
~/.config/fastfetch/themes/
```

Each theme is a single `.jsonc` file.

The **live** config is:

```
~/.config/fastfetch/config.jsonc
```

So:

```
candystore -fastfetch rainbow_pastel
```

Copies:

```
themes/rainbow_pastel.jsonc → config.jsonc
```

And fastfetch changes instantly.

---

## ✨ Fastfetch ASCII Logos
ASCII files live separately from config themes.

Live file:

```
~/.config/fastfetch/ascii.txt
```

Theme library:

```
~/.config/fastfetch/logos/*.txt
```

Anything you drop into `logos/` becomes selectable:

```
candystore -ascii lesbian_arch
candystore -ascii octopus
candystore -ascii random
```

ASCII art is one of the easiest ways to set a mood.  
Candystore makes swapping them beautiful.

---

## 🚀 Starship Themes
Starship is another “one file = one theme” situation.

Live file:

```
~/.config/starship.toml
```

Theme library:

```
~/.config/starship/themes/*.toml
```

Themes like:

```
hearts_and_skulls.toml
minimal_pastel.toml
witchcore_prompt.toml
```

Swap with:

```
candystore -starship hearts_and_skulls
```

Nothing fancy — clean, simple, reliable.

---

## 🌙 Waybar Themes
Waybar is more complex because it has multiple files that shape the bar:

- config.jsonc  
- style.css  
- various scripts (.sh)

The **live** versions are in:

```
~/.config/waybar/
```

Themes live inside:

```
~/.config/waybar/themes/<theme_name>/
```

Each theme folder contains its own:

```
config.jsonc
style.css
scripts/*.sh
```

Candystore copies all of these into the live folder when you run:

```
candystore -waybar hacker_girl
```

Waybar restarts, and your bar transforms.

---

# 🔧 3. How Candystore Executes a Theme Change
When you run:

```
candystore -kitty pastel
```

Candystore will:

1. identify the correct theme file  
2. check that it exists  
3. make a backup of your current live file (`kitty.conf.bak`)  
4. copy the new theme file into place  
5. print a confirmation message  
6. reload what needs reloading (Hyprland only)

It never deletes your themes and never overwrites theme libraries.

This is why it's safe to experiment.

---

# 📦 4. The Installer (What Happens on Setup)
When running:

```bash
./install.sh
```

Candystore’s installer will:

- create `~/.config/candystore`
- install the script
- back up your existing configs (kitty, btop, fastfetch, starship, waybar, hypr)
- set up empty theme folders if they don’t exist
- copy in the example themes from the repo
- give you instructions for adding Candystore to your PATH

It’s intentionally **non-destructive**, designed to allow someone to install it without losing their existing system.

---

# 🍫 5. Using Candystore
Examples:

### list available themes for an element
```
candystore -kitty list
candystore -hypr list
candystore -ascii list
```

### apply a theme
```
candystore -kitty pastel_glow
```

### random theme
```
candystore -btop random
```

### mix-and-match
```
candystore -hypr hexkitty -kitty pinkwave -ascii octopus
```

---

# 🛡️ 6. Backups & Safety
Candystore never deletes anything.  
Everything it touches gets backed up:

- `kitty.conf.bak`  
- `starship.toml.bak`  
- `ascii.txt.bak`  
- `config.jsonc.bak`  
- `~/.config/waybar.bak`  
- and a full hypr backup folder

You can always restore your previous setup with no stress.

---

# 📁 7. Repo Layout (for Contributors)
A Candystore-ready repository has this layout:

```
.  
├── candystore  
├── install.sh  
├── README.md  
├── LICENSE  
└── .config  
    ├── btop  
    ├── fastfetch  
    ├── hypr  
    ├── kitty  
    ├── starship  
    └── waybar
```

Every theme folder you contribute follows the same structure.

---

# 🎀 8. Closing Thoughts
Candystore is built to be fun — a little candy jar full of themes you can swap without fear. Please add dotfiles to it and add to the community's collection ^_^

Your Linux desktop becomes something fluid and expressive, something you can transform with a single command.

It’s your **aesthetic "candystore"**.  
Use it well. 😼🩷  
