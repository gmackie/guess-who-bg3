---@diagnostic disable: undefined-global
-- Campfire Guess Who? - Companion Data
-- Loads companion data from external JSON file for easy editing

---------------------------------------------------------------------------
-- DATA LOADING FROM JSON
---------------------------------------------------------------------------

-- Default fallback data (used if JSON fails to load)
local DefaultData = {
    companions = {
        { key = "Shadowheart", names = { "Shadowheart" } },
        { key = "Laezel",      names = { "Lae'zel", "Laezel" } },
        { key = "Astarion",    names = { "Astarion" } },
        { key = "Karlach",     names = { "Karlach" } },
        { key = "Gale",        names = { "Gale" } },
        { key = "Wyll",        names = { "Wyll" } },
        { key = "Halsin",      names = { "Halsin" } },
        { key = "Minthara",    names = { "Minthara" } },
    },
    romanceFlags = {
        Shadowheart = "Shadowheart_RomanceActive",
        Laezel      = "LaeZel_RomanceActive",
        Astarion    = "Astarion_RomanceActive",
        Karlach     = "Karlach_RomanceActive",
        Gale        = "Gale_RomanceActive",
        Wyll        = "Wyll_RomanceActive",
        Halsin      = "Halsin_RomanceActive",
        Minthara    = "Minthara_RomanceActive",
    },
    romanceAvailableFlags = {
        Shadowheart = "Shadowheart_RomanceAvailable",
        Laezel      = "LaeZel_RomanceAvailable",
        Astarion    = "Astarion_RomanceAvailable",
        Karlach     = "Karlach_RomanceAvailable",
        Gale        = "Gale_RomanceAvailable",
        Wyll        = "Wyll_RomanceAvailable",
        Halsin      = "Halsin_RomanceAvailable",
        Minthara    = "Minthara_RomanceAvailable",
    },
    questions = {
        ValuesMercy       = "Values mercy over vengeance?",
        LikesSnark        = "Appreciates sharp, snarky humor?",
        HatesAuthority    = "Chafes against rules and authority?",
        PrefersSubtlety   = "Prefers subtlety to brute force?",
        EnjoysRelics      = "Fascinated by relics and forbidden lore?",
        OpenFaith         = "Open and public about their faith?",
        ProtectsInnocents = "Protects innocents even at risk?",
        LovesRisk         = "Loves risky gambits?",
    },
    traits = {
        Shadowheart = { ValuesMercy=true, LikesSnark=false, HatesAuthority=false, PrefersSubtlety=true, EnjoysRelics=true, OpenFaith=false, ProtectsInnocents=true, LovesRisk=false },
        Laezel      = { ValuesMercy=false, LikesSnark=false, HatesAuthority=false, PrefersSubtlety=false, EnjoysRelics=false, OpenFaith=false, ProtectsInnocents=false, LovesRisk=true },
        Astarion    = { ValuesMercy=false, LikesSnark=true, HatesAuthority=true, PrefersSubtlety=true, EnjoysRelics=false, OpenFaith=false, ProtectsInnocents=false, LovesRisk=true },
        Karlach     = { ValuesMercy=true, LikesSnark=true, HatesAuthority=true, PrefersSubtlety=false, EnjoysRelics=false, OpenFaith=false, ProtectsInnocents=true, LovesRisk=true },
        Gale        = { ValuesMercy=true, LikesSnark=true, HatesAuthority=false, PrefersSubtlety=true, EnjoysRelics=true, OpenFaith=false, ProtectsInnocents=true, LovesRisk=false },
        Wyll        = { ValuesMercy=true, LikesSnark=false, HatesAuthority=false, PrefersSubtlety=false, EnjoysRelics=false, OpenFaith=false, ProtectsInnocents=true, LovesRisk=false },
        Halsin      = { ValuesMercy=true, LikesSnark=true, HatesAuthority=true, PrefersSubtlety=false, EnjoysRelics=false, OpenFaith=false, ProtectsInnocents=true, LovesRisk=false },
        Minthara    = { ValuesMercy=false, LikesSnark=false, HatesAuthority=false, PrefersSubtlety=true, EnjoysRelics=true, OpenFaith=false, ProtectsInnocents=false, LovesRisk=true },
    },
    config = {
        RequireSuccessScore = 3,
        BumpApprovalToMax   = true,
        EnforceMonogamy     = true,
        MultiRomanceAllowed = false,
        OncePerNight        = true,
    }
}

-- Load JSON data from file
local function LoadCompanionData()
    local data = DefaultData

    -- Try to load from JSON file
    local jsonPath = "Data/companions.json"
    local success, fileContent = pcall(function()
        return Ext.IO.LoadFile(jsonPath, "data")
    end)

    if success and fileContent and fileContent ~= "" then
        local parseSuccess, parsed = pcall(function()
            return Ext.Json.Parse(fileContent)
        end)

        if parseSuccess and parsed then
            data = parsed
            Ext.Utils.Print("[Campfire Guess Who?] Loaded companion data from companions.json")
        else
            Ext.Utils.PrintWarning("[Campfire Guess Who?] Failed to parse companions.json, using defaults")
        end
    else
        Ext.Utils.Print("[Campfire Guess Who?] companions.json not found, using default data")
    end

    return data
end

-- Load the data
local LoadedData = LoadCompanionData()

---------------------------------------------------------------------------
-- EXPORTED GLOBALS (used by GuessWho.lua)
---------------------------------------------------------------------------

CompanionRoster = LoadedData.companions or DefaultData.companions
RomanceFlags = LoadedData.romanceFlags or DefaultData.romanceFlags
RomanceAvailableFlags = LoadedData.romanceAvailableFlags or DefaultData.romanceAvailableFlags
GuessWhoTraitText = LoadedData.questions or DefaultData.questions
CompanionTraits = LoadedData.traits or DefaultData.traits
Config = LoadedData.config or DefaultData.config

---------------------------------------------------------------------------
-- RELOAD FUNCTION (for hot-reloading during development)
---------------------------------------------------------------------------

function ReloadCompanionData()
    local data = LoadCompanionData()
    CompanionRoster = data.companions or DefaultData.companions
    RomanceFlags = data.romanceFlags or DefaultData.romanceFlags
    RomanceAvailableFlags = data.romanceAvailableFlags or DefaultData.romanceAvailableFlags
    GuessWhoTraitText = data.questions or DefaultData.questions
    CompanionTraits = data.traits or DefaultData.traits
    Config = data.config or DefaultData.config
    Ext.Utils.Print("[Campfire Guess Who?] Companion data reloaded!")
end
