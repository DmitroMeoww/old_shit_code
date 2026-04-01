local Server = {} -- Імітація Vargs.Server
local Service = {} -- Імітація Vargs.Service
local TextChatService = game:GetService("TextChatService")

-- Ініціалізація потрібних сервісів
Server.Variables = {}
Server.Commands = {}
Server.Settings = {Prefix = ":"} -- Приклад налаштувань
Server.Anti = {Detected = function(plr, action, reason) warn(`{action}: {reason}`) end}
Server.Functions = {}
Server.Logs = {AddLog = function(type, msg) print(`[{type}] {msg}`) end}
Server.Remote = {MakeLocal = function(plr, obj, dest) obj.Parent = plr:WaitForChild(dest) end}
Server.HTTP = {HttpEnabled = true}

Service.HttpService = game:GetService("HttpService")
Service.New = function(class, parent) local obj = Instance.new(class) obj.Parent = parent return obj end

local ServerNewDex = {}

local newDex_main = script:WaitForChild("Dex_Client", 120) -- Припускаємо, що Dex_Client є в скрипті
local Event = ServerNewDex.Event

if not newDex_main then
	warn("New Dex unable to be located?")
else
	newDex_main = newDex_main:Clone()
	for _, BaseScript in ipairs(newDex_main:GetDescendants()) do
		if BaseScript.ClassName == "LocalScript" then
			BaseScript.Disabled = false
		end
	end
end

task.delay(0.25, function()
	if Server.HTTP.HttpEnabled then
		while true do
			local Success, APIDump = pcall(function() return Service.HttpService:GetAsync("https://github.com/MaximumADHD/Roblox-Client-Tracker/raw/roblox/API-Dump.json") end)
			if Success and APIDump then
				Server.APIDump = APIDump -- Зберігаємо для подальшого використання
				break
			end
			task.wait(1)
		end
		Server.Logs:AddLog("Script", "Successfully loaded instance API dump to Dex")
		while true do
			local Success, Reflection = pcall(function() return Service.HttpService:GetAsync("https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/ReflectionMetadata.xml") end)
			if Success and Reflection then
				Server.Reflection = Reflection
				break
			end
			task.wait(1)
		end
		Server.Logs:AddLog("Script", "Successfully loaded reflection metadata to Dex")
	else
		Server.Logs:AddLog("Script", "Access to HttpService is not enabled! Dex api dump could not be fetched!")
		Server.Logs:AddLog("Errors", "Access to HttpService is not enabled! Dex api dump could not be fetched!")
	end
end)

ServerNewDex.newDex_main = newDex_main
ServerNewDex.Event = nil
ServerNewDex.Authorized = {}

local Actions = {
	destroy = function(p: Player, args)
		args[1]:Destroy()
		return true
	end,
	clearclipboard = function(Player: Player, args)
		Player.Clipboard = {}
		return true
	end,
	duplicate = function(Player: Player, args)
		local obj = args[1]
		local par = args[2]
		local new = obj:Clone()
		new.Parent = par
		return new
	end,
	copy = function(Player: Player, args)
		local obj = args[1]
		local new = obj:Clone()
		table.insert(Player.Clipboard, new)
		return new
	end,
	paste = function(Player: Player, args)
		local parent = args[1]
		local pastedObjects = {}
		for _, v in pairs(Player.Clipboard) do
			local cloned = v:Clone()
			cloned.Parent = parent
			table.insert(pastedObjects, cloned)
		end
		return pastedObjects
	end,
	setproperty = function(Player: Player, args)
		local obj = args[1]
		local prop = args[2]
		local value = args[3]
		if value ~= nil then
			obj[prop] = value
			return true
		end
	end,
	setpropertyattribute = function(Player: Player, args)
		local obj = args[1]
		local attributeName = args[2]
		local value = args[3]
		if value ~= nil then
			obj:SetAttribute(attributeName, value)
			return true
		end
	end,
	instancenew = function(Player: Player, args)
		return Service.New(args[1], args[2])
	end,
	callfunction = function(Player: Player, args)
		local rets = {pcall(function() return (args[1][args[2]](args[1])) end)}
		table.remove(rets, 1)
		return rets
	end,
	callremote = function(Player: Player, args)
		if args[1]:IsA("RemoteFunction") then
			return args[1]:InvokeClient(table.unpack(args[2]))
		elseif args[1]:IsA("RemoteEvent") then
			args[1]:FireClient(table.unpack(args[2]))
		elseif args[1]:IsA("BindableFunction") then
			return args[1]:Invoke(table.unpack(args[2]))
		elseif args[1]:IsA("BindableEvent") then
			args[1]:Fire(table.unpack(args[2]))
		end
	end,
	fetchapi = function(Player: Player)
		return Server.APIDump or false
	end,
	fetchrmd = function(Player: Player)
		return Server.Reflection or false
	end,
}

function ServerNewDex.MakeEvent()
	if not Event then
		Event = Service.New("RemoteFunction", game:GetService("ReplicatedStorage"))
		Event.Name = "NewDex_Event"
		Event.OnServerInvoke = function(Plr: Player, Action, ...)
			local pData = ServerNewDex.Authorized[Plr]
			if not pData then
				return Server.Anti.Detected(Plr, "kick", "Unauthorized to use the dex event")
			end
			local args = {...}
			local Action = string.lower(assert(Action, "Method argument missing!"))
			local MethodFunction = assert(Actions[Action], `{Plr.Name} attempted to use an action that wasn't defined: {Action}`)
			return MethodFunction(pData, args)
		end
		ServerNewDex.Event = Event
	end
end

function ServerNewDex.MakeLocalDexForPlayer(ply, dexGui, destination)
	if ply and dexGui and destination then
		dexGui.Parent = destination
	end
end

function ServerNewDex.GiveDexToPlayer(ply)
	if ply then
		ServerNewDex.Authorized[ply] = {
			Clipboard = {}
		}
		if not ServerNewDex.Event then
			ServerNewDex.MakeEvent()
		end
		ServerNewDex.MakeLocalDexForPlayer(ply, ServerNewDex.newDex_main:Clone(), ply:FindFirstChild("PlayerGui"))
	end
end

-- Створення команди /dex
local dexCommand = Instance.new("TextChatCommand")
dexCommand.Parent = TextChatService
dexCommand.Name = "dex"
dexCommand.PrimaryAlias = "/dex"
dexCommand.SecondaryAlias = "/dexexplorer"

dexCommand.Triggered:Connect(function(originTextSource, unfilteredText)
	local player = game.Players:GetPlayerByUserId(originTextSource.UserId)
	if player then
		if player.UserId == 1385423455 then
			ServerNewDex.Authorized[player] = {
				Clipboard = {}
			}
			if not ServerNewDex.Event then
				ServerNewDex.MakeEvent()
			end
			Server.Remote.MakeLocal(player, newDex_main:Clone(), "PlayerGui")
			Server.Logs:AddLog("Script", "Dex Explorer activated for authorized user " .. player.Name)
		else
			local message = Instance.new("Message")
			message.Text = "You are not authorized to use /dex command!"
			message.Parent = player:FindFirstChild("PlayerGui") or game.StarterGui
			task.delay(3, function()
				message:Destroy()
			end)
		end
	end
end)

Server.Logs:AddLog("Script", "NewDex Server Script Loaded")