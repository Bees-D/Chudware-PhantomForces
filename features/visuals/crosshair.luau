local Feature = {}
Feature.name = "Crosshair"

local enabled = false
local size = 10
local gap = 5
local thickness = 1
local xhairColor = Color3.fromRGB(0, 255, 0)
local showDot = true
local lines = {}

function Feature.init(tab, ctx)
	local S = ctx.services
	local U = ctx.util
	local R = ctx.runtime

	tab:CreateSection("Crosshair")
	tab:CreateToggle({ Name = "Custom Crosshair", CurrentValue = false, Flag = "pf_xhair", Callback = function(v) enabled = v end })
	tab:CreateSlider({ Name = "Size", Range = {2, 30}, Increment = 1, CurrentValue = 10, Flag = "pf_xhair_size", Callback = function(v) size = v end })
	tab:CreateSlider({ Name = "Gap", Range = {0, 15}, Increment = 1, CurrentValue = 5, Flag = "pf_xhair_gap", Callback = function(v) gap = v end })
	tab:CreateColorPicker({ Name = "Color", Color = xhairColor, Flag = "pf_xhair_color", Callback = function(v) xhairColor = v end })
	tab:CreateToggle({ Name = "Center Dot", CurrentValue = true, Flag = "pf_xhair_dot", Callback = function(v) showDot = v end })

	lines.top = U.newDrawing("Line", { Thickness = thickness })
	lines.bottom = U.newDrawing("Line", { Thickness = thickness })
	lines.left = U.newDrawing("Line", { Thickness = thickness })
	lines.right = U.newDrawing("Line", { Thickness = thickness })
	lines.dot = U.newDrawing("Circle", { Thickness = 1, Filled = true, Radius = 2 })

	R.onRender("pf_crosshair", function()
		if not enabled then
			for _, d in pairs(lines) do U.hideDrawing(d) end
			return
		end

		local cam = S.Camera()
		if not cam then return end
		local cx = cam.ViewportSize.X / 2
		local cy = cam.ViewportSize.Y / 2

		if lines.top then
			lines.top.From = Vector2.new(cx, cy - gap - size)
			lines.top.To = Vector2.new(cx, cy - gap)
			lines.top.Color = xhairColor; lines.top.Visible = true
		end
		if lines.bottom then
			lines.bottom.From = Vector2.new(cx, cy + gap)
			lines.bottom.To = Vector2.new(cx, cy + gap + size)
			lines.bottom.Color = xhairColor; lines.bottom.Visible = true
		end
		if lines.left then
			lines.left.From = Vector2.new(cx - gap - size, cy)
			lines.left.To = Vector2.new(cx - gap, cy)
			lines.left.Color = xhairColor; lines.left.Visible = true
		end
		if lines.right then
			lines.right.From = Vector2.new(cx + gap, cy)
			lines.right.To = Vector2.new(cx + gap + size, cy)
			lines.right.Color = xhairColor; lines.right.Visible = true
		end
		if lines.dot then
			lines.dot.Position = Vector2.new(cx, cy)
			lines.dot.Color = xhairColor
			lines.dot.Visible = showDot
		end
	end)
end

function Feature.toggle(state) enabled = state end

return Feature
