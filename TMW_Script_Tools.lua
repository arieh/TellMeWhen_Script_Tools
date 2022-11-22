local TMW = TMW
if not TMW then return end

local TMW_ST = {debug=false}


_G.TMW_Script_Tools = LibStub("AceAddon-3.0"):NewAddon(TMW_ST, "TMW_Script_Tools", "AceEvent-3.0","AceConsole-3.0")
_G.TMWST= _G.TMW_Script_Tools
_G.TMW_ST = _G.TMW_Script_Tools

local TMW_ST = _G.TMW_Script_Tools

function TMW_ST:printDebug(text, var1, var2, var3)
	if TMW_ST.debug then
		TMW_ST:Print(text, var1 or "", var2 or "", var3 or "")
	end
end

function TMW_ST:toggleDebug(value)
	if (value ~= nil) then
		debug = value
	else
		debug = not debug
	end
end

local events = {}

function triggerEvent(event,...)
	for i=1,getn(events[event]) do
		events[event][i](event,...)
	end
end

function TMW_ST:AddEvent(event, cb)
	if (not events[event]) then 
		events[event] = {cb}
		TMW_ST:RegisterEvent(event, triggerEvent)
	else
		tinsert(events[event], cb)
	end
end

function TMW_ST:RemoveEvent(event, cb)
	if (not events[event]) then return end
	local found = -1
	for i=1, getn(events[event]) do
		if (events[event][i] == cb) then found = i end
	end

	if (found > -1) then
		tremove(events[event], found)
	end
end
