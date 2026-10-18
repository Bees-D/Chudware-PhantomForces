local Feature = {}
Feature.name = "Chams"

local enabled = false
local chamColor = Color3.fromRGB(255, 0, 100)
local highlights = {}
local UPDATE_INTERVAL = 0.5
local lastUpdate = 0

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Chams")
	tab:CreateToggle({ Name = "Chams", CurrentValue = false, Flag = "pf_chams", Callback = function(v) enabled = v; if not v then Feature.cleanup() end end })
	tab:CreateColorPicker({ Name = "Cham Color", Color = chamColor, Flag = "pf_cham_color", Callback = function(v) chamColor = v end })

	function Feature.cleanup()
		for inst in pairs(highlights) do U.clearHighlight(inst) end
		highlights = {}
	end

	R.onHeartbeat("pf_chams", function()
		if not enabled then return end

		local now = tick()
		if now - lastUpdate < UPDATE_INTERVAL then return end
		lastUpdate = now

		local seen = {}
		for _, player in ipairs(S.Players:GetPlayers()) do
			if U.isEnemy(player) then
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if char and hum and hum.Health > 0 then
					seen[char] = true
					U.setHighlight(char, {
						FillColor = chamColor,
						FillTransparency = 0.5,
						OutlineColor = chamColor,
						OutlineTransparency = 0,
						DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
					})
				end
			end
		end

		for inst in pairs(highlights) do
			if not seen[inst] then U.clearHighlight(inst); highlights[inst] = nil end
		end
		for inst in pairs(seen) do highlights[inst] = true end
	end)
end

function Feature.toggle(state) enabled = state end

return Feature
