-- ==========================================
-- SÉCURITÉ DE CHARGEMENT & ANTI-CRASH
-- ==========================================
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local plrs = cloneref(game:GetService("Players"))
local lplr = plrs.LocalPlayer or plrs:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- Délai de sécurité pour laisser les PlayerScripts et GUIs natifs s'initialiser
task.wait(15)

local repS = cloneref(game:GetService("ReplicatedStorage"))
local runS = cloneref(game:GetService("RunService"))
local ws = cloneref(game:GetService("Workspace"))
local coreGui = cloneref(game:GetService("CoreGui"))
local TeleportService = game:GetService("TeleportService")

-- Chargement ultra-sécurisé des modules avec vérification d'existence
local util, enum, ItemLibrary
pcall(function()
    local modulesFolder = repS:WaitForChild("Modules", 15)
    if modulesFolder then
        util = require(modulesFolder:WaitForChild("Utility", 5))
        enum = require(modulesFolder:WaitForChild("EnumLibrary", 5))
        ItemLibrary = require(modulesFolder:WaitForChild("ItemLibrary", 5))
    end
end)

local FighterController, SpectateController, MatchmakingController
pcall(function()
    local playerScripts = lplr:WaitForChild("PlayerScripts", 15)
    local controllers = playerScripts and playerScripts:WaitForChild("Controllers", 15)
    if controllers then
        pcall(function() FighterController = require(controllers:WaitForChild("FighterController", 5)) end)
        pcall(function() SpectateController = require(controllers:WaitForChild("SpectateController", 5)) end)
        pcall(function() MatchmakingController = require(controllers:WaitForChild("MatchmakingController", 5)) end)
    end
end)

getgenv().Config = {
    Enabled = true,
    FireRate = 0.0002,
    DesyncEnabled = true,
    UndergroundDepth = 4,
    DesyncAngles = { Yaw = 180, Pitch = 44, Roll = 0 },
    DesyncJitter = 1,
    
    SelectedWeapons = {
        Primary = nil,
        Secondary = nil,
        Melee = nil,
        Utility = nil
    },

    AutoQueueEnabled = true,
    QueueType = "1v1",
    LobbyTimeout = 30
}

--------------------------------------------------------------------------------
-- CRÉATION DU GUI SÉLECTEUR D'ARMES À GAUCHE
--------------------------------------------------------------------------------
pcall(function()
    if coreGui:FindFirstChild("WeaponPickerGUI") then
        coreGui.WeaponPickerGUI:Destroy()
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeaponPickerGUI"
screenGui.Parent = coreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 300)
mainFrame.Position = UDim2.new(0, 15, 0.35, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(50, 50, 50)
uiStroke.Thickness = 1
uiStroke.Parent = mainFrame

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -16, 0, 28)
tabFrame.Position = UDim2.new(0, 8, 0, 8)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabList = Instance.new("UIListLayout")
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Padding = UDim.new(0, 4)
tabList.Parent = tabFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -16, 1, -48)
scrollFrame.Position = UDim2.new(0, 8, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local itemList = Instance.new("UIListLayout")
itemList.SortOrder = Enum.SortOrder.LayoutOrder
itemList.Padding = UDim.new(0, 4)
itemList.Parent = scrollFrame

itemList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, itemList.AbsoluteContentSize.Y + 10)
end)

local categories = {"Primary", "Secondary", "Melee", "Utility"}
local currentCategory = "Primary"
local categoryButtons = {}

local function RefreshWeaponList()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    if ItemLibrary and ItemLibrary.Items then
        for itemName, itemData in pairs(ItemLibrary.Items) do
            local itemClass = itemData.Class or (itemData.Slot and categories[itemData.Slot])
            if itemClass == currentCategory or (not itemClass and currentCategory == "Primary") then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -6, 0, 26)
                local isSelected = (getgenv().Config.SelectedWeapons[currentCategory] == itemName)
                btn.BackgroundColor3 = isSelected and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(35, 35, 35)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Text = "  " .. tostring(itemName)
                btn.Font = Enum.Font.GothamMedium
                btn.TextSize = 12
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.Parent = scrollFrame
                
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 4)
                btnCorner.Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    getgenv().Config.SelectedWeapons[currentCategory] = itemName
                    RefreshWeaponList()
                end)
            end
        end
    end
end

for idx, catName in ipairs(categories) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.25, -3, 1, 0)
    tabBtn.BackgroundColor3 = (currentCategory == catName) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.Text = catName:sub(1, 3)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 11
    tabBtn.Parent = tabFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabBtn
    
    categoryButtons[catName] = tabBtn
    
    tabBtn.MouseButton1Click:Connect(function()
        currentCategory = catName
        for name, button in pairs(categoryButtons) do
            button.BackgroundColor3 = (name == catName) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(40, 40, 40)
        end
        RefreshWeaponList()
    end)
end

RefreshWeaponList()

--------------------------------------------------------------------------------
-- AUTO-ÉQUIPEMENT SÉCURISÉ
--------------------------------------------------------------------------------
local function EquipSelectedWeapons()
    pcall(function()
        if not FighterController then return end
        local localFighter = FighterController.LocalFighter or (FighterController.WaitForLocalFighter and FighterController:WaitForLocalFighter())
        
        if localFighter then
            for category, weaponName in pairs(getgenv().Config.SelectedWeapons) do
                if weaponName then
                    if localFighter.EquipWeapon then
                        localFighter:EquipWeapon(weaponName)
                    elseif localFighter.EquipSlot then
                        localFighter:EquipSlot(category)
                    end
                end
            end
        end
    end)
end

lplr.CharacterAdded:Connect(function(char)
    pcall(function()
        char:WaitForChild("Humanoid", 10)
        task.wait(1)
        EquipSelectedWeapons()
    end)
end)

if lplr.Character then
    task.spawn(EquipSelectedWeapons)
end

--------------------------------------------------------------------------------
-- AUTO QUEUE & TIMEOUT LOBBY SÉCURISÉS
--------------------------------------------------------------------------------
local function isInLobby()
    local success, result = pcall(function()
        local isSpectating = SpectateController and SpectateController.CurrentDuelSubject ~= nil
        local char = lplr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        return not isSpectating and (not hum or hum.Health <= 0)
    end)
    return success and result
end

local function tryQueue()
    if not getgenv().Config.AutoQueueEnabled then return false end
    local success = false
    pcall(function()
        if isInLobby() and MatchmakingController and type(MatchmakingController.QueueInto) == "function" then
            MatchmakingController:QueueInto(getgenv().Config.QueueType)
            success = true
        end
    end)
    return success
end

task.spawn(function()
    local lobbyTimer = 0
    task.wait(6)

    tryQueue()

    while true do
        task.wait(1)
        
        if isInLobby() then
            lobbyTimer = lobbyTimer + 1
            
            if lobbyTimer % 4 == 0 then
                tryQueue()
            end

            if lobbyTimer >= getgenv().Config.LobbyTimeout then
                lobbyTimer = 0
                pcall(function()
                    TeleportService:Teleport(game.PlaceId, lplr)
                end)
            end
        else
            lobbyTimer = 0
        end
    end
end)

--------------------------------------------------------------------------------
-- NOCLIP & DESYNC SÉCURISÉS
--------------------------------------------------------------------------------
runS.Stepped:Connect(function()
    pcall(function()
        if getgenv().Config.DesyncEnabled and lplr.Character then
            for _, part in ipairs(lplr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

local targetCache = { player = nil, root = nil, head = nil, time = 0 }
local CACHE_DURATION = 0.1
local deflectionCache = { data = {}, time = 0 }
local DEFLECTION_CACHE_DURATION = 0.05
local deflecting = {}
local currentDesyncCF = nil

plrs.PlayerRemoving:Connect(function(player)
    deflecting[player] = nil
    deflectionCache.data[player] = nil
end)

local function updateDeflection()
    pcall(function()
        if not FighterController or not FighterController.Objects then return end
        local now = tick()
        if now - deflectionCache.time < DEFLECTION_CACHE_DURATION then
            for player, val in pairs(deflectionCache.data) do
                deflecting[player] = val
            end
            return
        end

        deflectionCache.data = {}
        for _, fighterObj in FighterController.Objects do
            local player = fighterObj.Player
            if not player then continue end
            if not fighterObj.Entity or not fighterObj.Entity:IsAlive() or fighterObj:Get("IsSpectating") then
                deflectionCache.data[player] = false
                continue
            end
            local equipped = fighterObj.EquippedItem
            local isKatana = equipped and equipped.ViewModel and equipped.ViewModel.Name == "Katana"
            local isDeflecting = false
            if isKatana then
                isDeflecting = (equipped._attack_cooldown and equipped._attack_cooldown > tick()) or false
            end
            deflectionCache.data[player] = isDeflecting
        end
        deflectionCache.time = now
        for player, val in pairs(deflectionCache.data) do
            deflecting[player] = val
        end
    end)
end

local function isEnemy(player)
    if player == lplr then return false end
    local success, result = pcall(function()
        local duel = SpectateController and SpectateController.CurrentDuelSubject
        local localDueler = duel and duel:GetDueler(lplr)
        local localTeam = localDueler and localDueler:Get("TeamID") or nil
        if localTeam and duel and duel.Duelers then
            for _, dueler in duel.Duelers do
                if dueler.Player == player then
                    local team = dueler:Get("TeamID")
                    return team ~= localTeam
                end
            end
        end
        local pTeam = player:GetAttribute("TeamID")
        local lTeam = lplr:GetAttribute("TeamID")
        if pTeam and lTeam then
            return pTeam ~= lTeam
        end
        return true
    end)
    return success and result
end

local function getClosestTarget()
    local now = tick()
    if now - targetCache.time < CACHE_DURATION then
        if targetCache.player and targetCache.root and targetCache.head then
            local pChar = targetCache.player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Head") then
                return targetCache.player, targetCache.root, targetCache.head
            end
        end
    end

    local char = lplr.Character
    if not char then return nil, nil, nil end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil, nil, nil end
    local closestPlayer, closestRoot, closestHead = nil, nil, nil
    local closestDist = 500

    for _, player in plrs:GetPlayers() do
        if not isEnemy(player) then continue end
        local pChar = player.Character
        if not pChar then continue end
        local pRoot = pChar:FindFirstChild("HumanoidRootPart")
        local pHead = pChar:FindFirstChild("Head")
        local pHum = pChar:FindFirstChildWhichIsA("Humanoid")
        if not (pRoot and pHead and pHum and pHum.Health > 0) then continue end
        local dist = (myRoot.Position - pRoot.Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestPlayer = player
            closestRoot = pRoot
            closestHead = pHead
        end
    end

    targetCache.player = closestPlayer
    targetCache.root = closestRoot
    targetCache.head = closestHead
    targetCache.time = now
    return closestPlayer, closestRoot, closestHead
end

runS.Heartbeat:Connect(function()
    pcall(function()
        updateDeflection()
        local targetPlayer, targetRoot, targetHead = getClosestTarget()

        if targetRoot and targetHead then
            local desyncPos = targetRoot.Position - Vector3.new(0, getgenv().Config.UndergroundDepth, 0)
            currentDesyncCF = CFrame.lookAt(desyncPos, desyncPos + targetRoot.CFrame.LookVector)
        else
            currentDesyncCF = nil
        end

        if lplr.Character then
            local myRoot = lplr.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local oldCF = myRoot.CFrame
                local oldVel = myRoot.Velocity
                local oldRotVel = myRoot.RotVelocity

                if getgenv().Config.DesyncEnabled then
                    local jitterOffset = Vector3.new(
                        (math.random() - 0.5) * getgenv().Config.DesyncJitter,
                        0,
                        (math.random() - 0.5) * getgenv().Config.DesyncJitter
                    )
                    local angleShift = CFrame.Angles(
                        math.rad(getgenv().Config.DesyncAngles.Pitch),
                        math.rad(getgenv().Config.DesyncAngles.Yaw),
                        math.rad(getgenv().Config.DesyncAngles.Roll)
                    )

                    myRoot.CFrame = (currentDesyncCF or oldCF) * angleShift + jitterOffset
                    myRoot.Velocity = oldVel
                    myRoot.RotVelocity = oldRotVel
                else
                    if currentDesyncCF then
                        myRoot.CFrame = currentDesyncCF
                    end
                end

                runS:BindToRenderStep("__restore", 101, function()
                    if myRoot then
                        myRoot.CFrame = oldCF
                        myRoot.Velocity = oldVel
                        myRoot.RotVelocity = oldRotVel
                    end
                    runS:UnbindFromRenderStep("__restore")
                end)
            end
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(getgenv().Config.FireRate)

        pcall(function()
            if not getgenv().Config.Enabled then return end

            local targetPlayer, targetRoot, targetHead = getClosestTarget()
            if not targetPlayer or not targetHead or not targetRoot then return end
            if deflecting[targetPlayer] then return end

            local myChar = lplr.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            if not FighterController or not FighterController.LocalFighter then return end

            local item = FighterController.LocalFighter.EquippedItem
            if not item then return end

            local originPos = currentDesyncCF and currentDesyncCF.Position or targetRoot.Position
            local targetPos = targetHead.Position
            local aimCF = CFrame.lookAt(originPos, targetPos)
            local targetCF = targetHead.CFrame

            local randomOffset = Vector3.new(
                (math.random() - 0.5) * 0.1,
                (math.random() - 0.5) * 0.1,
                (math.random() - 0.5) * 0.1
            )
            local aimedPos = targetPos + randomOffset
            local objSpaceHeadOffset = targetHead.CFrame:ToObjectSpace(CFrame.new(aimedPos))

            local cameradata = {}
            cameradata[utf8.char(1)] = {
                [utf8.char(0)] = util:EncodeCFrame(aimCF),
                [utf8.char(1)] = util:EncodeCFrame(targetCF),
                [utf8.char(2)] = targetHead,
                [utf8.char(3)] = util:EncodeCFrame(objSpaceHeadOffset)
            }

            repS.Remotes.Replication.Fighter.UseItem:FireServer(
                item:Get("ObjectID"),
                enum:ToEnum("StartShooting"),
                cameradata,
                nil
            )
            pcall(function()
                repS.Remotes.Replication.Fighter.UseItem:FireServer(
                    item:Get("ObjectID"),
                    enum:ToEnum("StopShooting"),
                    nil,
                    nil
                )
            end)
        end)
    end
end)
