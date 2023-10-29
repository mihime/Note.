setfpscap(10)
---@diagnostic disable: undefined-global, lowercase-global, deprecated, undefined-field, ambiguity-1, unbalanced-assignments, redundant-parameter, cast-local-type, redefined-local, need-check-nil
lunaxshopconfig = {}
lunaxshopconfig.ver = "Bata TEST 7"


print("|======== LunaXShop =======|")
print("")
print("Start Load Script VER "..lunaxshopconfig.ver)
print("")
print(("=========================="))


repeat
    task.wait()
until game:IsLoaded()

if game.PlaceId == 8304191830 then
    repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
    repeat task.wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("collection"):FindFirstChild("grid"):FindFirstChild("List"):FindFirstChild("Outer"):FindFirstChild("UnitFrames")
else
    repeat task.wait() until game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name)
    game:GetService("ReplicatedStorage").endpoints.client_to_server.vote_start:InvokeServer()
    getgenv().start_time = os.time()
    local wavesStarted = false
    repeat
        wavesStarted = game:GetService("Workspace")["_waves_started"].Value
        task.wait()
    until wavesStarted or os.time() - getgenv().start_time >= 100 print("Waves Started -> ",getgenv().start_time)
    
    if not wavesStarted then
        warn("<-- Go Home -->")
        task.wait(5)
        game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
    end
end


task.wait(10)

local plr = game:GetService("Players").LocalPlayer
local players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Mouse = LocalPlayer:GetMouse()
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local _wave = game:GetService("Workspace"):WaitForChild("_wave_num")

-- function low_cpu()
-- 	UserInputService.WindowFocusReleased:Connect(function()
-- 		setfpscap(10)
-- 	end)
-- 	UserInputService.WindowFocused:Connect(function()
-- 		setfpscap(10)
-- 	end)
-- end

-- low_cpu()

--#region Report ERROR
local ErrConns = getconnections(game:GetService("ScriptContext").Error)
for _,v in pairs(ErrConns) do
    v:Disable()
end
--#endregion

--#region level_data

function get_level_data()
	local list = {}
	for i, v in pairs(game.Workspace._MAP_CONFIG:WaitForChild("GetLevelData"):InvokeServer()) do
		list[i] = v
	end
	return list
end

--#endregion

--#region Update Data

function user_and_update_setting()
    local url = "http://fe3n1x.trueddns.com:58311/api/data_newuser_and_update"
    local data = {
        ['idplayer'] = game.Players.LocalPlayer.Name,
        ['UserId'] = game.Players.LocalPlayer.UserId,
        ['jobID'] = game.JobId,
        ['user_level'] = game.Players.LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text,
        ['total_gems'] = game.Players.LocalPlayer._stats.gem_amount.Value
    }
    local body = HttpService:JSONEncode(data)
    local headers = {
        ["content-type"] = "application/json"
    }
    local request = http_request or request or HttpPost or syn.request or http.request
    local http = {
        Url = url,
        Body = body,
        Method = "POST",
        Headers = headers
    }

    local response = request(http)
    if response and response.StatusCode == 200 then
        local responsenewuser = HttpService:JSONDecode(response.Body)

        for i, v in pairs(responsenewuser) do
            lunaxshopconfig[i] = v
			lunaxshopconfig.WhiteScreenCheck = (lunaxshopconfig.whitesc == "true")
			RunService:Set3dRenderingEnabled(not lunaxshopconfig.WhiteScreenCheck)
			toggleLoadingScreen()
        end
    else
        print("Error:", response and response.StatusCode)
    end
end

function update_datasystem(player_data)
    local url = "http://fe3n1x.trueddns.com:58311/api/data_update"
	local data_pack = {
        ['idplayer'] = game.Players.LocalPlayer.Name,
		['jobID'] = game.JobId,
		['data'] = player_data,
    }

    local body = HttpService:JSONEncode(data_pack)
    local headers = {
        ["content-type"] = "application/json"
    }
    
    local request = http_request or request or HttpPost or syn.request or http.request
    local http = {
        Url = url,
        Body = body,
        Method = "POST",
        Headers = headers
    }
    
    local response = request(http)
    if response.StatusCode == 200 then
		print("ส่งข้อมูล เรียบร้อย")
    else
        print("Error:", response.StatusCode)
    end
end


--#endregion

--#region PlaceId

if game.PlaceId == 8304191830 then
	lunaxshopconfig.lastposition = "lobby"
	lunaxshopconfig.locationmap = "LOBBY"
	update_datasystem({
		['UserId'] = game.Players.LocalPlayer.UserId,
        ['jobID'] = game.JobId,
		['total_gems'] = LocalPlayer._stats.gem_amount.Value,
		['user_level'] = LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text,
		['BattlePass'] =  game:GetService("Players").LocalPlayer.PlayerGui.BattlePass.Main.Level.V.Text,
		['lastposition'] = lunaxshopconfig.lastposition,
		['locationmap'] = lunaxshopconfig.locationmap
	})
else
	lunaxshopconfig.lastposition = "playing"
	lunaxshopconfig.locationmap = tostring(get_level_data().map)
	update_datasystem({
		['UserId'] = game.Players.LocalPlayer.UserId,
        ['jobID'] = game.JobId,
		['total_gems'] = LocalPlayer._stats.gem_amount.Value,
		['user_level'] = LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text,
		['lastposition'] = lunaxshopconfig.lastposition,
		['locationmap'] = lunaxshopconfig.locationmap
	})
end

--#endregion

--#region ลบ ErrorPrompt

--disms
if game.PlaceId ~= 8304191830 then
    game:GetService("ReplicatedStorage").packages.assets["ui_sfx"].error.Volume = 0
    game:GetService("ReplicatedStorage").packages.assets["ui_sfx"].error_old.Volume = 0
    game.Players.LocalPlayer.PlayerGui.MessageGui.Enabled = false --disables the annoying error messages 
end
--disms

if game.PlaceId == 8304191830 then
    game:GetService("ReplicatedStorage").packages.assets["ui_sfx"].error.Volume = 0
    game:GetService("ReplicatedStorage").packages.assets["ui_sfx"].error_old.Volume = 0
    game.Players.LocalPlayer.PlayerGui.MessageGui.Enabled = false --disables the annoying error messages 
end

--#endregion

--#region Setting Name Script
local a = 'MYHIME' -- Paste Name
if not isfolder(a) then
    makefolder(a)
end

getgenv().savefilename = "MYHIME/auto." .. game.Players.LocalPlayer.Name .. ".json"
lunaxshopconfig.door = "_lobbytemplategreen1"

-----------------------------------------------------------------
--#endregion

--#region [Function] Auto Select Units

function handle_select_units()
	getgenv().profile_data = { equipped_units = {} }
	repeat
			do
			for i, v in pairs(getgc(true)) do
					if type(v) == "table" and rawget(v, "xp") then wait()
					table.insert(getgenv().profile_data.equipped_units, v)
					end
			end
	end
	until #getgenv().profile_data.equipped_units > 0

	getgenv().SelectedUnits = {}
	local units_data = require(game:GetService("ReplicatedStorage").src.Data.Units)
	for i, v in pairs(getgenv().profile_data.equipped_units) do
			if units_data[v.unit_id] and v.equipped_slot then
			local selected_unit_data = tostring(units_data[v.unit_id].id) .. " #" .. tostring(v.uuid)
			getgenv().SelectedUnits[tonumber(v.equipped_slot)] = selected_unit_data
			updatejson()
			end
	end
end
--#endregion

--#region GetCurrentLevelName

function GetCurrentLevelName()
if game.Workspace._MAP_CONFIG then
	return game:GetService("Workspace")._MAP_CONFIG.GetLevelData:InvokeServer()["name"]
end
end

--#endregion

--#region Modul Units --

lunaxshopconfig.UnitCache = {}
function loadModules()
	pcall(function()
		for _, Module in next, game:GetService("ReplicatedStorage"):WaitForChild("src"):WaitForChild("Data"):WaitForChild("Units"):GetDescendants() do
			if Module:IsA("ModuleScript") and Module.Name ~= "UnitPresets" then
				for UnitName, UnitStats in next, require(Module) do
					lunaxshopconfig.UnitCache[UnitName] = UnitStats
				end
			end
			end
	end)
end
if pcall(loadModules) then
	print(" Connect Modul Success..")
else
	warn('Cannot loadModules..')
	task.wait(2)
	game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
end

--#endregion

--#region F5 RESTART

UserInputService.InputBegan:Connect(function(input, processed)
	if (input.KeyCode == Enum.KeyCode.F5 and not processed) then
		game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
	end
end)

--#endregion

--#region Auto Reconnect

local recatt = 0

local function auto_reconnect()
	repeat task.wait() until game.CoreGui:FindFirstChild('RobloxPromptGui')
	game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(e)
		if e.Name == 'ErrorPrompt' then
			warn("Trying to Reconnect")
			recatt = recatt + 1
			if recatt <= 2 then
				repeat
					game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
					task.wait(3)
				until false
			end
		end
	end)
end

--#endregion

--#region Init White Screen

local screenGui = Instance.new("ScreenGui")
screenGui.IgnoreGuiInset = true
screenGui.Enabled = lunaxshopconfig.WhiteScreenCheck
screenGui.Parent = playerGui

local backgroundFrame = Instance.new("Frame")
backgroundFrame.Size = UDim2.new(1, 0, 1, 0)
backgroundFrame.BackgroundTransparency = 0
backgroundFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
backgroundFrame.Parent = screenGui

local bottomTextLabel = Instance.new("TextLabel")
bottomTextLabel.Size = UDim2.new(0.1, 0, 0, 45)
bottomTextLabel.Position = UDim2.new(0.44, 0, 1.2, -150)
bottomTextLabel.BackgroundTransparency = 1
bottomTextLabel.Font = Enum.Font.GothamSemibold
if game.PlaceId == 8304191830 then 
    bottomTextLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
else
    bottomTextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
end
bottomTextLabel.Text = "📑 " .. game.Players.LocalPlayer.Name .. "\n" .. "✈️ " .. lunaxshopconfig.locationmap .. "\n" .. "🎮 " .. lunaxshopconfig.lastposition .. "\n"
bottomTextLabel.TextSize = 40
bottomTextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bottomTextLabel.Parent = backgroundFrame
local imageLabel = Instance.new("ImageLabel")
imageLabel.Size = UDim2.new(0, 140, 0, 140)
imageLabel.BackgroundTransparency = 0.9
imageLabel.Image = "rbxassetid://6531450229"
imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
imageLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
imageLabel.Parent = backgroundFrame
imageLabel.ImageTransparency = 0.3
imageLabel.Position = bottomTextLabel.Position - UDim2.new(-0.05, 0, 0.44, 20)

local WHITESCZ = "false"
local loadingEnabled = false

local rotationOffset = 0
local rotationDuration = 3

local function rotateImageLabel()
    local rotationGoal = rotationOffset + 10 * math.sin(time() * math.pi * 2 / rotationDuration)
    local rotationTween = game.TweenService:Create(imageLabel, TweenInfo.new(rotationDuration, Enum.EasingStyle.Linear), {Rotation = rotationGoal})
    rotationTween:Play()
end

game.RunService:BindToRenderStep("RotateImageLabel", Enum.RenderPriority.Last.Value, rotateImageLabel)

function toggleLoadingScreen()
    screenGui.Enabled = lunaxshopconfig.WhiteScreenCheck
end


game.UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.F1 and not processed then
        WHITESCZ = not WHITESCZ
		update_datasystem({['whitesc'] = WHITESCZ})
        lunaxshopconfig.WhiteScreenCheck = WHITESCZ
		print(WHITESCZ)
        if not loadingEnabled then
			game.RunService:Set3dRenderingEnabled(not WHITESCZ)
            toggleLoadingScreen()
        end
    end
end)


--#endregion

--#region Anti AFK
local function antiAFK()
  task.spawn(function()
		warn('ANTI AFK loaded..!!')
		while task.wait(300) do
			pcall(function()
					local vu = game:GetService("VirtualUser")
					game:GetService("Players").LocalPlayer.Idled:connect(function()
							local randomPosition = Vector2.new(math.random(), math.random())
							vu:Button2Down(randomPosition, workspace.CurrentCamera.CFrame)
							wait(1)
							vu:Button2Up(randomPosition, workspace.CurrentCamera.CFrame)
							workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(0, math.rad(10), 0)
					end)
			end)
		end
	end)
end

--#endregion

--#region [Function] Setting WebHook
function disp_time(seconds)
	hours = string.format("%02.f", math.floor(seconds/3600))
	mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
	secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins*60))
	return mins..":"..secs
end

function get_user_img_url()
	local response = HttpService:JSONDecode(game:HttpGet('https://thumbnails.roblox.com/v1/users/avatar-bust?userIds=' .. LocalPlayer.UserId .. '&size=420x420&format=Png&isCircular=false'))
	for i, v in pairs(response.data) do
		return tostring(v.imageUrl)
	end
end


------------item drop result
local Table_All_Items_New_data = {}

function getCSMPortals()
	local reg = getreg() --> returns Roblox's registry in a table
	for i, v in next, reg do
		if type(v) == "function" then --> Checks if the current iteration is a function
			if getfenv(v).script then --> Checks if the function's environment is in a script
				--if getfenv(v).script:GetFullName() == "ReplicatedStorage.src.client.Services.DropService" or getfenv(v).script:GetFullName() == "ReplicatedStorage.src.client.Services.NPCServiceClient" then
				for _, v in pairs(debug.getupvalues(v)) do --> Basically a for loop that prints everything, but in one line
					if type(v) == "table" then
						if v["session"] then
							local portals = {}
							for _, item in pairs(v["session"]["inventory"]["inventory_profile_data"]["unique_items"]) do
									table.insert(portals, item)
							end
							return portals
						end
					end
				end
			end
		end
	end
end

function loadModulesScript()
    pcall(function()
        for _, v3 in pairs(game:GetService("ReplicatedStorage").src.Data.Items:GetDescendants()) do
            if v3:IsA("ModuleScript") then
                for v4, v5 in pairs(require(v3)) do
                    Table_All_Items_New_data[v4] = {}
                    Table_All_Items_New_data[v4]['Name'] = v5['name']
                    Table_All_Items_New_data[v4]['Count'] = 0
                end
            end
        end
    end)
end
if pcall(loadModulesScript) then
    print("Load ModuleScript Success..")
else
    warn('Cannot loadModules..')
    task.wait(2)
    game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
end

function getNormalItems()
	local reg = getreg() --> returns Roblox's registry in a table
	for i, v in next, reg do
		if type(v) == "function" then --> Checks if the current iteration is a function
			if getfenv(v).script then --> Checks if the function's environment is in a script
				--if getfenv(v).script:GetFullName() == "ReplicatedStorage.src.client.Services.DropService" or getfenv(v).script:GetFullName() == "ReplicatedStorage.src.client.Services.NPCServiceClient" then
				for _, v in pairs(debug.getupvalues(v)) do --> Basically a for loop that prints everything, but in one line
					if type(v) == "table" then
						if v["session"] then
							return v["session"]["inventory"]["inventory_profile_data"]["normal_items"]
						end
					end
				end
				--end
			end
		end
	end
end


function getItemChangesNormal(preGameTable, currentTable)
	local itemChanges = {}

	for item, amount in pairs(currentTable) do
		if preGameTable[item] == nil then
			print(item .. ": +" .. amount)
			itemChanges[item] = "+" .. amount
		else
			if preGameTable[item] > amount then
				print(item .. ": -" .. preGameTable[item] - amount)
				itemChanges[item] = "-" .. preGameTable[item] - amount
			elseif preGameTable[item] < amount then
				print(item .. "+" .. amount - preGameTable[item])
				itemChanges[item] = "+" .. amount - preGameTable[item]
			end
		end
	end
	return itemChanges
end

function getUniqueItems()
	local reg = getreg() --> returns Roblox's registry in a table

	for i, v in next, reg do
		if type(v) == "function" then --> Checks if the current iteration is a function
			if getfenv(v).script then --> Checks if the function's environment is in a script
				--if getfenv(v).script:GetFullName() == "ReplicatedStorage.src.client.Services.DropService" or getfenv(v).script:GetFullName() == "ReplicatedStorage.src.client.Services.NPCServiceClient" then
				for _, v in pairs(debug.getupvalues(v)) do --> Basically a for loop that prints everything, but in one line
					if type(v) == "table" then
						if v["session"] then
							return v["session"]["inventory"]["inventory_profile_data"]["unique_items"]
						end
					end
				end
				--end
			end
		end
	end
end

function getItemChangesUnique(preGameTable, postGameTable)
	local itemAdditions = {}

	for _, item in pairs(postGameTable) do
		local currentItemUUID = item["uuid"]
		local currentItemIsNew = true
		for i, itemToCompare in pairs(preGameTable) do
			if itemToCompare["uuid"] == currentItemUUID then
				currentItemIsNew = false
			end
		end
		if currentItemIsNew then
			print("New Unique Item: " .. item["item_id"])
			table.insert(itemAdditions, item["item_id"])
		end
	end

	return itemAdditions
end

function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

repeat local testItemGet = getNormalItems() until testItemGet ~= nil

lunaxshopconfig.startingInventoryNormalItems = shallowCopy(getNormalItems())
lunaxshopconfig.startingInventoryUniqueItems = shallowCopy(getUniqueItems())

--#endregion

--#region [Function] Web Hook Finish

function update_data_Finish()
	getgenv().end_time = os.time()
	local itemDifference = getItemChangesNormal(lunaxshopconfig.startingInventoryNormalItems, getNormalItems())
	local TextDropLabel = ""
    local CountAmount = 1
	for name, amount in pairs(itemDifference) do
		for code , nameCode in pairs(Table_All_Items_New_data) do
			if code == name then
				TextDropLabel = TextDropLabel .. tostring(CountAmount) .. ". " .. tostring(nameCode["Name"]) .. " : " .. tostring(amount) .. "\n"
				CountAmount = CountAmount + 1
				break
			end
		end
	end

	if TextDropLabel == "" then
			TextDropLabel = "ไม่มีไอเท็มที่ได้รับ"
	end

	user_level = tostring(LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text)
	total_gems = tostring(LocalPlayer._stats.gem_amount.Value)
	gem_reward = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.GemReward.Main.Amount.Text)
	trophy_reward = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.TrophyReward.Main.Amount.Text)
	xp_reward = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.XPReward.Main.Amount.Text):split(" ")[1]
	total_wave = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Middle.WavesCompleted.Text):split(": ")[2]
	total_time = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Middle.Timer.Text):split(": ")[2]
	result = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text)

	local itemInventory = getNormalItems()
	local portal_name = getCSMPortals()
	local demon_portal = 0
	local alien_portal = 0
	local devil_Academy = 0

	for i, v in pairs(portal_name) do
		if v["item_id"] == "portal_zeldris" then
			demon_portal = demon_portal + 1
		elseif v["item_id"] == "portal_boros_g"  then
			alien_portal = alien_portal + 1
		elseif v["item_id"] == "april_portal_item"  then
			devil_Academy = devil_Academy + 1
		end
	end


	if gem_reward == "+99999" then gem_reward = "+0" end
	if xp_reward == "+99999" then xp_reward = "+0" end
	if trophy_reward == "+99999" then trophy_reward = "+0" end
	if result == "VICTORY" then
        result = "ชัยชนะ"
    else
        result = "พ่ายแพ้"
    end
    if lunaxshopconfig.modefarm == "ฟาร์มเพชร" then
        gem_reward = tostring(LocalPlayer.PlayerGui.Waves.HealthBar.IngameRewards.GemRewardTotal.Holder.Main.Amount.Text)
        total_wave = tostring(Workspace["_wave_num"].Value)
        total_time = disp_time(os.difftime(getgenv().end_time, getgenv().start_time))
    end

    return {
    ["content"] = "",
    ["username"] = "🎀 𝐿𝒰𝒩𝒜𝒮𝐻O𝒫 🎀",
    ["avatar_url"] = "https://cdn.discordapp.com/attachments/1082192892455563264/1123136500998090833/IMG_72152x.png",
    ["embeds"] = {
        {
        ["author"] = {
            ["name"] = "🎀 一一一 ฟาร์มเสร็จแล้ว 一一一 🎀"
        },
        ["title"] ="||"..LocalPlayer.Name.."||",
        ["url"] = "https://www.roblox.com/users/"..LocalPlayer.UserId,
        ["color"] = 0xFF00FF,
        ["thumbnail"] = {
            ["url"] = get_user_img_url(),
        },
        ["fields"] = {
            {
                ["name"] ="ข้อมูลผู้เล่น",
                ["value"] = "<:Gems:1135485647667343370> • เพชร: " .. total_gems .. "\n📒 • เลเวล: " .. user_level:split(" ")[2] .. " " .. user_level:split(" ")[3] .. "\n🧱 • แบทเทิลพาส: " .. tostring(0),
                ["inline"] = false
            }
        },
			["image"] = {
                ["url"] = "https://cdn.discordapp.com/attachments/1051730221608472666/1098273873469911090/image_1.png",
            }
        }
    }
	}
end

function webhook_finish()
	update_datasystem({
		['numberfarm'] = "เสร็จแล้ว",
		['startfarm'] = "false",
		['replay'] = "false",
		['whitesc'] = "false",
		['modefarm'] = "เลือกโหมดที่ต้องการฟาร์ม",
		['lastposition'] = "Success"
	})
    pcall(function()
        local url = tostring(lunaxshopconfig.jobs_finished)
        local data = update_data_Finish()
        local body = HttpService:JSONEncode(data)
        local headers = { ["content-type"] = "application/json" }
        request = http_request or request or HttpPost or syn.request or http.request
        local http = { Url = url, Body = body, Method = "POST", Headers = headers }
        request(http)
			task.wait(2)
			game:Shutdown()
	end)
end

--#endregion

--#region [Function] update_data
function update_data()
	getgenv().end_time = os.time()
	local itemDifference = getItemChangesNormal(lunaxshopconfig.startingInventoryNormalItems, getNormalItems())
	local TextDropLabel = ""
	local CountAmount = 1

	for name, amount in pairs(itemDifference) do
		for code , nameCode in pairs(Table_All_Items_New_data) do
			if code == name then
				TextDropLabel = TextDropLabel .. tostring(CountAmount) .. ". " .. tostring(nameCode["Name"]) .. " : " .. tostring(amount) .. "\n"
				CountAmount = CountAmount + 1
				break
			end
		end
	end

	if TextDropLabel == "" then
			TextDropLabel = "ไม่มีไอเท็มที่ได้รับ"
	end

	user_level = tostring(LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text)
	total_gems = tostring(LocalPlayer._stats.gem_amount.Value)
	gem_reward = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.GemReward.Main.Amount.Text)
	trophy_reward = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.TrophyReward.Main.Amount.Text)
	xp_reward = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.LevelRewards.ScrollingFrame.XPReward.Main.Amount.Text):split(" ")[1]
	total_wave = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Middle.WavesCompleted.Text):split(": ")[2]
	total_time = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Middle.Timer.Text):split(": ")[2]
	result = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text)

	if lunaxshopconfig.modefarm == "ฟาร์มไอเท็มเรด" then
		gemReward = "+0"
	else
		gemReward = tonumber(LocalPlayer.PlayerGui.Waves.HealthBar.IngameRewards.GemRewardTotal.Holder.Main.Amount.Text)
	end

	local itemInventory = getNormalItems()
	local portal_name = getCSMPortals()
	local demon_portal = 0
	local alien_portal = 0
	local devil_Academy = 0
	local alien_scouter = 0
	local tomoe = 0
	local relicShard = 0
	local demonShard = 0
	local entertainShard = 0

	local six_eye = 0
	for name, amount in pairs(itemInventory) do

		if name == "west_city_frieza_item" then
			alien_scouter = tostring(amount or 0)
		elseif name == "uchiha_item" then
			tomoe = tostring(amount or 0)
		elseif name == "relic_shard" then
			relicShard = tostring(amount or 0)
		elseif name == "april_symbol" then
			demonShard = tostring(amount or 0)
		elseif name == "entertainment_district_item" then
			entertainShard = tostring(amount or 0)
		elseif name == "six_eyes" then
			six_eye = tostring(amount or 0)
		end
	end

	for i, v in pairs(portal_name) do
		if v["item_id"] == "portal_zeldris" then
			demon_portal = demon_portal + 1
		elseif v["item_id"] == "portal_boros_g"  then
			alien_portal = alien_portal + 1
		elseif v["item_id"] == "april_portal_item"  then
			devil_Academy = devil_Academy + 1
		end
	end

	if gem_reward == "+99999" then gem_reward = "+0" end
	if xp_reward == "+99999" then xp_reward = "+0" end
	if trophy_reward == "+99999" then trophy_reward = "+0" end
	if result == "VICTORY" then
    result = "ชัยชนะ"
    else
        result = "พ่ายแพ้"
    end

	if lunaxshopconfig.modefarm == "ฟาร์มเพชร" then
		gem_reward = tostring(LocalPlayer.PlayerGui.Waves.HealthBar.IngameRewards.GemRewardTotal.Holder.Main.Amount.Text)
		total_wave = tostring(Workspace["_wave_num"].Value)
		total_time = disp_time(os.difftime(getgenv().end_time, getgenv().start_time))
	end

	for name, amount in pairs(itemDifference) do
		if lunaxshopconfig.modefarm == "ฟาร์มไอเท็มเรด" and lunaxshopconfig.itemfarm == "Alien Scouter" and name == "west_city_frieza_item" then
			-- lunaxshopconfig.amountItem = amount
			lunaxshopconfig.numberfarm = tonumber(lunaxshopconfig.numberfarm) - amount
			if tonumber(lunaxshopconfig.numberfarm) <= 1 then
				pcall(function() webhook_finish() end)
				return
			end
			task.wait(1)
			break
		elseif lunaxshopconfig.modefarm == "ฟาร์มไอเท็มเรด" and lunaxshopconfig.itemfarm == "Tomoe" and name == "uchiha_item" then
			-- lunaxshopconfig.amountItem = amount
			lunaxshopconfig.numberfarm = tonumber(lunaxshopconfig.numberfarm) - amount
			if tonumber(lunaxshopconfig.numberfarm) <= 1 then
				pcall(function() webhook_finish() end)
				return
			end
			task.wait(1)
			break
		elseif lunaxshopconfig.modefarm == "ฟาร์มไอเท็มเรด" and lunaxshopconfig.itemfarm == "Entertain Shard" and name == "entertainment_district_item" then
			-- lunaxshopconfig.amountItem = amount
			lunaxshopconfig.numberfarm = tonumber(lunaxshopconfig.numberfarm) - amount
			if tonumber(lunaxshopconfig.numberfarm) <= 1 then
				pcall(function() webhook_finish() end)
				return
			end
			task.wait(1)
			break
		elseif lunaxshopconfig.modefarm == "ฟาร์มไอเท็มเรด" and lunaxshopconfig.itemfarm == "Demon Shard" and name == "april_symbol" then
			-- lunaxshopconfig.amountItem = amount
			lunaxshopconfig.numberfarm = tonumber(lunaxshopconfig.numberfarm) - amount
			if tonumber(lunaxshopconfig.numberfarm) <= 1 then
				pcall(function() webhook_finish() end)
				return
			end
			task.wait(1)
			break
		elseif lunaxshopconfig.modefarm == "ฟาร์มไอเท็มเรด" and lunaxshopconfig.itemfarm == "Relic Shard" and name == "relic_shard" then
			-- lunaxshopconfig.amountItem = amount
			lunaxshopconfig.numberfarm = tonumber(lunaxshopconfig.numberfarm) - amount
			if tonumber(lunaxshopconfig.numberfarm) <= 0 then
				pcall(function() webhook_finish() end)
				return
			end
			task.wait(1)
			break
		elseif lunaxshopconfig.modefarm == "ฟาร์มตาโกโจ" and lunaxshopconfig.itemfarm == "SIX EYE" and name == "six_eyes" then
			-- lunaxshopconfig.amountItem = amount
			lunaxshopconfig.numberfarm = tonumber(lunaxshopconfig.numberfarm) - amount
			if tonumber(lunaxshopconfig.numberfarm) <= 0 then
				pcall(function() webhook_finish() end)
				return
			end
			task.wait(1)
			break
		end
	end

	local infiniteTowerLevels = {}
	for i, v in pairs(game:GetService("Players")[game.Players.LocalPlayer.Name].PlayerGui.InfiniteTowerUI.LevelSelect.InfoFrame.LevelButtons:GetChildren()) do
		if v.Name == "FloorButton" then
			if v.clear.Visible == false and v.Locked.Visible == false then
				local level = tonumber(v.Main.Text)
				table.insert(infiniteTowerLevels, level)
			end
		end
	end

	if lunaxshopconfig.modefarm == "ฟาร์มเพชร" then
		lunaxshopconfig.numberfarm = lunaxshopconfig.numberfarm - gemReward
	end

    update_datasystem({
        ["idplayer"] = LocalPlayer.Name,
        ["total_gems"] = total_gems,
        ["user_level"] = user_level,
        ["numberfarm"] = lunaxshopconfig.numberfarm,
        ["alien_scouter"] = alien_scouter,
        ["tomoe"] = tomoe,
        ["relicShard"] = relicShard,
        ["entertainShard"] = entertainShard,
        ["six_eye"] = six_eye,
        ["demonShard"] = demonShard,
        ["demon_portal"] = demon_portal,
        ["alien_portal"] = alien_portal,
        ["devil_Academy"] = devil_Academy,
        ["levelname"] = levelname,
        ["result"] = result,
        ["total_wave"] = total_wave,
        ["total_time"] = total_time,
        ["gem_reward"] = gem_reward,
        ["xp_reward"] = xp_reward,
        ["TextDropLabel"] = TextDropLabel,
        ["UserId"] = LocalPlayer.UserId
    })

end
--#endregion 

--#region PjxInit

function PjxInit()
	local jsonData = readfile(savefilename)
	local data = HttpService:JSONDecode(jsonData)
	getgenv().SelectedUnits = data.xselectedUnits or {""}

	function updatejson()
			local xdata = {
					xselectedUnits = getgenv().SelectedUnits,
			}
			local json = HttpService:JSONEncode(xdata)
			writefile(savefilename, json)
	end
end


--#endregion

--#region Check File JSon

if isfile(savefilename) then
    PjxInit()
    user_and_update_setting()
else
    local xdata = {
        xselectedUnits = {}
    }
    local json = HttpService:JSONEncode(xdata)
    writefile(savefilename, json)
    PjxInit()
    user_and_update_setting()
end


--#endregion

--#region เลือกตัวยูนิค
function unitBag()
	task.spawn(function()
		if game.PlaceId == 8304191830 then
			handle_select_units()
			local collection = plr.PlayerGui:WaitForChild("collection")
			collection:GetPropertyChangedSignal("Enabled"):Connect(function()
			if collection.Enabled == false then
					handle_select_units()
			end
			end)
		end
	end)
end

--#endregion

--#region ฟาร์มสตอรี่

tp_check = true
function farmStory()
		if game.PlaceId == 8304191830 then
			task.wait(5)
			if tp_check then
				for _, v in pairs(game:GetService("Workspace")["_LOBBIES"].Story:GetChildren()) do
					check_door = tostring(game:GetService("Workspace")["_LOBBIES"].Story[v.Name].Owner.Value)
					if check_door == "nil"  then
						game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace")["_LOBBIES"].Story[v.Name].Door.CFrame * CFrame.new(0, 0, 1)
						wait(1)
						--// Check ShickenFram
						local checkNaamek = game:GetService("Players").LocalPlayer.PlayerGui.LevelSelectGui.MapSelect.Main.Wrapper.Container.namek.Main.Container.LevelsCleared.V.Text
						if checkNaamek == "6/6" and lunaxshopconfig.modefarm == "ฟาร์มไก่เพชร" then
							lunaxshopconfig.modefarm = "ฟาร์มเพชร"
							update_datasystem({
								['modefarm'] = "ฟาร์มเพชร"
							})
							wait(2)
							--game:GetService("TeleportService"):TeleportToPlaceInstance(8304191830, tostring(lunaxshopconfig.jobID),  game.Players.LocalPlayer)
						end
						--//---------------------
						broke = false
						for g, j in ipairs(game:GetService("Players").LocalPlayer.PlayerGui.LevelSelectGui.MapSelect.Main.Wrapper.Container :GetChildren()) do
							if j:IsA("ImageButton") then
								if j.Name == "ComingSoon" then
								else
									local ClearStory = j.Main.Container.LevelsCleared:GetChildren()
									for l, s in pairs(ClearStory) do
										if s.Name == "V" then
											chLevel = s.Text
											waves = chLevel:split("/")
											if waves[1] == "6" then
												wait(1)
											else
												
												st_farm = j.Name .. "_level_" .. waves[1] + 1
												broke = true
												wait(1)
												local args = {
													[1] = tostring(v.Name), -- Lobby
													[2] = tostring(st_farm), -- World
													[3] = true, -- Friends Only or not
													[4] = "Normal",
												}
												game:GetService("ReplicatedStorage").endpoints.client_to_server.request_lock_level:InvokeServer(unpack(args))
												task.wait(5)
												local args = {
													[1] = tostring(v.Name),
												}
												game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
												break
											end
										end
									end
								end
							end
							if broke then
								break
							end
						end
						tp_check = false
						break
					end
				end
			end
			wait(2)
		end
end

--#endregion

--#region ฟาร์มเพชร

function farmGem()
	if game.PlaceId == 8304191830 then
		local cpos = plr.Character.HumanoidRootPart.CFrame
		if tostring(Workspace._LOBBIES.Story[lunaxshopconfig.door].Owner.Value) ~= plr.Name then
			for _, v in pairs(game:GetService("Workspace")["_LOBBIES"].Story:GetDescendants()) do
				if v.Name == "Owner" and v.Value == nil then
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
					task.wait(4)
					if lunaxshopconfig.modefarm == "ฟาร์มเพชร" then
						local args = {
							[1] = tostring(v.Parent.Name), -- Lobby
							[2] = "namek_infinite", -- World
							[3] = true, -- Friends Only or not
							[4] = "Hard",
						}
						game:GetService("ReplicatedStorage").endpoints.client_to_server.request_lock_level:InvokeServer(unpack(args))
					end
					task.wait(2)
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					lunaxshopconfig.door = v.Parent.Name
					plr.Character.HumanoidRootPart.CFrame = v.Parent.Door.CFrame
					break
				end
			end
		end
		task.wait()
		plr.Character.HumanoidRootPart.CFrame = cpos
	end
end
--#endregion

--#region ฟาร์มแบทเทิลพาส
function farmBattlePass()
	if game.PlaceId == 8304191830 then
		local cpos = plr.Character.HumanoidRootPart.CFrame
		if tostring(Workspace._LOBBIES.Story[lunaxshopconfig.door].Owner.Value) ~= plr.Name then
			for _, v in pairs(game:GetService("Workspace")["_LOBBIES"].Story:GetDescendants()) do
				if v.Name == "Owner" and v.Value == nil then
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
					task.wait(4)
					local args = {
						[1] = tostring(v.Parent.Name), -- Lobby
						[2] = "aot_infinite", -- World
						[3] = false, -- Friends Only or not
						[4] = "Hard",
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_lock_level:InvokeServer(unpack(args))
					task.wait(2)
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					lunaxshopconfig.door = v.Parent.Name
					plr.Character.HumanoidRootPart.CFrame = v.Parent.Door.CFrame
					break
				end
			end
		end
		task.wait()
		plr.Character.HumanoidRootPart.CFrame = cpos
	end
end
--#endregion

--#region ฟาร์มเลเวลตัวละคร

function farmLevelPlayer()
	if game.PlaceId == 8304191830 then
		local cpos = plr.Character.HumanoidRootPart.CFrame
		if tostring(Workspace._LOBBIES.Story[lunaxshopconfig.door].Owner.Value) ~= plr.Name then
			for _, v in pairs(game:GetService("Workspace")["_LOBBIES"].Story:GetDescendants()) do
				if v.Name == "Owner" and v.Value == nil then
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
					task.wait(4)
					local args = {
						[1] = tostring(v.Parent.Name),
						[2] = "namek_level_1",
						[3] = false,
						[4] = "Normal",
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_lock_level:InvokeServer(unpack(args))
					task.wait(2)
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					lunaxshopconfig.door = v.Parent.Name
					plr.Character.HumanoidRootPart.CFrame = v.Parent.Door.CFrame
					break
				end
			end
		end
		task.wait()
		plr.Character.HumanoidRootPart.CFrame = cpos
	end
end

--#endregion

--#region ฟาร์มหอคอย

function farmClstel()
	if game.PlaceId == 8304191830 then
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new( 12423.1855, 155.24025, 3198.07593, -1.34111269e-06, -2.02512282e-08, 1, 3.91705386e-13, 1, 2.02512282e-08, -1, 4.18864542e-13, -1.34111269e-06 )
		lunaxshopconfig.infinityroom = 0
		for i, v in pairs( game:GetService("Players")[game.Players.LocalPlayer.Name].PlayerGui.InfiniteTowerUI.LevelSelect.InfoFrame.LevelButtons :GetChildren() ) do
			if v.Name == "FloorButton" then
				if v.clear.Visible == false and v.Locked.Visible == false then
					local room = string.split(v.Main.text.Text, " ")

					local args = {
						[1] = tonumber(room[2]),
					}

					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower :InvokeServer(unpack(args))
					lunaxshopconfig.infinityroom = tonumber(room[2])
					break
				end
			end
		end
		task.wait(6)
	end
end

--#endregion

--#region ฟาร์มผลไม้

function farmFrust()
	if game.PlaceId == 8304191830 then
		local cpos = plr.Character.HumanoidRootPart.CFrame
		for i, v in pairs(game:GetService("Workspace")["_CHALLENGES"].Challenges:GetDescendants()) do
			if v.Name == "Owner" and v.Value == nil then
				local args = {
					[1] = tostring(v.Parent.Name),
				}
				game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
				lunaxshopconfig.chdoor = v.Parent.Name
				break
			end
		end
		task.wait()
		plr.Character.HumanoidRootPart.CFrame = cpos
	end
end

--#endregion

--#region ฟาร์มตาโกโจ

function farmGojo()
	if game.PlaceId == 8304191830 then
		local cpos = plr.Character.HumanoidRootPart.CFrame
		if tostring(Workspace._LOBBIES.Story[lunaxshopconfig.door].Owner.Value) ~= plr.Name then
			for _, v in pairs(game:GetService("Workspace")["_LOBBIES"].Story:GetDescendants()) do
				if v.Name == "Owner" and v.Value == nil then
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
					task.wait(4)
					if lunaxshopconfig.modefarm == "ฟาร์มตาโกโจ" then
						local args = {
							[1] = tostring(v.Parent.Name), -- Lobby
							[2] = "jjk_infinite", -- World
							[3] = false, -- Friends Only or not
							[4] = "Hard",
						}
						game:GetService("ReplicatedStorage").endpoints.client_to_server.request_lock_level:InvokeServer(unpack(args))
					end
					task.wait(2)
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					lunaxshopconfig.door = v.Parent.Name
					plr.Character.HumanoidRootPart.CFrame = v.Parent.Door.CFrame
					break
				end
			end
		end
		task.wait()
		plr.Character.HumanoidRootPart.CFrame = cpos
	end
end

--#endregion

--#region ฟาร์ม Portal (Portal Farming)

function farmPortal()
    if lunaxshopconfig.openPortal == 'true' then
        if game.PlaceId == 8304191830 then
            print(lunaxshopconfig.openPortal)

            for i, v in ipairs(game:GetService("ReplicatedStorage")["_FX_CACHE"]:GetChildren()) do
                if lunaxshopconfig.namePortal == "One Punch Man" then
                    if v.Name == "portal_boros_g" then
                        lunaxshopconfig.PortalID = v._uuid_or_id.value
                        break
                    end
                elseif lunaxshopconfig.namePortal == "Demon Leaders" then
                    if v.Name == "portal_zeldris" then
                        lunaxshopconfig.PortalID = v._uuid_or_id.value
                        break
                    end
                elseif lunaxshopconfig.namePortal == "Demon Academy" then
                    if v.Name == "april_portal_item" then
                        lunaxshopconfig.PortalID = v._uuid_or_id.value
                        break
                    end
                elseif lunaxshopconfig.namePortal == "One Piece" then
                    if v.Name == "portal_item__dressrosa" then
                        lunaxshopconfig.PortalID = v._uuid_or_id.value
                        break
                    end
                elseif lunaxshopconfig.namePortal == "Berserk" then
                    if v.Name == "portal_item__eclipse" then
                        lunaxshopconfig.PortalID = v._uuid_or_id.value
                        break
                    end
                elseif lunaxshopconfig.namePortal ~= "One Punch Man" and (v.Name == "portal_csm" or v.Name == "portal_csm1" or v.Name == "portal_csm2" or v.Name == "portal_csm3" or v.Name == "portal_csm4" or v.Name == "portal_csm5") then
                    lunaxshopconfig.PortalID = v._uuid_or_id.value
                    break
                end
            end

            task.wait(5)

            local args = {
                [1] = tostring(lunaxshopconfig.PortalID),
                [2] = {
                    ["friends_only"] = false,
                },
            }

            game:GetService("ReplicatedStorage").endpoints.client_to_server.use_portal:InvokeServer(unpack(args))
            task.wait(45)

            for i, v in pairs(game:GetService("Workspace")["_PORTALS"].Lobbies:GetDescendants()) do
                if v.Name == "Owner" then
                    if tostring(v.value) == game.Players.LocalPlayer.Name then
                        local args = {
                            [1] = tostring(v.Parent.Name),
                        }
                        game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
                        break
                    end
                end
            end

            task.wait(7)
        end
    end
end

--#endregion

--#region ฟาร์ม ตามด่าน

function mapselect()
	if game.PlaceId == 8304191830 then
		local selectmap = tostring(lunaxshopconfig.selectmap)
		if selectmap == "เลือกเเมพ" then
			task.wait(1)
			print("Not Select Map.")
		else
			local cpos = plr.Character.HumanoidRootPart.CFrame
			if tostring(Workspace._LOBBIES.Story[lunaxshopconfig.door].Owner.Value) ~= plr.Name then
				for _, v in pairs(game:GetService("Workspace")["_LOBBIES"].Story:GetDescendants()) do
					if v.Name == "Owner" and v.Value == nil then
						local args = {
							[1] = tostring(v.Parent.Name),
						}
						game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
						task.wait(4)
						if lunaxshopconfig.modefarm == "ฟาร์มเลือกด่าน" then
							local args = {
								[1] = tostring(v.Parent.Name),
								[2] = selectmap,
								[3] = false,
								[4] = "Hard",
							}
							game:GetService("ReplicatedStorage").endpoints.client_to_server.request_lock_level:InvokeServer(unpack(args))
						end
						task.wait(2)
						local args = {
							[1] = tostring(v.Parent.Name),
						}
						game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
						game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
						lunaxshopconfig.door = v.Parent.Name
						plr.Character.HumanoidRootPart.CFrame = v.Parent.Door.CFrame
						break
					end
				end
			end
			task.wait()
			plr.Character.HumanoidRootPart.CFrame = cpos
		end
	end
end

--#endregion

--#region ซื้อยูนิตในร้านค้า

local function autobuyfunc(xx, item)
	task.wait()
	local args = {
		[1] = xx,
		[2] = item,
	}
	game:GetService("ReplicatedStorage").endpoints.client_to_server.buy_from_banner:InvokeServer(unpack(args))
end

function autoBuy()
	task.spawn(function()
    while task.wait(1) do
			if lunaxshopconfig.buyunit == "true" then
				game:GetService("StarterGui"):SetCore("SendNotification",{
					Title = "<-- AUTO BUY -->", -- Required
					Text = "กำลังทำงาน..", -- Required
					Icon = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=180&h=180 true";
					Duration = 2
				})
				while lunaxshopconfig.buyunit == "true" do
					autobuyfunc("EventClover", "gems10")
					task.wait()
				end
			else
				break
			end
		end
	end)
end

--#endregion

--#region รับโค้ด

function RedeemCode()
	local codes = {
			"TWOMILLION",
			"subtomaokuma",
			"CHALLENGEFIX",
			"GINYUFIX",
			"RELEASE",
			"SubToKelvingts",
			"SubToBlamspot",
			"KingLuffy",
			"TOADBOIGAMING",
			"noclypso",
			"FictioNTheFirst",
			"GOLDENSHUTDOWN",
			"GOLDEN",
			"SINS2",
			"subtosnowrbx",
			"Cxrsed",
			"VIGILANTE",
			"HAPPYEASTER",
			"ENTERTAINMENT",
			"DRESSROSA",
			"BILLION",
			"MADOKA",
			"AINCRAD",
			"SINS",
			"HERO",
			"UCHIHA",
			"CLOUD",
			"CHAINSAW",
			"NEWYEAR2023"
	}

	for _, code in ipairs(codes) do
			pcall(function()
					game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_code:InvokeServer(code)
			end)
	end

	wait(5)
	lunaxshopconfig.codeget = "ON"
	wait(1)
	update_datasystem({
		['codeget'] = 'OFF'
	})
end



--#endregion

--#region ย้ายห้อง JobID

function changRoom()
	if pcall(user_and_update_setting) then
		print("Connect Data Success..")
	else
		print("Failure Data Connect..")
		game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
	end
	playRoom = lunaxshopconfig.jobID
	Host_Check = game.Players.LocalPlayer
	if Host_Check == "Host_LunaXShop" then
		local function findLowPopulationServer(placeId)
			local servers = {}
			pcall(function()
				local response = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/'.. placeId ..'/servers/Public?sortOrder=Asc&limit=100'))
				for i, v in pairs(response.data) do
					if v.playing ~= nil and v.playing < 5 then
						table.insert(servers, v.id)
					end
				end
			end)
			return servers
		end
		
		local function teleportToLowPopulationServer(placeId)
			local servers = findLowPopulationServer(placeId)
			if #servers > 0 then
				TeleportService:TeleportToPlaceInstance(placeId, servers[1])
			else
				print("No servers found.")
			end
		end
		local placeId = 8304191830
		teleportToLowPopulationServer(placeId)
	end
	game:GetService("TeleportService"):TeleportToPlaceInstance(8304191830, tostring(playRoom),  game.Players.LocalPlayer)
end

--#endregion

--#region อัพเดตข้อมูล

task.spawn(function()
    while task.wait(1) do
        if game.PlaceId == 8304191830 then
            selectMode()
        else
            user_and_update_setting()
			break
        end
    end
end)

--#endregion

--#region รับเควส

function autoQuest()
	if game.PlaceId == 8304191830 then
		local questStory = LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.story.Scroll:GetChildren()
		for i, v in pairs(questStory) do
			if v.Name ~= "UIListLayout" and v.Name ~= "RefreshFrame" and v.Name ~= "Empty"  then
			if v.ClaimQuest.Visible == true then
				pcall(function()
				local args = {
					[1] = tostring(v.Name)
				}
				game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_quest:InvokeServer(unpack(args))
				game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_daily_reward:InvokeServer()
				game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_christmas_calendar_reward:InvokeServer()
				task.wait()
				end)
			end
		end
	end

		local questEvent = LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.event.Scroll:GetChildren()
			for i, v in pairs(questEvent) do
				if v.Name ~= "UIListLayout" and v.Name ~= "RefreshFrame" and v.Name ~= "Empty"  then
				if v.ClaimQuest.Visible == true then
					pcall(function()
					local args = {
						[1] = tostring(v.Name)
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_quest:InvokeServer(unpack(args))
					game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_daily_reward:InvokeServer()
					game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_christmas_calendar_reward:InvokeServer()
					task.wait()
					end)
				end
			end
		end

		local questDaily = LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.daily.Scroll:GetChildren()
			for i, v in pairs(questDaily) do
				if v.Name ~= "UIListLayout" and v.Name ~= "RefreshFrame" and v.Name ~= "Empty"  then
				if v.ClaimQuest.Visible == true then
					pcall(function()
					local args = {
						[1] = tostring(v.Name)
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_quest:InvokeServer(unpack(args))
					game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_daily_reward:InvokeServer()
					game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_christmas_calendar_reward:InvokeServer()
					task.wait()
					end)
				end
			end
		end

		local questInfinity = LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.infinite.Scroll:GetChildren()
			for i , v in pairs(questInfinity) do
				if v.Name ~= "UIListLayout" and v.Name ~= "RefreshFrame" and v.Name ~= "Empty"  then
				if v.ClaimQuest.Visible == true then
					pcall(function()
					local args = {
						[1] = tostring(v.Name)
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_quest:InvokeServer(unpack(args))
					game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_daily_reward:InvokeServer()
					game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_christmas_calendar_reward:InvokeServer()
					task.wait()
					end)
				end
			end
		end
	end
end


--#endregion

--#region วางยูนิต

function auto_place_units(position)
	math.randomseed(os.time())
	for i = 1, 6 do
		print("======= Unit Select =======")
		local unit_data = SelectedUnits[i]
		if unit_data ~= nil then
			print("======= Unit =======")
			local unit_id = unit_data:split(" #")[2]
			local unit_name = unit_data:split(" #")[1]
			if unit_name ~= "metal_knight_evolved" then
				-- place ground unit
				unitPostion = math.random(2,3)
				randomSpaw = math.random(-5,5)
				local args = {
					[1] = unit_id,
					[2] = CFrame.new(position[1].x + randomSpaw, position[1].y, position[1].z + randomSpaw) * CFrame.Angles(0, -0, -0)
				}
				game:GetService("ReplicatedStorage").endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))
				-- place hill unit
				unitPostion = math.random(2,3)
				randomSpaw = math.random(-5,5)
				local args = {
					[1] = unit_id,
					[2] = CFrame.new(position[unitPostion].x + randomSpaw, position[unitPostion].y, position[unitPostion].z + randomSpaw) * CFrame.Angles(0, -0, -0)
				}
				game:GetService("ReplicatedStorage").endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))

			elseif unit_name == "metal_knight_evolved" then
				-- place hill unit
				unitPostion = math.random(2,3)
				randomSpaw = math.random(-5,5)
				task.spawn(function()
					local args = {
						[1] = unit_id,
						[2] = CFrame.new(position[unitPostion].x + randomSpaw, position[unitPostion].y, position[unitPostion].z + randomSpaw) * CFrame.Angles(0, -0, -0)
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.spawn_unit:InvokeServer(unpack(args))
				end)
			end
		end
	end
end


function get_level_data()
	local list = {}
	for i, v in pairs(game.Workspace._MAP_CONFIG:WaitForChild("GetLevelData"):InvokeServer()) do
		list[i] = v
	end
	return list
end

if game.PlaceId ~= 8304191830 then
	lunaxshopconfig.getmaps = get_level_data().map
end

function plateUnit()
    task.spawn(function()
        while task.wait(1) do
            if game.PlaceId ~= 8304191830 then
                local maps = get_level_data().map
                local current_map = lunaxshopconfig.getmaps

                if maps and current_map then
                    for i, v in ipairs(game.Workspace["_UNITS"]:GetChildren()) do
                        if v:FindFirstChild("_stats") and v._stats.player.Value == nil then
                            local pos_x = v.HumanoidRootPart.Position.X
                            local pos_z = v.HumanoidRootPart.Position.Z
                            local position = { x = pos_x, y = v.HumanoidRootPart.Position.Y, z = pos_z }

							if current_map:match('namek') then
								auto_place_units({
									[1] = { x = pos_x, y = 91.80, z = pos_z }, -- ground unit position
									[2] = { x = -2959.61, y = 94.53, z = -696.83 }, -- hill unit position
									[3] = { x = -2952.06, y = 94.41, z = -721.40 }, -- hill unit position
								})
							elseif current_map:match('aot') then
								auto_place_units({
									[1] = { x = pos_x, y = 33.74, z = pos_z }, -- ground unit position
									[2] = { x = -3026.78, y = 38.41, z = -677.81 }, -- hill unit position
									[3] = { x = -3019.03, y = 38.41, z = -689.49 }, -- hill unit position
								})
							elseif current_map:match('demonslayer') then
								auto_place_units({
									[1] = { x = pos_x, y = 34.34, z = pos_z }, -- ground unit position
									[2] = { x = -2876.02, y = 37.24, z = -150.81 }, -- hill unit position
									[3] = { x = -2879.09, y = 39.57, z = -124.25 }, -- hill unit position
								})
							elseif current_map:match('naruto') then
								auto_place_units({
									[1] = { x = pos_x, y = 25.28, z = pos_z }, -- ground unit position
									[2] = { x = -910.64, y = 33.14, z = 294.41 }, -- hill unit position
									[3] = { x = -893.90, y = 29.56, z = 318.74 }, -- hill unit position
								})
							elseif current_map:match('marineford') then
								auto_place_units({
									[1] = { x = pos_x, y = 25.21, z = pos_z }, -- ground unit position
									[2] = { x = -2571.46, y = 29.50, z = -49.31 }, -- hill unit position
									[3] = { x = -2581.62, y = 28.35, z = -66.97 }, -- hill unit position
								})
							elseif current_map:match('tokyo_ghoul') then
								auto_place_units({
									[1] = { x = pos_x, y = 58.58, z = pos_z }, -- ground unit position
									[2] = { x = -2985.60, y = 66.70, z = -54.09 }, -- hill unit position
									[3] = { x = -2956.22, y = 62.82, z = -49.40 }, -- hill unit position
								})
							elseif current_map:match('hueco') then
								auto_place_units({
									[1] = { x = pos_x, y = 132.66, z = pos_z }, -- ground unit position
									[2] = { x = -184.33, y = 136.34, z = -757.71 }, -- hill unit position
									[3] = { x = -174.58, y = 136.34, z = -710.48 }, -- hill unit position
								})
							elseif current_map:match('hxhant') then
								auto_place_units({
									[1] = { x = pos_x, y = 23.01, z = pos_z }, -- ground unit position
									[2] = { x = -145.86, y = 26.72, z = 2965.56 }, -- hill unit position
									[3] = { x = -191.47, y = 27.20, z = 2952.01 }, -- hill unit position
								})
							elseif current_map:match('magnolia') then
								auto_place_units({
									[1] = { x = pos_x, y = 6.74, z = pos_z }, -- ground unit position
									[2] = { x = -596.36, y = 13.99, z = -824.33 }, -- hill unit position
									[3] = { x = -586.75, y = 13.88, z = -824.23 }, -- hill unit position
								})
							elseif current_map:match("jjk") then
								auto_place_units({
									[1] = { x = pos_x, y = 122.061, z = pos_z }, -- ground unit position
									[2] = { x = 390.69, y = 124.44, z = -79.02 }, -- hill unit position
									[3] = { x = 323.66, y = 125.39, z = 113.32 },
								})
							elseif current_map:match('hage') then
								auto_place_units({
									[1] = { x = pos_x, y = 1.23, z = pos_z }, -- ground unit position
									[2] = { x = -161.98, y = 5.03, z = -43.10 }, -- hill unit position
									[3] = { x = -122.39, y = 4.86, z = -43.87 }, -- hill unit position
								})
							elseif current_map:match('space') then
								auto_place_units({
									[1] = { x = pos_x, y = 15.25, z = pos_z }, -- ground unit position
									[2] = { x = -104.66, y = 19.62, z = -524.07 }, -- hill unit position
									[3] = { x = -106.91, y = 19.62, z = -524.60 }, -- hill unit position
								})
							elseif current_map:match('boros') then
								auto_place_units({
									[1] = { x = pos_x, y = 361.21, z = pos_z }, -- ground unit position
									[2] = { x = -336.19, y = 365.26, z = 1389.11 }, -- hill unit position
									[3] = { x = -336.18, y = 365.26, z = 1391.78 }, -- hill unit position
								})
							elseif current_map:match('7ds') then
								auto_place_units({
									[1] = { x = pos_x, y = 212.96, z = pos_z }, -- ground unit position
									[2] = { x = -87.39, y = 216.99, z = -214.06 }, -- hill unit position
									[3] = { x = -102.37, y = 219.20, z = -204.66 }, -- hill unit position
								})
							elseif current_map:match('mha') then
								auto_place_units({
									[1] = { x = pos_x, y = -13.24, z = pos_z }, -- ground unit position
									[2] = { x = -31.49, y = -10.02, z = 21.95 }, -- hill unit position
									[3] = { x = -54.03, y = -8.89, z = 3.62 }, -- hill unit position
								})
							elseif current_map:match('dressrosa') then
								auto_place_units({
									[1] = { x = pos_x, y = 2.60, z = pos_z }, -- ground unit position 
									[2] = { x = -35.40, y = 5.98, z = -201.43 }, -- hill unit position
									[3] = { x = -35.40, y = 5.98, z = -201.43 }, -- hill unit position
								})
							elseif current_map:match('sao') then
								auto_place_units({
									[1] = { x = pos_x, y =  37.53, z = pos_z }, -- ground unit position 
									[2] = { x = 101.85, y = 41.67, z = 16.34 }, -- hill unit position
									[3] = { x = 105.29, y = 41.67, z = 16.93}, -- hill unit position
								})
							elseif current_map:match('berserk') then
								auto_place_units({
									[1] = { x = pos_x, y =  -0.074, z = pos_z }, -- ground unit position 
									[2] = { x = -252.30, y = 3.54, z = 20.98 }, -- hill unit position
									[3] = { x = -241.66, y = 3.54, z = 17.30}, -- hill unit position
								})
							-- RAID --
							elseif current_map:match('uchiha') then
								auto_place_units({
									[1] = { x = pos_x, y = 536.89, z = pos_z }, -- ground unit position
									[2] = { x = 304.59, y = 539.89, z = -588.45 }, -- hill unit position
									[3] = { x = 267.66, y = 539.89, z = -560.54 }, -- hill unit position
								})
							elseif current_map:match('uchiha_hideout_final') then
								auto_place_units({
									[1] = { x = pos_x, y = 536.89, z = pos_z }, -- ground unit position
									[2] = { x = 304.59, y = 539.89, z = -588.45 }, -- hill unit position
									[3] = { x = 267.66, y = 539.89, z = -560.54 }, -- hill unit position
								})
							elseif current_map:match('west_city_frieza') then
								auto_place_units({
									[1] = { x = pos_x, y = 19.76, z = pos_z }, -- ground unit position
									[2] = { x = -2334.15, y = 31.41, z = -79.33 }, -- hill unit position
									[3] = { x = -2339.57, y = 32.03, z = -90.32 }, -- hill unit position
								})
							elseif current_map:match('entertainment_district') then
								auto_place_units({
									[1] = { x = pos_x, y = 495.600, z = pos_z }, -- ground unit position 
									[2] = { x = -130.05, y = 504.78, z = -93.73 }, -- hill unit position
									[3] = { x = -97.27, y = -97.27, z = -92.03 }, -- hill unit position
								})
							elseif current_map:match('mha_city_night') then
								auto_place_units({
									[1] = { x = pos_x, y =  -13.24, z = pos_z }, -- ground unit position 
									[2] = { x = -55.57, y = -8.89, z = 3.31 }, -- hill unit position
									[3] = { x = -50.44, y = -8.89, z = 3.05}, -- hill unit position
								})
							elseif current_map:match("karakura") then
								auto_place_units({
									[1] = { x = pos_x, y = 36.04, z = pos_z }, -- ground unit position
									[2] = { x = -212.72, y = 46.03, z = 598.99 }, -- hill unit position
									[3] = { x = -212.72, y = 46.03, z = 598.99 }, -- hill unit position
								})
							elseif current_map:match('thriller') then -- New Map Clestall
								auto_place_units({
									[1] = { x = pos_x, y =  109.37, z = pos_z }, -- ground unit position 
									[2] = { x = -196.43, y = 112.83, z = -611.77 }, -- hill unit position -130.05752563476562, 504.7899169921875, -93.732666015625
									[3] = { x = -200.55, y = 112.83, z = -612.51}, -- hill unit position -130.05752563476562, 504.7899169921875, -93.732666015625
								})
							elseif current_map:match('overlord') then -- Overlord
								auto_place_units({
									[1] = { x = pos_x, y =  0.99, z = pos_z }, -- ground unit position 
									[2] = { x = 278.42, y = 6.87, z = -11.06 }, -- hill unit position -130.05752563476562, 504.7899169921875, -93.732666015625
									[3] = { x = 277.03, y = 6.87, z = -17.79}, -- hill unit position -130.05752563476562, 504.7899169921875, -93.732666015625
								})
							elseif current_map:match('fate') then -- fate
								auto_place_units({
									[1] = { x = pos_x, y =  54.82, z = pos_z }, -- ground unit position 
									[2] = { x = -234.24, y = 58.57, z = -521.33 },
									[3] = { x = -234.43, y = 58.57, z = -504.09},
								})
							elseif current_map:match("bsd") then -- Portal New Event
								auto_place_units({
									[1] = { x = pos_x, y = 497.521, z = pos_z }, -- ground unit position
									[2] = { x = 1986.480, y = 502.435, z = -1461.179 }, -- hill unit position
									[3] = { x = 1986.480, y = 502.435, z = -1461.179 }, -- hill unit position
								})
							elseif current_map:match('demonslayer_raid') then -- fate
								auto_place_units({
									[1] = { x = pos_x, y = -15.07, z = pos_z }, -- ground unit position 
									[2] = { x = 108.65, y = -12.08, z = 361.89 },
									[3] = { x = 99.25, y = -10.01, z = 363.38 },
								})
							end
						end
					end
				end
			end
		end
	end)
end

--#endregion

--#region อัพเกรตยูนิต
function autoUpgrade()
	task.spawn(function()
    while task.wait(1) do
		if _wave.Value >= 4 then
					pcall(function() --///
						repeat task.wait() until game:GetService("Workspace"):WaitForChild("_UNITS")
						for _, v in ipairs(game:GetService("Workspace")["_UNITS"]:GetChildren()) do
							if v:FindFirstChild("_stats") then
								if tostring(v["_stats"].player.Value) == game.Players.LocalPlayer.Name and v["_stats"].xp.Value >= 0 then
									if v.Name == "wendy" or v.Name == "wendy:shiny" or v.Name == "sakura" then
										-- print(v.Name)
									else
										game:GetService("ReplicatedStorage").endpoints.client_to_server.upgrade_unit_ingame:InvokeServer(v)
									end
								end
							end
						end
					end)
				end
		end
	end)
end

--#endregion 

--#region ใช้สกิลอัตโนมัติ

function autoabilityfunc()
	pcall(function() --///
		repeat task.wait() until game:GetService("Workspace"):WaitForChild("_UNITS")
		for i, v in ipairs(game:GetService("Workspace")["_UNITS"]:GetChildren()) do
			if v:FindFirstChild("_stats") then
				if v._stats:FindFirstChild("player") and v._stats:FindFirstChild("xp") then
					if v.Name == "ichigo_mugetsu_evolved" or v.Name == "ichigo_mugetsu" then
						print('ichigo')
					elseif v.Name == "gojo_evolved" or v.Name == "kisuke_evolved" then
						game:GetService("ReplicatedStorage").endpoints.client_to_server.use_active_attack:InvokeServer(v)
					elseif v.Name == "wendy" or v.Name == "erwin" then
						game:GetService("ReplicatedStorage").endpoints.client_to_server.use_active_attack:InvokeServer(v)
						task.wait(11)
					end
				end
			end
		end
	end)
end

--#endregion

--#region ลบแมพ

local function DeleteMap()
	if game.PlaceId ~= 8304191830 then
		local removeMap = game:GetService("Workspace")["_map"]:GetChildren()
		local removeTerrain = game:GetService("Workspace")["_terrain"].terrain:GetChildren()
		for _, v in pairs(removeMap) do
			v:Destroy()
		end

		for _, v in pairs(removeTerrain) do
			v:Destroy()
		end
	end
end

--#endregion

--#region โหมดสตอรี่

function modeStory()
  task.spawn(function()
    while task.wait(10) do
			local resultx = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text)
			if resultx == "VICTORY" then
				pcall(function() update_data() end)
				local args = {
					[1] = "next_story"
				}
				game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(args))
				task.wait(100)
			else
				pcall(function() update_data() end)
				local a = { [1] = "replay" }
				game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(a))
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				playRoom = lunaxshopconfig.jobID
				game:GetService("TeleportService"):TeleportToPlaceInstance(8304191830, tostring(playRoom),  game.Players.LocalPlayer)
				task.wait(100)
				game:Shutdown()
			end
		end
	end)
end

--#endregion

--#region โหมดหอคอย

function modeClsatle()
  task.spawn(function()
    while task.wait(10) do
			task.wait(5)
			local resultx = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text)
			infTower_check = game:GetService("Players").LocalPlayer.PlayerGui.ResultsUI.Holder.LevelName.Text
			infinityTower = infTower_check:split(" ")
			if resultx == "VICTORY" then
				if tonumber(infinityTower[4]) >= tonumber(lunaxshopconfig.numberfarm) then
					pcall(function() webhook_finish() end)
				else
					pcall(function() update_data() end)
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower_from_game:InvokeServer()
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower_from_game:InvokeServer()
					wait(99)
				end
			else
				if tonumber(infinityTower[4]) >= tonumber(lunaxshopconfig.numberfarm) then
					pcall(function() webhook_finish() end)
				else
					pcall(function() update_data() end)
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower_from_game:InvokeServer()
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_infinite_tower_from_game:InvokeServer()
					wait(99)
				end
			end
		end
	end)
end

--#endregion

--#region โหมดไอเท็มเรด

function modeItemRaid()
  task.spawn(function()
    while task.wait(10) do
			task.wait(5)
			pcall(function() update_data() end)
			if lunaxshopconfig.replay == "true" then
				local a = { [1] = "replay" }
				game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(a))
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
				for i = 1, 60 do
					warn("game Shutdown in : " .. i)
					task.wait(1)
				end
				game:Shutdown()
			end
			task.wait(3)
			game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			for i = 1, 180 do
				warn("Game restart in : " .. i)
				task.wait(1)
			end
			game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
		end
	end)
end

--#endregion

--#region โหมดไก่เพชร

function modeChicken()
  task.spawn(function()
    while task.wait(15) do
			pcall(function() update_data() end)
			local aceCheck = game:GetService("Players").LocalPlayer.PlayerGui.ResultsUI.Holder.LevelName
			local resultx = tostring(LocalPlayer.PlayerGui.ResultsUI.Holder.Title.Text)
			if lunaxshopconfig.getmaps:match('namek_cartoon') then
				if aceCheck == "Act 6 - The Purple Tyrant" then
					if resultx == "VICTORY" then
						lunaxshopconfig.modefarm = "ฟาร์มเพชร" 
						update_datasystem({
							['modefarm'] = "ฟาร์มเพชร"
						})
						game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
					else
						local a = { [1] = "replay" }
						game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(a))
						wait(99)
					end
				else
					if resultx == "VICTORY" then
						local args = {
							[1] = "next_story"
						}
						game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(args))
					else
						local a = { [1] = "replay" }
						game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(a))
						wait(99)
					end
				end
			else
				lunaxshopconfig.modefarm = "ฟาร์มเพชร" 
				update_datasystem({
					['modefarm'] = "ฟาร์มเพชร"
				})
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			end
			wait(99)
		end
	end)
end

--#endregion

--#region โหมดผลไม้

function modeFruist()
	pcall(function() update_data() end)
	task.wait(3)
	game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
	task.wait(100)
	game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
end

--#endregion

--#region โหมดเวลตัวละคร

function modeLevelPlayer()
	task.spawn(function()
    while task.wait(15) do
			levePlayers = LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text
			levelCheck = levePlayers:split(" ")
			if tonumber(levelCheck[2]) >= tonumber(lunaxshopconfig.numberfarm) then
				pcall(function() webhook_finish() end)
				task.wait(3)
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			else
				pcall(function() update_data() end)
				local a = { [1] = "replay" }
				game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(a))
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			end
		end
	end)
end

--#endregion

--#region โหมดจบเกมส์

function modeGameEnd()
	task.spawn(function()
	print("2061 ==========")
    while task.wait(15) do
			if tonumber(lunaxshopconfig.numberfarm) <= 0 then
				webhook_finish()
				task.wait(3)
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			end
			update_data()
			task.wait(3)
			if lunaxshopconfig.replay == "true" then
				local a = { [1] = "replay" }
				game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(a))
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			end
			game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			for i = 1, 180 do
				warn("Game restart in : " .. i)
				task.wait(1)
			end
			game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			for i = 1, 60 do
				warn("game Shutdown in : " .. i)
				task.wait(1)
			end
			game:Shutdown()
			
		end
	end)
end

--#endregion

--#region โหมดจบเกมส์

function modestartChallengeEnd()
	task.spawn(function()
    while task.wait(15) do
			-- if tonumber(lunaxshopconfig.numberfarm) <= 0 then
			-- 	webhook_finish()
			-- 	task.wait(3)
			-- 	game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			-- 	for i = 1, 180 do
			-- 		warn("Game restart in : " .. i)
			-- 		task.wait(1)
			-- 	end
			-- 	game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			-- end
			-- update_data()
			-- task.wait(3)

			game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			for i = 1, 180 do
				warn("Game restart in : " .. i)
				task.wait(1)
			end
			game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			for i = 1, 60 do
				warn("game Shutdown in : " .. i)
				task.wait(1)
			end
			game:Shutdown()
			
		end
	end)
end

--#endregion

--#region โหมดจบเกมส์หาดาวรีโร

function checkChallenge()
    for i,v in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
        if v:IsA("SurfaceGui") then
            if v:FindFirstChild("ChallengeCleared") then
                return v.ChallengeCleared.Visible
            end
        end
    end
end

function farmstartChallenge()
    if game.PlaceId == 8304191830 then
        local cpos = plr.Character.HumanoidRootPart.CFrame
            for i, v in pairs(game:GetService("Workspace")["_CHALLENGES"].Challenges:GetDescendants()) do
                if v.Name == "Owner" and v.Value == nil then
                    local args = {  [1] = tostring(v.Parent.Name) }
                    game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
                    Settings.chdoor = v.Parent.Name
                    break
                end
            task.wait()
            plr.Character.HumanoidRootPart.CFrame = cpos
        end
    end
end

--#endregion

--#region โหมดเพชรออกแมพ

function amReplay()  
	task.spawn(function()
		while task.wait() do
			-- sell unit
			repeat task.wait() until game:GetService("Workspace"):WaitForChild("_UNITS")
			for i, v in ipairs(game:GetService("Workspace")["_UNITS"]:GetChildren()) do
				repeat task.wait() until v:WaitForChild("_stats")
				if tostring(v["_stats"].player.Value) == game.Players.LocalPlayer.Name then
					repeat task.wait() until v:WaitForChild("_stats"):WaitForChild("upgrade")
					game:GetService("ReplicatedStorage").endpoints.client_to_server.sell_unit_ingame:InvokeServer(v)
				end
			end
		end
	end)
end

function modeGemsOutmaps()
	task.spawn(function()
    while task.wait(15) do
			levePlayers = LocalPlayer.PlayerGui.spawn_units.Lives.Main.Desc.Level.Text
			levelCheck = levePlayers:split(" ")
			if tonumber(lunaxshopconfig.numberfarm) <= 0 then
				pcall(function () webhook_finish()  end)
				task.wait(3)
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
				break
			else
				if tonumber(levelCheck[2]) <= tonumber(50) and tonumber(_wave.Value) >= tonumber(15) then
					if lunaxshopconfig.replay == "true" then
						amReplay()
						break
					else
						update_data()
						task.wait(5)
						game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
						for i = 1, 180 do
							warn("Game restart in : " .. i)
							task.wait(1)
						end
						game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
						break
					end
				end
				if _wave.Value >= 25 then
					if lunaxshopconfig.replay == "true" then
						amReplay()
						break
					else
						update_data()
						task.wait(3)
						game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
						for i = 1, 180 do
							warn("Game restart in : " .. i)
							task.wait(1)
						end
						game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
						break
					end
				end
			end
		end
	end)
end

--#endregion

--#region โหมดแบทเทิลพาสจบเกม

function modeBattlePassEnd()
	task.spawn(function()
    while task.wait(15) do
			user_and_update_setting()
			if tonumber(lunaxshopconfig.numberfarm) <= tonumber(lunaxshopconfig.BattlePass) then
				pcall(function () webhook_finish()  end)
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			else
				pcall(function () update_data()  end)
				task.wait(3)
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
				break
			end
			
		end
	end)
end

--#endregion

--#region ฟาร์ม Portal

function farmbsd()
	if game.PlaceId == 8304191830 then
		for i, v in ipairs(game:GetService("ReplicatedStorage")["_FX_CACHE"]:GetChildren()) do
			if v.Name == "portal_item__bsd" then
				getgenv().PortalID = v._uuid_or_id.value
				break
			end
        end
		task.wait(5)
	
		local args = {
			[1] = tostring(getgenv().PortalID),
			[2] = {
				["friends_only"] = false,
			},
		}

		game:GetService("ReplicatedStorage").endpoints.client_to_server.use_portal:InvokeServer(unpack(args))
		task.wait(45)
		for i, v in pairs(game:GetService("Workspace")["_PORTALS"].Lobbies:GetDescendants()) do
			if v.Name == "Owner" then
				if tostring(v.value) == game.Players.LocalPlayer.Name then
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					break
				end
			end
		end
		task.wait(7)
	end
end


function farmfate()
	if game.PlaceId == 8304191830 then
		for i, v in ipairs(game:GetService("ReplicatedStorage")["_FX_CACHE"]:GetChildren()) do
			if v.Name == "portal_item__fate" then
				getgenv().PortalID = v._uuid_or_id.value
				break
			end
        end
		task.wait(5)
	
		local args = {
			[1] = tostring(getgenv().PortalID),
			[2] = {
				["friends_only"] = false,
			},
		}

		game:GetService("ReplicatedStorage").endpoints.client_to_server.use_portal:InvokeServer(unpack(args))
		task.wait(45)
		for i, v in pairs(game:GetService("Workspace")["_PORTALS"].Lobbies:GetDescendants()) do
			if v.Name == "Owner" then
				if tostring(v.value) == game.Players.LocalPlayer.Name then
					local args = {
						[1] = tostring(v.Parent.Name),
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.request_start_game:InvokeServer(unpack(args))
					break
				end
			end
		end
		task.wait(7)
	end
end

--#endregion

--#region โหมดแบทเทิลพาส

function modeBattlePass()
	task.spawn(function()
    while task.wait(15) do
			print(lunaxshopconfig.numberfarm)
			print(lunaxshopconfig.BattlePass)
			if _wave.Value >= 55 then
				if tonumber(lunaxshopconfig.numberfarm) <= tonumber(lunaxshopconfig.BattlePass) then
					pcall(function () webhook_finish()  end)
					for i = 1, 180 do
						warn("Game restart in : " .. i)
						task.wait(1)
					end
					game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
				else
					pcall(function () update_data()  end)
					task.wait(3)
					game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
					for i = 1, 180 do
						warn("Game restart in : " .. i)
						task.wait(1)
					end
					game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
					break
				end
			end
		end
	end)
end

--#endregion

--#region โหมดโกโจจบเกม

function modeGoJoEnd()
	task.spawn(function()
    while task.wait(15) do
			if tonumber(lunaxshopconfig.numberfarm) <= 0 then
				pcall(function () webhook_finish()  end)
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
			else
				pcall(function () update_data()  end)
				task.wait(3)
				local a = { [1] = "replay" }
				game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(a))
				for i = 1, 180 do
					warn("Game restart in : " .. i)
					task.wait(1)
				end
				game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
				break
			end
			
		end
	end)
end

--#endregion

--#region โหมดโกโจ

function modeGoJo()
	task.spawn(function()
    while task.wait(15) do
			if _wave.Value >= 32 then
				if tonumber(lunaxshopconfig.numberfarm) <= 0 then
					pcall(function () webhook_finish()  end)
					for i = 1, 180 do
						warn("Game restart in : " .. i)
						task.wait(1)
					end
					game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
				else
					pcall(function () update_data()  end)
					task.wait(3)
					game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
					for i = 1, 180 do
						warn("Game restart in : " .. i)
						task.wait(1)
					end
					game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
					break
				end
			end
		end
	end)
end

--#endregion

--#======================== Main Function ================================

--#region เลือกโหมดฟาร์ม

function selectMode()
	if lunaxshopconfig.WarpLobby == 'true' then
		cheackjobid = game.JobId
		if lunaxshopconfig.jobID == cheackjobid then
			print('Welcome to MainLobby')
		else
			changRoom()
		end
	end

	if lunaxshopconfig.startfarm == 'true' then
		if lunaxshopconfig.joinPortal == 'true' then
			joinPTplayer()
		elseif lunaxshopconfig.modefarm == 'ฟาร์มสตอรี่' then
			farmStory()
		elseif lunaxshopconfig.modefarm == 'ฟาร์มเพชร' then
			farmGem()
		elseif lunaxshopconfig.modefarm == 'ฟาร์มเลือกด่าน' then
			mapselect()
		elseif lunaxshopconfig.modefarm == 'ฟาร์ม BattlePass' then
			farmBattlePass()
		elseif lunaxshopconfig.modefarm == 'ฟาร์มเวลตัวละคร' then
			farmLevelPlayer()
		elseif lunaxshopconfig.modefarm == 'ฟาร์มหอคอย' then
			farmClstel()
		elseif lunaxshopconfig.modefarm == 'ฟาร์มผลไม้' then
			farmFrust()
		elseif lunaxshopconfig.modefarm == 'ฟาร์มไก่เพชร' then
			farmStory()
		elseif lunaxshopconfig.modefarm == 'ฟาร์มตาโกโจ' then
			farmGojo()
		elseif lunaxshopconfig.modefarm == 'หาดาว' then
			farmstartChallenge()
		elseif lunaxshopconfig.modefarm == 'อีเว้นหาคัมภีร์' then
			farmbsd()
		elseif lunaxshopconfig.modefarm == 'อีเว้นหาจอก' then
			farmfate()
		end	
	end
end


--#endregion

--#region เมนฟังชั่น
function Main()
    auto_reconnect()
    if game.PlaceId == 8304191830 then
        if lunaxshopconfig.codeget == "true" then
            RedeemCode()
            task.wait(15)
            update_datasystem {['codeget'] = false}
        end
		unitBag()
        autoQuest()
        selectMode()
    else
        DeleteMap()
        print("====================")
        print("Start Farm -> ", lunaxshopconfig.startfarm)
        print("Mode Farm -> ", lunaxshopconfig.modefarm)
        print("Gem -> ", lunaxshopconfig.total_gems)
        print("====================")
        if lunaxshopconfig.modefarm == 'ฟาร์มเพชร' then
            modeGemsOutmaps()
        elseif lunaxshopconfig.modefarm == 'ฟาร์ม BattlePass' then
            modeBattlePass()
        elseif lunaxshopconfig.modefarm == 'ฟาร์มตาโกโจ' then
            modeGoJo()
        end
        autoUpgrade()
        plateUnit()
		autoabilityfunc()
    end
end

Main()


--#endregion

--#region Buy UNIY SHOP

-- local buyunitX = false
-- UserInputService.InputBegan:Connect(function(input, processed)
-- 	if (input.KeyCode == Enum.KeyCode.F2 and not processed) then
-- 		if buyunitX then
-- 			buyunitX = false
-- 			lunaxshopconfig.buyunit = "false"
			
-- 		else
-- 			buyunitX = true
-- 			lunaxshopconfig.buyunit = "true"
-- 			autoBuy()
-- 		end
-- 	end
-- end)

--#endregion

--#region โหมดจบเกมส์

function modeGameEndBsd()
	task.spawn(function()
		while task.wait(10) do
			local portal_name = getCSMPortals()
			local portal_uuid
			local portal_depth = 6 
			while portal_depth >= 5 do
				for i, v in pairs(portal_name) do
					if v['item_id'] == "portal_item__bsd" then
						local v_portal_depth = v["_unique_item_data"]["_unique_portal_data"]["portal_depth"]
						if v_portal_depth == portal_depth then
							portal_uuid = v.uuid
							break
						end
					end
				end
				if portal_uuid then
					local args = {
						[1] = "replay",
						[2] = {
							["item_uuid"] = portal_uuid
						}
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(args))
					wait(2)
					break
				else
					portal_depth = portal_depth - 1
				end
			end
			game:GetService("TeleportService"):TeleportToPlaceInstance(8304191830, tostring(getgenv().jobID),  game.Players.LocalPlayer)
			for i = 1, 180 do
				warn("Game restart in : " .. i)
				task.wait(1)
			end
			game:GetService("TeleportService"):TeleportToPlaceInstance(8304191830, tostring(getgenv().jobID),  game.Players.LocalPlayer)
			game:GetService("TeleportService"):TeleportToPlaceInstance(8304191830, tostring(getgenv().jobID),  game.Players.LocalPlayer)
			for i = 1, 60 do
				warn("game Shutdown in : " .. i)
				task.wait(1)
			end
			game:Shutdown()
		end
	end)
end


function modeGameEndfate()
	task.spawn(function()
		while task.wait(10) do
			local portal_name = getCSMPortals()
			local portal_uuid
			local portal_depth = 0 
			while portal_depth >= 0 do
				for i, v in pairs(portal_name) do
					if v['item_id'] == "portal_item__fate" then
						local v_portal_depth = v["_unique_item_data"]["_unique_portal_data"]["portal_depth"]
						if v_portal_depth == portal_depth then
							portal_uuid = v.uuid
							break
						end
					end
				end
				if portal_uuid then
					local args = {
						[1] = "replay",
						[2] = {
							["item_uuid"] = portal_uuid
						}
					}
					game:GetService("ReplicatedStorage").endpoints.client_to_server.set_game_finished_vote:InvokeServer(unpack(args))
					wait(2)
					break
				else
					portal_depth = portal_depth - 1
				end
			end
			game:GetService("TeleportService"):TeleportToPlaceInstance(8304191830, tostring(getgenv().jobID),  game.Players.LocalPlayer)
			for i = 1, 180 do
				warn("Game restart in : " .. i)
				task.wait(1)
			end
			game:GetService("TeleportService"):TeleportToPlaceInstance(8304191830, tostring(getgenv().jobID),  game.Players.LocalPlayer)
			game:GetService("TeleportService"):TeleportToPlaceInstance(8304191830, tostring(getgenv().jobID),  game.Players.LocalPlayer)
			for i = 1, 60 do
				warn("game Shutdown in : " .. i)
				task.wait(1)
			end
			game:Shutdown()
		end
	end)
end
--#endregion

--#region เข้า Portal คนอื่น

function joinPTplayer()

	for i, v in pairs(game:GetService("Workspace")["_PORTALS"].Lobbies:GetChildren()) do
		local args = {
			[1] = tostring(v.Name),
		}
		game:GetService("ReplicatedStorage").endpoints.client_to_server.request_join_lobby:InvokeServer(unpack(args))
		task.wait(3) 
	end
	task.wait(5) --// Wait New Loop 

end

--#endregion

--#region F4 Set loca

UserInputService.InputBegan:Connect(function(input, processed)
	if (input.KeyCode == Enum.KeyCode.F4 and not processed) then
		print("update_datasystem")
		update_datasystem({['jobID'] = game.JobId})
	end
end)

--#endregion

--#region GameFinished Auto

coroutine.resume(coroutine.create(function()
	local GameFinished = game:GetService("Workspace"):WaitForChild("_DATA"):WaitForChild("GameFinished")
	GameFinished:GetPropertyChangedSignal("Value"):Connect(function()
		if GameFinished.Value == true then
			wait(2)
			if lunaxshopconfig.modefarm == 'ฟาร์มสตอรี่' then
				modeStory()
			elseif lunaxshopconfig.modefarm == 'ฟาร์มเพชร' then
				modeGameEnd()
			elseif lunaxshopconfig.modefarm == 'ฟาร์ม BattlePass' then
				modeBattlePassEnd()
			elseif lunaxshopconfig.modefarm == 'ฟาร์มเวลตัวละคร' then
				modeLevelPlayer()
			elseif lunaxshopconfig.modefarm == 'ฟาร์มหอคอย' then
				modeClsatle()
			elseif lunaxshopconfig.modefarm == 'ฟาร์มผลไม้' then
				modeFruist()
			elseif lunaxshopconfig.modefarm == 'ฟาร์มไก่เพชร' then
				modeChicken()
			elseif lunaxshopconfig.modefarm == 'ฟาร์มตาโกโจ' then
				modeGoJoEnd()
			elseif lunaxshopconfig.modefarm == 'ฟาร์มไอเท็มเรด' then
				modeGameEnd()
			elseif lunaxshopconfig.modefarm == 'ฟาร์มเลือกด่าน' then
				modeGameEnd()
			elseif lunaxshopconfig.modefarm == 'หาดาว' then
				modestartChallengeEnd()
			elseif lunaxshopconfig.modefarm == 'อีเว้นหาคัมภีร์' then
				modeGameEndBsd()
			elseif lunaxshopconfig.modefarm == 'อีเว้นหาจอก' then
				modeGameEndfate()
			end
		end
	end)
end))

--#endregion

--#region claim_daily_reward

function RedeemQuests(quests)
    for _, quest in pairs(quests) do
        if quest.Name ~= "UIListLayout" and quest.Name ~= "RefreshFrame" then
            pcall(function()
                game:GetService("ReplicatedStorage").endpoints.client_to_server.redeem_quest:InvokeServer(quest.Name)
            end)
        end
    end
end

function Dailyquest()
    game:GetService("ReplicatedStorage").endpoints.client_to_server.accept_npc_quest:InvokeServer("berserk_daily")
    game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_daily_reward:InvokeServer()
    local questTypes = {
        game:GetService("Players").LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.story.Scroll:GetChildren(),
        game:GetService("Players").LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.event.Scroll:GetChildren(),
        game:GetService("Players").LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.daily.Scroll:GetChildren(),
        game:GetService("Players").LocalPlayer.PlayerGui.QuestsUI.Main.Main.Main.Content.infinite.Scroll:GetChildren()
    }
    
    for _, quests in pairs(questTypes) do
        RedeemQuests(quests)
    end
    
    wait(15)
end

function DailyMission()
    local missions = {
        "mha 12.0.0_dailymission_bleach2_daily",
        "mha 12.0.0_dailymission_dressrosa_daily",
        "mha 12.0.0_dailymission_clover_daily",
        "mha 12.0.0_dailymission_7ds_daily",
        "mha 12.0.0_dailymission_mha_daily",
        "mha 12.0.0_dailymission_jojo_daily",
        "mha 12.0.0_dailymission_opm_daily"
    }
    
    for _, mission in pairs(missions) do
        game:GetService("ReplicatedStorage").endpoints.client_to_server.request_claim_dailymission:InvokeServer(mission)
    end
    
    wait(15)
end

pcall(function()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
    game:GetService("ReplicatedStorage").endpoints.client_to_server.claim_daily_reward:InvokeServer()
end)


--#endregion

--#region NetCheck
function checkInterNet()
    warn("Auto Reconnect Loaded")
    while task.wait(5) do
        game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(a)
            if a.Name == 'ErrorPrompt' then
                task.wait(10)
                warn("Trying to Reconnect")
                game:GetService("TeleportService"):Teleport(8304191830, game.Players.LocalPlayer)
            end
        end)
    end
end
--#endregion

--#======================================================================


-----------------| 	Suscess Load Module |-------------------------

antiAFK()
warn("===========================================")
warn("")
print("          Load Script Suscess!!!!!        ")
print("                   VER ".. lunaxshopconfig.ver)
warn("")
warn("===========================================")


if game.PlaceId == 8304191830 then
	while wait(10) do
		spawn(function()
			user_and_update_setting()
			Main()
		end)
	end
	Dailyquest()
	DailyMission()
    repeat task.wait(0.5) until Workspace:WaitForChild(game.Players.LocalPlayer.Name)
    checkInterNet()
elseif game.PlaceId ~= 8304191830 then
    repeat task.wait(0.5) until Workspace:WaitForChild("_terrain")
    checkInterNet()
end

---------------------------------------------------------------------
