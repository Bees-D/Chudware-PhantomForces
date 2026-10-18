local Feature = {}
Feature.name = "Triggerbot"

local enabled = false
local delayS = 0.04
local teamCheck = true
local holdKey = Enum.KeyCode.T
local hold = true
local last = 0

function Feature.init(tab, ctx)
	local S, U, R, T = ctx.services, ctx.util, ctx.runtime, ctx.tracker
	tab:CreateSection("Triggerbot")
	tab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "pf_trig", Callback = function(v) enabled = v end })
	tab:CreateToggle({ Name = "Hold key (T) only", CurrentValue = true, Flag = "pf_trig_hold", Callback = function(v) hold = v end })
	tab:CreateSlider({ Name = "Delay (s)", Range = {0, 0.3}, Increment = 0.01, CurrentValue = 0.04, Flag = "pf_trig_delay", Callback = function(v) delayS = v end })
	tab:CreateToggle({ Name = "Team check", CurrentValue = true, Flag = "pf_trig_team", Callback = function(v) teamCheck = v end })

	if not S.VIM then
		tab:CreateParagraph({ Title = "LIMITED", Content = "VirtualInputManager unavailable; triggerbot disabled." })
		return
	end

	R.onRender("pf_trig", function()
		if not enabled then return end
		if hold and not S.UIS:IsKeyDown(holdKey) then return end
		if tick() - last < delayS then return end
		local cam = S.Camera(); if not cam then return end
		-- raycast from camera forward; check hit belongs to an enemy body
		local ray = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * 2000)
		if not (ray and ray.Instance) then return end
		-- is the hit near an enemy root?
		local hitPos = ray.Position
		for _, tg in ipairs(T.targets) do
			if not (teamCheck and tg.isEnemy == false) then
				if (tg.pos - hitPos).Magnitude < 6 then
					last = tick()
					pcall(function()
						S.VIM:SendMouseButtonEvent(0,0,0,true,game,1)
						task.defer(function() S.VIM:SendMouseButtonEvent(0,0,0,false,game,1) end)
					end)
					break
				end
			end
		end
	end)
end

function Feature.toggle(state) enabled = state end
return Feature
