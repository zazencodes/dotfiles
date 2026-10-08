# Hammerspoon

Config: [`hammerspoon/init.lua`](../hammerspoon/init.lua), symlinked to `~/.hammerspoon/init.lua`.

After editing, reload from the Hammerspoon menu bar icon → **Reload Config**.

## Hotkeys

### Resize focused window (`cmd+ctrl`)

Resizes stay centered on the window. Hold the keys to repeat.

| Key | Action |
| --- | --- |
| `h` / `l` | Shrink / grow width |
| `j` / `k` | Shrink / grow height |
| `-` / `=` | Shrink / grow uniformly |

### Move focused window (`cmd+ctrl+shift`)

Hold the keys to repeat.

| Key | Action |
| --- | --- |
| `h` / `l` | Move left / right |
| `j` / `k` | Move down / up |

### Paste downsized image (`ctrl+shift+v`)

If the clipboard holds an image, pastes a copy scaled to 50% (longest edge capped at 1600px), then restores the original clipboard. Otherwise sends a normal paste. Settings are the `IMAGE_PASTE_*` constants at the top of `init.lua`.

### New CotEditor document (`ctrl+alt+cmd+n`)

Opens a new CotEditor document and brings it to the front. AeroSpace places it on the current workspace. The first use triggers a macOS prompt asking to let Hammerspoon control CotEditor.
