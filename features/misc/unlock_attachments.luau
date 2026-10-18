local Feature = {}
Feature.name = "Unlock All Attachments"

function Feature.init(tab, ctx)
	local U, N = ctx.util, ctx.notify
	tab:CreateSection("Unlocks")
	tab:CreateButton({ Name = "Unlock All Attachments", Callback = function()
		local mods, patched = 0, 0
		U.forEachAttachment(function(m) mods = mods + 1; patched = patched + U.patchTableKey(m, "unlockkills", 0) end)
		if N then N.ok("Attachments: " .. patched .. " unlocked (" .. mods .. " modules). Reopen loadout.") end
	end })
end

function Feature.toggle(state) end
return Feature
