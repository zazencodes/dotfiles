# AeroSpace

Config: [`.aerospace.toml`](../.aerospace.toml), symlinked to `~/.aerospace.toml`.

After editing, reload with `alt+shift+;` then `esc`.

## Settings

- Tiling layout by default, orientation chosen from monitor shape. No gaps.
- Persistent workspaces: `1`–`9` and `A C E G I M N O P Q R S T U V W X Y Z`.
- Mouse jumps to the center of the monitor when focus moves to another monitor.
- Does not start at login.

## Hotkeys (`alt`)

| Key | Action |
| --- | --- |
| `h` / `j` / `k` / `l` | Focus left / down / up / right |
| `shift` + `h` / `j` / `k` / `l` | Move window left / down / up / right |
| `-` / `=` | Shrink / grow window |
| `/` | Tiles layout (toggle horizontal / vertical) |
| `,` | Accordion layout (toggle horizontal / vertical) |
| `1`–`9`, letter | Go to workspace |
| `shift` + `1`–`9`, letter | Move window to workspace |
| `tab` | Go back to the previous workspace |
| `shift+tab` | Move workspace to the next monitor |
| `shift+;` | Enter service mode |

Workspaces `B`, `D`, `F` (and `H J K L`) are unbound, so `alt+b`, `alt+d`, `alt+f` stay free for readline word navigation in the terminal.

## Service mode (`alt+shift+;`)

Each key runs its action and returns to main mode.

| Key | Action |
| --- | --- |
| `esc` | Reload config |
| `space` | Toggle fullscreen |
| `r` | Reset layout (flatten workspace tree) |
| `f` | Toggle floating / tiling |
| `h` / `j` / `k` / `l` | Join with window left / down / up / right |
