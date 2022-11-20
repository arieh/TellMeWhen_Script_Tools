
local CASTBAR_STAGE_INVALID = -1;
local CASTBAR_STAGE_DURATION_INVALID = -1;

local TMW = TMW
local TMW_ST = TMW_Script_Tools

local CNDT = TMW.CNDT
local Env = CNDT.Env

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWST", 11, "Script Tools", false, false)

Env.EmpoweredCasts = {
	units = {}
}

Env.EmpoweredCasts.getStage = function(unit)
	if not Env.EmpoweredCasts.units[unit] then return 0 end
	return Env.EmpoweredCasts.units[unit].currentStage
end

Env.EmpoweredCasts.getSpell = function(unit)
	if not Env.EmpoweredCasts.units[unit] then return '' end
	return Env.EmpoweredCasts.units[unit].spellName
end

ConditionCategory:RegisterCondition(8.5,  "TMWSTEMPOWEREDSPELL", {
    text = "Empowered Spell Stage",
    tooltip = "Current stage of empowered spell",
	useSUG = "spell",	
    name = function(editbox)
		editbox:SetTexts(L["SPELLTOCOMP1"], L["CNDT_ONLYFIRST"])
	end,
    min = 0,
    max = 5,
    icon = "Interface\\Icons\\inv_10_enchanting2_elementalswirl_color1",
    tcoords = CNDT.COMMON.standardtcoords,

    specificOperators = {["<="] = true, [">="] = true, ["=="]=true, ["~="]=true},

    applyDefaults = function(conditionData, conditionSettings)
        local op = conditionSettings.Operator

        if not conditionData.specificOperators[op] then
            conditionSettings.Operator = "<="
        end
    end,

	events = function(ConditionObject, c)
		return
			ConditionObject:GenerateNormalEventString("TMW_CNDT_EMPOWERED_UPDATED")
	end,
	funcstr = function(c)
		local addUnit = function(unit, stages, spell)
			local config = {
				numStages = stages,
				spellName = spell,
				currentStage = 0,
				timers = {}
			}
			Env.EmpoweredCasts.units[unit] = config
			return config
		end

		local module = CNDT:GetModule("TMWST_EMPOWERED_CAST", true)

		if not module then
			module = CNDT:NewModule("TMWST_EMPOWERED_CAST", "AceEvent-3.0")

			module:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START", function(event, unit)
				local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo(unit);

				if not name then return end

				local config = addUnit(unit, numStages -1 , name)

				local sumDuration = 0;

				TMW:Fire("TMW_CNDT_EMPOWERED_UPDATED")	

				local getStageDuration = function(stage)
					if stage == numStages then	
						return GetUnitEmpowerHoldAtMaxTime(unit);
					else
						return GetUnitEmpowerStageDuration(unit, stage-1);
					end
				end;

				for i = 1,numStages-1,1 do
					local duration = getStageDuration(i);

					if(duration > CASTBAR_STAGE_DURATION_INVALID) then
						sumDuration = sumDuration + duration;
						config.timers[i] = C_Timer.NewTicker(sumDuration/1000, function()
							config.currentStage = i
							TMW:Fire("TMW_CNDT_EMPOWERED_UPDATED")
						end, 1)
					end
				end
			end)

			module:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP", function(event, unit)
				local config = Env.EmpoweredCasts.units[unit]

				if not config then return end

				for i=1,config.numStages do 
					if config.timers[i] then config.timers[i]:Cancel() end
				end		
				
				Env.EmpoweredCasts.units[unit] = nil

				TMW:Fire("TMW_CNDT_EMPOWERED_UPDATED")	
			end)
		end

		return [[(strlower(c.NameFirst) == strlower(EmpoweredCasts.getSpell(c.Unit)) and EmpoweredCasts.getStage(c.Unit) c.Operator c.Level)]]
	end 
})