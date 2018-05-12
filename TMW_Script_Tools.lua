local TMW = TMW
if not TMW then return end

local TMW_ST = {debug=false}
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
	TMW:RegisterCallback("TMW_ST_VARIABLE_MODIFIED", DogTag, "FireEvent")

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