local Feature = {}
Feature.name = "Fullbright"

local enabled = false
local brightness = 3
local originals = nil
local lastApply = 0

function Feature.init(tab, ctx)
	local S = ctx.services
	local R = ctx.runtime

	tab:CreateSection("Fullbright")
	tab:CreateToggle({ Name = "Fullbright", CurrentValue = false, Flag = "pf_fullbright", Callback = function(v) enabled = v; if not v and originals then restore() end end })
	tab:CreateSlider({ Name = "Brightness", Range = {1, 10}, Increment = 0.5, CurrentValue = 3, Flag = "pf_fb_val", Callback = function(v) brightness = v; lastApply = 0 end })

	local function capture()
		if originals then return end
		local L = S.Lighting
		originals = {
			Brightness = L.Brightness, Ambient = L.Ambient, OutdoorAmbient = L.OutdoorAmbient,
			ClockTime = L.ClockTime, FogEnd = L.FogEnd,
		}
		local atm = L:FindFirstChildOfClass("Atmosphere")
		if atm then originals.AtmDensity = atm.Density end
	end

	function restore()
		if not originals then return end
		local L = S.Lighting
		for k, v in pairs(originals) do
			if k == "AtmDensity" then
				local atm = L:FindFirstChildOfClass("Atmosphere")
				if atm then pcall(function() atm.Density = v end) end
			else pcall(function() L[k] = v end) end
		end
		originals = nil
	end

	R.onHeartbeat("pf_fullbright", function()
		if not enabled then return end
		local now = tick()
		if now - lastApply < 1 then return end
		lastApply = now
		capture()
		local L = S.Lighting
		L.Brightness = brightness
		L.Ambient = Color3.new(1, 1, 1)
		L.OutdoorAmbient = Color3.new(1, 1, 1)
		L.ClockTime = 14
		L.FogEnd = 1e6
		local atm = L:FindFirstChildOfClass("Atmosphere")
		if atm then pcall(function() atm.Density = 0 end) end
	end)
end

function Feature.toggle(state) enabled = state end

return Feature
