local Feature = {}
Feature.name = "Fly & Noclip"

local flyEnabled = false
local noclipEnabled = false
local flySpeed = 2
local bodyVel = nil
local bodyGyro = nil
local noclipParts = {}

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Fly & Noclip")
	tab:CreateParagraph({ Title = "WARNING", Content = "PF has anti-fly detection. Use at your own risk." })
	tab:CreateToggle({ Name = "Fly (V key)", CurrentValue = false, Flag = "pf_fly", Callback = function(v) flyEnabled = v end })
	tab:CreateSlider({ Name = "Fly Speed", Range = {1, 10}, Increment = 0.5, CurrentValue = 2, Flag = "pf_fly_spd", Callback = function(v) flySpeed = v end })
	tab:CreateToggle({ Name = "Noclip", CurrentValue = false, Flag = "pf_noclip", Callback = function(v) noclipEnabled = v end })

	local flyActive = false

	local function startFly()
		local hrp = S.HRP()
		if not hrp or flyActive then return end
		flyActive = true

		bodyVel = Instance.new("BodyVelocity")
		bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVel.Velocity = Vector3.zero
		bodyVel.Parent = hrp

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.P = 9e4
		bodyGyro.Parent = hrp
	end

	local function stopFly()
		flyActive = false
		if bodyVel then pcall(function() bodyVel:Destroy() end); bodyVel = nil end
		if bodyGyro then pcall(function() bodyGyro:Destroy() end); bodyGyro = nil end
	end

	R.onRender("pf_fly", function()
		if not flyEnabled then
			if flyActive then stopFly() end
			return
		end

		local hrp = S.HRP()
		if not hrp then return end
		local cam = S.Camera()
		if not cam then return end

		if S.UIS:IsKeyDown(Enum.KeyCode.V) then
			if not flyActive then
				startFly()
			else
				stopFly()
			end
			task.wait(0.3)
		end

		if flyActive and bodyVel and bodyGyro then
			local dir = Vector3.zero
			if S.UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
			if S.UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
			if S.UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
			if S.UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
			if S.UIS:IsKeyDown(Enum.KeyCode.E) then dir = dir + Vector3.new(0, 1, 0) end
			if S.UIS:IsKeyDown(Enum.KeyCode.Q) then dir = dir - Vector3.new(0, 1, 0) end

			if dir.Magnitude > 0 then
				bodyVel.Velocity = dir.Unit * flySpeed * 50
			else
				bodyVel.Velocity = Vector3.zero
			end

			bodyGyro.CFrame = cam.CFrame
		end
	end)

	R.onHeartbeat("pf_noclip", function()
		if not noclipEnabled then
			for part, orig in pairs(noclipParts) do
				pcall(function() part.CanCollide = orig end)
			end
			noclipParts = {}
			return
		end

		local char = S.Character()
		if not char then return end

		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				if noclipParts[part] == nil then
					noclipParts[part] = part.CanCollide
				end
				part.CanCollide = false
			end
		end
	end)
end

function Feature.toggle(state) flyEnabled = state; noclipEnabled = state end

return Feature
