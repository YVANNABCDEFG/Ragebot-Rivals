local repS = cloneref(game:GetService("ReplicatedStorage"))
local plrs = cloneref(game:GetService("Players"))
local runS = cloneref(game:GetService("RunService"))
local coreGui = cloneref(game:GetService("CoreGui"))

local lplr = plrs.LocalPlayer

-- ============================================================================
-- VERROU ABSOLU : ATTENTE QUE LE PERSONNAGE SOIT SPAWN ÉT A BOUGIÉ DE 1 STUD
-- ============================================================================
local function waitForCharacterMovement()
    print("En attente du spawn et du premier déplacement du personnage...")
    
    local char = lplr.Character or lplr.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 30)
    local hum = char:WaitForChild("Humanoid", 30)
    
    if not root or not hum then return end
    
    -- Attente que le joueur bouge d'au moins 1 stud depuis sa position initiale
    local startPos = root.Position
    while (root.Position - startPos).Magnitude < 1 do
        task.wait(0.1)
    end
    
    print("Personnage actif et en mouvement détecté ! Démarrage du script...")
end

waitForCharacterMovement()

-- Pause supplémentaire pour laisser le moteur réseau du jeu se stabiliser
task.wait(2)

--------------------------------------------------------------------------------
-- CHARGEMENT SÉCURISÉ DES MODULES (APRÈS LE DÉPLACEMENT)
--------------------------------------------------------------------------------
local util, enum, ItemLibrary, FighterController, SpectateController

pcall(function()
    local modules = repS:WaitForChild("Modules", 15)
    if modules then
        util = require(modules:WaitForChild("Utility", 10))
        enum = require(modules:WaitForChild("EnumLibrary", 10))
        ItemLibrary = require(modules:WaitForChild("ItemLibrary", 10))
    end
    
    local playerScripts = lplr:WaitForChild("PlayerScripts", 15)
    local controllers = playerScripts and playerScripts:WaitForChild("Controllers", 15)
    if controllers then
        pcall(function() FighterController = require(controllers:WaitForChild("FighterController", 10)) end)
        pcall(function() SpectateController = require(controllers:WaitForChild("SpectateController", 10)) end)
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
    }
}

--------------------------------------------------------------------------------
-- CRÉATION DU GUI SÉLECTEUR D'ARMES
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
-- AUTO-ÉQUIPEMENT
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

EquipSelectedWeapons()

--------------------------------------------------------------------------------
-- NOCLIP & DESYNC
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
        for _, fighterObj in pairs(FighterController.Objects) do
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
            for _, dueler in ipairs(duel.Duelers) do
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
        if targetCache.player and targetCache.
