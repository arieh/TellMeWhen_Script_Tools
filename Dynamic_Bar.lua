local TMW = TMW
local TMW_ST = TMW_ST
if not TMW or not TMW_ST then return end

local Type = TMW.Classes.IconType:New("dynamicbar")
Type.name = "Dynamic Bar"
Type.desc = "A Bar that can be controlled by LUA scripts"
Type.menuIcon = "Interface/Icons/inv_box_04"
Type.unitType = "unitid"
Type.hasNoGCD = true
Type.canControlGroup = true
Type.menuSpaceBefore = true

Type:SetAllowanceForView("icon", false)

Type:UsesAttributes("value, maxValue, valueColor")
Type:UsesAttributes("state")
Type:UsesAttributes("texture")

local function Value_OnUpdate(icon)
	if not icon.script_values.triggerFunc(icon) then
		return
	end
	
	if icon.script_values.changed then
		icon:YieldInfo(true, icon.script_values.current, icon.script_values.max, icon.script_values.colors)

		icon.script_values.changed = false		
		return
	end
end

function Type:HandleYieldedInfo(icon, iconToSet, value, maxValue, valueColor)

	iconToSet:SetInfo("value, maxValue, valueColor;",
			value, maxValue, valueColor
		)
end


function Type:Setup(icon)
	icon:SetInfo("texture", "Interface/Icons/inv_box_04")
	
	icon:SetUpdateMethod("auto")

	icon:SetUpdateFunction(Value_OnUpdate)	

	icon.script_values = {
		max = 100,
		current = 0,
		changed = true,
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

		if (value > values.max) then return end

		values.current = value

		values.changed = true
	end

	function icon:setBarColors(startColor, midColor, lastColor)
		TMW_ST:printDebug("icon:setBarColors", startColor, midColor, lastColor)

		local start = startColor or values.colors[0]
		local mid = midColor or values.colors[1]
		local last = lastColor or values.colors[2]

		values.colors = {start, mid, last}
 	end

 	function icon:registerTriggerFunction(fnc)
 		values.triggerFunc = fnc
 	end

 	icon:SetInfo("state;", {Alpha = 1})
	icon:Update()
end

TMW:RegisterCallback("TMW_CONFIG_ICON_TYPE_CHANGED", function(event, icon, type, oldType)
	local icspv = icon:GetSettingsPerView()

	if type == Type.type then
		icon:GetSettings().CustomTex = "NONE"
		local layout = TMW.TEXT:GetTextLayoutForIcon(icon)

		if layout == "bar1" or layout == "bar2" then
			icspv.Texts[1] = "[(Value / ValueMax * 100):Round:Percent]"
			icspv.Texts[2] = "[Value:Short \"/\" ValueMax:Short]"
		end
	elseif oldType == Type.type then
		if icspv.Texts[1] == "[(Value / ValueMax * 100):Round:Percent]" then
			icspv.Texts[1] = nil
		end
		if icspv.Texts[2] == "[Value:Short \"/\" ValueMax:Short]" then
			icspv.Texts[2] = nil
		end
	end
end)


Type:Register(157)
