local Feature = {}
Feature.name = "Freecam"

local active = false
local speed = 2
local saved

function Feature.init(tab, ctx)
	local S, R = ctx.services, ctx.runtime
	tab:CreateSection("Freecam")
	tab:CreateToggle({ Name = "Freecam (P toggles)", CurrentValue = false, Flag = "pf_freecam", Callback = function(v)
		-- toggle handled by key; this just arms/disarms
		if not v and active then
			local cam = S.Camera(); if cam and saved then cam.CameraType = saved end
			active = false
		end
	end })
	tab:CreateSlider({ Name = "Speed", Range = {0.5, 8}, Increment = 0.5, CurrentValue = 2, Flag = "pf_freecam_spd", Callback = function(v) speed = v end })

	local cool = 0
	R.onRender("pf_freecam", function(dt)
		local cam = S.Camera(); if not cam then return end
		if S.UIS:IsKeyDown(Enum.KeyCode.P) and tick() - cool > 0.4 then
			cool = tick()
			if not active then saved = cam.CameraType; cam.CameraType = Enum.CameraType.Scriptable; active = true
			else cam.CameraType = saved or Enum.CameraType.Custom; active = false end
		end
		if not active then return end
		local dir = Vector3.zero
		if S.UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
		if S.UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
		if S.UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
		if S.UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
		if S.UIS:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.yAxis end
		if S.UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.yAxis end
		if dir.Magnitude > 0 then cam.CFrame = cam.CFrame + dir.Unit * speed * dt * 60 end
	end)
end

function Feature.toggle(state) end
return Feature
