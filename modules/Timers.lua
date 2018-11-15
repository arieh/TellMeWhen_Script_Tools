local TMW_ST = TMW_Script_Tools

function wrap(method, name)
	local t = TMW.TIMERS[name]
	TMW_ST:printDebug("Timer "..method, name, t)
	t[method](t)
	if (method ~='GetTime') then
		TMW:Fire("TMW_TIMER_MODIFIED", name)
	end
end

function TMW_ST:InitTimer(name)
	wrap('GetTime', name)
end

function TMW_ST:TimerStart(name)
	wrap('Start', name)
end

function TMW_ST:TimerPause(name)
	wrap('Pause', name)
end

function TMW_ST:TimerStop(name)
	wrap('Stop', name)
end

function TMW_ST:TimerReset(name)
	wrap('Reset', name)
end

function TMW_ST:TimerRestart(name)
	wrap('Stop', name)
	wrap('Start', name)
end