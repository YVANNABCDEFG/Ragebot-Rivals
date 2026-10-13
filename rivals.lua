-- ==========================================
-- SÉCURITÉ DE CHARGEMENT & ANTI-CRASH
-- ==========================================
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local plrs = cloneref(game:GetService("Players"))
local lplr = plrs.LocalPlayer or plrs:GetPropertyChangedSignal("LocalPlayer"):Wait()

-- Délai de sécurité pour laisser les PlayerScripts et GUIs natifs s'initialiser
task.wait(5)

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
