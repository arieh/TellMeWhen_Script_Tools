
local CASTBAR_STAGE_INVALID = -1;
local CASTBAR_STAGE_DURATION_INVALID = -1;

local TMW = TMW
local TMW_ST = TMW_Script_Tools

local CNDT = TMW.CNDT
local Env = CNDT.Env

local aura_env = {}

local ConditionCategory = CNDT:GetCategory("ATTRIBUTES_TMWST", 11, "Script Tools", false, false)

Env.EmpoweredStage = 0
Env.EmpoweredSpellName = ''
Env.EmpoweredNumStages = 0

ConditionCategory:RegisterCondition(8.5,  "TMWSTEMPOWEREDSPELL", {
    text = "Empowered Spell Stage",
    tooltip = "Current stage of empowered spell",
    unit="player",
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
		local module = CNDT:GetModule("TMWST_EMPOWERED_CAST", true)
		if not module then
			module = CNDT:NewModule("TMWST_EMPOWERED_CAST", "AceEvent-3.0")
			module.Timers = {}
			module:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START", function()
				local unit = 'player'
				local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo(unit);

				if not name then return end

				Env.EmpoweredStage = 0
				Env.EmpoweredSpellName = name
				Env.EmpoweredNumStages = numStages + 1;

				local sumDuration = 0;

				TMW:Fire("TMW_CNDT_EMPOWERED_UPDATED")	

				local getStageDuration = function(stage)
					if stage == Env.EmpoweredNumStages then	
						return GetUnitEmpowerHoldAtMaxTime(unit);
					else
						return GetUnitEmpowerStageDuration(unit, stage-1);
					end
				end;

				for i = 1,Env.EmpoweredNumStages-1,1 do
					local duration = getStageDuration(i);

					if(duration > CASTBAR_STAGE_DURATION_INVALID) then
						sumDuration = sumDuration + duration;
						module.Timers[i] = C_Timer.NewTicker(sumDuration/1000, function()
							Env.EmpoweredStage = i
							TMW:Fire("TMW_CNDT_EMPOWERED_UPDATED")
						end, 1)
					end
				end
			end)

			module:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP", function()
				for i=1,Env.EmpoweredNumStages do 
					if module.Timers[i] then Timers[i]:Cancel() end
				end		
				module.Timers = {}
				Env.EmpoweredStage = 0
				Env.EmpoweredSpellName = ''
				Env.EmpoweredNumStages = 0
				TMW:Fire("TMW_CNDT_EMPOWERED_UPDATED")	
			end)
		end

		return [[(strlower(c.NameFirst) == strlower(EmpoweredSpellName) and EmpoweredStage c.Operator c.Level)]]
	end 
})