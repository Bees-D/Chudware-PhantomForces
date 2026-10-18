local Feature = {}
Feature.name = "Fullbright"

local enabled = false
local orig
local last = 0

function Feature.init(tab, ctx)
	local S, R = ctx.services, ctx.runtime
	tab:CreateSection("Fullbright")

	local function restore()
		if not orig then return end
		local L = S.Lighting
		for k, v in pairs(orig) do pcall(function() L[k] = v end) end
		orig = nil
	end

	tab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "pf_fb", Callback = function(v)
		enabled = v; if not v then restore() end
	end })

	R.onHeartbeat("pf_fb", function()
		if not enabled then return end
		if tick() - last < 1 then return end
		last = tick()
		local L = S.Lighting
		if not orig then orig = { Brightness = L.Brightness, ClockTime = L.ClockTime, FogEnd = L.FogEnd, Ambient = L.Ambient, OutdoorAmbient = L.OutdoorAmbient } end
		pcall(function()
			L.Brightness = 2; L.ClockTime = 14; L.FogEnd = 1e9
			L.Ambient = Color3.new(1,1,1); L.OutdoorAmbient = Color3.new(1,1,1)
		end)
	end)
end

function Feature.toggle(state) enabled = state end
return Feature
