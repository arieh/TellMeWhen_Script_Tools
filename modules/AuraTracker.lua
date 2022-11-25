local EventHub = TMW_ST:NewModule("AuraTracker","AceEvent-3.0")
local GetAuras = TMW.COMMON.Auras and TMW.COMMON.Auras.GetAuras
local ConditionObject = TMW.ConditionObject

-- the concept of this tracker is as follows:
-- 1. We create a unit payload when either:
--
--   	a) User queries about the unit
--   	b) A UNIT_AURA event was triggered for it.

--	  In both cases, we create a full list of auras for that unit
-- 2. When UNIT_AURA event is triggered, we update the list based on event
-- 3. To make sure we dont risk cases where auras might be added outside of UNIT_AURA 
--    range, we make sure to remove units when:
--		a) their nameplate was removed, 
--		b) they left the party
--		c) their cache has passed the TTL 

-- list of tracked units

local units = {}

function tmwGetUnitAura(unit, spell, onlyMine)
	local name, rank, icon, castTime, minRange, maxRange, spellID = GetSpellInfo(spell)

	local config = GetAuras(unit)

	if (not config) then return nil end

	local instances = config.instances
	local lookup = config.lookup

	local spellLookup =  lookup(spell) or lookup[spellID]

	for instanceId,_ in spellLookup do 
		if (instances[instanceId]) then
			return instances[instanceId]
		end
	end
	return nil
end

function getUnitAura(unit, spell)
	-- in case the unit is not currently tracked, 
	-- make sure to add it
	local config = addUnit(unit)
	
	if (not config) then return nil end

	-- normalize input
	local spellName = GetSpellInfo(spell)
	return config.auras[spellName]
end

TMW_ST.UnitAuras = {
	unitHasAura = function(unit, spell)
		if (GetAuras) then
			return tmwGetUnitAura(unit, spell) ~= nil
		else
			return getUnitAura(unit, spell) ~= nill
		end
	end,
	getUnitAura = function(unit, spell)
		if (GetAuras) then
			return tmwGetUnitAura(unit, spell)
		else
			return getUnitAura(unit, spell)
		end
	end
}

-- list of current roster memebers
local roster = {}

local CACHE_TTL = 60

local cleanupTimer = C_Timer.NewTicker(CACHE_TTL, function()
	TMW_ST:printDebug("AuraTracker: cleaning up cache")

	local counter = 0

	for guid, unit in pairs(units) do
		if (TMW.time > units[guid].created+CACHE_TTL) then
			units[guid] = nil
			counter = counter+1
		end
	end

	if (counter > 0) then
		TMW_ST:printDebug("AuraTracker: cleaned up "..counter.." items")
	end
end)

_G.debufUnitTracker  = function()
	ViragDevTool:AddData(units,'TMW ST tracked units')
end		
function addUnit(unit)
	local id = UnitGUID(unit or '')

	if (not id) then return nil end

	if (units[id]) then return units[id] end

	units[id] = {
		auras = {},
		instanceIds = {},
		created = TMW.time
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
	TMW_ST:printDebug("AuraTracker: adding unit aura", unit, aura.name)

	local config = addUnit(unit)
	local spellName = GetSpellInfo(aura.name) or aura.name

	config.auras[spellName] = aura
	config.instanceIds[aura.auraInstanceID] = spellName
end

function removeUnitAura(unit, instanceId)
	local config = addUnit(unit)

	local spellName = config.instanceIds[instanceId]

	TMW_ST:printDebug("AuraTracker: removing unit aura", unit, spellName)

	if (spellName ~= nil) then
		config.auras[spellName] = nil
		config.instanceIds[instanceId] = nil
	end	
end

-- update tracked units based on update payload
EventHub:RegisterEvent('UNIT_AURA', function(event, unit, updates)
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
end)

-- in case unit is not in range, might not be tracked by UNIT_AURA,
-- so we remove its payload
EventHub:RegisterEvent("NAME_PLATE_UNIT_REMOVED", function(event, token)
	local guid = UnitGUID(token)
	if (units[guid]) then
		units[guid] = nil
	end
end)

-- in case roster changed, we want to make sure we dont have stale
-- data, so we clean it up
EventHub:RegisterEvent('GROUP_ROSTER_UPDATE', function(event)
	local new_roster = {}
	local prefix = IsInRaid() and 'raid' or 'party'
	for i=1,GetNumGroupMembers() do
		local guid = UnitGUID(prefix..i)

		if guid then new_roster[guid] = true end
	end

	for guid,_ in pairs(roster) do
		if (not new_roster[guid]) then
			TMW_ST:printDebug("AuraTracker: roster update removed "..guid)
			units[guid] = nil
		end
	end

	roster = new_roster
end)