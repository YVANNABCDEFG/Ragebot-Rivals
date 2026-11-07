-- ══════════════════════════════════════════════════════════════
-- UTOPIA — AIMBOT + SILENT AIM + MISC (VERSION CORRIGÉE)
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
    Misc = Window:AddTab("Misc / Env"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}

local AimbotGroup = Tabs.Combat:AddLeftGroupbox("Aimbot")
local SilentAimGroup = Tabs.Combat:AddRightGroupbox("Silent Aim")
local VisualsGroup = Tabs.Combat:AddLeftGroupbox("Visuals")

local LightingGroup = Tabs.Misc:AddLeftGroupbox("Lighting")
local SkyboxGroup = Tabs.Misc:AddRightGroupbox("Skybox & Weather")
local CharGroup = Tabs.Misc:AddLeftGroupbox("Character")

-- ══════════════════════════════════════════════════════════════
-- LOGIQUE DE L'AIMBOT
-- ══════════════════════════════════════════════════════════════
local Aimbot = {}
Aimbot.__index = Aimbot

local function _abCircle()
    local c = Drawing.new("Circle")
    c.Thickness = 1
    c.Transparency = 1
    c.Color = Color3.fromRGB(255, 255, 255)
    c.Filled = false
    c.Visible = false
    return c
end

function Aimbot.new()
    local self = setmetatable({}, Aimbot)
    self.target = nil
    self.fovCircle = _abCircle()
    self.fovFill = _abCircle()
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
        if not cam then return nil end
        local radius = Options.aim_fov and Options.aim_fov.Value or 150
        local vp = cam.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        
        if self.currentLockedTarget and self.currentLockedTarget.Parent then
            local hum = self.currentLockedTarget.Parent:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local sp, on = cam:WorldToViewportPoint(self.currentLockedTarget.Position)
                if on and (Vector2.new(sp.X, sp.Y) - center).Magnitude <= radius then
                    return self.currentLockedTarget
                end
            end
        end

        local best, bestScore = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if not char then continue end
            local hum = char:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            if LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then continue end
            
            local part = getTargetPart(char)
            if not part then continue end
            local screen, onScreen = cam:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            local score = (Vector2.new(screen.X, screen.Y) - center).Magnitude
            if score < bestScore then
                bestScore = score
                best = part
            end
        end
        self.currentLockedTarget = best
        return best
    end

    local function updateFov()
        local cam = Camera
        if not cam then return end
        local vp = cam.ViewportSize
        local radius = Options.aim_fov and Options.aim_fov.Value or 150
        local lerp = 0.2
        local focal = (vp.X / 2) / math.tan(math.rad(cam.FieldOfView) / 2)
        local pixelRadius = focal * math.tan(math.rad(radius))
        local circle = self.fovCircle
        local screenPos2D = Vector2.new(vp.X / 2, vp.Y / 2)
        
        circle.Radius = circle.Radius + (pixelRadius - circle.Radius) * lerp
        circle.Position = screenPos2D
        self.fovFill.Radius = circle.Radius
        self.fovFill.Position = screenPos2D
        circle.Color = Options.aim_color and Options.aim_color.Value or Color3.fromRGB(255, 0, 0)
        self.fovFill.Color = Options.aim_fill_color and Options.aim_fill_color.Value or Color3.fromRGB(255, 0, 0)
    end

    local function onRender()
        local toggle = Toggles.aim_toggle and Toggles.aim_toggle.Value
        local showFov = Toggles.aim_showfov and Toggles.aim_showfov.Value
        if not toggle then self.fovCircle.Visible = false; self.fovFill.Visible = false; return end
        updateFov()
        self.fovCircle.Visible = showFov
        self.fovFill.Visible = showFov and (Toggles.aim_fov_fill and Toggles.aim_fov_fill.Value or false)
        if self.fovFill.Visible then self.fovFill.Filled = true end
        if not isAimHeld() then return end
        local target = acquire()
        if not target then return end
        local sp3, on = Camera:WorldToViewportPoint(target.Position)
        if on then
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local dx = sp3.X - center.X
            local dy = sp3.Y - center.Y
            if math.abs(dx) < 2 and math.abs(dy) < 2 then return end
            local sensitivity = Options.aim_sens and Options.aim_sens.Value or 10
            local div = math.clamp(51 - sensitivity, 1, 50)
            local moveX = math.clamp(dx / div, -100, 100)
            local moveY = math.clamp(dy / div, -100, 100)
            pcall(function() mousemoverel(moveX, moveY) end)
        end
    end
    RunService.RenderStepped:Connect(onRender)
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
        local radius = Options.silent_fov and Options.silent_fov.Value or 150
        local screenCenter = Camera.ViewportSize / 2
        local closestTargetPart = nil
        local shortestDistance = radius
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local isTeammate = LocalPlayer.Team and player.Team == LocalPlayer.Team
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
                                local rayParams = RaycastParams.new()
                                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                                rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
                                local rayResult = Workspace:Raycast(Camera.CFrame.Position, targetPart.Position - Camera.CFrame.Position, rayParams)
                                if not rayResult then shortestDistance = distanceToCenter; closestTargetPart = targetPart end
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
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end

    RunService:BindToRenderStep("SilentAimSnap", Enum.RenderPriority.Camera.Value + 1, function()
        if not Toggles.silent_toggle.Value then return end
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then ExecuteSnap() end
    end)

    task.spawn(function()
        while true do
            task.wait(0.09)
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
        end
    end)
    return self
end

local _silentInst = nil
local function startSilent() if not _silentInst then _silentInst = SilentAim.new() end end

-- ══════════════════════════════════════════════════════════════
-- LOGIQUE MISC (ENVIRONNEMENT ET TEXTURES)
-- ══════════════════════════════════════════════════════════════

local OriginalSky = Lighting:FindFirstChildOfClass("Sky")
local OriginalAmbient = Lighting.Ambient
local OriginalBrightness = Lighting.Brightness
local OriginalShadows = Lighting.GlobalShadows
local CurrentCustomSky = nil

-- FONCTION POUR TÉLÉCHARGER LES IMAGES GITHUB ET LES CONVERTIR EN ID ROBLOX
local function downloadAsset(url, name)
    if not isfile or not writefile or not getcustomasset then return "" end
    local fileName = "Utopia_" .. name .. ".png"
    if not isfile(fileName) then
        local success, response = pcall(function() return game:HttpGet(url) end)
        if success then
            writefile(fileName, response)
        else
            return ""
        end
    end
    local success, assetId = pcall(function() return getcustomasset(fileName) end)
    if success then return assetId end
    return ""
end

-- SKYBOX IDS (Utopia)
local SkyIDs = {
    ["Default"] = nil,
    ["Night"] = {Up="rbxassetid://159454299", Dn="rbxassetid://159454296", Ft="rbxassetid://159454293", Bk="rbxassetid://159454286", Lf="rbxassetid://159454300", Rt="rbxassetid://159454288"},
    ["Space"] = {Up="rbxassetid://12064152", Dn="rbxassetid://12064128", Ft="rbxassetid://12063984", Bk="rbxassetid://12064107", Lf="rbxassetid://12064115", Rt="rbxassetid://12063992"},
    ["Utopia"] = {
        Up = downloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skyup.png", "skyup"),
        Dn = downloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skydn.png", "skydn"),
        Ft = downloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skyft.png", "skyft"),
        Bk = downloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skybk.png", "skybk"),
        Lf = downloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skylf.png", "skylf"),
        Rt = downloadAsset("https://raw.githubusercontent.com/YuriAlwaysOnRL/LegoPack/main/skyrt.png", "skyrt")
    }
}

-- TEXTURE UTOPIA ID
local UtopiaTextureId = downloadAsset("https://github.com/pashagamer23221-spec/texture/blob/main/texture.png?raw=true", "utopia_texture")
local OriginalTextures = {}

local function ApplyUtopiaTexture(enable)
    if not UtopiaTextureId or UtopiaTextureId == "" then return end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Texture") or obj:IsA("Decal") then
            if enable then
                if obj.Texture == "rbxassetid://7658055825" then
                    if not OriginalTextures[obj] then OriginalTextures[obj] = obj.Texture end
                    obj.Texture = UtopiaTextureId
                end
            else
                if OriginalTextures[obj] then
                    obj.Texture = OriginalTextures[obj]
                    OriginalTextures[obj] = nil
                end
            end
        end
    end
end

-- SYSTEME DE PLUIE ULTRA-VISIBLE
local RainFolder = Instance.new("Folder")
RainFolder.Name = "UtopiaRainFolder"
RainFolder.Parent = Workspace

local RainPart = Instance.new("Part")
RainPart.Name = "UtopiaRainPart"
RainPart.Size = Vector3.new(1500, 1, 1500)
RainPart.Transparency = 1
RainPart.Anchored = true
RainPart.CanCollide = false
RainPart.CanQuery = false
RainPart.CanTouch = false
RainPart.Parent = RainFolder

local RainEmitter = Instance.new("ParticleEmitter")
RainEmitter.Name = "RainEmitter"
RainEmitter.Texture = "rbxassetid://241876428" -- Texture de goutte
RainEmitter.Rate = 5000
RainEmitter.Lifetime = NumberRange.new(0.5, 1.5)
RainEmitter.Speed = NumberRange.new(100, 200)
RainEmitter.SpreadAngle = Vector2.new(2, 2)
RainEmitter.Rotation = NumberRange.new(0, 0)
RainEmitter.RotSpeed = NumberRange.new(0, 0)
RainEmitter.Transparency = NumberSequence.new(0.4)
RainEmitter.Size = NumberSequence.new(0.8) -- Gouttes plus grosses pour être vues
RainEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
RainEmitter.LightEmission = 1
RainEmitter.Acceleration = Vector3.new(0, -150, 0)
RainEmitter.Enabled = false
RainEmitter.Parent = RainPart

-- Fait suivre la pluie à la caméra
RunService.RenderStepped:Connect(function()
    if Toggles.rain_enabled and Toggles.rain_enabled.Value and Camera then
        -- Positionne la pluie 100 studs au-dessus de la caméra
        RainPart.CFrame = CFrame.new(Camera.CFrame.Position + Vector3.new(0, 100, 0))
        RainEmitter.Enabled = true
    else
        RainEmitter.Enabled = false
    end
end)

-- ══════════════════════════════════════════════════════════════
-- INTERFACE DU MENU (GUI)
-- ══════════════════════════════════════════════════════════════

-- COMBAT UI
do local t = AimbotGroup:AddToggle("aim_toggle", { Text = "Enable Aimbot", Default = false, Callback = function(val) if val then startAim() end end }); Toggles["aim_toggle"] = t end
do local t = AimbotGroup:AddLabel("Aimbot Keybind"):AddKeyPicker("aim_key", { Text = "Hold Key", Default = "MouseButton2", Mode = "Hold" }); Options["aim_key"] = t end
AimbotGroup:AddSlider("aim_sens", { Text = "Aim Sensitivity", Default = 10, Min = 1, Max = 50, Rounding = 0, Compact = true })
AimbotGroup:AddSlider("aim_fov", { Text = "Aimbot FOV", Default = 150, Min = 10, Max = 1000, Rounding = 0, Compact = true })
AimbotGroup:AddDropdown("aim_part", { Text = "Target Part", Default = "Head", Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"} })

do local t = SilentAimGroup:AddToggle("silent_toggle", { Text = "Enable Silent Aim", Default = false, Callback = function(val) if val then startSilent() end end }); Toggles["silent_toggle"] = t end
SilentAimGroup:AddSlider("silent_fov", { Text = "Silent FOV Radius", Default = 150, Min = 10, Max = 1000, Rounding = 0, Compact = true })
SilentAimGroup:AddDropdown("silent_part", { Text = "Target Part", Default = "Head", Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"} })

do local t = VisualsGroup:AddToggle("aim_showfov", { Text = "Show Aimbot FOV", Default = true }); Toggles["aim_showfov"] = t end
VisualsGroup:AddLabel("Aimbot FOV Color"):AddColorPicker("aim_color", { Default = Color3.fromRGB(255, 0, 0) })

-- MISC UI (ENVIRONNEMENT)
do 
    local t = LightingGroup:AddToggle("misc_fullbright", {
        Text = "Fullbright (No Shadows)",
        Default = false,
        Callback = function(val)
            if val then
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                Lighting.GlobalShadows = false
                Lighting.Brightness = 2
            else
                Lighting.Ambient = OriginalAmbient
                Lighting.GlobalShadows = OriginalShadows
                Lighting.Brightness = OriginalBrightness
            end
        end
    }); Toggles["misc_fullbright"] = t
end

LightingGroup:AddLabel("Ambient Color"):AddColorPicker("misc_ambient", { Default = Color3.fromRGB(128, 128, 128), Callback = function(color) Lighting.Ambient = color end })
LightingGroup:AddSlider("misc_time", { Text = "Time of Day", Default = 14, Min = 0, Max = 24, Rounding = 0, Suffix = "h", Callback = function(val) Lighting.ClockTime = val end })

SkyboxGroup:AddDropdown("misc_sky", {
    Text = "Select Skybox",
    Default = "Default",
    Values = {"Default", "Night", "Space", "Utopia"},
    Callback = function(val)
        if CurrentCustomSky then CurrentCustomSky:Destroy() end
        if val ~= "Default" and SkyIDs[val] and SkyIDs[val].Bk ~= "" then
            if OriginalSky then OriginalSky.Parent = nil end
            local newSky = Instance.new("Sky")
            newSky.SkyboxBk = SkyIDs[val].Bk
            newSky.SkyboxDn = SkyIDs[val].Dn
            newSky.SkyboxFt = SkyIDs[val].Ft
            newSky.SkyboxLf = SkyIDs[val].Lf
            newSky.SkyboxRt = SkyIDs[val].Rt
            newSky.SkyboxUp = SkyIDs[val].Up
            newSky.Parent = Lighting
            CurrentCustomSky = newSky
        else
            if OriginalSky then OriginalSky.Parent = Lighting end
        end
    end
})

do local t = SkyboxGroup:AddToggle("rain_enabled", { Text = "Enable Rain", Default = false }); Toggles["rain_enabled"] = t end
SkyboxGroup:AddSlider("rain_intensity", { Text = "Rain Intensity", Default = 5000, Min = 500, Max = 10000, Rounding = 0, Callback = function(val) RainEmitter.Rate = val end })
SkyboxGroup:AddLabel("Rain Color"):AddColorPicker("rain_color", { Default = Color3.fromRGB(200, 220, 255), Callback = function(color) RainEmitter.Color = ColorSequence.new(color) end })

do 
    local t = SkyboxGroup:AddToggle("utopia_texture", {
        Text = "Apply Utopia Texture (Replaces ID)",
        Default = false,
        Callback = function(val) ApplyUtopiaTexture(val) end
    }); Toggles["utopia_texture"] = t
end

-- CHARACTER UI
CharGroup:AddSlider("misc_ws", { Text = "WalkSpeed", Default = 16, Min = 16, Max = 200, Rounding = 0, Callback = function(val) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = val end end })
CharGroup:AddSlider("misc_jp", { Text = "JumpPower", Default = 50, Min = 50, Max = 200, Rounding = 0, Callback = function(val) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = val end end })
do local t = CharGroup:AddToggle("misc_infjump", { Text = "Infinite Jump", Default = false }); Toggles["misc_infjump"] = t end

UserInputService.JumpRequest:Connect(function()
    if Toggles.misc_infjump and Toggles.misc_infjump.Value then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- PARAMÈTRES UI
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload Script", function() 
    if CurrentCustomSky then CurrentCustomSky:Destroy() end
    if RainFolder then RainFolder:Destroy() end
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
