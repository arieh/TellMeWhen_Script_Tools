---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by arieh.
--- DateTime: 5/25/18 7:46 AM
---
local TMW = TMW
local TMW_ST = TMW_Script_Tools

--caching
local _UnitExists = UnitExists
local _UnitReaction = UnitReaction

local CNDT = TMW.CNDT
local Env = CNDT.Env

--expose CountInRange to condition functions
Env.CountInRange = function()
    return TMW_ST:CountInRange()
end


local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWST", 11, "Script Tools", false, false)
local LibRangeCheck = LibStub("LibRangeCheck-2.0")
local rangeChecker = LibRangeCheck:GetHarmMaxChecker(8) or LibRangeCheck:GetHarmMinChecker(8)

local EnemyCounter = {
    count = 0,
    enabled = false,
    registered = false,
    max_scan = 40,
    current_max = 5,
    counter_name = "tmwst_hostiles_in_range",
    last_time = time(),
    last_value = 0
}

TMW_ST.EnemyCounter_Config = EnemyCounter

function TMW_ST:CountInRange(stop)

    if (not stop) then
        stop = 5
    end
    
    local current_time = time()

    if (current_time == EnemyCounter.last_time and stop <= EnemyCounter.last_value) then
        return EnemyCounter.last_value
    end

    EnemyCounter.last_time = current_time

    local count = 0
    local name

    for i = 1, EnemyCounter.max_scan do
        name = 'nameplate' .. i

        if _UnitExists(name) and _UnitReaction(name, "player") < 5 and rangeChecker(name) == true then
            count = count + 1

            if count == stop then
                return count
            end
        end
    end
    
    EnemyCounter.last_value = count

    return count
end


TMW_ST:InitCounter(TMW_ST.EnemyCounter_Config.counter_name, 0)

function TMW_ST:UpdateUnitCounter(stop)
    local count = TMW_ST:CountInRange(stop)
    local params = EnemyCounter

    if (count ~= params.count) then
        TMW_ST:UpdateCounter(params.counter_name, count)
        params.count = count
        TMW_ST:Print('counter', count)
    end
end

function TMW_ST:EnableUnitCounter(stop)
    local params = EnemyCounter

    if (not stop) then
        stop = EnemyCounter.current_max
    end

    if (stop < EnemyCounter.current_max) then 
        stop = EnemyCounter.current_max
    else
        EnemyCounter.current_max = stop
    end

    params.enabled = true

    TMW_ST:UpdateUnitCounter(stop)

    if (params.registered) then return end

    TMW_ST:AddEvent("COMBAT_LOG_EVENT_UNFILTERED", function()
        if (not params.enabled) then return end

        TMW_ST:UpdateUnitCounter(stop)
    end)

    params.registered = true
end

function TMW_ST:DisableUnitCounter()
    TMW_ST.InRange.enabled = false
    EnemyCounter.current_max = 5
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