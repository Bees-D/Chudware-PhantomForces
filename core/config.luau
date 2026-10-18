local Config = {}
local data = {}
local FILE = "Chudware_PF.json"
local hasFS = pcall(function() return readfile and writefile end)

function Config.get(key, default)
	if data[key] ~= nil then return data[key] end
	return default
end

function Config.set(key, value)
	data[key] = value
	Config.save()
end

function Config.load()
	if not hasFS then return end
	local ok, content = pcall(readfile, FILE)
	if ok and content then
		local ok2, decoded = pcall(game.HttpService.JSONDecode, game:GetService("HttpService"), content)
		if ok2 and type(decoded) == "table" then data = decoded end
	end
end

function Config.save()
	if not hasFS then return end
	pcall(function()
		local encoded = game:GetService("HttpService"):JSONEncode(data)
		writefile(FILE, encoded)
	end)
end

_G._chud_modules = _G._chud_modules or {}
_G._chud_modules.config = Config
return Config
