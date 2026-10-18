local Feature = {}
Feature.name = "Freecam"

local enabled = false
local speed = 1
local savedCamType = nil

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Freecam")
	tab:CreateToggle({ Name = "Freecam (P key)", CurrentValue = false, Flag = "pf_freecam", Callback = function(v) enabled = v end })
	tab:CreateSlider({ Name = "Speed", Range = {0.5, 5}, Increment = 0.5, CurrentValue = 1, Flag = "pf_freecam_spd", Callback = function(v) speed = v end })

	local active = false

	R.onRender("pf_freecam", function(dt)
		local cam = S.Camera()
		if not cam then return end

		if S.UIS:IsKeyDown(Enum.KeyCode.P) then
			if not active and enabled then
				active = true
				savedCamType = cam.CameraType
				cam.CameraType = Enum.CameraType.Scriptable
			elseif active then
				active = false
				cam.CameraType = savedCamType or Enum.CameraType.Custom
			end
			task.wait(0.3)
		end

		if not active then return end

		local moveDir = Vector3.new()
		if S.UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
		if S.UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
		if S.UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
		if S.UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
		if S.UIS:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
		if S.UIS:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end

		if moveDir.Magnitude > 0 then
			cam.CFrame = cam.CFrame + moveDir.Unit * speed * dt * 60
		end
	end)
end

function Feature.toggle(state) enabled = state end

return Feature
