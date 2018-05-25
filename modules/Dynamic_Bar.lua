local TMW = TMW
local TMW_ST = TMW_ST
if not TMW or not TMW_ST then return end

local L = TMW.L

local Type = TMW.Classes.IconType:New("dynamicbar")
Type.name = "Dynamic Bar"
Type.desc = "A Bar that can be controlled by LUA scripts"
Type.menuIcon = "Interface/Icons/inv_box_04"
Type.hasNoGCD = true
Type.menuSpaceBefore = true

Type:SetAllowanceForView("icon", false)

Type:UsesAttributes("value, maxValue, valueColor")
Type:UsesAttributes("state")
Type:UsesAttributes("texture")
Type:UsesAttributes("auraSourceUnit, auraSourceGUID")
Type:UsesAttributes("start, duration")
Type:UsesAttributes("stack, stackText")

local STATE_SHOW = TMW.CONST.STATE.DEFAULT_SHOW

Type:RegisterConfigPanel_XMLTemplate(165, "TellMeWhen_IconStates", {
	[STATE_SHOW]     = { order = 1, text = "|cFF00FF00" .. L["DEFAULT"], },
})


local function Value_OnUpdate(icon)
	local script_values = icon.script_values

	if not script_values.triggerFunc(icon) then
		return
	end

	if script_values.changed then
		icon:SetInfo("state; value, maxValue, valueColor; start, duration; stack, stackText",
			STATE_SHOW, 
			script_values.current, script_values.max, 
			script_values.colors,
			script_values.duration.start, script_values.duration.duration,
			script_values.stacks.stacks, script_values.stacks.text
		)

		script_values.changed = false
	end
end


function Type:Setup(icon)
	icon:SetInfo("texture", "Interface/Icons/inv_box_04")
	
	icon:SetUpdateMethod("auto")

	icon:SetUpdateFunction(Value_OnUpdate)	

	icon.script_values = {
		max = 100,
		current = 0,
		changed = true,
		duration = {
			start = 0,
			duration = 0
		},
		stacks = {
			stacks = 0,
			text = 0
		},
		colors = {"#ffff1200", "#ffffff00", "#ff00ff00"},
		show = true,
		triggerFunc = function() 
			return true
		end
	}

	local values = icon.script_values

	function icon:setMaxValue(value)
		TMW_ST:printDebug("icon:setMaxValue", value)
		values.max = value
		values.changed = true
	end

	function icon:setCurrentValue(value)
		TMW_ST:printDebug("icon:setCurrentValue", value)

		values.current = value

		values.changed = true
	end

	function icon:setBarColors(startColor, midColor, lastColor)
		TMW_ST:printDebug("icon:setBarColors", startColor, midColor, lastColor)

		local start = startColor or values.colors[0]
		local mid = midColor or values.colors[1]
		local last = lastColor or values.colors[2]

		values.colors = {start, mid, last}

		values.changed = true
 	end

 	function icon:startDurationTracking(duration)
 		TMW_ST:printDebug("icon:startDurationTracking", start_value)

 		values.duration.start = TMW.time
 		values.duration.duration = duration
		values.changed = true
 	end

 	function icon:setStacks(stacks, text)
 		TMW_ST:printDebug("icon:setStacks", stacks, text)

 		values.stacks.stacks = stacks

 		if (text ~= nil) then
 			values.stacks.text = text
 		else
 			values.stacks.text = stacks
 		end

 		values.changed = true
 	end

 	function icon:registerTriggerFunction(fnc)
 		values.triggerFunc = fnc
 	end

	icon:Update()
end

TMW:RegisterCallback("TMW_CONFIG_ICON_TYPE_CHANGED", function(event, icon, type, oldType)
	local icspv = icon:GetSettingsPerView()

	if type == Type.type and oldType == "" then
		icon:GetSettings().CustomTex = "NONE"
		local layout = TMW.TEXT:GetTextLayoutForIcon(icon)

		if layout == "bar1" or layout == "bar2" then
			icspv.Texts[1] = "[(Value / ValueMax * 100):Round:Percent]"
			icspv.Texts[2] = "[Value:Short \"/\" ValueMax:Short]"
		end
	end
end)


Type:Register(157)
