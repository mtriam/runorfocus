# MangoWM Run or Focus

A small helper script for [MangoWM](https://github.com/DreamMaoMao/mangowm) that provides keyboard-driven application switching similar to pinned applications in GNOME Dash-to-Dock, KDE Plasma, Unity, and the Windows taskbar, where pressing Super+1, Super+2, etc. launches or focuses the corresponding application for fast, direct, and convenient access.

Bind the script to a single key to create an all-in-one application handler. Depending on the current state, it will:

 - focus an existing application window
 - cycle through multiple windows of the same application
 - switch to the previously focused window when no other matching windows exist
 - automatically switch between tags
 - launch the application if it is not running

> **Update:** Added support for `rfcmt` and `rfe`, new variants that can find windows by title/title fragment and ignore matching window titles.

---

## Requirements

- MangoWM
- Bash
- jq
- wlrctl (required for the `rofw.sh` variant)

---

## Usage

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

#### * Use `mmsg get all-clients | jq -r '.clients[].appid'` (or `mmsg -w -c` and change the active window) to obtain application appids. You can also open the desired application windows and generate bind commands with `bind_generator.sh` (requires the new mmsg IPC), then adjust them manually to match your setup.

#### ** Use `mmsg get all-clients | jq -r '.clients[].title'` to obtain window titles for `rfcmt`, or use `rfe` with a title fragment to exclude a matching window.


---

## Examples

New mmsg IPC format:

### Focus, cycle, or launch konsole on first tag

```bash
~/local/bin/rfcm 1 org.kde.konsole konsole
```

### Focus Nautilus or launch it on current tag

```bash
~/local/bin/rfcm c org.gnome.Nautilus GSK_RENDERER=gl nautilus
```

### Launch Midnight Commander in the Alacritty terminal emulator on current tag or focus it if already open using a window title fragment

```bash
~/s/m/rfcmt c "mc [" alacritty -e mc
```

### Run Alacritty or focus it if already open, excluding Midnight Commander running in Alacritty

```bash
~/.local/bin/fre c Alacritty "mc [" alacritty
```

### Run Alacritty or focus it if already open without excluding any title fragment

```bash
~/.local/bin/fre c Alacritty "" alacritty
```

Old mmsg IPC format:


### Focus or launch konsole using rofw (wlrctl-based) on current tag

```bash
~/local/bin/rofw c org.kde.konsole konsole
```

### Focus or launch code-oss on first tag

```bash
~/local/bin/rof 1 code-oss code.mjs code --password-store=gnome-libsecret

```

### Focus Nautilus or launch it on second tag

```bash
~/local/bin/rof 2 org.gnome.Nautilus nautilus GSK_RENDERER=gl nautilus
```

---

## MangoWM Keybindings example

```ini
bind = SUPER, RETURN, spawn, ~/.local/bin/rfcm 1 org.kde.konsole konsole
bind = SUPER, e, spawn, ~/.local/bin/rfcm c org.gnome.Nautilus GSK_RENDERER=gl nautilus
bind = SUPER, m, spawn, ~/.local/bin/rfcmt "mc [" alacritty -e mc
bind = SUPER,1,spawn, ~/.local/bin/fre c Alacritty "mc [" alacritty
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


---

## How It Works

### If the app is already focused

The script searches for another matching window and focuses it. If only one matching window exists, it switches to the previously focused window.

This makes repeated key presses behave like a window cycler.

---

### If the app exists but is not focused

The script focuses the first matching window

---

### If the app is not running

The script:

1. switches to the specified tag
2. launches the application
---

## Installation

### Local install

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

- Debian
```bash
sudo apt install wlrctl
```
---

## License

GPL-3.0
