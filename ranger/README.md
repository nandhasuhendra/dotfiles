# Ranger

Configuration for the Ranger terminal file manager.

## Files

- `rc.conf` — Ranger keybindings and behavior.
- `rifle.conf` — file-opening rules.
- `scope.sh` — file preview helpers.
- `commands.py` — custom Ranger commands.
- `commands_full.py` — extended command implementation/reference.

## Installation

Ranger normally reads configuration from `~/.config/ranger`.

```bash
mkdir -p ~/.config/ranger
ln -sfn "$PWD/ranger/rc.conf" ~/.config/ranger/rc.conf
ln -sfn "$PWD/ranger/rifle.conf" ~/.config/ranger/rifle.conf
ln -sfn "$PWD/ranger/scope.sh" ~/.config/ranger/scope.sh
ln -sfn "$PWD/ranger/commands.py" ~/.config/ranger/commands.py
```

Make sure `scope.sh` is executable when installed as a standalone file.

## Scope

Ranger-specific behavior belongs here; terminal, shell, and editor settings remain separate.