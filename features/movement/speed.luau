local Feature = {}
Feature.name = "Speed"

local enabled = false
local speed = 24

function Feature.init(tab, ctx)
	local S = ctx.services
	local R = ctx.runtime

	tab:CreateSection("Speed")
	tab:CreateParagraph({ Title = "NOTE", Content = "PF default walk is 16. Values above ~25 may trigger anticheat." })
	tab:CreateToggle({ Name = "Speed Hack", CurrentValue = false, Flag = "pf_speed", Callback = function(v) enabled = v end })
	tab:CreateSlider({ Name = "Walk Speed", Range = {16, 100}, Increment = 1, CurrentValue = 24, Flag = "pf_speed_val", Callback = function(v) speed = v end })

	R.onHeartbeat("pf_speed", function()
		if not enabled then return end
		local hum = S.Humanoid()
		if hum then
			pcall(function() hum.WalkSpeed = speed end)
		end
	end)
end

function Feature.toggle(state) enabled = state end

return Feature
