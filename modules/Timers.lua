local TMW_ST = TMW_Script_Tools
local Timers = {}
TMW_ST.Timers = Timers

function wrap(method, func)
	if (not func) then 
		func = function(name)
			local t = TMW.TIMERS[name]
			TMW_ST:printDebug("Timer "..method, name, t)
			t[method](t)
			if (method ~='GetTime') then
				TMW:Fire("TMW_TIMER_MODIFIED", name)
			end
		end
	end

	TMW_ST["Timer"..method] = func
	Timers[method] = func
end

local methods = {"Start","Pause","Stop","Reset","GetTime"}

for _,method in pairs(methods) do
	wrap(method)
end

wrap('Init', function(name)
	Timers.GetTime(name);	
end)

wrap('Restart', function(name)
	Timers.Stop(name)
	Timers.Start(name)
end)