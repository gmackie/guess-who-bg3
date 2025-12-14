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

- [BG3 Script Extender](https://github.com/Norbyte/bg3se) (required)

## Installation

1. Install BG3 Script Extender if you haven't already
2. Download the latest `.pak` file from [Releases](https://github.com/gmackie/guess-who-bg3/releases)
3. Place the `.pak` file in your BG3 Mods folder:
   - Windows: `%LocalAppData%\Larian Studios\Baldur's Gate 3\Mods`
   - Mac: `~/Documents/Larian Studios/Baldur's Gate 3/Mods`
4. Enable the mod in your mod manager of choice

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

### Using LSLib (divine.exe)

```bash
# Windows
divine.exe -g bg3 -a create-package -s MyRomanceGuessWho -d MyRomanceGuessWho.pak

# The mod folder structure should be:
# MyRomanceGuessWho/
#   Mods/MyRomanceGuessWho/meta.lsx
#   Public/...
#   ScriptExtender/...
#   Data/companions.json
```

### Using BG3 Modder's Multitool

1. Open the Multitool
2. Drag the `MyRomanceGuessWho` folder onto the window
3. Click "Pack Mod"

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

## Disclaimer

This is a fan-made mod. Baldur's Gate 3 is a trademark of Larian Studios. All trademarks belong to their respective owners.
