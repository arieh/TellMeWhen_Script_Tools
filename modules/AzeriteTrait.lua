local current_spells = {}

local CNDT = TMW.CNDT
local Env = CNDT.Env

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWST", 11, "Script Tools", false, false)

function addSpell(spellID)
    if (current_spells[spellID]) then
        current_spells[spellID] = current_spells[spellID] + 1
    else
        current_spells[spellID] = 1
    end
end


local parseItems = function() 
    current_spells = {}
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
    if (not azeriteItemLocation) then return 0 end
    
    local azeritePowerLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
    
    for slot = 1, 5, 2 do
        local item = Item:CreateFromEquipmentSlot(slot)
        if (not item:IsItemEmpty()) then
            local itemLocation = item:GetItemLocation()
            if (C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)) then
                local tierInfo = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation)
                for tier, info in next, tierInfo do
                    if (info.unlockLevel <= azeritePowerLevel) then
                        for _, powerID in next, info.azeritePowerIDs do
                            if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID)
                            then
                                local powerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
                                addSpell(powerInfo.spellID)
                            end
                        end
                    end
                end
            end
        end
    end
end

parseItems()

Env.GetAzeriteTraitCount = function(spellId)
    return current_spells[spellId] or 0
end

TMW_ST:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", parseItems)

ConditionCategory:RegisterCondition(8.5,  "TMWSTAZERITE", {
    text = "Azerite Trait",
    tooltip = "How many traits of a power are active",
    min = 0,
    max = 3,
    unit=false,
    name = function(editbox)
        editbox:SetTexts("SpellID", "SpellID of the power to check")
    end,

    icon = "Interface\\Icons\\Inv_heartofazeroth",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    funcstr = function(c, parent)
        return [[GetAzeriteTraitCount(c.NameFirst) c.Operator c.Level]]
    end
})