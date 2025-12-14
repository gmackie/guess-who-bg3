---@diagnostic disable: undefined-global
-- Campfire Guess Who? - Server Logic
-- Implements sessions, item spawning/cleanup, romance selection, and approval handling

GuessWho = GuessWho or {}

---------------------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------------------
local YES_TEMPLATE = "GMK_AnswerYes"
local NO_TEMPLATE  = "GMK_AnswerNo"

---------------------------------------------------------------------------
-- STATE
---------------------------------------------------------------------------
local sessions      = {}   -- playerGuid -> { targetCompUuid, compKey, qOrder, index, score }
local nightlyPlayed = {}   -- playerGuid -> true
local compUuidByKey = {}   -- key -> uuid (resolved once)
local nameIndex     = {}   -- lowercased display name -> key

---------------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------------

-- Get player ID string for session tracking
local function pid(c)
    return tostring(c)
end

-- Check if character is a player
local function isPlayer(c)
    return Osi.IsPlayer(c) == 1
end

-- Display text to player (uses Messages config if available)
local function say(p, t)
    Osi.DisplayText(p, t)
end

-- Get message from config or use fallback
local function getMessage(key, fallback)
    if Messages and Messages[key] then
        return Messages[key]
    end
    return fallback
end

-- Build name lookup index from CompanionRoster
local function buildNameIndex()
    nameIndex = {}
    for _, e in ipairs(CompanionRoster) do
        for _, nm in ipairs(e.names) do
            nameIndex[nm:lower()] = e.key
        end
    end
end

-- Resolve companion UUIDs at runtime by display name
local function resolveCompanions()
    buildNameIndex()

    -- Iterate through all entities to find origin companions
    for _, entity in ipairs(Ext.Entity.GetAllEntitiesWithComponent("ServerCharacter")) do
        if entity.ServerCharacter then
            local uuid = entity.Uuid and entity.Uuid.EntityUuid
            if uuid and Osi.IsOriginCharacter(uuid) == 1 then
                -- Try to get display name
                local displayName = ""
                if entity.DisplayName and entity.DisplayName.NameKey then
                    displayName = Ext.Loca.GetTranslatedString(entity.DisplayName.NameKey.Handle.Handle) or ""
                end

                local compKey = nameIndex[displayName:lower()]
                if compKey and not compUuidByKey[compKey] then
                    compUuidByKey[compKey] = uuid
                end
            end
        end
    end
end

-- Get companion key from UUID
local function keyByUuid(uuid)
    for k, u in pairs(compUuidByKey) do
        if u == uuid then
            return k
        end
    end
    return nil
end

-- Get list of benched companions for a player (not in active party)
local function benchedCompanionsFor(player)
    local out = {}
    for _, uuid in pairs(compUuidByKey) do
        if Osi.IsInPartyWith(uuid, player) == 0 then
            table.insert(out, uuid)
        end
    end
    return out
end

-- Pick random element from table
local function pickRandom(t)
    if #t > 0 then
        return t[math.random(1, #t)]
    end
    return nil
end

-- Get shuffled list of trait keys for a companion
local function shuffledTraitKeys(compKey)
    local t = CompanionTraits[compKey]
    if not t then
        return {}
    end

    local k = {}
    for kk, _ in pairs(t) do
        table.insert(k, kk)
    end

    -- Fisher-Yates shuffle
    for i = #k, 2, -1 do
        local j = math.random(1, i)
        k[i], k[j] = k[j], k[i]
    end

    return k
end

-- Add YES/NO answer items to player inventory
local function addAnswerItems(player)
    Osi.TemplateAddTo(YES_TEMPLATE, player, 1, 1)
    Osi.TemplateAddTo(NO_TEMPLATE, player, 1, 1)
end

-- Remove YES/NO answer items from player inventory
local function removeAnswerItems(player)
    -- Remove all YES items
    local yesCount = Osi.GetItemTemplateCount(player, YES_TEMPLATE) or 0
    if yesCount > 0 then
        Osi.TemplateRemoveFrom(YES_TEMPLATE, player, yesCount)
    end

    -- Remove all NO items
    local noCount = Osi.GetItemTemplateCount(player, NO_TEMPLATE) or 0
    if noCount > 0 then
        Osi.TemplateRemoveFrom(NO_TEMPLATE, player, noCount)
    end
end

-- Display current question to player
local function promptQuestion(player, traitKey, idx, total)
    local q = GuessWhoTraitText[traitKey] or traitKey
    local template = getMessage("QuestionPrompt", "[Guess Who? %d/%d]\n%s\nUse 'Answer: YES' or 'Answer: NO'.")
    say(player, string.format(template, idx, total, q))
end

-- Set romance for the chosen companion
local function setRomanceFor(player, compUuid, compKey)
    -- (A) Approval bump (optional)
    if Config.BumpApprovalToMax then
        local amount = Config.ApprovalBoostAmount or 100
        Osi.ChangeApprovalRating(compUuid, player, 0, amount)
    end

    -- (B) Enforce monogamy by clearing all others
    if Config.EnforceMonogamy and not Config.MultiRomanceAllowed then
        for key, flag in pairs(RomanceFlags) do
            if key ~= compKey then
                Osi.SetFlag(flag, 0, player)
            end
        end
    end

    -- (C) Activate chosen companion's real romance flag
    local activeFlag = RomanceFlags[compKey]
    if activeFlag then
        Osi.SetFlag(activeFlag, 1, player)
    end

    -- (D) Optionally close "available" flags (prevents re-select prompts)
    if Config.CloseAvailableFlags ~= false then
        local avail = RomanceAvailableFlags[compKey]
        if avail then
            Osi.SetFlag(avail, 0, player)
        end
    end
end

-- End the current round and determine success/failure
local function endRound(player, s)
    removeAnswerItems(player)

    local compKey = keyByUuid(s.targetCompUuid) or "Unknown"
    local score = s.score
    local total = #s.qOrder
    local success = score >= (Config.RequireSuccessScore or 3)

    if success then
        setRomanceFor(player, s.targetCompUuid, s.compKey)
        local template = getMessage("SuccessMessage", "You scored %d/%d. You and %s share a deep connection tonight.")
        say(player, string.format(template, score, total, compKey))
    else
        local template = getMessage("FailureMessage", "You scored %d/%d with %s. The moment wasn't quite right.")
        say(player, string.format(template, score, total, compKey))
    end

    sessions[pid(player)] = nil
    nightlyPlayed[pid(player)] = true
end

---------------------------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------------------------

-- Reset nightly played status (called after Long Rest)
function GuessWho.ResetNight()
    nightlyPlayed = {}
    Ext.Utils.Print("[Campfire Guess Who?] Nightly status reset.")
end

-- Start a new Guess Who? session
function GuessWho.Start(player)
    if not isPlayer(player) then
        return
    end

    -- Resolve companions if not already done
    if not next(compUuidByKey) then
        resolveCompanions()
    end

    local p = pid(player)

    -- Check if already played tonight
    if Config.OncePerNight and nightlyPlayed[p] then
        say(player, getMessage("AlreadyPlayedTonight", "You've already played tonight. Try again after your next Long Rest."))
        return
    end

    -- Get list of eligible companions (benched ones)
    local candidates = benchedCompanionsFor(player)
    if #candidates == 0 then
        say(player, getMessage("NoEligibleCompanions", "No romance-eligible companions are benched tonight."))
        return
    end

    -- Pick random companion
    local compUuid = pickRandom(candidates)
    local compKey  = keyByUuid(compUuid)

    -- Get shuffled questions
    local qOrder = shuffledTraitKeys(compKey)

    -- Limit to configured questions per round
    local questionsPerRound = Config.QuestionsPerRound or 5
    local total = math.min(#qOrder, questionsPerRound)
    while #qOrder > total do
        table.remove(qOrder)
    end

    if total == 0 then
        say(player, "Couldn't set up the game (no traits).")
        return
    end

    -- Initialize session
    sessions[p] = {
        targetCompUuid = compUuid,
        compKey        = compKey,
        qOrder         = qOrder,
        index          = 1,
        score          = 0,
    }

    -- Add answer items and start game
    addAnswerItems(player)
    say(player, getMessage("GameStart", "Campfire Guess Who? begins. A figure sits across the firelight..."))
    promptQuestion(player, qOrder[1], 1, total)
end

-- Process player's answer
function GuessWho.Answer(player, isYes)
    local s = sessions[pid(player)]

    if not s then
        say(player, getMessage("NoActiveSession", "No active Guess Who? round. Use the starter item to begin."))
        return
    end

    -- Check if answer is correct
    local truth = CompanionTraits[s.compKey][s.qOrder[s.index]]
    if truth == nil then
        truth = false
    end

    if (truth and isYes) or (not truth and not isYes) then
        s.score = s.score + 1
    end

    -- Move to next question or end round
    s.index = s.index + 1

    if s.index > #s.qOrder then
        endRound(player, s)
    else
        promptQuestion(player, s.qOrder[s.index], s.index, #s.qOrder)
    end
end
