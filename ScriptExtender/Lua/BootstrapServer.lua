---@diagnostic disable: undefined-global
-- Campfire Guess Who? - Bootstrap Server
-- Entry point for BG3 Script Extender
-- Note: Ext, Osi, and other globals are provided by BG3SE at runtime

Ext.Require("Shared/CompanionData.lua")
Ext.Require("Server/GuessWho.lua")

-- Register Osiris listeners for the minigame procedures
Ext.Osiris.RegisterListener("PROC_GMK_GuessWho_Start", 1, "after",
    function(player)
        GuessWho.Start(player)
    end)

Ext.Osiris.RegisterListener("PROC_GMK_GuessWho_Answer", 2, "after",
    function(player, ans)
        GuessWho.Answer(player, ans == "YES")
    end)

Ext.Osiris.RegisterListener("PROC_GMK_GuessWho_ResetNight", 0, "after",
    function()
        GuessWho.ResetNight()
    end)

Ext.Utils.Print("[Campfire Guess Who?] Mod loaded successfully!")
