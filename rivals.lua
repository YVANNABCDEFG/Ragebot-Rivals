-- ══════════════════════════════════════════════════════════════
-- UTOPIA — FULL SCRIPT (FIXED & READY)
-- ══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Chargement de l'UI Library
local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title = "Utopia",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab("Combat"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc / Env"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}

local AimbotGroup = Tabs.Combat:AddLeftGroupbox("Aimbot")
local SilentAimGroup = Tabs.Combat:AddRightGroupbox("Silent Aim")

local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP (Player Info)")
local FOVGroup = Tabs.Visuals:AddRightGroupbox("FOV Customization")

local LightingGroup = Tabs.Misc:AddLeftGroupbox("Lighting & Effects")
local SkyboxGroup = Tabs.Misc:AddRightGroupbox("Skybox & Weather")
local CharGroup = Tabs.Misc:AddLeftGroupbox("Character & Camera")

-- ══════════════════════════════════════════════════════════════
-- TARGET INFO UI (HITMARKER)
-- ══════════════════════════════════════════════════════════════
local TargetInfoGUI = Instance.new("ScreenGui")
TargetInfoGUI.Name = "UtopiaTargetInfo"
TargetInfoGUI.ResetOnSpawn = false
TargetInfoGUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local TargetFrame = Instance.new("Frame")
TargetFrame.Size = UDim2.new(0, 220, 0, 85)
TargetFrame.Position = UDim2.new(0.5, -110, 0.5, 100)
TargetFrame.BackgroundColor3 = Color3.fromRGB(25, 15, 20)
TargetFrame.BackgroundTransparency = 0.2
TargetFrame.BorderSizePixel = 0
TargetFrame.Visible = false
TargetFrame.Parent = TargetInfoGUI
Instance.new("UICorner", TargetFrame).CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", TargetFrame)
UIStroke.Color = Color3.fromRGB(255, 130, 170)
UIStroke.Thickness = 2

local TargetName = Instance.new("TextLabel", TargetFrame)
TargetName.Size = UDim2.new(1, 0, 0, 24)
TargetName.BackgroundTransparency = 1
TargetName.Text = "Target Name"
TargetName.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetName.Font = Enum.Font.GothamBold
TargetName.TextSize = 14

local TargetDist = Instance.new("TextLabel", TargetFrame)
TargetDist.Size = UDim2.new(1, 0, 0, 16)
TargetDist.Position = UDim2.new(0, 0, 0, 24)
TargetDist.BackgroundTransparency = 1
TargetDist.Text = "50 studs away"
TargetDist.TextColor3 = Color3.fromRGB(200, 170, 180)
TargetDist.Font = Enum.Font.Gotham
TargetDist.TextSize = 11

local TargetHPText = Instance.new("TextLabel", TargetFrame)
TargetHPText.Size = UDim2.new(1, 0, 0, 16)
TargetHPText.Position = UDim2.new(0, 0, 0, 44)
TargetHPText.BackgroundTransparency = 1
TargetHPText.Text = "HP: 100 / 100"
TargetHPText.TextColor3 = Color3.fromRGB(80, 240, 150)
TargetHPText.Font = Enum.Font.GothamBold
TargetHPText.TextSize = 11

local HealthBarBg = Instance.new("Frame", TargetFrame)
HealthBarBg.Size = UDim2.new(0.8, 0, 0, 6)
HealthBarBg.Position = UDim2.new(0.1, 0, 0, 66)
HealthBarBg.BackgroundColor3 = Color3.fromRGB(50, 30, 40)
HealthBarBg.BorderSizePixel = 0
Instance.new("UICorner", HealthBarBg).CornerRadius = UDim.new(1, 0)

local HealthBarFill = Instance.new("Frame", HealthBarBg)
HealthBarFill.Size = UDim2.new(1, 0, 1, 0)
HealthBarFill.BackgroundColor3 = Color3.fromRGB(80, 240, 150)
HealthBarFill.BorderSizePixel = 0
Instance.new("UICorner", HealthBarFill).CornerRadius = UDim.new(1, 0)

-- ══════════════════════════════════════════════════════════════
-- FOV VISUELS (Dégradé animé)
-- ══════════════════════════════════════════════════════════════
local aimFovFrame = Instance.new("Frame")
aimFovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
aimFovFrame.Position = UDim2.fromScale(0.5, 0.5)
aimFovFrame.Size = UDim2.fromOffset(0, 0) -- Taille initiale à 0
aimFovFrame.BackgroundColor3 = Color3.new(1, 1, 1)
aimFovFrame.BorderSizePixel = 0
aimFovFrame.Visible = false
aimFovFrame.ZIndex = 4
aimFovFrame.Parent = TargetInfoGUI
Instance.new("UICorner", aimFovFrame).CornerRadius = UDim.new(1, 0)

local aimFovGradient = Instance.new("UIGradient", aimFovFrame)
aimFovGradient.Color = ColorSequence.new(Color3.fromRGB(255, 130, 170), Color3.fromRGB(150, 100, 255))
aimFovGradient.Rotation = 0

local silentFovOutline = Instance.new("Frame")
silentFovOutline.AnchorPoint = Vector2.new(0.5, 0.5)
silentFovOutline.Position = UDim2.fromScale(0.5, 0.5)
silentFovOutline.Size = UDim2.fromOffset(0, 0) -- Taille initiale à 0
silentFovOutline.BackgroundTransparency = 1
silentFovOutline.Visible = false
silentFovOutline.ZIndex = 4
silentFovOutline.Parent = TargetInfoGUI
Instance.new("UICorner", silentFovOutline).CornerRadius = UDim.new(1, 0)
local silentFovStroke = Instance.new("UIStroke", silentFovOutline)
silentFovStroke.Color = Color3.fromRGB(80, 200, 255)
silentFovStroke.Thickness = 1.5
silentFovStroke.Transparency = 0.3

-- ══════════════════════════════════════════════════════════════
-- LOGIQUE DE L'AIMBOT
-- ══════════════════════════════════════════════════════════════
local Aimbot = {}
Aimbot.__index = Aimbot

function Aimbot.new()
    local self = setmetatable({}, Aimbot)
    self.currentLockedTarget = nil

    local function getTargetPart(character)
        local partName = Options.aim_part and Options.aim_part.Value or "Head"
        return character:FindFirstChild(partName) or character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    end

    local function isAimHeld()
        local mode = Toggles.aim_key and Toggles.aim_key.Mode or "Hold"
        local key = Options.aim_key and Options.aim_key.Value or "MouseButton2"
        if mode == "Always" then return true end
        if mode == "Toggle" then return Toggles.aim_key.Value end
        if key == "MouseButton2" or key == "MB2" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
        if key == "MouseButton1" or key == "MB1" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
        local success, keyCode = pcall(function() return Enum.KeyCode[key] end)
        if success and keyCode then return UserInputService:IsKeyDown(keyCode) end
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end

    local function acquire()
        local cam = Camera
        if not cam then return nil, nil end
        local radius = Options.aim_fov and Options.aim_fov.Value or 200
        local vp = cam.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        
        if self.currentLockedTarget and self.currentLockedTarget.Parent then
            local hum = self.currentLockedTarget.Parent:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local sp, on = cam:WorldToViewportPoint(self.currentLockedTarget.Position)
                if on and (Vector2.new(sp.X, sp.Y) - center).Magnitude <= radius then
                    return self.currentLockedTarget, hum.Parent
                end
            end
        end

        local best, bestScore, bestChar = nil, math.huge, nil
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if not char then continue end
            local hum = char:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            if Toggles.aim_team.Value and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then continue end
            
            local part = getTargetPart(char)
            if not part then continue end
            
            local sp, onScreen = cam:WorldToViewportPoint(part.Position)
            if not onScreen or sp.Z <= 0 then continue end
            
            local score = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if score > radius then continue end

            if Toggles.aim_wall.Value then
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Exclude
                rp.FilterDescendantsInstances = { LocalPlayer.Character, char }
                rp.IgnoreWater = true
                local res = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rp)
                if res then continue end
            end

            if score < bestScore then
                bestScore = score
                best = part
                bestChar = char
            end
        end
        self.currentLockedTarget = best
        return best, bestChar
    end

    RunService.RenderStepped:Connect(function(dt)
        local toggle = Toggles.aim_toggle and Toggles.aim_toggle.Value
        if not toggle then 
            aimFovFrame.Visible = false
            TargetFrame.Visible = false
            return 
        end
        
        local radius = Options.aim_fov.Value
        aimFovFrame.Size = UDim2.fromOffset(radius * 2, radius * 2)
        aimFovFrame.BackgroundTransparency = Options.aim_fill_trans.Value
        aimFovGradient.Color = ColorSequence.new(Options.aim_color1.Value, Options.aim_color2.Value)
        aimFovGradient.Rotation = (aimFovGradient.Rotation + dt * 80) % 360
        aimFovFrame.Visible = Toggles.aim_showfov.Value
        
        if not isAimHeld() then 
            TargetFrame.Visible = false
            return 
        end
        
        local target, targetChar = acquire()
        if not target then 
            TargetFrame.Visible = false
            return 
        end
        
        -- Update Target Info UI
        local hum = targetChar and targetChar:FindFirstChild("Humanoid")
        if hum then
            TargetFrame.Visible = true
            TargetName.Text = targetChar.Name
            TargetHPText.Text = string.format("HP: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
            HealthBarFill.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
            HealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), hum.Health / hum.MaxHealth)
            TargetDist.Text = string.format("%d studs", math.floor((target.Position - Camera.CFrame.Position).Magnitude))
        else
            TargetFrame.Visible = false
        end
        
        -- Logique de visée
        local targetSP = Camera:WorldToViewportPoint(target.Position)
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local delta = Vector2.new(targetSP.X, targetSP.Y) - center
        local dist = delta.Magnitude
        if dist < 1 then return end
        
        local speed = 0.1 + (Options.aim_smooth.Value * 0.95)
        speed *= Options.aim_sens.Value
        local norm = math.clamp(dt * 60, 0.1, 2.0)
        
        local moveX = math.clamp(delta.X * speed * norm, -Options.aim_max.Value, Options.aim_max.Value)
        local moveY = math.clamp(delta.Y * speed * norm, -Options.aim_max.Value, Options.aim_max.Value)
        
        pcall(function() mousemoverel(moveX, moveY) end)
    end)
    return self
end

local _aimbotInst = nil
local function startAim() if not _aimbotInst then _aimbotInst = Aimbot.new() end end

-- ══════════════════════════════════════════════════════════════
-- LOGIQUE DU SILENT AIM
-- ══════════════════════════════════════════════════════════════
local SilentAim = {}
SilentAim.__index = SilentAim

function SilentAim.new()
    local self = setmetatable({}, SilentAim)
    self.isSimulating = false

    local function GetClosestTarget()
        local radius = Options.silent_fov and Options.silent_fov.Value or 60
        local screenCenter = Camera.ViewportSize / 2
        local closestTargetPart = nil
        local shortestDistance = radius

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local isTeammate = Toggles.silent_team.Value and LocalPlayer.Team and player.Team == LocalPlayer.Team
                if not isTeammate and player.Character then
                    local char = player.Character
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    local partName = Options.silent_part and Options.silent_part.Value or "Head"
                    local targetPart = char:FindFirstChild(partName)

                    if humanoid and humanoid.Health > 0 and targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if distanceToCenter < shortestDistance then
                                local canSeeTarget = true
                                if Toggles.silent_wall.Value then
                                    local rayParams = RaycastParams.new()
                                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
                                    local rayResult = Workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, rayParams)
                                    if rayResult then canSeeTarget = false end
                                end
                                if canSeeTarget then
                                    shortestDistance = distanceToCenter
                                    closestTargetPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
        return closestTargetPart
    end

    local function ExecuteSnap()
        local target = GetClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Toggles.silent_toggle.Value then
            if not self.isSimulating then
                ExecuteSnap()
            end
        end
    end)

    task.spawn(function()
        while true do
            if Toggles.silent_toggle.Value and UserInputService:IsKeyDown(Enum.KeyCode.K) then
                local target = GetClosestTarget()
                if target then
                    ExecuteSnap()
                    local viewportSize = Camera.ViewportSize
                    
                    self.isSimulating = true
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(viewportSize.X / 2, viewportSize.Y / 2, 0, true, game, 1)
                        task.wait(0.02)
                        VirtualInputManager:SendMouseButtonEvent(viewportSize.X / 2, viewportSize.Y / 2, 0, false, game, 1)
                    end)
                    self.isSimulating = false
                end
            end
            task.wait(0.09)
        end
    end)
    
    -- Update Silent FOV Visual
    RunService.RenderStepped:Connect(function()
        if Toggles.silent_toggle.Value and Toggles.silent_showfov.Value then
            local radius = Options.silent_fov.Value
            silentFovOutline.Size = UDim2.fromOffset(radius * 2, radius * 2)
            silentFovOutline.Visible = true
            silentFovStroke.Color = Options.silent_color.Value
        else
            silentFovOutline.Visible = false
        end
    end)
    
    return self
end
local _silentInst = nil
local function startSilent() if not _silentInst then _silentInst = SilentAim.new() end end

-- ══════════════════════════════════════════════════════════════
-- ESP AMÉLIORÉ (Barre de vie + Distance)
-- ══════════════════════════════════════════════════════════════
local espObjects = {}
local function removeESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do pcall(function() obj:Remove() end) end
        espObjects[player] = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not Toggles.esp_enabled or not Toggles.esp_enabled.Value then
        for plr, _ in pairs(espObjects) do removeESP(plr) end
        return
    end

    local activePlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then continue end
                    
                    activePlayers[player] = true
                    if not espObjects[player] then
                        espObjects[player] = {
                            box = Drawing.new("Square"),
                            name = Drawing.new("Text"),
                            dist = Drawing.new("Text"),
                            healthBarBg = Drawing.new("Square"),
                            healthBarFill = Drawing.new("Square"),
                            tracer = Drawing.new("Line")
                        }
                    end
                    
                    local esp = espObjects[player]
                    local top, onScreen1 = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                    local bottom, onScreen2 = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    if onScreen1 or onScreen2 then
                        local height = math.abs(top.Y - bottom.Y)
                        local width = height / 2
                        local x = top.X - width / 2
                        local y = top.Y
                        
                        -- Box
                        if Toggles.esp_box.Value then
                            esp.box.Size = Vector2.new(width, height)
                            esp.box.Position = Vector2.new(x, y)
                            esp.box.Color = Options.esp_color.Value
                            esp.box.Thickness = 1
                            esp.box.Visible = true
                        else esp.box.Visible = false end
                        
                        -- Name & Dist
                        if Toggles.esp_name.Value then
                            esp.name.Text = player.Name
                            esp.name.Size = 14
                            esp.name.Center = true
                            esp.name.Outline = true
                            esp.name.Position = Vector2.new(top.X, y - 24)
                            esp.name.Color = Color3.fromRGB(255, 255, 255)
                            esp.name.Visible = true
                            
                            esp.dist.Text = string.format("%d studs", math.floor((hrp.Position - Camera.CFrame.Position).Magnitude))
                            esp.dist.Size = 12
                            esp.dist.Center = true
                            esp.dist.Outline = true
                            esp.dist.Position = Vector2.new(top.X, y - 10)
                            esp.dist.Color = Color3.fromRGB(200, 200, 200)
                            esp.dist.Visible = true
                        else 
                            esp.name.Visible = false 
                            esp.dist.Visible = false
                        end
                        
                        -- Health Bar
                        if Toggles.esp_health.Value then
                            esp.healthBarBg.Size = Vector2.new(3, height)
                            esp.healthBarBg.Position = Vector2.new(x - 6, y)
                            esp.healthBarBg.Color = Color3.fromRGB(0, 0, 0)
                            esp.healthBarBg.Visible = true
                            
                            local hpPercentage = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            esp.healthBarFill.Size = Vector2.new(3, height * hpPercentage)
                            esp.healthBarFill.Position = Vector2.new(x - 6, y + height - (height * hpPercentage))
                            esp.healthBarFill.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), hpPercentage)
                            esp.healthBarFill.Visible = true
                        else 
                            esp.healthBarBg.Visible = false
                            esp.healthBarFill.Visible = false
                        end
                        
                        -- Tracer
                        if Toggles.esp_tracer.Value then
                            esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            esp.tracer.To = Vector2.new(top.X, y + height)
                            esp.tracer.Color = Options.esp_color.Value
                            esp.tracer.Thickness = 1
                            esp.tracer.Visible = true
                        else esp.tracer.Visible = false end
                    else
                        esp.box.Visible = false; esp.name.Visible = false; esp.dist.Visible = false
                        esp.healthBarBg.Visible = false; esp.healthBarFill.Visible = false; esp.tracer.Visible = false
                    end
                end
            end
        end
    end
    
    for plr, _ in pairs(espObjects) do
        if not activePlayers[plr] then removeESP(plr) end
    end
end)

-- ══════════════════════════════════════════════════════════════
-- ENVIRONNEMENT & TEXTURE UTOPIA
-- ══════════════════════════════════════════════════════════════
local OriginalSky = Lighting:FindFirstChildOfClass("Sky")
local OriginalAmbient = Lighting.Ambient
local OriginalBrightness = Lighting.Brightness
local OriginalShadows = Lighting.GlobalShadows
local CurrentCustomSky = nil
local OriginalTextures = {}

local function getOrDownloadAsset(url, name)
    if not (isfile and writefile and getcustomasset) then return "" end
    local fileName = "Utopia_" .. name .. ".png"
    if not isfile(fileName) then
        local success, response = pcall(function() return game:HttpGet(url) end)
        if success then pcall(writefile, fileName, response) else return "" end
    end
    local success, assetId = pcall(function() return getcustomasset(fileName) end)
    if success then return assetId end
    return ""
end

local function ApplyUtopiaTexture(enable)
    if enable then
        local UtopiaTextureId = getOrDownloadAsset("https://github.com/pashagamer23221-spec/texture/blob/main/texture.png?raw=true", "utopia_texture")
        if UtopiaTextureId == "" then return end
        task.spawn(function()
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    if obj.Texture == "rbxassetid://7658055825" then
                        if not OriginalTextures[obj] then OriginalTextures[obj] = obj.Texture end
                        obj.Texture = UtopiaTextureId
                    end
                end
                task.wait()
            end
        end)
    else
        for obj, originalTexture in pairs(OriginalTextures) do
            if obj and obj.Parent then obj.Texture = originalTexture end
        end
        OriginalTextures = {}
    end
end

-- PLUIE
local RainFolder = Instance.new("Folder", Workspace)
RainFolder.Name = "UtopiaRainFolder"
local RainPart = Instance.new("Part", RainFolder)
RainPart.Size = Vector3.new(1500, 1, 1500)
RainPart.Transparency = 1
RainPart.Anchored = true
RainPart.CanCollide = false
RainPart.CanQuery = false
RainPart.CanTouch = false

local RainEmitter = Instance.new("ParticleEmitter", RainPart)
RainEmitter.Texture = "rbxassetid://241876428"
RainEmitter.Lifetime = NumberRange.new(0.8, 1.2)
RainEmitter.Rate = 3000
RainEmitter.Speed = NumberRange.new(80, 120)
RainEmitter.SpreadAngle = Vector2.new(2, 2)
RainEmitter.Rotation = NumberRange.new(0, 0)
RainEmitter.RotSpeed = NumberRange.new(0, 0)
RainEmitter.Transparency = NumberSequence.new(0.4)
RainEmitter.Size = NumberSequence.new(0.6)
RainEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
RainEmitter.LightEmission = 1
RainEmitter.Acceleration = Vector3.new(0, -200, 0)
RainEmitter.Enabled = false

RunService.RenderStepped:Connect(function()
    if Toggles.rain_enabled and Toggles.rain_enabled.Value and Camera then
        RainPart.CFrame = Camera.CFrame * CFrame.new(0, 40, 0)
        RainEmitter.Enabled = true
    else
        RainEmitter.Enabled = false
    end
end)

-- FOG & EFFECTS
local CC = Instance.new("ColorCorrectionEffect", Lighting)
CC.Name = "UtopiaCC"
CC.Enabled = false
local function UpdateFog()
    if Toggles.fog_enabled and Toggles.fog_enabled.Value then
        Lighting.FogEnd = Options.fog_end.Value
        Lighting.FogStart = Options.fog_start.Value
    else
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    end
end

local noclipConn, flyConn = nil, nil
local function toggleNoclip(state)
    if noclipConn then noclipConn:Disconnect() end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                end
            end
        end)
    end
end

local function toggleFly(state)
    if flyConn then flyConn:Disconnect() end
    if state then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyConn = RunService.RenderStepped:Connect(function()
                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end
                bv.Velocity = moveDir * 50
            end)
            task.delay(0.1, function() if not Toggles.fly_enabled.Value and bv then bv:Destroy() end end)
        end
    end
end

-- ══════════════════════════════════════════════════════════════
-- INTERFACE DU MENU (GUI)
-- ══════════════════════════════════════════════════════════════

-- COMBAT UI
AimbotGroup:AddToggle("aim_toggle", { Text = "Enable Aimbot", Default = false, Callback = function(val) if val then startAim() end end })
AimbotGroup:AddLabel("Aimbot Keybind"):AddKeyPicker("aim_key", { Text = "Hold Key", Default = "MouseButton2", Mode = "Hold" })
AimbotGroup:AddSlider("aim_smooth", { Text = "Smoothness", Default = 0.85, Min = 0, Max = 1, Rounding = 2, Compact = true })
AimbotGroup:AddSlider("aim_sens", { Text = "Sensitivity", Default = 1.0, Min = 0.2, Max = 2.0, Rounding = 2, Compact = true })
AimbotGroup:AddSlider("aim_max", { Text = "Max Pixel / Frame", Default = 150, Min = 20, Max = 400, Rounding = 0, Compact = true })
AimbotGroup:AddSlider("aim_fov", { Text = "FOV Radius", Default = 200, Min = 30, Max = 500, Rounding = 0, Compact = true })
AimbotGroup:AddToggle("aim_wall", { Text = "Wall Check", Default = true })
AimbotGroup:AddToggle("aim_team", { Text = "Team Check", Default = true })
AimbotGroup:AddDropdown("aim_part", { Text = "Aim Part", Default = "Head", Values = {"Head", "HumanoidRootPart", "UpperTorso"} })

SilentAimGroup:AddToggle("silent_toggle", { Text = "Enable Silent Aim", Default = false, Callback = function(val) if val then startSilent() end end })
SilentAimGroup:AddSlider("silent_fov", { Text = "Silent FOV Radius", Default = 60, Min = 10, Max = 1000, Rounding = 0, Compact = true })
SilentAimGroup:AddToggle("silent_wall", { Text = "Wall Check", Default = true })
SilentAimGroup:AddToggle("silent_team", { Text = "Team Check", Default = true })
SilentAimGroup:AddDropdown("silent_part", { Text = "Target Part", Default = "Head", Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"} })

-- VISUALS UI
FOVGroup:AddToggle("aim_showfov", { Text = "Show Aimbot FOV", Default = true })
FOVGroup:AddLabel("Aimbot Color 1"):AddColorPicker("aim_color1", { Default = Color3.fromRGB(255, 130, 170) })
FOVGroup:AddLabel("Aimbot Color 2"):AddColorPicker("aim_color2", { Default = Color3.fromRGB(150, 100, 255) })
FOVGroup:AddSlider("aim_fill_trans", { Text = "Aimbot Fill Transparency", Default = 0.8, Min = 0, Max = 1, Rounding = 2, Compact = true })
FOVGroup:AddToggle("silent_showfov", { Text = "Show Silent FOV", Default = true })
FOVGroup:AddLabel("Silent FOV Color"):AddColorPicker("silent_color", { Default = Color3.fromRGB(80, 200, 255) })

ESPGroup:AddToggle("esp_enabled", { Text = "Enable ESP", Default = false })
ESPGroup:AddToggle("esp_box", { Text = "Draw Boxes", Default = true })
ESPGroup:AddToggle("esp_name", { Text = "Draw Names & Dist", Default = true })
ESPGroup:AddToggle("esp_health", { Text = "Draw Health Bar", Default = true })
ESPGroup:AddToggle("esp_tracer", { Text = "Draw Tracers", Default = false })
ESPGroup:AddLabel("ESP Color"):AddColorPicker("esp_color", { Default = Color3.fromRGB(255, 130, 170) })

-- MISC UI
LightingGroup:AddToggle("misc_fullbright", { Text = "Fullbright (No Shadows)", Default = false, Callback = function(val)
    if val then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255); Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255); Lighting.GlobalShadows = false; Lighting.Brightness = 2
    else
        Lighting.Ambient = OriginalAmbient; Lighting.GlobalShadows = OriginalShadows; Lighting.Brightness = OriginalBrightness
    end
end })
LightingGroup:AddLabel("Ambient Color"):AddColorPicker("misc_ambient", { Default = Color3.fromRGB(128, 128, 128), Callback = function(color) Lighting.Ambient = color end })
LightingGroup:AddSlider("misc_time", { Text = "Time of Day", Default = 14, Min = 0, Max = 24, Rounding = 0, Callback = function(val) Lighting.ClockTime = val end })
LightingGroup:AddToggle("fog_enabled", { Text = "Enable Fog", Default = false, Callback = function() UpdateFog() end })
LightingGroup:AddSlider("fog_start", { Text = "Fog Start", Default = 0, Min = 0, Max = 1000, Rounding = 0, Callback = function() UpdateFog() end })
LightingGroup:AddSlider("fog_end", { Text = "Fog End", Default = 500, Min = 50, Max = 5000, Rounding = 0, Callback = function() UpdateFog() end })
LightingGroup:AddToggle("cc_enabled", { Text = "Color Correction Effect", Default = false, Callback = function(val) CC.Enabled = val end })
LightingGroup:AddSlider("cc_sat", { Text = "Saturation", Default = 0, Min = -1, Max = 1, Rounding = 2, Callback = function(val) CC.Saturation = val end })

SkyboxGroup:AddDropdown("misc_sky", {
    Text = "Select Skybox", Default = "Default", Values = {"Default", "Utopia"},
    Callback = function(val)
        if CurrentCustomSky then CurrentCustomSky:Destroy() end
        if val == "Utopia" then
            local up = getOrDownloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skyup.png", "skyup")
            local dn = getOrDownloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skydn.png", "skydn")
            local ft = getOrDownloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skyft.png", "skyft")
            local bk = getOrDownloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skybk.png", "skybk")
            local lf = getOrDownloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skylf.png", "skylf")
            local rt = getOrDownloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skyrt.png", "skyrt")
            if up ~= "" then
                if OriginalSky then OriginalSky.Parent = nil end
                local newSky = Instance.new("Sky")
                newSky.SkyboxUp = up; newSky.SkyboxDn = dn; newSky.SkyboxFt = ft
                newSky.SkyboxBk = bk; newSky.SkyboxLf = lf; newSky.SkyboxRt = rt
                newSky.Parent = Lighting
                CurrentCustomSky = newSky
            end
        else
            if OriginalSky then OriginalSky.Parent = Lighting end
        end
    end
})
SkyboxGroup:AddToggle("rain_enabled", { Text = "Enable Rain", Default = false })
SkyboxGroup:AddSlider("rain_intensity", { Text = "Rain Rate", Default = 3000, Min = 100, Max = 5000, Rounding = 0, Callback = function(val) RainEmitter.Rate = val end })
SkyboxGroup:AddLabel("Rain Color"):AddColorPicker("rain_color", { Default = Color3.fromRGB(200, 220, 255), Callback = function(color) RainEmitter.Color = ColorSequence.new(color) end })
SkyboxGroup:AddToggle("utopia_texture", { Text = "Apply Utopia Texture", Default = false, Callback = function(val) ApplyUtopiaTexture(val) end })

CharGroup:AddSlider("cam_fov", { Text = "Camera FOV", Default = 70, Min = 30, Max = 120, Rounding = 0, Callback = function(val) Camera.FieldOfView = val end })
CharGroup:AddSlider("misc_ws", { Text = "WalkSpeed", Default = 16, Min = 16, Max = 200, Rounding = 0, Callback = function(val) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end end })
CharGroup:AddSlider("misc_jp", { Text = "JumpPower", Default = 50, Min = 50, Max = 200, Rounding = 0, Callback = function(val) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = val end end })
CharGroup:AddToggle("misc_infjump", { Text = "Infinite Jump", Default = false })
CharGroup:AddToggle("noclip_enabled", { Text = "Noclip", Default = false, Callback = function(val) toggleNoclip(val) end })
CharGroup:AddToggle("fly_enabled", { Text = "Fly", Default = false, Callback = function(val) toggleFly(val) end })

UserInputService.JumpRequest:Connect(function()
    if Toggles.misc_infjump and Toggles.misc_infjump.Value then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload Script", function() 
    if CurrentCustomSky then CurrentCustomSky:Destroy() end
    if RainFolder then RainFolder:Destroy() end
    if CC then CC:Destroy() end
    if TargetInfoGUI then TargetInfoGUI:Destroy() end
    if noclipConn then noclipConn:Disconnect() end
    if flyConn then flyConn:Disconnect() end
    ApplyUtopiaTexture(false)
    Library:Unload() 
end)

Library:SetWatermarkVisibility(true)
Library:SetWatermark("Utopia")
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("UtopiaConfig")
SaveManager:SetFolder("UtopiaConfig/Configs")
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:BuildConfigSection(Tabs["UI Settings"])
