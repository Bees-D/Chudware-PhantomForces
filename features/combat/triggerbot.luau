local Feature = {}
Feature.name = "Triggerbot"

local enabled = false
local delay = 0.05
local lastFire = 0

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Triggerbot")
	tab:CreateToggle({ Name = "Triggerbot", CurrentValue = false, Flag = "pf_triggerbot", Callback = function(v) enabled = v end })
	tab:CreateSlider({ Name = "Delay (s)", Range = {0, 0.2}, Increment = 0.01, CurrentValue = 0.05, Flag = "pf_trig_delay", Callback = function(v) delay = v end })

	local VIM = U.try(function() return game:GetService("VirtualInputManager") end)

	R.onRender("pf_triggerbot", function()
		if not enabled then return end
		if not VIM then return end

		local cam = S.Camera()
		if not cam then return end

		local now = tick()
		if now - lastFire < delay then return end

		local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 1000)
		if ray and ray.Instance then
			local hit = ray.Instance
			local model = hit:FindFirstAncestorOfClass("Model")
			if model then
				local player = S.Players:GetPlayerFromCharacter(model)
				if player and U.isEnemy(player) then
					local hum = model:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						lastFire = now
						pcall(function()
							VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
							task.defer(function()
								VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
							end)
						end)
					end
				end
			end
		end
	end)
end

function Feature.toggle(state) enabled = state end

return Feature
