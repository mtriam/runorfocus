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
- Works entirely through `mmsg`

---

## Requirements

- MangoWM
- Bash

---

## Usage

```bash
rof  <fallback_tag|c> <appid> <process_name> <command>
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

---

## Notes

- `appid` must match MangoWM window appid exactly.
- For Flatpak apps, appid may differ from process name.
- The script uses `pgrep -x` and `pgrep -f` for process detection.

---

## License

GPL 3.0
