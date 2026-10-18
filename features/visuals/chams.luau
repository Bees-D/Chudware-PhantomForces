local Feature = {}
Feature.name = "Chams"

local enabled = false
local teamCheck = true

function Feature.init(tab, ctx)
	local S, U, R, T = ctx.services, ctx.util, ctx.runtime, ctx.tracker
	tab:CreateSection("Chams (visible players)")
	tab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "pf_chams", Callback = function(v) enabled = v; if not v then U.clearAllHighlights() end end })
	tab:CreateToggle({ Name = "Team check", CurrentValue = true, Flag = "pf_chams_team", Callback = function(v) teamCheck = v end })

	R.onHeartbeat("pf_chams", function()
		if not enabled then return end
		local bodies = S.Bodies()
		if not bodies then return end
		-- map body model -> team via nearest target identity
		for _, bf in ipairs(bodies:GetChildren()) do
			local model = bf:FindFirstChildOfClass("Model")
			if model then
				-- find this body's team from tracker by proximity
				local part = model:FindFirstChildWhichIsA("BasePart")
				local enemy = nil
				if part then
					local bestD = 16
					for _, tg in ipairs(T.targets) do
						local d = (tg.pos - part.Position).Magnitude
						if d < bestD then bestD = d; enemy = tg.isEnemy end
					end
				end
				if not (teamCheck and enemy == false) then
					local col = (enemy == true) and Color3.fromRGB(255,60,60) or (enemy == false and Color3.fromRGB(60,200,90) or Color3.fromRGB(230,220,90))
					U.setHighlight(model, { FillColor = col, FillTransparency = 0.5, OutlineColor = col, OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop })
				end
			end
		end
	end)
end

function Feature.toggle(state) enabled = state end
return Feature
