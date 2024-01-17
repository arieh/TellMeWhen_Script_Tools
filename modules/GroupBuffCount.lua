local TMW = TMW
local TMW_ST = TMW_Script_Tools

local CNDT = TMW.CNDT
local Env = CNDT.Env
local GetAuras = TMW.COMMON.Auras and TMW.COMMON.Auras.GetAuras

local EVENT_NAME = GetAuras and 'TMW_UNIT_AURA' or 'UNIT_AURA'

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWST", 11, "Script Tools", false, false)


function getGroupBuffCount(spell, stop, countDead)
	if (not stop) then stop = 10 end
	local isParty = not IsInRaid()
	local prefix = isParty and 'party' or 'raid'

	local count = 0
	local groupSize = GetNumGroupMembers()
	local start = not isParty and 1 or 0

	for i=start, groupSize do
		local name = i==0 and 'player' or prefix .. i
		if countDead and UnitIsDeadOrGhost(name) then
			count = count + 1
		elseif TMW_ST.UnitAuras.getUnitAuras(name, spell, true) then
			count = count+1
		end

		if (count == stop) then 
			return count 
		end
	end

	return count
end

function isFullGroupCovered(spell)
	local groupSize = GetNumGroupMembers() or 1
	if (groupSize == 0) then groupSize = 1 end
	
	return getGroupBuffCount(spell, groupSize, true) == groupSize
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
			ConditionObject:GenerateNormalEventString(EVENT_NAME)
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
	formatter = TMW.C.Formatter.BOOL,
	funcstr = [[BOOLCHECK(isFullGroupCovered(c.NameFirst))]],
	Env = {
		isFullGroupCovered = isFullGroupCovered
	},
	events = function(ConditionObject, c)
		return
			ConditionObject:GenerateNormalEventString(EVENT_NAME)
	end,
})
