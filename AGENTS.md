# AGENTS.md

This document provides guidance for AI coding agents working on this project.

## Project Overview

**Campfire Guess Who?** is a Baldur's Gate 3 mod built using BG3 Script Extender (BG3SE). It adds a campfire minigame that lets players choose and lock in a romance partner through trivia questions about companions.

## Tech Stack

- **BG3 Script Extender (BG3SE)** - Lua scripting framework for BG3 modding
- **Lua** - Primary scripting language (runs server-side via BG3SE)
- **JSON** - All game data is stored in editable JSON files
- **LSLib/divine.exe** - Tool for creating PAK files (Windows only)
- **GitHub Actions** - CI/CD for automated PAK builds

## Project Structure

```
MyRomanceGuessWho/
├── .github/workflows/
│   └── build.yml              # GitHub Actions workflow for PAK creation
├── Data/                      # All editable game data (JSON files)
│   ├── companions.json        # Companion definitions and romance flags
│   ├── questions.json         # Trivia questions
│   ├── traits.json            # Per-companion answers to questions
│   └── config.json            # Game settings and messages
├── Mods/MyRomanceGuessWho/
│   └── meta.lsx               # Mod metadata (UUID, version, dependencies)
├── Public/MyRomanceGuessWho/
│   ├── Stats/Generated/Data/
│   │   └── _Items.txt         # Item definitions (starter item, YES/NO answers)
│   └── Story/RawFiles/Goals/
│       └── ROM_GuessWho.lsx   # Osiris goal for event routing
├── ScriptExtender/Lua/
│   ├── BootstrapServer.lua    # Entry point, registers Osiris listeners
│   ├── Server/
│   │   └── GuessWho.lua       # Core game logic (sessions, scoring, romance flags)
│   └── Shared/
│       └── CompanionData.lua  # Loads all JSON data files
├── scripts/
│   ├── build.sh               # Local build script (requires divine in PATH)
│   └── pack-mod.sh            # ShinyHobo-style pack script
├── AGENTS.md                  # This file
├── LICENSE                    # MIT License
└── README.md                  # User documentation
```

## Data Files (JSON)

All game data is in `Data/` folder. **Non-technical team members can edit these directly.**

### `Data/questions.json`
Defines trivia questions shown to players.
```json
{
  "questions": [
    { "key": "ValuesMercy", "text": "Values mercy over vengeance?" },
    { "key": "LikesSnark", "text": "Appreciates sharp, snarky humor?" }
  ]
}
```
- `key` - Unique identifier (used in traits.json)
- `text` - Question text shown to player

### `Data/traits.json`
Defines each companion's answers to questions.
```json
{
  "Shadowheart": {
    "_description": "Half-elf cleric of Shar...",
    "ValuesMercy": true,
    "LikesSnark": false
  }
}
```
- Keys starting with `_` are ignored (use for comments)
- `true` = YES is the correct answer
- `false` = NO is the correct answer

### `Data/config.json`
Game settings and customizable messages.
```json
{
  "gameplay": {
    "RequireSuccessScore": 3,
    "QuestionsPerRound": 5,
    "OncePerNight": true
  },
  "romance": {
    "BumpApprovalToMax": true,
    "EnforceMonogamy": true
  },
  "messages": {
    "GameStart": "Campfire Guess Who? begins...",
    "SuccessMessage": "You scored %d/%d. You and %s share a deep connection."
  }
}
```

### `Data/companions.json`
Companion definitions and BG3 romance flags.
```json
{
  "companions": [
    { "key": "Shadowheart", "names": ["Shadowheart"], "enabled": true }
  ],
  "romanceFlags": {
    "Shadowheart": "Shadowheart_RomanceActive"
  }
}
```
- `enabled` - Set to `false` to disable a companion
- `names` - Display name variants for UUID resolution
- `romanceFlags` - **Don't change unless you know BG3's internals**

## Key Lua Files

### `ScriptExtender/Lua/Shared/CompanionData.lua`
Loads all JSON files and exports globals:
- `CompanionRoster` - List of enabled companions
- `RomanceFlags` / `RomanceAvailableFlags` - BG3 flag names
- `GuessWhoTraitText` - Question key → text lookup
- `CompanionTraits` - Companion → trait answers
- `Config` - Flattened gameplay settings
- `Messages` - Customizable UI text

### `ScriptExtender/Lua/Server/GuessWho.lua`
Core game logic:
- `GuessWho.Start(player)` - Initiates a session, picks random companion, shows first question
- `GuessWho.Answer(player, isYes)` - Processes answer, updates score, advances or ends game
- `GuessWho.ResetNight()` - Clears nightly played status (called after Long Rest)

## Development Guidelines

### Adding New Questions
1. Add to `Data/questions.json`:
   ```json
   { "key": "NewQuestion", "text": "Does this companion like cheese?" }
   ```
2. Add answers for ALL companions in `Data/traits.json`:
   ```json
   "Shadowheart": { "NewQuestion": true, ... }
   ```
3. No Lua changes needed - data is loaded at runtime

### Adding New Companions
1. Add to `companions` array in `Data/companions.json`
2. Add romance flags to `romanceFlags` and `romanceAvailableFlags`
3. Add full trait entry in `Data/traits.json`

### Customizing Messages
Edit `Data/config.json` under `messages`. Use `%s` for strings, `%d` for numbers:
- `SuccessMessage`: params are (score, total, companionName)
- `FailureMessage`: params are (score, total, companionName)
- `QuestionPrompt`: params are (currentIndex, total, questionText)

### Disabling a Companion
Set `"enabled": false` in `Data/companions.json`:
```json
{ "key": "Minthara", "names": ["Minthara"], "enabled": false }
```

### Testing Locally
1. Build the PAK using divine.exe or BG3 Modder's Multitool
2. Copy PAK to BG3 Mods folder
3. Enable via mod manager
4. In-game: use console commands or spawn the starter item

### Hot-Reloading Data (Development)
Call `ReloadCompanionData()` from BG3SE console to reload all JSON files without restarting.

## Build Process

### Automated (GitHub Actions)
Push a tag like `v1.0.0` to trigger the build workflow:
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Manual (Windows)
```powershell
divine.exe -g bg3 --action create-package --source "C:\path\to\MyRomanceGuessWho" --destination "C:\path\to\MyRomanceGuessWho.pak" -l all
```

## Common Tasks

### Bump Version
1. Update `Version64` in `Mods/MyRomanceGuessWho/meta.lsx`
2. BG3 uses a specific int64 format - see existing value for reference

### Change Mod UUID
Only do this if creating a derivative mod:
1. Generate new UUID (e.g., `uuidgen` command)
2. Update in `meta.lsx` under ModuleInfo

### Debug in Game
BG3SE provides a console. Common debug approaches:
- Add `Ext.Utils.Print()` statements in Lua
- Check `%LocalAppData%\Larian Studios\Baldur's Gate 3\Script Extender Logs`

## Important Notes

- **JSON comments**: Use keys starting with `_` (e.g., `_comment`, `_description`)
- **Absolute paths**: divine.exe requires absolute paths for source/destination
- **meta.lsx Folder field**: Must exactly match the mod directory name
- **BG3SE dependency**: Mod won't load without Script Extender installed
- **Romance flags**: Use the exact flag names from the game - they're case-sensitive
- **Multiplayer**: Each player runs independent sessions; logic executes on host

## Resources

- [BG3SE GitHub](https://github.com/Norbyte/bg3se)
- [BG3SE Documentation](https://github.com/Norbyte/bg3se/tree/master/Docs)
- [LSLib GitHub](https://github.com/Norbyte/lslib)
- [BG3 Modding Wiki](https://bg3.wiki/wiki/Modding:Introduction)
- [BG3 Modder's Multitool](https://github.com/ShinyHobo/BG3-Modders-Multitool)
