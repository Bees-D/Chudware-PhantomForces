local Notify = {}

local _rayfield = nil

function Notify.setRayfield(rf)
	_rayfield = rf
end

function Notify.send(title, content, duration)
	if _rayfield and _rayfield.Notify then
		pcall(function()
			_rayfield:Notify({
				Title = title or "Chudware PF",
				Content = content or "",
				Duration = duration or 4,
				Image = nil,
			})
		end)
	end
end

function Notify.ok(msg) Notify.send("Chudware PF", msg, 3) end
function Notify.warn(msg) Notify.send("Warning", msg, 5) end
function Notify.err(msg) Notify.send("Error", msg, 6) end

return Notify
