#!/usr/bin/env bash

# --- candystore installer 🍬 ------------------------------------------------------
# creator: h3xkitty
#
# this installer does:
#   1. checks for required dependencies (kitty, btop, fastfetch, starship, waybar)
#   2. installs the "candystore" script into ~/.config/candystore
#   3. creates the folder structure for all theme types
#   4. makes backups of your current configs (non-destructive)
#   5. seeds configs + themes from this repo's .config/ directory
#
# design goals:
#   • never deletes anything
#   • backs up before overwriting active configs
#   • merges themes (no overwrite) so users keep their existing themes
# ----------------------------------------------------------------------------------

set -e

# --- repo paths -------------------------------------------------------------------

REPO_DIR="$(dirname "$0")"
REPO_CONFIG="$REPO_DIR/.config"

# --- dependency check 🍥 -----------------------------------------------------------
# asks before installing missing dependencies using pacman
# ----------------------------------------------------------------------------------

check_dep() {
  local dep="$1"
  local pkg="$2"

  if command -v "$dep" >/dev/null 2>&1; then
    echo "✔ $dep is installed"
  else
    echo "✖ $dep is not installed"

    read -rp "install $dep now? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      echo "🍬 installing $pkg..."
      sudo pacman -S --noconfirm "$pkg"
    else
      echo "⚠ skipping install of $dep"
    fi
  fi
}

echo "🍭 checking dependencies..."

check_dep "kitty" "kitty"
check_dep "btop" "btop"
check_dep "fastfetch" "fastfetch"
check_dep "starship" "starship"
check_dep "waybar" "waybar"

echo "✔ dependency check complete"
echo

# --- step 1: install candystore into ~/.config/candystore -------------------------

INSTALL_DIR="$HOME/.config/candystore"
CANDYSTORE_SOURCE="$REPO_DIR/candystore"
CANDYSTORE_TARGET="$INSTALL_DIR/candystore"

echo "🍬 installing candystore..."

mkdir -p "$INSTALL_DIR"

cp "$CANDYSTORE_SOURCE" "$CANDYSTORE_TARGET"
chmod +x "$CANDYSTORE_TARGET"

echo "✔ candystore installed at: $CANDYSTORE_TARGET"
echo "ℹ️  add this to your PATH to run 'candystore' globally:"
echo "    export PATH=\"\$HOME/.config/candystore:\$PATH\""
echo

# --- step 2: create theme directories (safe, non-destructive) ---------------------

echo "🍭 creating theme directories (if missing)..."

mkdir -p "$HOME/.config/hypr/themes"
mkdir -p "$HOME/.config/kitty/themes"
mkdir -p "$HOME/.config/btop/themes/colors"
mkdir -p "$HOME/.config/fastfetch/themes"
mkdir -p "$HOME/.config/fastfetch/logos"
mkdir -p "$HOME/.config/starship/themes"
mkdir -p "$HOME/.config/waybar/themes"

echo "✔ theme directories ready"
echo

# --- step 3: hyprland backup + repo themes merge -----------------------------------
# - copies current ~/.config/hypr into ~/.config/hypr/themes/backup (once)
# - does NOT change active theme
# - merges repo .config/hypr/themes/* into ~/.config/hypr/themes (no overwrite)
# ----------------------------------------------------------------------------------

echo "🌀 handling hyprland..."

HYPR_DIR="$HOME/.config/hypr"
HYPR_BACKUP_DIR="$HOME/.config/hypr/themes/backup"
REPO_HYPR_DIR="$REPO_CONFIG/hypr"
REPO_HYPR_THEMES="$REPO_HYPR_DIR/themes"

if [ -d "$HYPR_DIR" ]; then
  if [ -d "$HYPR_BACKUP_DIR" ]; then
    echo "  • hypr backup already exists at: $HYPR_BACKUP_DIR (skipping copy)"
  else
    mkdir -p "$HYPR_BACKUP_DIR"

    if command -v rsync >/dev/null 2>&1; then
      # safe hypr backup: exclude the "themes" folder to avoid recursive copy
      rsync -a --exclude "themes" "$HYPR_DIR/" "$HYPR_BACKUP_DIR/" >/dev/null 2>&1
      echo "  ✔ hypr config backed up safely to: $HYPR_BACKUP_DIR"
    else
      echo "  ⚠ rsync not found, skipping hypr backup to avoid copying into itself."
      echo "    install rsync if you want automatic hypr backups:"
      echo "    sudo pacman -S rsync"
    fi
  fi
else
  echo "  ⚠ no ~/.config/hypr directory found (skipping hypr backup)"
fi

if [ -d "$REPO_HYPR_THEMES" ]; then
  echo "  ✔ syncing hypr themes from repo → ~/.config/hypr/themes (no overwrite)..."
  cp -rn "$REPO_HYPR_THEMES"/. "$HOME/.config/hypr/themes"/ || true
else
  echo "  ℹ️ no repo hypr themes at: $REPO_HYPR_THEMES (skipping theme sync)"
fi

echo "  ℹ️ current hyprland theme is untouched. use candystore -hypr later."
echo


# --- step 4: kitty backup + repo config + themes merge -----------------------------
# - backs up current kitty.conf → kitty.conf.bak
# - seeds kitty.conf from repo .config/kitty/kitty.conf if present
# - merges repo kitty themes into ~/.config/kitty/themes (no overwrite)
# ----------------------------------------------------------------------------------

echo "🐱 handling kitty..."

KITTY_CONF="$HOME/.config/kitty/kitty.conf"
KITTY_CONF_BAK="$HOME/.config/kitty/kitty.conf.bak"
REPO_KITTY_DIR="$REPO_CONFIG/kitty"
REPO_KITTY_CONF="$REPO_KITTY_DIR/kitty.conf"
REPO_KITTY_THEMES="$REPO_KITTY_DIR/themes"

if [ -f "$KITTY_CONF" ]; then
  if [ -f "$KITTY_CONF_BAK" ]; then
    echo "  • kitty backup already exists at: $KITTY_CONF_BAK (skipping backup)"
  else
    cp "$KITTY_CONF" "$KITTY_CONF_BAK"
    echo "  ✔ backed up kitty.conf to: $KITTY_CONF_BAK"
  fi
else
  echo "  ⚠ no kitty.conf found at: $KITTY_CONF"
fi

if [ -f "$REPO_KITTY_CONF" ]; then
  cp "$REPO_KITTY_CONF" "$KITTY_CONF"
  echo "  ✔ seeded kitty.conf from repo: $REPO_KITTY_CONF"
else
  echo "  ℹ️ no repo kitty.conf at: $REPO_KITTY_CONF (skipping seed)"
fi

if [ -d "$REPO_KITTY_THEMES" ]; then
  echo "  ✔ syncing kitty themes from repo → ~/.config/kitty/themes (no overwrite)..."
  cp -rn "$REPO_KITTY_THEMES"/. "$HOME/.config/kitty/themes"/ || true
else
  echo "  ℹ️ no repo kitty/themes dir at: $REPO_KITTY_THEMES (skipping theme sync)"
fi

echo

# --- step 5: btop backup + repo config + color themes merge ------------------------
# - backs up btop.conf → btop.conf.bak
# - seeds from repo .config/btop/btop.conf if present
# - backs up colors.theme → colors.theme.bak (if exists)
# - seeds colors.theme from repo .config/btop/themes/colors.theme or creates empty
# - merges repo color files into ~/.config/btop/themes/colors/ (no overwrite)
# ----------------------------------------------------------------------------------

echo "📊 handling btop..."

BTOP_CONF="$HOME/.config/btop/btop.conf"
BTOP_CONF_BAK="$HOME/.config/btop/btop.conf.bak"
BTOP_COLORS="$HOME/.config/btop/themes/colors.theme"
BTOP_COLORS_BAK="$HOME/.config/btop/themes/colors.theme.bak"

REPO_BTOP_DIR="$REPO_CONFIG/btop"
REPO_BTOP_CONF="$REPO_BTOP_DIR/btop.conf"
REPO_BTOP_COLORS="$REPO_BTOP_DIR/themes/colors.theme"
REPO_BTOP_COLORS_DIR="$REPO_BTOP_DIR/themes/colors"

# backup btop.conf
if [ -f "$BTOP_CONF" ]; then
  if [ -f "$BTOP_CONF_BAK" ]; then
    echo "  • btop backup already exists at: $BTOP_CONF_BAK (skipping backup)"
  else
    cp "$BTOP_CONF" "$BTOP_CONF_BAK"
    echo "  ✔ backed up btop.conf to: $BTOP_CONF_BAK"
  fi
else
  echo "  ⚠ no btop.conf found at: $BTOP_CONF"
fi

# seed btop.conf
if [ -f "$REPO_BTOP_CONF" ]; then
  cp "$REPO_BTOP_CONF" "$BTOP_CONF"
  echo "  ✔ seeded btop.conf from repo: $REPO_BTOP_CONF"
else
  echo "  ℹ️ no repo btop.conf at: $REPO_BTOP_CONF (skipping seed)"
fi

# backup colors.theme
if [ -f "$BTOP_COLORS" ]; then
  if [ -f "$BTOP_COLORS_BAK" ]; then
    echo "  • btop colors.theme backup already exists at: $BTOP_COLORS_BAK (skipping backup)"
  else
    cp "$BTOP_COLORS" "$BTOP_COLORS_BAK"
    echo "  ✔ backed up colors.theme to: $BTOP_COLORS_BAK"
  fi
else
  echo "  ℹ️ no existing colors.theme at: $BTOP_COLORS (nothing to backup)"
fi

# seed colors.theme
if [ -f "$REPO_BTOP_COLORS" ]; then
  cp "$REPO_BTOP_COLORS" "$BTOP_COLORS"
  echo "  ✔ seeded colors.theme from repo: $REPO_BTOP_COLORS"
else
  if [ ! -f "$BTOP_COLORS" ]; then
    touch "$BTOP_COLORS"
    echo "  ℹ️ created empty colors.theme at: $BTOP_COLORS (no repo default)"
  fi
fi

# merge color theme files
if [ -d "$REPO_BTOP_COLORS_DIR" ]; then
  echo "  ✔ syncing btop color themes from repo → ~/.config/btop/themes/colors (no overwrite)..."
  mkdir -p "$HOME/.config/btop/themes/colors"
  cp -rn "$REPO_BTOP_COLORS_DIR"/. "$HOME/.config/btop/themes/colors"/ || true
else
  echo "  ℹ️ no repo btop color themes dir at: $REPO_BTOP_COLORS_DIR (skipping)"
fi

echo

# --- step 6: fastfetch backup + repo config + logos/themes merge --------------------
# - backs up ascii.txt + config.jsonc to .bak
# - seeds both from repo .config/fastfetch/ if present
# - merges logos + themes from repo (no overwrite)
# ----------------------------------------------------------------------------------

echo "⚡ handling fastfetch..."

FF_DIR="$HOME/.config/fastfetch"
FF_ASCII="$FF_DIR/ascii.txt"
FF_ASCII_BAK="$FF_DIR/ascii.txt.bak"
FF_CONF="$FF_DIR/config.jsonc"
FF_CONF_BAK="$FF_DIR/config.jsonc.bak"

REPO_FF_DIR="$REPO_CONFIG/fastfetch"
REPO_FF_ASCII="$REPO_FF_DIR/ascii.txt"
REPO_FF_CONF="$REPO_FF_DIR/config.jsonc"
REPO_FF_LOGOS="$REPO_FF_DIR/logos"
REPO_FF_THEMES="$REPO_FF_DIR/themes"

mkdir -p "$FF_DIR" "$FF_DIR/logos" "$FF_DIR/themes"

# backups
if [ -f "$FF_ASCII" ]; then
  if [ -f "$FF_ASCII_BAK" ]; then
    echo "  • ascii.txt backup already exists at: $FF_ASCII_BAK (skipping backup)"
  else
    cp "$FF_ASCII" "$FF_ASCII_BAK"
    echo "  ✔ backed up ascii.txt to: $FF_ASCII_BAK"
  fi
fi

if [ -f "$FF_CONF" ]; then
  if [ -f "$FF_CONF_BAK" ]; then
    echo "  • config.jsonc backup already exists at: $FF_CONF_BAK (skipping backup)"
  else
    cp "$FF_CONF" "$FF_CONF_BAK"
    echo "  ✔ backed up config.jsonc to: $FF_CONF_BAK"
  fi
fi

# seed config.jsonc
if [ -f "$REPO_FF_CONF" ]; then
  cp "$REPO_FF_CONF" "$FF_CONF"
  echo "  ✔ seeded fastfetch config.jsonc from repo: $REPO_FF_CONF"
else
  echo "  ℹ️ no repo fastfetch config.jsonc at: $REPO_FF_CONF (skipping seed)"
fi

# seed ascii.txt
if [ -f "$REPO_FF_ASCII" ]; then
  cp "$REPO_FF_ASCII" "$FF_ASCII"
  echo "  ✔ seeded ascii.txt from repo: $REPO_FF_ASCII"
else
  echo "  ℹ️ no repo ascii.txt at: $REPO_FF_ASCII (skipping seed)"
fi

# merge logos
if [ -d "$REPO_FF_LOGOS" ]; then
  echo "  ✔ syncing fastfetch logos from repo → ~/.config/fastfetch/logos (no overwrite)..."
  cp -rn "$REPO_FF_LOGOS"/. "$FF_DIR/logos"/ || true
else
  echo "  ℹ️ no repo fastfetch logos dir at: $REPO_FF_LOGOS (skipping logs sync)"
fi

# merge themes
if [ -d "$REPO_FF_THEMES" ]; then
  echo "  ✔ syncing fastfetch themes from repo → ~/.config/fastfetch/themes (no overwrite)..."
  cp -rn "$REPO_FF_THEMES"/. "$FF_DIR/themes"/ || true
else
  echo "  ℹ️ no repo fastfetch themes dir at: $REPO_FF_THEMES (skipping themes sync)"
fi

echo

# --- step 7: starship backup + repo config + themes merge ---------------------------
# - backs up ~/.config/starship.toml to starship.toml.bak
# - seeds from repo .config/starship/starship.toml if present
# - merges repo starship themes into ~/.config/starship/themes (no overwrite)
# ----------------------------------------------------------------------------------

echo "🚀 handling starship..."

STAR_CONF="$HOME/.config/starship.toml"
STAR_CONF_BAK="$HOME/.config/starship.toml.bak"
REPO_STAR_DIR="$REPO_CONFIG/starship"
REPO_STAR_CONF="$REPO_STAR_DIR/starship.toml"
REPO_STAR_THEMES="$REPO_STAR_DIR/themes"

if [ -f "$STAR_CONF" ]; then
  if [ -f "$STAR_CONF_BAK" ]; then
    echo "  • starship backup already exists at: $STAR_CONF_BAK (skipping backup)"
  else
    cp "$STAR_CONF" "$STAR_CONF_BAK"
    echo "  ✔ backed up starship.toml to: $STAR_CONF_BAK"
  fi
else
  echo "  ⚠ no starship.toml at: $STAR_CONF (nothing to backup)"
fi

if [ -f "$REPO_STAR_CONF" ]; then
  cp "$REPO_STAR_CONF" "$STAR_CONF"
  echo "  ✔ seeded starship.toml from repo: $REPO_STAR_CONF"
else
  echo "  ℹ️ no repo starship.toml at: $REPO_STAR_CONF (skipping seed)"
fi

if [ -d "$REPO_STAR_THEMES" ]; then
  echo "  ✔ syncing starship themes from repo → ~/.config/starship/themes (no overwrite)..."
  cp -rn "$REPO_STAR_THEMES"/. "$HOME/.config/starship/themes"/ || true
else
  echo "  ℹ️ no repo starship themes dir at: $REPO_STAR_THEMES (skipping theme sync)"
fi

echo

# --- step 8: waybar backup + repo config + themes merge -----------------------------
# - backs up ~/.config/waybar → ~/.config/waybar.bak (once)
# - seeds from repo .config/waybar/* into ~/.config/waybar
# - merges repo waybar themes into ~/.config/waybar/themes (no overwrite)
# ----------------------------------------------------------------------------------

echo "🌙 handling waybar..."

WAYBAR_DIR="$HOME/.config/waybar"
WAYBAR_BAK="$HOME/.config/waybar.bak"
REPO_WAYBAR_DIR="$REPO_CONFIG/waybar"
REPO_WAYBAR_THEMES="$REPO_WAYBAR_DIR/themes"

if [ -d "$WAYBAR_DIR" ]; then
  if [ -d "$WAYBAR_BAK" ]; then
    echo "  • waybar backup already exists at: $WAYBAR_BAK (skipping backup)"
  else
    cp -r "$WAYBAR_DIR" "$WAYBAR_BAK"
    echo "  ✔ backed up waybar directory to: $WAYBAR_BAK"
  fi
else
  echo "  ⚠ no ~/.config/waybar directory found (nothing to backup)"
fi

if [ -d "$REPO_WAYBAR_DIR" ]; then
  echo "  ✔ syncing waybar base config from repo → ~/.config/waybar (may overwrite, but backup exists)..."
  mkdir -p "$WAYBAR_DIR"
  cp -r "$REPO_WAYBAR_DIR"/. "$WAYBAR_DIR"/
else
  echo "  ℹ️ no repo waybar dir at: $REPO_WAYBAR_DIR (skipping base config)"
fi

if [ -d "$REPO_WAYBAR_THEMES" ]; then
  echo "  ✔ syncing waybar themes from repo → ~/.config/waybar/themes (no overwrite)..."
  mkdir -p "$HOME/.config/waybar/themes"
  cp -rn "$REPO_WAYBAR_THEMES"/. "$HOME/.config/waybar/themes"/ || true
else
  echo "  ℹ️ no repo waybar themes dir at: $REPO_WAYBAR_THEMES (skipping theme sync)"
fi

echo

# --- done --------------------------------------------------------------------------

echo "✔ install complete. you can now run: candystore"
echo "  use candystore -kitty / -hypr / -ascii / etc. once your themes are in place."
