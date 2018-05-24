local TMW = TMW
if not TMW then return end

local TMW_ST = {debug=false}

local _UnitExists = UnitExists
local _CheckDistance = CheckInteractDistance
local _UnitReaction = UnitReaction

_G.TMW_ST = LibStub("AceAddon-3.0"):NewAddon(TMW_ST, "TMW_Script_Tools", "AceEvent-3.0","AceConsole-3.0")
_G.TMW_Script_Tools = _G.TMW_ST


function TMW_ST:printDebug(text, var1, var2, var3)
	if TMW_ST.debug then
		TMW_ST:Print(text, var1 or "", var2 or "", var3 or "")
	end
end

function TMW_ST:toggleDebug()
	debug = not debug
end

function TMW_ST:InitCounter(name, initialValue)
	TMW_ST:printDebug("Initializing Counter", name, initialValue)
	TMW.COUNTERS[name] = initialValue or 0
end			

function TMW_ST:UpdateCounter(name, value)
	TMW_ST:printDebug("Setting Counter Value", name, value)
	TMW.COUNTERS[name] = value
	TMW:Fire("TMW_COUNTER_MODIFIED", name)
end

function TMW_ST:GetCounter(name)
	return TMW.COUNTERS[name]
end

TMW_ST.ScriptTexts = {}

function TMW_ST:SetScriptText(name, text)
	TMW_ST.ScriptTexts[name] = text
	TMW:Fire("TMW_ST_VARIABLE_MODIFIED", name)
end

local DogTag = LibStub("LibDogTag-3.0", true)
if DogTag then
	 DogTag:AddTag("TMW", "ST_GetScriptText", {
		code = function(name)
			return TMW_ST.ScriptTexts[name] or ""
		end,
		arg = {
			'name', 'string', '@req',
		},
		ret = "string",
		doc = "Return the value of a script variable",
		example = '[ST_GetScriptText("var1")] => "my var"',
		events = "TMW_ST_VARIABLE_MODIFIED",
		category = "Userland"
    })
end



function TMW_ST:CountInRange(stop)
	if (not stop) then
		stop = 5
	end

	local inRange = 0


	for i = 1, 40 do
		local name = 'nameplate' .. i

		if _UnitExists(name) and _UnitReaction(name, "player") < 5 and _CheckDistance(name, 2) == true then
			inRange = inRange + 1

			if inRange == stop then
				return inRange
			end
		end
	end

	return inRange
end

TMW_ST.InRange = {
	count = 0,
	enabled = false,
	registered = false,
	counter_name = "tmwst_hostiles_in_range"
}

TMW_ST:InitCounter(TMW_ST.InRange.counter_name, 0)

function TMW_ST:UpdateUnitCounter()
	local count = TMW_ST:CountInRange()
	local params = TMW_ST.InRange

	if (count ~= params.count) then
		TMW_ST:UpdateCounter(params.counter_name, count)
		params.count = count
	end
end

function TMW_ST:EnableUnitCounter()
	local params = TMW_ST.InRange

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


local CNDT = TMW.CNDT
local Env = CNDT.Env
Env.CountInRange = function() return TMW_ST:CountInRange() end

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWST", 11, "Script Tools", false, false)

ConditionCategory:RegisterCondition(8.5,  "TMWSTENEMYCOUNT", {
	text = "Enemy Count",
	tooltip = "Number of enemies within 8 yards of player",
	min = 0,
	max = 5,
	unit="player",
	formatter = TMW.C.Formatter:New(function(val)
		return val
	end),

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
