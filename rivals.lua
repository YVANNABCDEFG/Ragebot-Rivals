-- ══════════════════════════════════════════════════════════════
-- UTOPIA — MEGA SCRIPT (VERSION FIXÉE - MÊME LOGIQUE + VISUELS)
-- ══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- ══════════════════════════════════════════════════════════════
-- ✨ THÈME ROSE PASTEL
-- ══════════════════════════════════════════════════════════════
local PinkTheme = {
    FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
    Main = Color3.fromRGB(38, 28, 35),
    Outline = Color3.fromRGB(90, 65, 80),
    Font = Color3.fromRGB(245, 225, 235),
    FontGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 225)), ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 225, 235))}),
    Button = Color3.fromRGB(70, 50, 62),
    ButtonGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 55, 70)), ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 50, 62))}),
    ButtonOutline = Color3.fromRGB(110, 75, 95),
    ButtonFont = Color3.fromRGB(245, 225, 235),
    Element = Color3.fromRGB(45, 32, 40),
    ElementGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 37, 46)), ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 32, 40))}),
    ElementOutline = Color3.fromRGB(95, 68, 85),
    ElementFont = Color3.fromRGB(240, 220, 230),
    ElementFontDark = Color3.fromRGB(190, 170, 180),
    ElementFontLight = Color3.fromRGB(255, 235, 245),
    ElementBorder = Color3.fromRGB(105, 75, 92),
    Tab = Color3.fromRGB(50, 36, 45),
    TabGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 42, 52)), ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 36, 45))}),
    TabOutline = Color3.fromRGB(95, 68, 85),
    TabFont = Color3.fromRGB(220, 200, 215),
    ActiveTab = Color3.fromRGB(95, 60, 82),
    ActiveTabGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(108, 68, 92)), ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 60, 82))}),
    ActiveTabOutline = Color3.fromRGB(165, 115, 145),
    ActiveTabFont = Color3.fromRGB(255, 235, 245),
    Toggle = Color3.fromRGB(60, 42, 53),
    ToggleGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(68, 48, 60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 42, 53))}),
    ToggleOutline = Color3.fromRGB(100, 72, 88),
    ToggleFill = Color3.fromRGB(225, 135, 185),
    ToggleFillGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 150, 200)), ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 125, 175))}),
    ToggleFillOutline = Color3.fromRGB(250, 170, 215),
    Slider = Color3.fromRGB(60, 42, 53),
    SliderGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(68, 48, 60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 42, 53))}),
    SliderFill = Color3.fromRGB(225, 135, 185),
    SliderFillGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 150, 200)), ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 125, 175))}),
    SliderOutline = Color3.fromRGB(100, 72, 88),
    Dropdown = Color3.fromRGB(45, 32, 40),
    DropdownGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 37, 46)), ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 32, 40))}),
    DropdownOutline = Color3.fromRGB(95, 68, 85),
    DropdownFont = Color3.fromRGB(240, 220, 230),
    DropdownOption = Color3.fromRGB(52, 37, 46),
    DropdownOptionGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 42, 52)), ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 37, 46))}),
    DropdownOptionOutline = Color3.fromRGB(95, 68, 85),
    DropdownOptionFont = Color3.fromRGB(240, 220, 230),
    DropdownOptionActive = Color3.fromRGB(95, 60, 82),
    DropdownOptionActiveGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(108, 68, 92)), ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 60, 82))}),
    DropdownOptionActiveOutline = Color3.fromRGB(165, 115, 145),
    DropdownOptionActiveFont = Color3.fromRGB(255, 235, 245),
    Tooltip = Color3.fromRGB(45, 32, 40),
    TooltipGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 37, 46)), ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 32, 40))}),
    TooltipOutline = Color3.fromRGB(110, 75, 95),
    TooltipFont = Color3.fromRGB(240, 220, 230),
    Keybind = Color3.fromRGB(60, 42, 53),
    KeybindGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(68, 48, 60)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 42, 53))}),
    KeybindOutline = Color3.fromRGB(100, 72, 88),
    KeybindFont = Color3.fromRGB(240, 220, 230),
    KeybindFill = Color3.fromRGB(225, 135, 185),
    KeybindFillGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 150, 200)), ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 125, 175))}),
    KeybindFillOutline = Color3.fromRGB(250, 170, 215),
    KeybindFillFont = Color3.fromRGB(255, 235, 245),
    Window = Color3.fromRGB(32, 23, 29),
    WindowOutline = Color3.fromRGB(90, 65, 80),
    WindowGradient = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 27, 34)), ColorSequenceKeypoint.new(1, Color3.fromRGB(32, 23, 29))}),
    WindowFont = Color3.fromRGB(255, 230, 245),
    Title = Color3.fromRGB(255, 220, 240),
}

local Window = Library:CreateWindow({
    Title = "Utopia",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

pcall(function() Library:SetTheme(PinkTheme) end)

local Tabs = {
    Combat = Window:AddTab("Combat"),
    Visuals = Window:AddTab("Visuals"),
    Misc = Window:AddTab("Misc / Env"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}

local AimbotGroup = Tabs.Combat:AddLeftGroupbox("Aimbot")
local SilentAimGroup = Tabs.Combat:AddRightGroupbox("Silent Aim")

local ESPGroup = Tabs.Visuals:AddLeftGroupbox("ESP (Player Info)")
local FOVGroup = Tabs.Visuals:AddRightGroupbox("FOV Circles")

local LightingGroup = Tabs.Misc:AddLeftGroupbox("Lighting & Effects")
local SkyboxGroup = Tabs.Misc:AddRightGroupbox("Skybox & Weather")
local CharGroup = Tabs.Misc:AddLeftGroupbox("Character & Camera")

-- ══════════════════════════════════════════════════════════════
-- 🎯 TARGET INFO UI — REDESIGN (HP exacts)
-- ══════════════════════════════════════════════════════════════
local TargetInfoGUI = Instance.new("ScreenGui")
TargetInfoGUI.Name = "UtopiaTargetInfo"
TargetInfoGUI.ResetOnSpawn = false
TargetInfoGUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local TargetFrame = Instance.new("Frame")
TargetFrame.Size = UDim2.new(0, 230, 0, 90)
TargetFrame.Position = UDim2.new(0.5, -115, 0.5, 70)
TargetFrame.BackgroundColor3 = Color3.fromRGB(32, 22, 30)
TargetFrame.BackgroundTransparency = 0.05
TargetFrame.BorderSizePixel = 0
TargetFrame.Visible = false
TargetFrame.Parent = TargetInfoGUI

local TargetCorner = Instance.new("UICorner", TargetFrame)
TargetCorner.CornerRadius = UDim.new(0, 10)

local TargetGradient = Instance.new("UIGradient", TargetFrame)
TargetGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(48, 32, 44)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 18, 24))
})
TargetGradient.Rotation = 45

local UIStroke = Instance.new("UIStroke", TargetFrame)
UIStroke.Color = Color3.fromRGB(225, 135, 185)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.1

local UIStrokeGradient = Instance.new("UIGradient", UIStroke)
UIStrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 215)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 130, 200))
})
UIStrokeGradient.Rotation = 45

local TargetName = Instance.new("TextLabel", TargetFrame)
TargetName.Size = UDim2.new(1, -100, 0, 22)
TargetName.Position = UDim2.new(0, 10, 0, 8)
TargetName.BackgroundTransparency = 1
TargetName.Text = "Target"
TargetName.TextColor3 = Color3.fromRGB(255, 220, 240)
TargetName.Font = Enum.Font.GothamBold
TargetName.TextSize = 14
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.TextTruncate = Enum.TextTruncate.AtEnd

local TargetDist = Instance.new("TextLabel", TargetFrame)
TargetDist.Size = UDim2.new(0, 80, 0, 22)
TargetDist.Position = UDim2.new(1, -90, 0, 8)
TargetDist.BackgroundTransparency = 1
TargetDist.Text = "50m"
TargetDist.TextColor3 = Color3.fromRGB(210, 180, 200)
TargetDist.Font = Enum.Font.GothamMedium
TargetDist.TextSize = 11
TargetDist.TextXAlignment = Enum.TextXAlignment.Right

local HealthText = Instance.new("TextLabel", TargetFrame)
HealthText.Size = UDim2.new(1, -20, 0, 16)
HealthText.Position = UDim2.new(0, 10, 0, 32)
HealthText.BackgroundTransparency = 1
HealthText.Text = "100 / 100 HP"
HealthText.TextColor3 = Color3.fromRGB(255, 200, 230)
HealthText.Font = Enum.Font.GothamMedium
HealthText.TextSize = 11
HealthText.TextXAlignment = Enum.TextXAlignment.Left

local HealthBarBg = Instance.new("Frame", TargetFrame)
HealthBarBg.Size = UDim2.new(1, -20, 0, 9)
HealthBarBg.Position = UDim2.new(0, 10, 0, 56)
HealthBarBg.BackgroundColor3 = Color3.fromRGB(20, 14, 18)
HealthBarBg.BorderSizePixel = 0

local HBGorner = Instance.new("UICorner", HealthBarBg)
HBGorner.CornerRadius = UDim.new(0, 4)

local HealthBarFill = Instance.new("Frame", HealthBarBg)
HealthBarFill.Size = UDim2.new(1, 0, 1, 0)
HealthBarFill.BackgroundColor3 = Color3.fromRGB(225, 135, 185)
HealthBarFill.BorderSizePixel = 0

local HBFCorner = Instance.new("UICorner", HealthBarFill)
HBFCorner.CornerRadius = UDim.new(0, 4)

local HBGradient = Instance.new("UIGradient", HealthBarFill)
HBGradient.Color = ColorSequence.new(Color3.fromRGB(255, 140, 200), Color3.fromRGB(200, 110, 240))
HBGradient.Rotation = 0

-- ══════════════════════════════════════════════════════════════
-- 🌈 MODULE FOV GRADIENT ANIMÉ
-- ══════════════════════════════════════════════════════════════
local GradientFOV = {}
GradientFOV.__index = GradientFOV

function GradientFOV.new(opts)
    local self = setmetatable({}, GradientFOV)
    self.opts = opts
    self.rotation = 0
    self.segmentCount = 64
    self.segments = {}
    self.currentRadius = 0

    self.outline = Drawing.new("Circle")
    self.outline.Thickness = 2
    self.outline.Transparency = 1
    self.outline.Filled = false
    self.outline.Visible = false

    self.fill = Drawing.new("Circle")
    self.fill.Filled = true
    self.fill.Visible = false

    for i = 1, self.segmentCount do
        local seg = Drawing.new("Circle")
        seg.Filled = true
        seg.Radius = 3
        seg.Thickness = 1
        seg.Transparency = 1
        seg.Visible = false
        self.segments[i] = seg
    end

    return self
end

function GradientFOV:Update(dt)
    local show = self.opts.getShow and self.opts.getShow() or false
    if not show then
        self.outline.Visible = false
        self.fill.Visible = false
        for _, seg in ipairs(self.segments) do seg.Visible = false end
        return
    end

    local cam = Workspace.CurrentCamera
    if not cam then return end

    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local radiusValue = self.opts.getRadius()

    -- 🔧 MÊME FORMULE QUE L'ORIGINAL (avec abs pour éviter négatif)
    local focal = (vp.X / 2) / math.tan(math.rad(cam.FieldOfView) / 2)
    local pixelRadius = math.abs(focal * math.tan(math.rad(radiusValue)))

    -- Lerp smooth comme l'original
    if self.currentRadius == 0 then self.currentRadius = pixelRadius end
    self.currentRadius = self.currentRadius + (pixelRadius - self.currentRadius) * 0.2

    local col1 = self.opts.getColor1()
    local col2 = self.opts.getColor2()
    local showFill = self.opts.getShowFill and self.opts.getShowFill() or false
    local fillTrans = self.opts.getFillTransparency and self.opts.getFillTransparency() or 0.8

    -- Contour
    self.outline.Position = center
    self.outline.Radius = self.currentRadius
    self.outline.Color = col1
    self.outline.Visible = true

    if showFill then
        self.fill.Position = center
        self.fill.Radius = self.currentRadius
        self.fill.Color = col2
        self.fill.Transparency = fillTrans
        self.fill.Visible = true

        local speed = self.opts.getRotateSpeed and self.opts.getRotateSpeed() or 1.5
        self.rotation = (self.rotation + dt * speed) % (math.pi * 2)

        for i, seg in ipairs(self.segments) do
            local angle = ((i - 1) / self.segmentCount) * math.pi * 2
            local x = center.X + math.cos(angle) * self.currentRadius
            local y = center.Y + math.sin(angle) * self.currentRadius
            seg.Position = Vector2.new(x, y)
            local t = (1 - math.cos(angle + self.rotation)) / 2
            seg.Color = col1:Lerp(col2, t)
            seg.Radius = 3
            seg.Transparency = math.clamp(fillTrans * 0.6, 0, 1)
            seg.Visible = true
        end
    else
        self.fill.Visible = false
        for _, seg in ipairs(self.segments) do seg.Visible = false end
    end
end

-- ══════════════════════════════════════════════════════════════
-- AIMBOT — LOGIQUE ORIGINALE (fix wallcheck locked target uniquement)
-- ══════════════════════════════════════════════════════════════
local Aimbot = {}
Aimbot.__index = Aimbot

function Aimbot.new()
    local self = setmetatable({}, Aimbot)
    self.currentLockedTarget = nil
    self.fov = GradientFOV.new({
        getShow = function() return Toggles.aim_toggle and Toggles.aim_toggle.Value and Toggles.aim_showfov and Toggles.aim_showfov.Value end,
        getRadius = function() return Options.aim_fov and Options.aim_fov.Value or 200 end,
        getColor1 = function() return Options.aim_color and Options.aim_color.Value or Color3.fromRGB(255, 150, 200) end,
        getColor2 = function() return Options.aim_fill_color and Options.aim_fill_color.Value or Color3.fromRGB(200, 120, 240) end,
        getShowFill = function() return Toggles.aim_fill and Toggles.aim_fill.Value end,
        getFillTransparency = function() return Options.aim_fill_trans and Options.aim_fill_trans.Value or 0.8 end,
        getRotateSpeed = function() return Options.aim_rotate_speed and Options.aim_rotate_speed.Value or 1.5 end,
    })

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

    -- ✅ ACQUIRE — logique IDENTIQUE à l'original, sauf wallcheck sur locked target
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
                    -- 🐛 FIX : appliquer le wallcheck aussi sur la cible déjà lockée
                    if Toggles.aim_wall.Value then
                        local rp = RaycastParams.new()
                        rp.FilterType = Enum.RaycastFilterType.Exclude
                        rp.FilterDescendantsInstances = { LocalPlayer.Character, hum.Parent }
                        rp.IgnoreWater = true
                        local res = Workspace:Raycast(Camera.CFrame.Position, self.currentLockedTarget.Position - Camera.CFrame.Position, rp)
                        if not res then
                            return self.currentLockedTarget, hum.Parent
                        end
                        -- sinon on skip et on cherche une nouvelle cible
                    else
                        return self.currentLockedTarget, hum.Parent
                    end
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
            self.fov:Update(dt)
            TargetFrame.Visible = false
            return
        end

        self.fov:Update(dt)

        if not isAimHeld() then
            TargetFrame.Visible = false
            return
        end

        local target, targetChar = acquire()
        if not target then
            TargetFrame.Visible = false
            return
        end

        -- Update Target Info (esthétique seulement)
        local hum = targetChar and targetChar:FindFirstChild("Humanoid")
        if hum then
            TargetFrame.Visible = true
            TargetName.Text = targetChar.Name
            local hp = math.floor(hum.Health)
            local maxHp = math.floor(hum.MaxHealth)
            HealthBarFill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
            HealthText.Text = hp .. " / " .. maxHp .. " HP"
            TargetDist.Text = math.floor((target.Position - Camera.CFrame.Position).Magnitude) .. " studs"

            local ratio = hum.Health / hum.MaxHealth
            if ratio > 0.6 then
                HealthBarFill.BackgroundColor3 = Color3.fromRGB(225, 135, 185)
                HBGradient.Color = ColorSequence.new(Color3.fromRGB(255, 140, 200), Color3.fromRGB(200, 110, 240))
            elseif ratio > 0.3 then
                HealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 180, 100)
                HBGradient.Color = ColorSequence.new(Color3.fromRGB(255, 200, 100), Color3.fromRGB(255, 140, 80))
            else
                HealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 80, 100)
                HBGradient.Color = ColorSequence.new(Color3.fromRGB(255, 100, 120), Color3.fromRGB(220, 40, 80))
            end
            HealthText.TextColor3 = HealthBarFill.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.4)
        else
            TargetFrame.Visible = false
        end

        -- ⚙️ MOUVEMENT — EXACTEMENT IDENTIQUE À L'ORIGINAL
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
-- SILENT AIM — LOGIQUE ORIGINALE + FOV visuel (nouveau)
-- ══════════════════════════════════════════════════════════════
local SilentAim = {}
SilentAim.__index = SilentAim

function SilentAim.new()
    local self = setmetatable({}, SilentAim)
    self.isSimulating = false
    self.fov = GradientFOV.new({
        getShow = function() return Toggles.silent_toggle and Toggles.silent_toggle.Value and Toggles.silent_showfov and Toggles.silent_showfov.Value end,
        getRadius = function() return Options.silent_fov and Options.silent_fov.Value or 60 end,
        getColor1 = function() return Options.silent_fov_color and Options.silent_fov_color.Value or Color3.fromRGB(255, 120, 200) end,
        getColor2 = function() return Options.silent_fov_fill_color2 and Options.silent_fov_fill_color2.Value or Color3.fromRGB(140, 100, 255) end,
        getShowFill = function() return Toggles.silent_fill and Toggles.silent_fill.Value end,
        getFillTransparency = function() return Options.silent_fill_trans and Options.silent_fill_trans.Value or 0.8 end,
        getRotateSpeed = function() return Options.silent_rotate_speed and Options.silent_rotate_speed.Value or 2.0 end,
    })

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

    RunService.RenderStepped:Connect(function(dt)
        self.fov:Update(dt)
    end)

    return self
end
local _silentInst = nil
local function startSilent() if not _silentInst then _silentInst = SilentAim.new() end end

-- ══════════════════════════════════════════════════════════════
-- ESP AMÉLIORÉ (esthétique)
-- ══════════════════════════════════════════════════════════════
local espObjects = {}
local function removeESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        espObjects[player] = nil
    end
end

local function newESPCorner()
    local line = Drawing.new("Line")
    line.Thickness = 2
    line.Visible = false
    return line
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
                            health = Drawing.new("Text"),
                            distance = Drawing.new("Text"),
                            tracer = Drawing.new("Line"),
                            hpBg = Drawing.new("Square"),
                            hpFill = Drawing.new("Square"),
                            c1 = newESPCorner(), c2 = newESPCorner(),
                            c3 = newESPCorner(), c4 = newESPCorner(),
                            c5 = newESPCorner(), c6 = newESPCorner(),
                            c7 = newESPCorner(), c8 = newESPCorner(),
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
                        local color = Options.esp_color and Options.esp_color.Value or Color3.fromRGB(225, 135, 185)
                        local useCorners = Toggles.esp_corners and Toggles.esp_corners.Value

                        if Toggles.esp_box.Value and not useCorners then
                            esp.box.Size = Vector2.new(width, height)
                            esp.box.Position = Vector2.new(x, y)
                            esp.box.Color = color
                            esp.box.Thickness = 2
                            esp.box.Visible = true
                        else
                            esp.box.Visible = false
                        end

                        if Toggles.esp_box.Value and useCorners then
                            local cLen = math.min(width, height) * 0.2
                            local corners = {
                                {x, y, x + cLen, y, x, y, x, y + cLen},
                                {x + width, y, x + width - cLen, y, x + width, y, x + width, y + cLen},
                                {x, y + height, x + cLen, y + height, x, y + height, x, y + height - cLen},
                                {x + width, y + height, x + width - cLen, y + height, x + width, y + height, x + width, y + height - cLen},
                            }
                            local lines = {esp.c1, esp.c2, esp.c3, esp.c4, esp.c5, esp.c6, esp.c7, esp.c8}
                            for i, c in ipairs(corners) do
                                local hLine = lines[(i - 1) * 2 + 1]
                                local vLine = lines[(i - 1) * 2 + 2]
                                hLine.From = Vector2.new(c[1], c[2])
                                hLine.To = Vector2.new(c[3], c[4])
                                hLine.Color = color
                                hLine.Thickness = 2
                                hLine.Visible = true
                                vLine.From = Vector2.new(c[5], c[6])
                                vLine.To = Vector2.new(c[7], c[8])
                                vLine.Color = color
                                vLine.Thickness = 2
                                vLine.Visible = true
                            end
                        else
                            local lines = {esp.c1, esp.c2, esp.c3, esp.c4, esp.c5, esp.c6, esp.c7, esp.c8}
                            for _, ln in ipairs(lines) do ln.Visible = false end
                        end

                        if Toggles.esp_name.Value then
                            esp.name.Text = player.Name
                            esp.name.Size = 14
                            esp.name.Center = true
                            esp.name.Outline = true
                            esp.name.OutlineColor = Color3.fromRGB(0, 0, 0)
                            esp.name.Position = Vector2.new(top.X, y - 18)
                            esp.name.Color = Color3.fromRGB(255, 220, 240)
                            esp.name.Visible = true
                        else
                            esp.name.Visible = false
                        end

                        if Toggles.esp_distance and Toggles.esp_distance.Value then
                            local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                            esp.distance.Text = dist .. "m"
                            esp.distance.Size = 12
                            esp.distance.Center = true
                            esp.distance.Outline = true
                            esp.distance.OutlineColor = Color3.fromRGB(0, 0, 0)
                            esp.distance.Position = Vector2.new(top.X, y + height + 2)
                            esp.distance.Color = Color3.fromRGB(220, 180, 210)
                            esp.distance.Visible = true
                        else
                            esp.distance.Visible = false
                        end

                        if Toggles.esp_tracer.Value then
                            esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            esp.tracer.To = Vector2.new(top.X, y + height)
                            esp.tracer.Color = color
                            esp.tracer.Thickness = 1.5
                            esp.tracer.Visible = true
                        else
                            esp.tracer.Visible = false
                        end

                        if Toggles.esp_health.Value then
                            local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            local barH = height
                            local barW = 3
                            local barX = x - 7
                            local barY = y

                            esp.hpBg.Size = Vector2.new(barW, barH)
                            esp.hpBg.Position = Vector2.new(barX, barY)
                            esp.hpBg.Color = Color3.fromRGB(30, 20, 25)
                            esp.hpBg.Filled = true
                            esp.hpBg.Visible = true

                            local fillH = barH * hpRatio
                            esp.hpFill.Size = Vector2.new(barW, fillH)
                            esp.hpFill.Position = Vector2.new(barX, barY + (barH - fillH))
                            if hpRatio > 0.6 then
                                esp.hpFill.Color = Color3.fromRGB(100, 255, 150)
                            elseif hpRatio > 0.3 then
                                esp.hpFill.Color = Color3.fromRGB(255, 200, 90)
                            else
                                esp.hpFill.Color = Color3.fromRGB(255, 80, 100)
                            end
                            esp.hpFill.Filled = true
                            esp.hpFill.Visible = true

                            esp.health.Text = math.floor(hum.Health) .. "%"
                            esp.health.Size = 11
                            esp.health.Center = false
                            esp.health.Outline = true
                            esp.health.OutlineColor = Color3.fromRGB(0, 0, 0)
                            esp.health.Position = Vector2.new(barX - 22, barY + barH / 2 - 6)
                            esp.health.Color = Color3.fromRGB(255, 220, 240)
                            esp.health.Visible = true
                        else
                            esp.health.Visible = false
                            esp.hpBg.Visible = false
                            esp.hpFill.Visible = false
                        end
                    else
                        esp.box.Visible = false
                        esp.name.Visible = false
                        esp.tracer.Visible = false
                        esp.health.Visible = false
                        esp.distance.Visible = false
                        esp.hpBg.Visible = false
                        esp.hpFill.Visible = false
                        for _, k in ipairs({"c1","c2","c3","c4","c5","c6","c7","c8"}) do esp[k].Visible = false end
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
-- ENVIRONNEMENT (inchangé)
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
-- UI MENU
-- ══════════════════════════════════════════════════════════════

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
FOVGroup:AddLabel("── Aimbot FOV ──")
FOVGroup:AddToggle("aim_showfov", { Text = "Show Aimbot FOV", Default = true })
FOVGroup:AddLabel("Aimbot Outline Color"):AddColorPicker("aim_color", { Default = Color3.fromRGB(255, 150, 200) })
FOVGroup:AddToggle("aim_fill", { Text = "Aimbot FOV Fill", Default = false })
FOVGroup:AddLabel("Aimbot Gradient Color"):AddColorPicker("aim_fill_color", { Default = Color3.fromRGB(200, 120, 240) })
FOVGroup:AddSlider("aim_fill_trans", { Text = "Aimbot Fill Transparency", Default = 0.8, Min = 0, Max = 1, Rounding = 2, Compact = true })
FOVGroup:AddSlider("aim_rotate_speed", { Text = "Aimbot Wheel Speed", Default = 1.5, Min = 0, Max = 8, Rounding = 2, Compact = true })

FOVGroup:AddLabel("── Silent Aim FOV ──")
FOVGroup:AddToggle("silent_showfov", { Text = "Show Silent FOV", Default = true })
FOVGroup:AddLabel("Silent Outline Color"):AddColorPicker("silent_fov_color", { Default = Color3.fromRGB(255, 120, 200) })
FOVGroup:AddToggle("silent_fill", { Text = "Silent FOV Fill", Default = false })
FOVGroup:AddLabel("Silent Gradient Color"):AddColorPicker("silent_fov_fill_color2", { Default = Color3.fromRGB(140, 100, 255) })
FOVGroup:AddSlider("silent_fill_trans", { Text = "Silent Fill Transparency", Default = 0.8, Min = 0, Max = 1, Rounding = 2, Compact = true })
FOVGroup:AddSlider("silent_rotate_speed", { Text = "Silent Wheel Speed", Default = 2.0, Min = 0, Max = 8, Rounding = 2, Compact = true })

ESPGroup:AddToggle("esp_enabled", { Text = "Enable ESP", Default = false })
ESPGroup:AddToggle("esp_box", { Text = "Draw Boxes", Default = true })
ESPGroup:AddToggle("esp_corners", { Text = "Corner Brackets Style", Default = false })
ESPGroup:AddToggle("esp_name", { Text = "Draw Names", Default = true })
ESPGroup:AddToggle("esp_health", { Text = "Draw Health", Default = true })
ESPGroup:AddToggle("esp_distance", { Text = "Draw Distance", Default = true })
ESPGroup:AddToggle("esp_tracer", { Text = "Draw Tracers", Default = false })
ESPGroup:AddLabel("ESP Color"):AddColorPicker("esp_color", { Default = Color3.fromRGB(225, 135, 185) })

-- MISC UI (identique)
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
    if _aimbotInst and _aimbotInst.fov then
        pcall(function() _aimbotInst.fov.outline:Remove() end)
        pcall(function() _aimbotInst.fov.fill:Remove() end)
        for _, seg in ipairs(_aimbotInst.fov.segments) do pcall(function() seg:Remove() end) end
    end
    if _silentInst and _silentInst.fov then
        pcall(function() _silentInst.fov.outline:Remove() end)
        pcall(function() _silentInst.fov.fill:Remove() end)
        for _, seg in ipairs(_silentInst.fov.segments) do pcall(function() seg:Remove() end) end
    end
    for plr, _ in pairs(espObjects) do removeESP(plr) end
    ApplyUtopiaTexture(false)
    Library:Unload()
end)

Library:SetWatermarkVisibility(true)
Library:SetWatermark("Utopia 🌸")
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("UtopiaConfig")
SaveManager:SetFolder("UtopiaConfig/Configs")
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:BuildConfigSection(Tabs["UI Settings"])

pcall(function() Library:SetTheme(PinkTheme) end)
