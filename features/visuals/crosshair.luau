local Feature = {}
Feature.name = "Crosshair"

local enabled = false
local gap, len = 4, 8
local dot = {}

function Feature.init(tab, ctx)
	local S, U, R = ctx.services, ctx.util, ctx.runtime
	tab:CreateSection("Crosshair")
	tab:CreateToggle({ Name = "Enabled", CurrentValue = false, Flag = "pf_cross", Callback = function(v) enabled = v end })
	tab:CreateSlider({ Name = "Gap", Range = {0, 20}, Increment = 1, CurrentValue = 4, Flag = "pf_cross_gap", Callback = function(v) gap = v end })
	tab:CreateSlider({ Name = "Length", Range = {2, 30}, Increment = 1, CurrentValue = 8, Flag = "pf_cross_len", Callback = function(v) len = v end })

	local col = Color3.fromRGB(0,255,0)
	local lines = {
		U.newDrawing("Line", { Thickness = 1, Color = col, Transparency = 1 }),
		U.newDrawing("Line", { Thickness = 1, Color = col, Transparency = 1 }),
		U.newDrawing("Line", { Thickness = 1, Color = col, Transparency = 1 }),
		U.newDrawing("Line", { Thickness = 1, Color = col, Transparency = 1 }),
	}

	R.onRender("pf_cross", function()
		if not enabled then for _, l in ipairs(lines) do U.hideDrawing(l) end return end
		local cam = S.Camera(); if not cam then return end
		local c = cam.ViewportSize / 2
		lines[1].From = Vector2.new(c.X - gap - len, c.Y); lines[1].To = Vector2.new(c.X - gap, c.Y); lines[1].Visible = true
		lines[2].From = Vector2.new(c.X + gap, c.Y); lines[2].To = Vector2.new(c.X + gap + len, c.Y); lines[2].Visible = true
		lines[3].From = Vector2.new(c.X, c.Y - gap - len); lines[3].To = Vector2.new(c.X, c.Y - gap); lines[3].Visible = true
		lines[4].From = Vector2.new(c.X, c.Y + gap); lines[4].To = Vector2.new(c.X, c.Y + gap + len); lines[4].Visible = true
	end)
end

function Feature.toggle(state) enabled = state end
return Feature
