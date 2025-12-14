---@diagnostic disable: undefined-global
-- Campfire Guess Who? - Companion Data
-- Loads all game data from external JSON files in Data/ folder

---------------------------------------------------------------------------
-- JSON FILE LOADER
---------------------------------------------------------------------------

local function LoadJsonFile(filename)
    local path = "Data/" .. filename
    local success, fileContent = pcall(function()
        return Ext.IO.LoadFile(path, "data")
    end)

    if success and fileContent and fileContent ~= "" then
        local parseSuccess, parsed = pcall(function()
            return Ext.Json.Parse(fileContent)
        end)

        if parseSuccess and parsed then
            Ext.Utils.Print("[Campfire Guess Who?] Loaded " .. filename)
            return parsed, true
        else
            Ext.Utils.PrintWarning("[Campfire Guess Who?] Failed to parse " .. filename)
            return nil, false
        end
    else
        Ext.Utils.PrintWarning("[Campfire Guess Who?] Failed to load " .. filename)
        return nil, false
    end
end

---------------------------------------------------------------------------
-- DEFAULT DATA (fallbacks if JSON files are missing)
---------------------------------------------------------------------------

local Defaults = {
    companions = {
        { key = "Shadowheart", names = { "Shadowheart" }, enabled = true },
        { key = "Laezel", names = { "Lae'zel", "Laezel" }, enabled = true },
        { key = "Astarion", names = { "Astarion" }, enabled = true },
        { key = "Karlach", names = { "Karlach" }, enabled = true },
        { key = "Gale", names = { "Gale" }, enabled = true },
        { key = "Wyll", names = { "Wyll" }, enabled = true },
        { key = "Halsin", names = { "Halsin" }, enabled = true },
        { key = "Minthara", names = { "Minthara" }, enabled = true },
    },
    romanceFlags = {
        Shadowheart = "Shadowheart_RomanceActive",
        Laezel = "LaeZel_RomanceActive",
        Astarion = "Astarion_RomanceActive",
        Karlach = "Karlach_RomanceActive",
        Gale = "Gale_RomanceActive",
        Wyll = "Wyll_RomanceActive",
        Halsin = "Halsin_RomanceActive",
        Minthara = "Minthara_RomanceActive",
    },
    romanceAvailableFlags = {
        Shadowheart = "Shadowheart_RomanceAvailable",
        Laezel = "LaeZel_RomanceAvailable",
        Astarion = "Astarion_RomanceAvailable",
        Karlach = "Karlach_RomanceAvailable",
        Gale = "Gale_RomanceAvailable",
        Wyll = "Wyll_RomanceAvailable",
        Halsin = "Halsin_RomanceAvailable",
        Minthara = "Minthara_RomanceAvailable",
    },
    questions = {
        { key = "ValuesMercy", text = "Values mercy over vengeance?" },
        { key = "LikesSnark", text = "Appreciates sharp, snarky humor?" },
        { key = "HatesAuthority", text = "Chafes against rules and authority?" },
        { key = "PrefersSubtlety", text = "Prefers subtlety to brute force?" },
        { key = "EnjoysRelics", text = "Fascinated by relics and forbidden lore?" },
        { key = "OpenFaith", text = "Open and public about their faith?" },
        { key = "ProtectsInnocents", text = "Protects innocents even at risk?" },
        { key = "LovesRisk", text = "Loves risky gambits?" },
    },
    traits = {
        Shadowheart = { ValuesMercy = true, LikesSnark = false, HatesAuthority = false, PrefersSubtlety = true, EnjoysRelics = true, OpenFaith = false, ProtectsInnocents = true, LovesRisk = false },
        Laezel = { ValuesMercy = false, LikesSnark = false, HatesAuthority = false, PrefersSubtlety = false, EnjoysRelics = false, OpenFaith = false, ProtectsInnocents = false, LovesRisk = true },
        Astarion = { ValuesMercy = false, LikesSnark = true, HatesAuthority = true, PrefersSubtlety = true, EnjoysRelics = false, OpenFaith = false, ProtectsInnocents = false, LovesRisk = true },
        Karlach = { ValuesMercy = true, LikesSnark = true, HatesAuthority = true, PrefersSubtlety = false, EnjoysRelics = false, OpenFaith = false, ProtectsInnocents = true, LovesRisk = true },
        Gale = { ValuesMercy = true, LikesSnark = true, HatesAuthority = false, PrefersSubtlety = true, EnjoysRelics = true, OpenFaith = false, ProtectsInnocents = true, LovesRisk = false },
        Wyll = { ValuesMercy = true, LikesSnark = false, HatesAuthority = false, PrefersSubtlety = false, EnjoysRelics = false, OpenFaith = false, ProtectsInnocents = true, LovesRisk = false },
        Halsin = { ValuesMercy = true, LikesSnark = true, HatesAuthority = true, PrefersSubtlety = false, EnjoysRelics = false, OpenFaith = false, ProtectsInnocents = true, LovesRisk = false },
        Minthara = { ValuesMercy = false, LikesSnark = false, HatesAuthority = false, PrefersSubtlety = true, EnjoysRelics = true, OpenFaith = false, ProtectsInnocents = false, LovesRisk = true },
    },
    config = {
        gameplay = { RequireSuccessScore = 3, QuestionsPerRound = 5, OncePerNight = true },
        romance = { BumpApprovalToMax = true, ApprovalBoostAmount = 100, EnforceMonogamy = true, MultiRomanceAllowed = false, CloseAvailableFlags = true },
        messages = {
            GameStart = "Campfire Guess Who? begins. A figure sits across the firelight...",
            QuestionPrompt = "[Guess Who? %d/%d]\n%s\nUse 'Answer: YES' or 'Answer: NO'.",
            SuccessMessage = "You scored %d/%d. You and %s share a deep connection tonight.",
            FailureMessage = "You scored %d/%d with %s. The moment wasn't quite right.",
            AlreadyPlayedTonight = "You've already played tonight. Try again after your next Long Rest.",
            NoEligibleCompanions = "No romance-eligible companions are benched tonight.",
            NoActiveSession = "No active Guess Who? round. Use the starter item to begin.",
        },
    },
}

---------------------------------------------------------------------------
-- DATA LOADING
---------------------------------------------------------------------------

local function LoadAllData()
    local data = {}

    -- Load companions.json
    local companionsData = LoadJsonFile("companions.json")
    if companionsData then
        data.companions = companionsData.companions or Defaults.companions
        data.romanceFlags = companionsData.romanceFlags or Defaults.romanceFlags
        data.romanceAvailableFlags = companionsData.romanceAvailableFlags or Defaults.romanceAvailableFlags
    else
        data.companions = Defaults.companions
        data.romanceFlags = Defaults.romanceFlags
        data.romanceAvailableFlags = Defaults.romanceAvailableFlags
    end

    -- Load questions.json
    local questionsData = LoadJsonFile("questions.json")
    if questionsData and questionsData.questions then
        data.questions = questionsData.questions
    else
        data.questions = Defaults.questions
    end

    -- Load traits.json
    local traitsData = LoadJsonFile("traits.json")
    if traitsData then
        -- Filter out metadata keys (starting with _)
        data.traits = {}
        for key, value in pairs(traitsData) do
            if type(value) == "table" and not key:match("^_") then
                -- Also filter out _description from trait values
                data.traits[key] = {}
                for traitKey, traitValue in pairs(value) do
                    if not traitKey:match("^_") then
                        data.traits[key][traitKey] = traitValue
                    end
                end
            end
        end
    else
        data.traits = Defaults.traits
    end

    -- Load config.json
    local configData = LoadJsonFile("config.json")
    if configData then
        data.config = {
            gameplay = configData.gameplay or Defaults.config.gameplay,
            romance = configData.romance or Defaults.config.romance,
            messages = configData.messages or Defaults.config.messages,
        }
    else
        data.config = Defaults.config
    end

    return data
end

-- Load data on startup
local LoadedData = LoadAllData()

---------------------------------------------------------------------------
-- BUILD QUESTION TEXT LOOKUP
-- Converts array format to key-value for backward compatibility
---------------------------------------------------------------------------

local function BuildQuestionTextLookup(questions)
    local lookup = {}
    for _, q in ipairs(questions) do
        if q.key and q.text then
            lookup[q.key] = q.text
        end
    end
    return lookup
end

---------------------------------------------------------------------------
-- EXPORTED GLOBALS (used by GuessWho.lua)
---------------------------------------------------------------------------

-- Filter to only enabled companions
CompanionRoster = {}
for _, companion in ipairs(LoadedData.companions) do
    if companion.enabled ~= false then
        table.insert(CompanionRoster, companion)
    end
end

RomanceFlags = LoadedData.romanceFlags
RomanceAvailableFlags = LoadedData.romanceAvailableFlags
GuessWhoTraitText = BuildQuestionTextLookup(LoadedData.questions)
CompanionTraits = LoadedData.traits

-- Flatten config for backward compatibility
Config = {
    RequireSuccessScore = LoadedData.config.gameplay.RequireSuccessScore,
    QuestionsPerRound = LoadedData.config.gameplay.QuestionsPerRound or 5,
    OncePerNight = LoadedData.config.gameplay.OncePerNight,
    BumpApprovalToMax = LoadedData.config.romance.BumpApprovalToMax,
    ApprovalBoostAmount = LoadedData.config.romance.ApprovalBoostAmount or 100,
    EnforceMonogamy = LoadedData.config.romance.EnforceMonogamy,
    MultiRomanceAllowed = LoadedData.config.romance.MultiRomanceAllowed,
    CloseAvailableFlags = LoadedData.config.romance.CloseAvailableFlags,
}

-- Messages config
Messages = LoadedData.config.messages

---------------------------------------------------------------------------
-- RELOAD FUNCTION (for hot-reloading during development)
---------------------------------------------------------------------------

function ReloadCompanionData()
    LoadedData = LoadAllData()

    -- Rebuild exports
    CompanionRoster = {}
    for _, companion in ipairs(LoadedData.companions) do
        if companion.enabled ~= false then
            table.insert(CompanionRoster, companion)
        end
    end

    RomanceFlags = LoadedData.romanceFlags
    RomanceAvailableFlags = LoadedData.romanceAvailableFlags
    GuessWhoTraitText = BuildQuestionTextLookup(LoadedData.questions)
    CompanionTraits = LoadedData.traits

    Config = {
        RequireSuccessScore = LoadedData.config.gameplay.RequireSuccessScore,
        QuestionsPerRound = LoadedData.config.gameplay.QuestionsPerRound or 5,
        OncePerNight = LoadedData.config.gameplay.OncePerNight,
        BumpApprovalToMax = LoadedData.config.romance.BumpApprovalToMax,
        ApprovalBoostAmount = LoadedData.config.romance.ApprovalBoostAmount or 100,
        EnforceMonogamy = LoadedData.config.romance.EnforceMonogamy,
        MultiRomanceAllowed = LoadedData.config.romance.MultiRomanceAllowed,
        CloseAvailableFlags = LoadedData.config.romance.CloseAvailableFlags,
    }

    Messages = LoadedData.config.messages

    Ext.Utils.Print("[Campfire Guess Who?] All data reloaded!")
end
