# MangoWM Run or Focus

A small helper script for [MangoWM](https://github.com/DreamMaoMao/mangowm) that:

- focuses an existing application window if it already exists
- cycles through multiple windows of the same app
- switches between tags automatically
- launches the application if it is not running

Perfect for keybindings like:

- press once → focus app
- press again → cycle to next window
- app not running → start it

---

## Features

- Focus existing windows by `appid`
- Cycle through windows on repeated key presses
- searches only tags that contain windows (avoids empty tags for faster switching)
- Optional fallback tag
- Launch app if no matching window exists
- Detect running processes before launching
- Works entirely through `mmsg` (or mmseg and wlrctl)

---

## Requirements

- MangoWM
- Bash
- wlrctl (required for the `rofw.sh` variant)

---

## Usage

Use either the original `rof` script or the `rofw` (wlrctl-based) variant.

```bash
rof <fallback_tag|c> <appid> <process_name> <command...>
```

or

```bash
rofw <fallback_tag|c> <appid> <command...>
```



### Arguments

| Argument | Description |
|---|---|
| `fallback_tag` | Tag where the application will be launched if it is not currently running |
| `c` | Use current tag as fallback |
| `appid` | Window appid used by MangoWM (check with `mmsg -w -c`) |
| `process_name` | Process name checked with `pgrep -x` and `pgrep -f` |
| `command` | Command used to launch the app (you can include arguments, flags, etc.) |

---

## Examples

### Focus or launch konsole on current tag

```bash
~/local/bin/rof c org.kde.konsole konsole konsole
```

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
bind = SUPER, RETURN, spawn, ~/local/bin/rof c org.kde.konsole konsole konsole
bind = SUPER, e, spawn, ~/local/bin/rof 2 org.gnome.Nautilus nautilus GSK_RENDERER=gl nautilus
```

or

```ini
bind = SUPER, RETURN, spawn, ~/local/bin/rofw c org.kde.konsole konsole
bind = SUPER, e, spawn, ~/local/bin/rofw 2 org.gnome.Nautilus GSK_RENDERER=gl nautilus
```


---

## How It Works

### If the app is already focused

The script:

1. searches for another matching window
2. cycles through windows on the current tag
3. searches other tags
4. wraps around all tags if needed

This makes repeated key presses behave like a window cycler.

---

### If the app exists but is not focused

The script:

1. searches the fallback tag first
2. searches remaining tags
3. focuses the first matching window

- rofw — focuses the window directly (wlrctl window focus).

---

### If the app is not running

The script:

1. switches to the fallback tag
2. launches the command

---

## Installation

### Local install

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

## Notes

Window cycling occurs only on the active tag when there is more than one window; when there is only one, the script jumps through all tags that have windows.


---

## License

GPL 3.0
