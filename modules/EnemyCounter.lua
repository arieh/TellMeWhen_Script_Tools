---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by arieh.
--- DateTime: 5/25/18 7:46 AM
---
local TMW = TMW
local TMW_ST = TMW_Script_Tools

--caching
local _UnitExists = UnitExists
local _CheckInteractDistance = CheckInteractDistance
local _UnitReaction = UnitReaction

local CNDT = TMW.CNDT
local Env = CNDT.Env

--expose CountInRange to condition functions
Env.CountInRange = function()
    return TMW_ST:CountInRange()
end


local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWST", 11, "Script Tools", false, false)

local EnemyCounter = {
    count = 0,
    enabled = false,
    registered = false,
    max_scan = 40,
    counter_name = "tmwst_hostiles_in_range"
}

TMW_ST.EnemyCounter_Config = EnemyCounter

function TMW_ST:CountInRange(stop)
    if (not stop) then
        stop = 5
    end

    local count = 0
    local name

    for i = 1, EnemyCounter.max_scan do
        name = 'nameplate' .. i

        if _UnitExists(name) and _UnitReaction(name, "player") < 5 and _CheckInteractDistance(name, 2) == true then
            count = count + 1

            if count == stop then
                return count
            end
        end
    end

    return count
end


TMW_ST:InitCounter(TMW_ST.EnemyCounter_Config.counter_name, 0)

function TMW_ST:UpdateUnitCounter()
    local count = TMW_ST:CountInRange()
    local params = EnemyCounter

    if (count ~= params.count) then
        TMW_ST:UpdateCounter(params.counter_name, count)
        params.count = count
    end
end

function TMW_ST:EnableUnitCounter()
    local params = EnemyCounter

    params.enabled = true

    TMW_ST:UpdateUnitCounter()

    if (params.registered) then return end

    TMW_ST:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function()
        if (not params.enabled) then return end

        TMW_ST:UpdateUnitCounter()
    end)

    params.registered = true
end

function TMW_ST:DisableUnitCounter()
    TMW_ST.InRange.enabled = false
end

ConditionCategory:RegisterCondition(8.5,  "TMWSTENEMYCOUNT", {
    text = "Enemy Count",
    tooltip = "Number of enemies within 8 yards of player",
    min = 0,
    max = 5,
    unit="player",

    icon = "Interface\\Icons\\ability_hunter_snipershot",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = "<="
        end
    end,

    funcstr = function(c, parent)
        return [[(CountInRange() c.Operator c.Level)]]
    end
})