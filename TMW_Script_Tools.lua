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

local function isPowerLearned(powerid)
    local isSelected        
    for _, itemLocation in AzeriteUtil.EnumerateEquipedAzeriteEmpoweredItems() do
        isSelected = C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerid)
        if isSelected then return true end
    end
    return false
end

function TMW_ST:isAzeriteTrait(spellId)
    if not AdvancedTooltips or not AdvancedTooltips.SpellData[spellId] then 
    	return false 
    end
    
    return isPowerLearned(AdvancedTooltips.SpellData[spellId][5])
end
