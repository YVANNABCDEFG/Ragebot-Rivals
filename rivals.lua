local repS = cloneref(game:GetService("ReplicatedStorage"))
local plrs = cloneref(game:GetService("Players"))
local runS = cloneref(game:GetService("RunService"))
local coreGui = cloneref(game:GetService("CoreGui"))
local uis = cloneref(game:GetService("UserInputService"))

local lplr = plrs.LocalPlayer

-- Pause propre pour laisser le jeu charger
task.wait(3)

local util, enum, ItemLibrary

pcall(function()
    local modules = repS:WaitForChild("Modules", 5)
    if modules then
        util = require(modules:WaitForChild("Utility", 3))
        enum = require(modules:WaitForChild("EnumLibrary", 3))
        ItemLibrary = require(modules:WaitForChild("ItemLibrary", 3))
    end
end)

getgenv().Config = {
    Enabled = true,
    FireRate = 0.0005,
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
-- NOCLIP & DESYNC PROTÉGÉS CONTRE LES ÉCRANS DE CHARGEMENT
--------------------------------------------------------------------------------
runS.Stepped:Connect(function()
    pcall(function()
        if getgenv().Config.DesyncEnabled and lplr.Character then
            local root = lplr.Character:FindFirstChild("HumanoidRootPart")
            if root and root.Position.Y > -300 then
                for _, part in ipairs(lplr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

local targetCache = { player = nil, root = nil, head = nil, time = 0 }
local CACHE_DURATION = 0.1
local currentDesyncCF = nil

local function isEnemy(player)
    if player == lplr then return false end
    local pTeam = player:GetAttribute("TeamID")
    local lTeam = lplr:GetAttribute("TeamID")
    if pTeam and lTeam then
        return pTeam ~= lTeam
    end
    return true
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

    for _, player in ipairs(plrs:GetPlayers()) do
        if isEnemy(player) then
            local pChar = player.Character
            if pChar then
                local pRoot = pChar:FindFirstChild("HumanoidRootPart")
                local pHead = pChar:FindFirstChild("Head")
                local pHum = pChar:FindFirstChildWhichIsA("Humanoid")
                if pRoot and pHead and pHum and pHum.Health > 0 then
                    local dist = (myRoot.Position - pRoot.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                        closestRoot = pRoot
                        closestHead = pHead
                    end
                end
            end
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
        local char = lplr.Character
        if not char then return end
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not myRoot or not hum or hum.Health <= 0 or myRoot.Position.Y < -300 then
            currentDesyncCF = nil
            return
        end

        local targetPlayer, targetRoot, targetHead = getClosestTarget()

        if targetRoot and targetHead then
            local desyncPos = targetRoot.Position - Vector3.new(0, getgenv().Config.UndergroundDepth, 0)
            currentDesyncCF = CFrame.lookAt(desyncPos, desyncPos + targetRoot.CFrame.LookVector)
        else
            currentDesyncCF = nil
        end

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
    end)
end)

--------------------------------------------------------------------------------
-- BOUCLE DE TIR SÉCURISÉE (ACTIVÉE UNIQUEMENT EN JEU)
--------------------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(getgenv().Config.FireRate)

        pcall(function()
            if not getgenv().Config.Enabled then return end

            local char = lplr.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then return end
            if char.HumanoidRootPart.Position.Y < -300 then return end -- Bloqué pendant les téléportations

            local targetPlayer, targetRoot, targetHead = getClosestTarget()
            if not targetPlayer or not targetHead or not targetRoot then return end

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

            local remotes = repS:FindFirstChild("Remotes")
            local replication = remotes and remotes:FindFirstChild("Replication")
            local fighterRemote = replication and replication:FindFirstChild("Fighter")
            local useItemRemote = fighterRemote and fighterRemote:FindFirstChild("UseItem")

            if useItemRemote and util and enum then
                useItemRemote:FireServer(
                    "Primary",
                    enum:ToEnum("StartShooting"),
                    cameradata,
                    nil
                )
                pcall(function()
                    useItemRemote:FireServer(
                        "Primary",
                        enum:ToEnum("StopShooting"),
                        nil,
                        nil
                    )
                end)
            end
        end)
    end
end)
