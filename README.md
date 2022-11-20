TellMeWhen Script Tools
=======================

This addon is meant to add scripting capabilities to TellMeWhen, alongside adding experimental/niche condition cases to TellMeWhen.

# Main modules

1. [Counters and timers](#counters-and-timers)- adds the ability to manipulate TMW [counters](#counters), [timers](#timers) and [icon text](#script-text) in LUA.
2. [Dynamic Bar](#dynamic-bar) - adds a new bar type that is fully controlled by LUA.
3. [Conditions](#conditions):
	a) Empowered Cast Stages - adds a new condition to track the cast stage of an empowered cast.
	b) EnemyCounter - adds a new condition based on how many enemies are in melee range.
4. [Bar Ticks Marks](#bar-tick-marks) - allows you to add tick-marks on bars with LUA
	* [Example usages for tick marks](#tick-mark-examples)


# How to use LUA hooks in TMW

Adding LUA hooks to TMW is done by going to the `Notifications` tab in an icon's settings, and choosing the `LUA`
option. 

The most important hook for `TMW ST` is `On Icon Setup`. You will note that many modules provide an `Init` method that *must* be used on icon setup.

A common pattern is to initialize configs and constants on setup, and then share them on other hooks. For eg:

```lua
-- on icon setup
local icon = ...

local config = {
	counter_name = 'my_counter'
}
icon.my_config = config

TMW_ST:InitCounter(counter_name)
```

```lua
-- on show
local icon = ...
TMW_ST:UpdateCounter(icon.my_config.counter_name, 1)
```


```lua
-- on hide
local icon = ...
TMW_ST:UpdateCounter(icon.my_config.counter_name, 0)
```

The examples section includes a bunch of TMW imports that show usage of the varios modules.

# Modules


## Empower Cast Stage condition

Adds a new condition under `Scripts Tools >  Epowered Spell Stage`

## Counters and timers

### Counters

1. `TMW_ST:InitCounter(counter_name)` - **Must be called on `Icon Setup`**. If you do not, TMW will throw errors at you.

2. `TMW_ST:UpdateCounter(counter_name, value)`
3. `TMW_ST:GetCounter(counter_name)`

### Timers

1. `TMW_ST.Timers.Init(name)` - **Must be called on `Icon Setup`**.
2. `TMW_ST.Timers.Start(name)`
3. `TMW_ST.Timers.Stop(name)`
4. `TMW_ST.Timers.Reset(name)`
5. `TMW_ST.Timers.Restart(name)`
6. `TMW_ST.Timers.GetTime(name)`

### Script Text

1. `TMW_ST:SetScriptText(name, text)` - a LUA method to set a value to be accessed in DogTags
2. `[ST_GetScriptText(name)]` - a DogTag available in TMW icon text fields


## Dynamic Bar

This module adds a new icon type - `Dynamic Bar`. This icon has a list of dedicated methods that can be used in LUA

### `icon:setMaxValue(value)`

It is recomended that you call this method on `Icon Setup` with some default value

### `icon:setCurrentValue(value)`

### `icon:setBarColors(startColor, midColor, lastColor)`

Colors should be string colors as provided by TMW color picker (with `#` at the start).

The most common usecase for this method is to dymanically change the bar color. This can be done by passing the same color 3 times to the function:

```lua
local icon = ...

local green = '#38f13600'

icon:setBarColors(green, green, green)
```

### `icon:startDurationTracking(duration)`

Starts a duration countdown with `duration` length (in miliseconds). If you use this without setting max/current values, it will control the bar display. Otherwise, it will create a value you can track using the various duration DogTags (that is - if you set max/current after you set the duration).

### `icon:setStacks(stacks [, text])`

Will set the stacks attribute of the icon, so you can access in via DogTags. If you pass `stackText` it will control the value being displayed by the DogTag.

### `icon:registerTriggerFunction(fnc)`

This function will run on every update to the bar. If it returns `true` the update will commence, otherwise it will skip the update cycle.
You can use this function if you want to monitor the icon update cycle, or to make calculations on every tick.

## Conditions

These are new condition types under the `Script Tools` sub-menu in the condition choices.

1. Enemy Count - How many enemies are within melee range of player
2. Epowered Spell Stage

## Bar Tick Marks

1. `TMW_ST.Ticks.addTick(icon[,mode [,color] ] )` 
2. `TMW_ST.Ticks.addTicks(icon, howMany [,mode [,color] ] )`
3. `TMW_ST.Ticks.clearTicks(icon)`

It is recomended that you call `clearTicks` on `Icon Setup`.

Colors are the color strings for TMW color picker (without `#` at the start)

### Modes

* `TMW_ST.Ticks.modes.HORIZONTAL` - should be used for horizontal bars. Default value
* `TMW_ST.Ticks.modes.VERTICAL` - should be used for vertical bars.


### Tick Mark Examples

Add 3 magenta colored ticks to a bar:

```lua
-- on icon setup
local icon = ...

local Ticks = TMW_ST.Ticks

Ticks.clearTicks(icon)
Ticks.addTicks(icon, 3, Ticks.modes.HORIZONTAL, "ce35d3aa")
```

Add a tick to rage power bar based on how much rage is needed for Shield Block

```lua

local icon = ...
local activeSpec = GetActiveSpecGroup()
local _, _, _, selected = GetTalentInfoByID(382767, activeSpec)

local total_rage = 100
local sb_cost = 30
if (selected) then total_rage = 115 end

Ticks.clearTicks(icon)
Ticks.addTick(icon, sb_cost/total_rage)

-- if we were fancy we can instead run this code on load+talent_changed events so it's always correct
```
