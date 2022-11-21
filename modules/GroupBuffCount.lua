local TMW = TMW
local TMW_ST = TMW_Script_Tools

local CNDT = TMW.CNDT
local Env = CNDT.Env

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWST", 11, "Script Tools", false, false)


function getGroupBuffCount(spell, stop)
	if (not stop) then stop = 10 end

	local count = 0

	for i=1,GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)
			
		if (TMW_ST.UnitAuras.getUnitAura(name, spell)) then
			count = count+1
		end	

		if (count == stop) then 
			return count 
		end
	end

	return count
end


ConditionCategory:RegisterCondition(8.7,  "TMWSTBUFFCOUNT", {
    text = "Group Buff Count",
    tooltip = "How many players in group have a certain buff",

	min = 0,
	max = 10,
	
	name = function(editbox)
	 	editbox:SetTexts(L["SPELLTOCOMP1"], L["CNDT_ONLYFIRST"])
	end,
	useSUG = true,
	unit = false,
	icon = "Interface\\Icons\\inv_misc_key_04",
	tcoords = CNDT.COMMON.standardtcoords,
	funcstr = [[(getGroupBuffCount(c.NameFirst) or 0) c.Operator c.Level]],
	Env = {
		getGroupBuffCount = getGroupBuffCount
	},
	events = function(ConditionObject, c)
		return
			ConditionObject:GenerateNormalEventString("UNIT_AURA")
	end,
})

ConditionCategory:RegisterCondition(8.8,  "TMWSTALLGROUPBUFF", {
    text = "All Group Has Buff",
    tooltip = "How many players in group have a certain buff",
    bool = true,
	
	name = function(editbox)
	 	editbox:SetTexts(L["SPELLTOCOMP1"], L["CNDT_ONLYFIRST"])
	end,
	useSUG = true,
	unit = false,
	icon = "Interface\\Icons\\ability_warrior_battleshout",
	tcoords = CNDT.COMMON.standardtcoords,
	funcstr = [[(getGroupBuffCount(c.NameFirst, GetNumGroupMembers()) or 0) == GetNumGroupMembers()]],
	Env = {
		getGroupBuffCount = getGroupBuffCount,
		GetNumGroupMembers= GetNumGroupMembers
	},
	events = function(ConditionObject, c)
		return
			ConditionObject:GenerateNormalEventString("UNIT_AURA")
	end,
})
