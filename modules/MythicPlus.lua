
local CNDT = TMW.CNDT
local Env = CNDT.Env
local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWST", 11, "Script Tools", false, false)

local MythicPlus_Data = {
    level = 0,
    counter_name = "tmwst_mythic_plus_level"
}

TMW_ST:InitCounter(MythicPlus_Data.counter_name, 0)


local GetMythicPlusLevel = function()
    return MythicPlus_Data.level
end


local handleScenarioUpdate = function()
    local cmLevel = C_ChallengeMode.GetActiveKeystoneInfo();
    
    TMW_ST:UpdateCounter(MythicPlus_Data.counter_name, cmLevel)
    MythicPlus_Data.level = cmLevel
end

TMW_ST:RegisterEvent("SCENARIO_CRITERIA_UPDATE", handleScenarioUpdate)


Env.GetMythicPlusLevel = GetMythicPlusLevel

ConditionCategory:RegisterCondition(8.5,  "TMWSTMYTHICPLUS", {
    text = "Keystone Level",
    tooltip = "Level of currently active Keystone",
    min = 0,
    max = 30,
    unit= 'Player',
    icon = "Interface\\Icons\\inv_relics_hourglass",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true, [">"]=true, ["<"] = true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = "<="
        end
    end,

    funcstr = function(c, parent)
        return [[(GetMythicPlusLevel() c.Operator c.Level)]]
    end
})

