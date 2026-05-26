# MangoWM Run or Focus

A small helper script for [MangoWM](https://github.com/DreamMaoMao/mangowm) that:

- focuses an existing application window
- cycles through multiple windows of the same app
- switches to the previously focused window when only one matching window is active
- automatically switches between tags
- launches the application if it is not running

## Purpose

Bind this script to a single key to turn it into an all-in-one app handler. Pressing the key will focus an existing window of the app, cycle through multiple windows of the same app, switch to the previously focused window if only one match exists, automatically switch tags when needed, or launch the app if it is not running.

Ideal for a fast single-key workflow: launching, focusing, switching, and cycling windows without separate bindings.

---

## Requirements

- MangoWM
- Bash
- wlrctl (required for the `rofw.sh` variant)

---

## Usage

Use `rfcm` (new IPC `mmsg`) as the primary variant:

```bash
rfcm <tag|c> <appid> <command...>
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
| `appid` | Window app ID used by MangoWM (check with `mmsg -w -c`) |
| `command` | Command used to launch the application (arguments and flags are supported) |
| `process_name` | Process name checked with `pgrep -x` and `pgrep -f` (legacy IPC variants only) |

---

## Examples

### Focus, cycle, or launch konsole using rfcm (new mmsg IPC variant)

```bash
~/local/bin/rfcm 1 org.kde.konsole konsole
```

### Focus Nautilus or launch it on second tag

```bash
~/local/bin/rfcm 2 org.gnome.Nautilus GSK_RENDERER=gl nautilus
```

### Focus or launch konsole on current tag

```bash
~/local/bin/rfcm c org.kde.konsole konsole
```

Older IPC variants:


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
bind = SUPER, RETURN, spawn, ~/local/bin/rfcm 1 org.kde.konsole konsole
bind = SUPER, e, spawn, ~/local/bin/rfcm 2 org.gnome.Nautilus GSK_RENDERER=gl nautilus
```

Older IPC variants:

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
chmod +x ~/.local/bin/rfcm
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
