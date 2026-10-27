# AeroSpace desktop

The configuration replaces skhd shortcuts and yabai tiling with
AeroSpace 0.21.3-Beta or newer. Ansible installs the app and sets macOS preferences;
this package owns `~/.config/aerospace/aerospace.toml`. No yabai or skhd dependency
is needed for this profile.

## Controls

| Input | Action |
|---|---|
| Alt-1…9 | Switch AeroSpace workspace, without transition animation |
| Alt-Shift-1…9 | Send window to workspace without following |
| Alt-P / Alt-N | Focus display to the left / right |
| Alt-F | Toggle AeroSpace fullscreen (maximize within the workspace) |
| Alt-B | Balance the current layout |
| Alt-D | Toggle floating / tiled |
| Alt-Shift-R | Reload config; this replaces the old process-restart shortcut |
| Alt-minus / Alt-equal | Shrink / grow a tiled window by 50 along its container axis |
| Alt-Shift-minus / Alt-Shift-equal | Shrink / grow along the other axis |
| Alt-slash | Switch between horizontal / vertical tiles |
| Alt-Shift-H/J/K/L | Group with the window to the left / below / above / right |
| Ctrl+Cmd-left-drag | Native macOS window movement, after applying Ansible preferences |

Hover focus is enabled; keyboard focus does not move the pointer. Floating windows
use normal edge/corner resizing. Gaps are 6 with no outer padding. System Settings,
System Information and windows whose titles end in `Preferences` float. Title
matching happens at detection time; a title assigned later can miss the rule.

There are no automatic app-to-workspace rules: the existing setup used manual
placement. To recreate this machine's arrangement, send Ghostty to 1, Zen to 2
and Spotify to 3 using Alt-Shift-number.

## Migration on an existing Mac

1. Install AeroSpace and preferences with Ansible's `aerospace,macos-preferences`
   tags. Update this checkout, then stow both desktop packages:

   ```sh
   cd ~/projects/dotfiles
   stow --target="$HOME" --verbose aerospace window-effects
   ```

   Move an existing `~/.aerospace.toml` aside first: AeroSpace rejects ambiguous
   config locations. Review Stow conflicts instead of overwriting local files.
   Archive any existing yabai/skhd configuration before retiring it.
2. Install [Window Effects](https://github.com/jobrk/window-effects) with Ansible's
   `window-effects` tag and `window_effects_enabled=true`. Enable
   `window_effects_autoload=true` for recovery after Dock restarts. This requires
   administrator authentication and the documented reduced-SIP/arm64e setup;
   neither repository changes SIP. See Ansible's README for the exact command.
3. Save the existing window/Space arrangement, then consolidate ordinary windows
   onto one native macOS desktop per display while yabai still runs. Native
   Spaces do not become AeroSpace workspaces. Keep the old Spaces for rollback.
4. Clear yabai's effects so the new journal saves the apps' normal appearance,
   then stop and disable the old services before restarting Dock:

   ```sh
   yabai -m config window_opacity off
   yabai -m config window_shadow on
   skhd --stop-service
   yabai --stop-service
   launchctl disable "gui/$(id -u)/com.koekeishiya.skhd"
   launchctl disable "gui/$(id -u)/com.asmvik.yabai"
   killall Dock
   sudo "/Library/Application Support/WindowEffects/loader"
   open -a AeroSpace
   ```

   Restarting Dock removes yabai's resident scripting addition. Load only our
   backend. Grant AeroSpace Accessibility access when prompted.
5. Validate the active config and start the appearance watcher:

   ```sh
   aerospace reload-config --dry-run --no-gui --warnings-as-errors
   aerospace config --config-path
   launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/local.window-effects.plist"
   ~/.local/bin/window-effects doctor
   ```

   Both apps now start at login. Ansible's `desktop_activate=true` can start them
   on subsequent provisions, but refuses while yabai/skhd are running. Native
   dragging may require relaunching existing apps or logging out/in.
6. Send Ghostty to workspace 1, Zen to 2 and Spotify to 3. Test the controls below,
   then run the explicit cleanup when ready to retire the old desktop.

The full installer selects both desktop packages on macOS. Stowing configuration
alone does not start or stop any services.

## Differences and acceptance checks

- **Shadows and opacity:** Window Effects removes shadows from AeroSpace-managed
  normal windows and sets active opacity to 1.0, inactive to 0.9. System Settings
  and System Information are excluded. Unmanaged windows and OS panels retain
  their appearance. Policy lives in `window-effects/.config/window-effects/config.json`.
  Ghostty's `window-decoration = none` and Zen's compact mode remain app settings.
- **Layout:** this uses AeroSpace's container layout, not automatic BSP
  second-child splitting. Use the grouping controls above for nested splits.
- **Mouse:** Ctrl+Cmd-left-drag replaces Ctrl-left-drag; keyboard resizing replaces
  Ctrl-right-drag. Window Effects handles appearance only.
- **Workspaces:** instant switching applies to AeroSpace workspaces. Native
  fullscreen Spaces, Mission Control and application animations remain separate.
- **Hover focus:** test native browser/video fullscreen and popups. If focus jumps,
  set `focus-follows-mouse.enabled = false` and reload.

Core integration is verified on macOS 27.2 (26B123), including shadows, opacity,
restoration and Dock recovery; see the
[compatibility record](https://github.com/jobrk/window-effects/blob/main/COMPATIBILITY.md).
Sleep/wake, external-display reconnection, physical mouse gestures and native
fullscreen/popups still need interactive testing. Check applications that use
script/Java launchers: AeroSpace can miss their windows.

## Retire the old desktop

After cutover, archive any local legacy configuration, then run from the Ansible
checkout:

```sh
ansible-playbook -i inventory.ini main.yml --tags desktop-cleanup --ask-become-pass
```

This explicit tag requires the old daemons to be stopped and the new desktop to
respond. It removes yabai/skhd packages, their LaunchAgents, their former Stow
links, `/Library/ScriptingAdditions/yabai.osax` and `/etc/sudoers.d/yabai`.
Custom configuration directories and native Spaces are left intact. It does not
change SIP or Window Effects' files and autoload rule. Normal provisioning does
not run cleanup.

## Rollback

After retirement, rollback requires reinstalling yabai/skhd and recovering their
configurations. Their last tracked versions are available with
`git archive 728257d yabai skhd | tar -x` from this checkout; use the private
backup instead if there were local edits. Reinstall the packages before the
legacy service commands below.

Stop the appearance watcher first and restore its saved state:

```sh
launchctl bootout "gui/$(id -u)/local.window-effects"
launchctl disable "gui/$(id -u)/local.window-effects"
~/.local/bin/window-effects restore
```

If the backend is unavailable, load it before running restore. Set
`start-at-login = false` in the AeroSpace config and reload it. Run
`aerospace enable off` to bring hidden windows onscreen, then quit AeroSpace from
its menu. After reinstalling the old packages and recovering their configs,
restore their configuration links and start the services:

```sh
stow --target="$HOME" skhd yabai
launchctl enable "gui/$(id -u)/com.koekeishiya.skhd"
launchctl enable "gui/$(id -u)/com.asmvik.yabai"
skhd --start-service
yabai --start-service
```

Native Space placement may need manual restoration.
The removed scripting addition and its sudoers rule must also be reinstalled if
the old configuration needs them. Nothing in this migration edits SIP. To remove the
Window Effects loader and its autoload rule, use its `scripts/uninstall-backend.sh`
with sudo after stopping the watcher and restoring effects. Restart Dock to unload
its resident code. Do not re-enable SIP while continuing to use Window Effects.

To undo the newly added native dragging preference, remove its entry from
Ansible and run `defaults delete -g NSWindowShouldDragOnGesture`, then relaunch
affected apps or log out/in. The other managed preferences match the values
observed on this machine before migration.

## Sources

- [AeroSpace guide](https://nikitabobko.github.io/AeroSpace/guide)
- [Commands](https://nikitabobko.github.io/AeroSpace/commands)
- [Native modifier dragging](https://github.com/nikitabobko/AeroSpace#tip-of-the-day)
- [macOS 27 launcher detection report](https://github.com/nikitabobko/AeroSpace/discussions/2282)
- [macOS 27 desktop-widget report](https://github.com/nikitabobko/AeroSpace/discussions/2265)
- [Native fullscreen and hover focus report](https://github.com/nikitabobko/AeroSpace/discussions/2277)
