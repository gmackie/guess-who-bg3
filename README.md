# Campfire Guess Who?

A Baldur's Gate 3 mod that lets players choose and lock in a romance partner through a campfire trivia minigame.

## Features

- **Direct partner selection**: Answer questions correctly to romance your chosen companion
- **Real romance flags**: Uses the game's actual `*_RomanceActive` flags, not custom tags
- **Multiplayer safe**: Each player runs their own independent session
- **Easily customizable**: Edit questions and companion traits via JSON file

## Supported Companions

- Shadowheart
- Lae'zel
- Astarion
- Karlach
- Gale
- Wyll
- Halsin
- Minthara

## Requirements

- Baldur's Gate 3 (any platform)
- [BG3 Script Extender](https://github.com/Norbyte/bg3se/releases) (required)

## Installation

### Step 1: Install BG3 Script Extender

The Script Extender is required for this mod to function.

1. Go to [BG3 Script Extender Releases](https://github.com/Norbyte/bg3se/releases)
2. Download the latest release (e.g., `ScriptExtender-v*.zip`)
3. Extract the archive
4. Copy `DWrite.dll` to your BG3 `bin` folder:
   - **Steam (Windows)**: `C:\Program Files (x86)\Steam\steamapps\common\Baldurs Gate 3\bin`
   - **GOG (Windows)**: `C:\GOG Games\Baldur's Gate 3\bin`
   - **Steam (Mac)**: Right-click BG3 in Steam → Manage → Browse Local Files → Contents/MacOS
5. Launch the game once to verify Script Extender loads (you'll see a console window briefly appear on Windows)

### Step 2: Install the Mod

1. Download `MyRomanceGuessWho.zip` from [Releases](https://github.com/gmackie/guess-who-bg3/releases)
2. Extract the ZIP file - it contains `MyRomanceGuessWho.pak` and `info.json`
3. Copy `MyRomanceGuessWho.pak` to your BG3 Mods folder:
   - **Windows**: `%LocalAppData%\Larian Studios\Baldur's Gate 3\Mods`
   - **Mac**: `~/Documents/Larian Studios/Baldur's Gate 3/Mods`
4. Enable the mod using a mod manager (see below)

### Step 3: Enable with a Mod Manager

#### BG3 Mod Manager (Recommended)

1. Download [BG3 Mod Manager](https://github.com/LaughingLeader/BG3ModManager/releases)
2. Run the mod manager and point it to your BG3 installation
3. The mod should appear in the left panel (inactive mods)
4. Drag `Campfire Guess Who` to the right panel (active mods)
5. Click **Export Order to Game**
6. Launch the game

#### Vortex (Nexus Mods)

1. Install [Vortex](https://www.nexusmods.com/about/vortex/)
2. Add Baldur's Gate 3 as a managed game
3. Drag the `.pak` file onto Vortex or use "Install From File"
4. Enable the mod in your load order
5. Deploy mods and launch

#### Manual (No Mod Manager)

1. Copy the `.pak` file to the Mods folder (see Step 2)
2. Find or create `modsettings.lsx` in:
   - **Windows**: `%LocalAppData%\Larian Studios\Baldur's Gate 3\PlayerProfiles\Public`
   - **Mac**: `~/Documents/Larian Studios/Baldur's Gate 3/PlayerProfiles/Public`
3. Add the mod entry inside the `<Mods>` section (requires XML editing - mod managers are easier)

## How to Play

1. At camp, use the **"Campfire Guess Who?"** item from your inventory
2. A random benched companion will be selected as your mystery partner
3. Answer 5 yes/no questions about their personality using the **Answer: YES** and **Answer: NO** items
4. Score 3 or more correct answers to lock in the romance!

### Rules

- Once per Long Rest per player
- Only benched companions are eligible (not in your active party)
- Success sets the companion's `*_RomanceActive` flag
- By default, other romances are cleared (monogamy mode)

## Multiplayer

This mod is fully multiplayer compatible:

### How It Works
- **Independent sessions**: Each player can play their own Guess Who? game
- **Per-player tracking**: The "once per night" limit is tracked separately for each player
- **Host-side logic**: All game logic runs on the host's machine via Script Extender
- **Separate romance outcomes**: Each player's romance flags are set independently

### Multiplayer Setup
1. **All players** must have BG3 Script Extender installed
2. **Only the host** needs to have the mod enabled (but all players having it won't cause issues)
3. The host's mod settings apply to the session
4. Each player can use the Campfire Guess Who? item independently at camp

### Tips for Multiplayer
- Coordinate at camp so players don't start games simultaneously (avoids confusion)
- Each player gets their own random companion - you might get different people!
- Romance outcomes are per-player, so multiple players can romance the same companion

## Configuration

Edit `Data/companions.json` to customize:

### Questions

```json
"questions": {
  "ValuesMercy": "Values mercy over vengeance?",
  "LikesSnark": "Appreciates sharp, snarky humor?",
  ...
}
```

### Companion Traits

Set `true` if YES is correct, `false` if NO is correct:

```json
"traits": {
  "Shadowheart": {
    "ValuesMercy": true,
    "LikesSnark": false,
    ...
  }
}
```

### Game Settings

```json
"config": {
  "RequireSuccessScore": 3,      // Correct answers needed to win (out of 5)
  "BumpApprovalToMax": true,     // Auto-increase approval on success
  "EnforceMonogamy": true,       // Clear other romances on success
  "MultiRomanceAllowed": false,  // Allow multiple active romances
  "OncePerNight": true           // Limit to once per Long Rest
}
```

## Building from Source

### Requirements

- [LSLib](https://github.com/Norbyte/lslib) (for creating PAK files)
- OR [BG3 Modder's Multitool](https://github.com/ShinyHobo/BG3-Modders-Multitool)

### Using GitHub Actions (Easiest)

1. Fork this repository
2. Push a tag to trigger the build:
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
3. Download the built PAK from the Releases page

### Using LSLib (divine.exe)

```bash
# Windows (use absolute paths!)
divine.exe -g bg3 --action create-package --source "C:\path\to\MyRomanceGuessWho" --destination "C:\path\to\MyRomanceGuessWho.pak" -l all
```

### Using BG3 Modder's Multitool

1. Download [BG3 Modder's Multitool](https://github.com/ShinyHobo/BG3-Modders-Multitool/releases)
2. Open the Multitool
3. Drag the `MyRomanceGuessWho` folder onto the window
4. Click "Pack Mod"

## Project Structure

```
MyRomanceGuessWho/
├── Data/
│   └── companions.json              # Editable companion data & questions
├── Mods/MyRomanceGuessWho/
│   └── meta.lsx                     # Mod metadata
├── Public/MyRomanceGuessWho/
│   ├── Stats/Generated/Data/
│   │   └── _Items.txt               # Item definitions
│   └── Story/RawFiles/Goals/
│       └── ROM_GuessWho.lsx         # Osiris event routing
└── ScriptExtender/Lua/
    ├── BootstrapServer.lua          # Entry point
    ├── Server/
    │   └── GuessWho.lua             # Core game logic
    └── Shared/
        └── CompanionData.lua        # Data loader
```

## Troubleshooting

### Mod doesn't load
- Verify Script Extender is installed correctly (`DWrite.dll` in bin folder)
- Check that the mod is enabled in your mod manager
- Look for errors in `%LocalAppData%\Larian Studios\Baldur's Gate 3\Script Extender Logs`

### Item doesn't appear
- Make sure you've enabled the mod and exported/deployed your load order
- Try starting a new game or loading an earlier save

### Multiplayer issues
- Ensure all players have Script Extender installed
- Have the host verify their mod load order

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Editing Questions/Traits

Non-technical contributors can simply edit `Data/companions.json` - no Lua knowledge required!

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

- Larian Studios for Baldur's Gate 3
- [Norbyte](https://github.com/Norbyte) for BG3 Script Extender and LSLib
- [LaughingLeader](https://github.com/LaughingLeader) for BG3 Mod Manager
- [ShinyHobo](https://github.com/ShinyHobo) for BG3 Modder's Multitool

## Disclaimer

This is a fan-made mod. Baldur's Gate 3 is a trademark of Larian Studios. All trademarks belong to their respective owners.
