# AGENTS.md

This document provides guidance for AI coding agents working on this project.

## Project Overview

**Campfire Guess Who?** is a Baldur's Gate 3 mod built using BG3 Script Extender (BG3SE). It adds a campfire minigame that lets players choose and lock in a romance partner through trivia questions about companions.

## Tech Stack

- **BG3 Script Extender (BG3SE)** - Lua scripting framework for BG3 modding
- **Lua** - Primary scripting language (runs server-side via BG3SE)
- **LSLib/divine.exe** - Tool for creating PAK files (Windows only)
- **GitHub Actions** - CI/CD for automated PAK builds

## Project Structure

```
MyRomanceGuessWho/
├── .github/workflows/
│   └── build.yml              # GitHub Actions workflow for PAK creation
├── Data/
│   └── companions.json        # Editable companion data (questions, traits, config)
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
│       └── CompanionData.lua  # Loads companion data from JSON
├── scripts/
│   ├── build.sh               # Local build script (requires divine in PATH)
│   └── pack-mod.sh            # ShinyHobo-style pack script
├── AGENTS.md                  # This file
├── LICENSE                    # MIT License
└── README.md                  # User documentation
```

## Key Files

### `Data/companions.json`
The primary data file - **non-technical team members can edit this directly**. Contains:
- `companions` - List of romanceable companions with display name variants
- `romanceFlags` - Actual BG3 story flags (don't change unless you know the game's internals)
- `questions` - Trivia questions displayed to players
- `traits` - Per-companion answers (true = YES is correct)
- `config` - Game settings (score threshold, monogamy, etc.)

### `ScriptExtender/Lua/Server/GuessWho.lua`
Core game logic:
- `GuessWho.Start(player)` - Initiates a session, picks random companion, shows first question
- `GuessWho.Answer(player, isYes)` - Processes answer, updates score, advances or ends game
- `GuessWho.ResetNight()` - Clears nightly played status (called after Long Rest)

### `Mods/MyRomanceGuessWho/meta.lsx`
Mod metadata in LSX (XML) format. Key fields:
- `UUID` - Unique mod identifier
- `Version64` - Version number (BG3's int64 format)
- `Folder` - Must match the mod folder name exactly
- Dependencies section declares BG3SE requirement

## Development Guidelines

### Adding New Questions
1. Add the question key and text to `Data/companions.json` under `questions`
2. Add the answer (true/false) for each companion under `traits`
3. No Lua changes needed - data is loaded at runtime

### Adding New Companions
1. Add to `companions` array in `companions.json` with name variants
2. Add their romance flags to `romanceFlags` and `romanceAvailableFlags`
3. Add their trait answers under `traits`

### Modifying Game Logic
- Edit `ScriptExtender/Lua/Server/GuessWho.lua`
- BG3SE API docs: https://github.com/Norbyte/bg3se/tree/master/Docs
- Osiris functions available via `Osi.*` global

### Testing Locally
1. Build the PAK using divine.exe or BG3 Modder's Multitool
2. Copy PAK to BG3 Mods folder
3. Enable via mod manager
4. In-game: use console commands or spawn the starter item

## Build Process

### Automated (GitHub Actions)
Push a tag like `v1.0.0` to trigger the build workflow:
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Manual (Windows)
```powershell
divine.exe -g bg3 --action create-package --source MyRomanceGuessWho --destination MyRomanceGuessWho.pak -l all
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
