local EventHub = TMW_ST:NewModule("AuraTracker","AceEvent-3.0")
local units = {}

TMW_ST.UnitAuras = {
	getUnitAura = function(unit, spell)
		local id = getId(unit)
		local spellName = GetSpellInfo(spell)
		if (not units[id]) then return nil end
		return units[id].auras[spellName]
	end
}

function getGroupBuffCount(spell, stop)
	if (not stop) then stop = 10 end
	-- support all formats
	local spellName = GetSpellInfo(spell)	

	local count = 0

	for i=1,GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)
		local id = getId(name)
			
		if (units[id] and units[id].auras[spellName]) then
			count = count+1
		end	

		-- if (AuraUtil.FindAuraByName(spellName, name)) then 
		-- 	count = count+1 
		-- end

		if (count == stop) then 
			return count 
		end
	end

	return count
end

_G.debufUnitTracker  = function()
	ViragDevTool:AddData(units,'units')
end		


function getId(unit)
	local name, realm = UnitNameUnmodified(unit)
	return name .. (realm or '')
end

function addUnit(unit)
	local id = getId(unit)

	if (units[id]) then return units[id] end

	units[id] = {
		auras = {},
		instanceIds = {}
	}

    local function HandleAura(aura)
        addUnitAura(unit,aura)
    end

    local batchCount = nil
    local usePackedAura = true
    AuraUtil.ForEachAura(unit, "HELPFUL", batchCount, HandleAura, usePackedAura)
    AuraUtil.ForEachAura(unit, "HARMFUL", batchCount, HandleAura, usePackedAura)

	return units[id] 
end

function addUnitAura(unit, aura)
	local config = addUnit(unit)
	local spellName = GetSpellInfo(aura.name)

	config.auras[spellName] = aura
	config.instanceIds[aura.auraInstanceID] = spellName
end

function removeUnitAura(unit, instanceId)
	local config = addUnit(unit)

	local spellName = config.instanceIds[instanceId]

	if (spellName ~= nil) then
		config.auras[spellName] = nil
		config.instanceIds[instanceId] = nil
	end	
end

function updateAuras()
	for i=1,GetNumGroupMembers() do
		local name = GetRaidRosterInfo(i)

		addUnit(name)
	end
end

function unitAura(event, unit, updates)
	if (updates.addedAuras) then
		for _,aura in ipairs(updates.addedAuras) do
			addUnitAura(unit, aura)	
		end
	end

	if (updates.removedAuraInstanceIDs) then
		for i=1, getn(updates.removedAuraInstanceIDs) do
			removeUnitAura(unit, updates.removedAuraInstanceIDs[i])
		end
	end
end

EventHub:RegisterEvent('UNIT_AURA', unitAura)
EventHub:RegisterEvent('PLAYER_ENTERING_WORLD', updateAuras)
EventHub:RegisterEvent('GROUP_ROSTER_UPDATE', updateAuras)
