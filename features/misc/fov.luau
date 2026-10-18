local Feature = {}
Feature.name = "FOV"

local enabled = false
local target = 90

function Feature.init(tab, ctx)
	local S, R = ctx.services, ctx.runtime
	tab:CreateSection("Camera FOV")
	tab:CreateToggle({ Name = "Override FOV", CurrentValue = false, Flag = "pf_fov", Callback = function(v) enabled = v end })
	tab:CreateSlider({ Name = "FOV", Range = {70, 120}, Increment = 1, CurrentValue = 90, Flag = "pf_fov_val", Callback = function(v) target = v end })

	R.onRender("pf_fov", function()
		if not enabled then return end
		local cam = S.Camera(); if not cam then return end
		pcall(function() cam.FieldOfView = target end)
	end)
end

function Feature.toggle(state) enabled = state end
return Feature
