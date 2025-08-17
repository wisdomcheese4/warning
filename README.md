# Warning Addon for Windower (Final Fantasy XI)

## Overview
The Warning addon is a tool for Final Fantasy XI players using Windower. It provides real-time alerts for enemy TP (Technique Points) moves and tracked spells used on the player or their party members. The addon displays a persistent, draggable on-screen menu that shows "No Threat Detected" in green when idle. When a threat is detected, it switches to red text displaying the ability in the format "<Ability> --> <Player(s) targeted>", and plays an audio cue. Each alert lasts for 8 seconds before disappearing, and multiple alerts are listed on separate lines if detected in quick succession.

This addon helps players react quickly to dangerous enemy abilities, improving awareness in combat situations like parties, alliances, or solo play.

## Features
- **Persistent Menu**: Always-visible draggable text box on screen.
  - Green "No Threat Detected" when no alerts.
  - Red text for active alerts, e.g., "Leaf Dagger --> Khalisar" or "Fire --> Khalisar".
- **Multi-Alert Support**: Handles multiple threats simultaneously, listing each on a new line.
- **Audio Cue**: Plays a custom sound (alert.wav) when a threat is detected.
- **Customizable Position**: Drag with mouse or use in-game command to set position, saved for future loads.
- **Detection Logic**: Detects mob TP readies (category 7) and spell starts (category 8) targeting party members.
- **Spell Tracking**: Use commands to add/remove specific spells to track; TP moves are always tracked.
- **Configurable**: Settings like font size, colors, display time, and tracked spells are adjustable via commands or settings.xml.

## Requirements
- **Windower**: Latest version installed and running.
- **FFXI**: Final Fantasy XI client.
- **Libraries**: Requires Windower's 'resources', 'texts', 'config', 'coroutine', 'tables', and 'sets' libraries (included by default).
- **Sound File**: A WAV file named `alert.wav` placed in the addon's folder for audio alerts. You can download free alert sounds online and convert to WAV if needed.

## Installation
1. **Create Folder**: In your Windower directory, go to `addons` and create a new folder named `warning` (lowercase).
2. **Save Script**: Copy the provided `warning.lua` code into a file named `warning.lua` inside the `warning` folder.
3. **Add Sound**: Place your `alert.wav` file in the `warning` folder.
4. **Load Addon**: In-game, type `//lua load warning` (or add to your init script for auto-loading).
5. **Optional**: If settings.xml generates in `warning/data/`, you can edit it for customizations (e.g., change sound file name or tracked spells).

## Usage
- **Loading**: Use `//lua load warning` in-game chat.
- **Unloading**: `//lua unload warning` to disable.
- **Positioning**:
  - Drag the text box with your mouse to move it.
  - Or use `//warn pos x y` (e.g., `//warn pos 400 400` for center screen). Position saves automatically.
- **Reload Settings**: `//warn reload` to reload changes from settings.xml.
- **Spell Tracking Commands**:
  - `//warn add Spell Name` (e.g., `//warn add Fire`): Adds a spell to track (case sensitive, exact match).
  - `//warn remove Spell Name` (e.g., `//warn remove Fire`): Removes a tracked spell.
  - `//warn list`: Lists all currently tracked spells.
- **Testing**: Engage an enemy that readies a TP move or casts a tracked spell on you/party. The menu should update to red with details, play the sound, and revert after 8 seconds.

## Customization
- **Font Size/Color**: Edit the `defaults` table in `warning.lua` (e.g., size = 18 for larger text).
- **Display Time**: Change `display_time = 8` to adjust how long each alert shows.
- **Sound**: Rename your WAV file and update `sound = 'yourfile.wav'` in defaults or settings.xml.
- **Tracked Spells**: Managed via in-game commands; saved in settings.xml.
- **Message Format**: Modify the `msg` string in the action event to change the alert text.
- After changes, reload the addon or restart Windower.

## Troubleshooting
- **No Alerts**: Ensure the enemy is readying a TP move or casting a tracked spell on you/party. Check Windower console for errors.
- **No Sound**: Verify `alert.wav` is in the folder and plays in a media player. Test path with a debug version if needed.
- **Text Not Visible**: Adjust position with command or drag. Ensure texts library is loaded.
- **Errors**: Delete `data/settings.xml` to reset defaults. Report errors with details for fixes.
- **Multiple Alerts**: If threats overlap, they stack vertically; oldest disappears first after 8 seconds.
- **Spell Not Adding**: Ensure exact spelling (e.g., "Fire" not "fire"). Use `//warn list` to check.

## Known Limitations
- Detects mob TP readies (category 7) and spell starts (category 8), but only tracked spells for magic.
- Audio requires a valid WAV file; no support for other formats.
- No filtering for specific mobs—alerts on all enemy threats targeting party.
- Performance: In heavy combat with many threats, the menu may grow tall; consider shortening display_time.

## Credits
- Developed by Wisdomcheese4.
- Based on Windower API and community resources.
- Inspired by FFXI addon examples for packet handling.

## Version History
- **1.0** (August 16, 2025): Initial release with TP detection, spell tracking, menu, audio, and multi-alert support.

For support or suggestions, contact Wisdomcheese4 or post in FFXI forums/Windower Discord. Enjoy safer adventuring in Vana'diel!
