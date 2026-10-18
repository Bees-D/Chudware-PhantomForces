local Feature = {}
Feature.name = "No Recoil"

local enabled = false
local lastCF = nil
local shooting = false

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("No Recoil")
	tab:CreateToggle({ Name = "No Recoil", CurrentValue = false, Flag = "pf_norecoil", Callback = function(v) enabled = v end })

	R.onRender("pf_norecoil", function()
		if not enabled then
			lastCF = nil
			return
		end

		local cam = S.Camera()
		if not cam then return end

		local mouse = S.Mouse()
		if not mouse then
			lastCF = cam.CFrame
			return
		end

		local isDown = S.UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)

		if isDown then
			if not shooting and lastCF then
				shooting = true
			end
			if shooting and lastCF then
				local current = cam.CFrame
				local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = lastCF:GetComponents()
				local px, py, pz = current:GetComponents()
				cam.CFrame = CFrame.new(px, py, pz, r00, r01, r02, r10, r11, r12, r20, r21, r22)
			end
		else
			shooting = false
		end

		lastCF = cam.CFrame
	end)
end

function Feature.toggle(state) enabled = state end

return Feature
