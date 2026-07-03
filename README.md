# MangoWM Run or Focus

A small helper script for [MangoWM](https://github.com/DreamMaoMao/mangowm) that provides keyboard-driven application switching similar to pinned applications in GNOME Dash-to-Dock, KDE Plasma, Unity, and the Windows taskbar, where pressing Super+1, Super+2, etc. launches or focuses the corresponding application for fast, direct, and convenient access.

Bind the script to a single key to create an all-in-one application handler. Depending on the current state, it will:

 - focus an existing application window
 - cycle through multiple windows of the same application
 - switch to the previously focused window when no other matching windows exist
 - automatically switch between tags
 - launch the application if it is not running

> **Update:** `rf.sh` is now the current version and recommended default.

---

## Requirements

- MangoWM
- Bash
- jq

---

## Current version (`rf.sh`)

### Usage

```bash
rf <tag|c> <appid|""> <window_title|""> <ignore_title_fragment|""> <command...>
```

You can filter by:
- appid only (`window_title` and `ignore_title_fragment` as `""`)
- window title only (`appid` as `""`)
- both appid and window title
- appid/title with an ignored title fragment

At least one of `appid` or `window_title` must be non-empty.

### Arguments

| Argument | Description |
|---|---|
| `tag` | Tag where the application will be launched if it is not already running |
| `c` | Use the current tag |
| `appid` | Window app ID used by MangoWM (use `""` to ignore appid matching) |
| `window_title` | Window title or title fragment to match (use `""` to ignore title matching) |
| `ignore_title_fragment` | Window title fragment to exclude from matches (use `""` to disable) |
| `command` | Command used to launch the application (arguments and flags are supported) |

Use `mmsg get all-clients | jq -r '.clients[] | [.appid, .title] | @tsv'` to inspect appids and titles.

### Examples

Focus/cycle/launch Konsole on first tag:

```bash
~/.local/bin/rf 1 org.kde.konsole "" "" konsole
```

Focus Nautilus or launch it on current tag:

```bash
~/.local/bin/rf c org.gnome.Nautilus "" "" GSK_RENDERER=gl nautilus
```

Launch Midnight Commander in Alacritty on current tag or focus matching window by title:

```bash
~/.local/bin/rf c "" "mc [" "" alacritty -e mc
```

Run Alacritty or focus it while excluding Midnight Commander title fragment:

```bash
~/.local/bin/rf c Alacritty "" "mc [" alacritty
```

### MangoWM Keybindings example

```ini
bind = SUPER, RETURN, spawn, ~/.local/bin/rf 1 org.kde.konsole "" "" konsole
bind = SUPER, e, spawn, ~/.local/bin/rf c org.gnome.Nautilus "" "" GSK_RENDERER=gl nautilus
bind = SUPER, m, spawn, ~/.local/bin/rf c "" "mc [" "" alacritty -e mc
bind = SUPER,1,spawn, ~/.local/bin/rf c Alacritty "" "mc [" alacritty
```

### Bind generator (`rf`)

Generate `rf` keybinds from currently visible clients:

```bash
~/.local/bin/bind_generator_rf
```

### How It Works

If the app is already focused:
- when another matching window exists, it cycles to the next one
- when only one matching window exists, it switches to the previously focused window

If the app exists but is not focused:
- it focuses the matching window

If the app is not running:
- it switches to the specified tag (when `tag` is numeric)
- launches the application command

### Installation

```bash
mkdir -p ~/.local/bin
wget -O ~/.local/bin/rf https://raw.githubusercontent.com/mtriam/runorfosuc/main/rf.sh
wget -O ~/.local/bin/bind_generator_rf https://raw.githubusercontent.com/mtriam/runorfosuc/main/bind_generator_rf.sh
chmod +x ~/.local/bin/rf
chmod +x ~/.local/bin/bind_generator_rf
```

---

## Older versions (legacy variants)

### Usage

Use `rfcm` (new IPC `mmsg`) as the primary variant:

```bash
rfcm <tag|c> <appid> <command...>
```

Use `rfcmt` to match by window title instead of appid:

```bash
rfcmt <tag|c> <window_title> <command...>
```

Use `rfe` to run or focus by appid while ignoring a matching title fragment:

```bash
rfe <tag|c> <appid> <ignore_title_fragment> <command...>
```

For older IPC-compatible workflows, you can still use:

```bash
rof <tag|c> <appid> <process_name> <command...>
```

or

```bash
rofw <tag|c> <appid> <command...>
```

### Arguments

| Argument | Description |
|---|---|
| `tag` | Tag where the application will be launched if it is not already running |
| `c` | Use the current tag |
| `appid` | Window app ID used by MangoWM <sup>*</sup> |
| `window_title` | Window title or title fragment used to match an existing window for `rfcmt` ** |
| `ignore_title_fragment` | Window title fragment to exclude from matching windows for `rfe` ** |
| `command` | Command used to launch the application (arguments and flags are supported) |
| `process_name` | Process name checked with `pgrep -x` and `pgrep -f` (legacy IPC variants only) |

#### * Use `mmsg get all-clients | jq -r '.clients[].appid'` (or `mmsg -w -c` and change the active window) to obtain application appids.

#### ** Use `mmsg get all-clients | jq -r '.clients[].title'` to obtain window titles for `rfcmt`, or use `rfe` with a title fragment to exclude a matching window.

### Examples

New mmsg IPC format:

Focus, cycle, or launch konsole on first tag:

```bash
~/local/bin/rfcm 1 org.kde.konsole konsole
```

Focus Nautilus or launch it on current tag:

```bash
~/local/bin/rfcm c org.gnome.Nautilus GSK_RENDERER=gl nautilus
```

Launch Midnight Commander in the Alacritty terminal emulator on current tag or focus it if already open using a window title fragment:

```bash
~/s/m/rfcmt c "mc [" alacritty -e mc
```

Run Alacritty or focus it if already open, excluding Midnight Commander running in Alacritty:

```bash
~/.local/bin/fre c Alacritty "mc [" alacritty
```

Run Alacritty or focus it if already open without excluding any title fragment:

```bash
~/.local/bin/fre c Alacritty "" alacritty
```

Old mmsg IPC format:

Focus or launch konsole using rofw (wlrctl-based) on current tag:

```bash
~/local/bin/rofw c org.kde.konsole konsole
```

Focus or launch code-oss on first tag:

```bash
~/local/bin/rof 1 code-oss code.mjs code --password-store=gnome-libsecret
```

Focus Nautilus or launch it on second tag:

```bash
~/local/bin/rof 2 org.gnome.Nautilus nautilus GSK_RENDERER=gl nautilus
```

### MangoWM Keybindings example

```ini
bind = SUPER, RETURN, spawn, ~/.local/bin/rfcm 1 org.kde.konsole konsole
bind = SUPER, e, spawn, ~/.local/bin/rfcm c org.gnome.Nautilus GSK_RENDERER=gl nautilus
bind = SUPER, m, spawn, ~/.local/bin/rfcmt "mc [" alacritty -e mc
bind = SUPER,1,spawn, ~/.local/bin/fre c Alacritty "mc [" alacritty
```

### Bind generator (legacy)

Generate legacy `rfcm` keybinds:

```bash
bash bind_generator.sh
```

Older IPC variants:

```ini
bind = SUPER, RETURN, spawn, ~/.local/bin/rof c org.kde.konsole konsole konsole
bind = SUPER, e, spawn, ~/.local/bin/rof 2 org.gnome.Nautilus nautilus GSK_RENDERER=gl nautilus
```

or

```ini
bind = SUPER, RETURN, spawn, ~/.local/bin/rofw c org.kde.konsole konsole
bind = SUPER, e, spawn, ~/.local/bin/rofw 2 org.gnome.Nautilus GSK_RENDERER=gl nautilus
```

### How It Works

If the app is already focused:

The script searches for another matching window and focuses it. If only one matching window exists, it switches to the previously focused window.

This makes repeated key presses behave like a window cycler.

If the app exists but is not focused:

The script focuses the first matching window.

If the app is not running:

1. switches to the specified tag
2. launches the application

### Installation

```bash
mkdir -p ~/.local/bin
wget -O ~/.local/bin/rfcm https://raw.githubusercontent.com/mtriam/runorfosuc/main/rfcm.sh
wget -O ~/.local/bin/rfcmt https://raw.githubusercontent.com/mtriam/runorfosuc/main/rfcmt.sh
wget -O ~/.local/bin/rfe https://raw.githubusercontent.com/mtriam/runorfosuc/main/rfe.sh
chmod +x ~/.local/bin/rfcm
chmod +x ~/.local/bin/rfcmt
chmod +x ~/.local/bin/rfe
```

or (older IPC variants)

```bash
mkdir -p ~/.local/bin
wget -O ~/.local/bin/rof https://raw.githubusercontent.com/mtriam/runorfosuc/main/rof.sh
chmod +x ~/.local/bin/rof
```

or

```bash
mkdir -p ~/.local/bin
wget -O ~/.local/bin/rofw https://raw.githubusercontent.com/mtriam/runorfosuc/main/rofw.sh
chmod +x ~/.local/bin/rofw
```

`wlrctl` installation examples (depending on your distribution):

- Arch Linux (AUR helper):

```bash
# using paru or yay
paru -S wlrctl
# or
yay -S wlrctl
```

- Debian:

```bash
sudo apt install wlrctl
```

---

## License

GPL-3.0
