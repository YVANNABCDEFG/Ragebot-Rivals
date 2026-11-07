--[[
    UTOPIA v17.0 — MATCHED WORKING LOGIC
    LocalScript | StarterPlayer > StarterPlayerScripts
    
    Press Z to toggle aim | RightShift = menu | ALT = drag
]]

local Players = game:GetService("Players")
local WS      = game:GetService("Workspace")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local Tween   = game:GetService("TweenService")
local HS      = game:GetService("HttpService")
local Lighting= game:GetService("Lighting")

local LP     = Players.LocalPlayer
local Mouse  = LP:GetMouse()

local SLOT = "Utopia_v17"
if shared[SLOT] then pcall(shared[SLOT]); shared[SLOT] = nil end
local active = true
local guiRef = nil

local Orig = {
    Ambient = Lighting.Ambient, Outdoor = Lighting.OutdoorAmbient,
    Gravity = WS.Gravity, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
    FogColor = Lighting.FogColor,
    FOV = WS.CurrentCamera and WS.CurrentCamera.FieldOfView or 70, Materials = {},
}

local Config = {
    Enabled = false,  -- OFF par défaut, toggle avec Z (comme le working script)
    RequireRMB = false,  -- Si false, aim dès que Enabled = true
    ToggleKey = Enum.KeyCode.Z,
    Smoothness = 0.7,  -- 0-1 : 0=smooth, 1=snap
    Sensitivity = 1.0,
    Prediction = 0.14,
    FOVRadius = 150,
    ShowFOV = true, WallCheck = true, TeamCheck = true,
    TargetPart = "Head", TargetPriority = "FOV",
    FOVColor = Color3.fromRGB(255, 80, 80),
    FOVPulse = true,
    Triggerbot = false, FireRate = 0.05,
    CrosshairColor = Color3.fromRGB(147,51,234),
    CrosshairColorScan = Color3.fromRGB(255,200,90),
    CrosshairColorLock = Color3.fromRGB(255,90,110),
    CrosshairStyle = "Plus", ShowCrosshair = true,
    BracketColor = Color3.fromRGB(255,90,110), ShowBrackets = true,
    ShowWatermark = true, ShowTargetInfo = true, ShowMinimap = true,
    Notifications = true, SoundEffects = true, ShowStats = true, Hitmarker = true,
    ThemeName = "Utopia", AccentColor = Color3.fromRGB(147,51,234),
    AccentColor2 = Color3.fromRGB(80,200,255), UIScale = 1.0,
    ToggleMenuKey = Enum.KeyCode.RightShift, DragModifier = Enum.KeyCode.LeftAlt,
    Fullbright = false, WalkSpeed = 16, JumpPower = 50, Gravity = 196.2,
    AmbientColor = Lighting.Ambient, FogEnabled = false, FogColor = Color3.fromRGB(100,100,100),
    FogStart = 0, FogEnd = 1000, TimeOfDay = 14, CameraFOV = 70, ZoomOnRMB = false, ZoomFOV = 40,
    AutoLoadConfig = "", AutoSaveConfig = "", Binds = {},
}

local hasFS = (typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function")

local function ser(v)
    if typeof(v) == "Color3" then return {__c3 = {v.R, v.G, v.B}} end
    if typeof(v) == "EnumItem" then return {__e = tostring(v)} end
    if type(v) == "table" then local o = {}; for k, vv in pairs(v) do o[k] = ser(vv) end; return o end
    return v
end
local function deser(v)
    if type(v) == "table" then
        if v.__c3 then return Color3.new(v.__c3[1], v.__c3[2], v.__c3[3]) end
        if v.__e then
            local parts = {}
            for p in string.gmatch(v.__e, "[^%.]+") do table.insert(parts, p) end
            if parts[1] == "Enum" and parts[2] and parts[3] then
                local et = Enum[parts[2]]; if et then return et[parts[3]] end
            end
            return v
        end
        local o = {}; for k, vv in pairs(v) do o[k] = deser(vv) end; return o
    end
    return v
end

local GLOBAL_FILE = "Utopia_globals.json"
local function loadGlobals()
    if not hasFS or not isfile(GLOBAL_FILE) then return end
    local ok, json = pcall(readfile, GLOBAL_FILE); if not ok then return end
    local ok2, data = pcall(function() return HS:JSONDecode(json) end); if not ok2 then return end
    data = deser(data)
    for k, v in pairs(data) do if Config[k] ~= nil then Config[k] = v end end
end
local function saveGlobals()
    if not hasFS then return end
    local data = { AutoLoadConfig = Config.AutoLoadConfig, AutoSaveConfig = Config.AutoSaveConfig, ThemeName = Config.ThemeName, UIScale = Config.UIScale, ToggleMenuKey = Config.ToggleMenuKey, DragModifier = Config.DragModifier }
    pcall(writefile, GLOBAL_FILE, HS:JSONEncode(ser(data)))
end
loadGlobals()

local Themes = {
    Utopia   = {accent=Color3.fromRGB(147,51,234), accent2=Color3.fromRGB(80,200,255), bg=Color3.fromRGB(14,14,20), bgHeader=Color3.fromRGB(18,18,26), bgRow=Color3.fromRGB(22,22,30), track=Color3.fromRGB(34,34,48), text=Color3.fromRGB(228,230,240), sub=Color3.fromRGB(130,135,155), dim=Color3.fromRGB(80,80,100)},
    Midnight = {accent=Color3.fromRGB(60,140,255), accent2=Color3.fromRGB(140,60,255), bg=Color3.fromRGB(8,12,24), bgHeader=Color3.fromRGB(12,18,32), bgRow=Color3.fromRGB(16,24,40), track=Color3.fromRGB(28,40,58), text=Color3.fromRGB(220,230,255), sub=Color3.fromRGB(120,140,180), dim=Color3.fromRGB(70,90,130)},
    Matrix   = {accent=Color3.fromRGB(40,220,90), accent2=Color3.fromRGB(140,255,100), bg=Color3.fromRGB(6,12,8), bgHeader=Color3.fromRGB(10,18,12), bgRow=Color3.fromRGB(14,24,16), track=Color3.fromRGB(28,44,30), text=Color3.fromRGB(200,255,210), sub=Color3.fromRGB(100,180,120), dim=Color3.fromRGB(60,110,70)},
    Blood    = {accent=Color3.fromRGB(220,30,50), accent2=Color3.fromRGB(255,100,80), bg=Color3.fromRGB(16,6,8), bgHeader=Color3.fromRGB(24,10,12), bgRow=Color3.fromRGB(30,14,16), track=Color3.fromRGB(50,26,30), text=Color3.fromRGB(255,220,220), sub=Color3.fromRGB(180,120,130), dim=Color3.fromRGB(120,60,70)},
}
local CurrentTheme = Themes[Config.ThemeName] or Themes.Utopia
local function getTheme()
    if Config.ThemeName == "Custom" then
        local t = {}; for k, v in pairs(Themes.Utopia) do t[k] = v end
        t.accent = Config.AccentColor; t.accent2 = Config.AccentColor2; return t
    end
    return Themes[Config.ThemeName] or Themes.Utopia
end

local themeElements, refreshers = {}, {}
local function reg(obj, role, prop)
    table.insert(themeElements, {obj=obj, role=role, prop=prop or "BackgroundColor3"})
    local v = CurrentTheme[role]; if v then pcall(function() obj[prop or "BackgroundColor3"] = v end) end
end
local function regGrad(g, r1, r2)
    table.insert(themeElements, {obj=g, gradient=true, r1=r1, r2=r2})
    pcall(function() g.Color = ColorSequence.new(CurrentTheme[r1], CurrentTheme[r2]) end)
end
local function addRefresh(fn) table.insert(refreshers, fn) end
local function refresh()
    CurrentTheme = getTheme()
    for _, e in ipairs(themeElements) do
        if e.obj and e.obj.Parent then
            if e.gradient then pcall(function() e.obj.Color = ColorSequence.new(CurrentTheme[e.r1], CurrentTheme[e.r2]) end)
            else local v = CurrentTheme[e.role]; if v then pcall(function() e.obj[e.prop] = v end) end end
        end
    end
    for _, fn in ipairs(refreshers) do pcall(fn) end
end

local FILE = "Utopia_v17_configs.json"
local function writeAll(all)
    local s = {}; for n, c in pairs(all) do s[n] = ser(c) end
    local json = HS:JSONEncode(s)
    if hasFS then pcall(writefile, FILE, json) else shared.Utopia_v17_Cfg = json end
end
local function readAll()
    local json
    if hasFS and isfile(FILE) then local ok, r = pcall(readfile, FILE); if ok then json = r end end
    if not json and shared.Utopia_v17_Cfg then json = shared.Utopia_v17_Cfg end
    if not json then return {} end
    local ok, raw = pcall(function() return HS:JSONDecode(json) end); if not ok then return {} end
    local out = {}; for n, c in pairs(raw) do out[n] = deser(c) end; return out
end
local ConfigStore = {
    Save = function(n, c) local all = readAll(); all[n] = c; writeAll(all); return true end,
    Load = function(n) return readAll()[n] end,
    Delete = function(n) local all = readAll(); all[n] = nil; writeAll(all); return true end,
    List = function() local names = {}; for n in pairs(readAll()) do table.insert(names, n) end; table.sort(names); return names end,
}

local function cleanup()
    if not active then return end
    active = false
    pcall(function()
        Lighting.Ambient = Orig.Ambient; Lighting.OutdoorAmbient = Orig.Outdoor
        Lighting.GlobalShadows = true; Lighting.Brightness = 1
        Lighting.FogEnd = Orig.FogEnd; Lighting.FogStart = Orig.FogStart; Lighting.FogColor = Orig.FogColor
        WS.Gravity = Orig.Gravity
        if WS.CurrentCamera then WS.CurrentCamera.FieldOfView = Orig.FOV end
        for part, mat in pairs(Orig.Materials) do if part and part.Parent then part.Material = mat end end
    end)
    if guiRef then guiRef:Destroy() end
end
shared[SLOT] = cleanup

--═══════════════════════════════════════════════════════════════
--  GUI
--═══════════════════════════════════════════════════════════════
local playerGui = LP:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("UtopiaGUI") then playerGui.UtopiaGUI:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "UtopiaGUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
gui.DisplayOrder = 999999; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui; guiRef = gui

local uiScale = Instance.new("UIScale", gui); uiScale.Scale = Config.UIScale

local function playSound(id, vol, pitch)
    if not Config.SoundEffects then return end
    local s = Instance.new("Sound"); s.SoundId = id; s.Volume = vol or 0.5; s.PlaybackSpeed = pitch or 1
    s.Parent = guiRef; s:Play(); task.delay(2, function() if s then s:Destroy() end end)
end

local function ripple(parent, x, y)
    local r = Instance.new("Frame")
    r.AnchorPoint = Vector2.new(0.5, 0.5); r.Position = UDim2.fromOffset(x, y)
    r.Size = UDim2.fromOffset(0, 0); r.BackgroundColor3 = CurrentTheme.accent
    r.BackgroundTransparency = 0.5; r.BorderSizePixel = 0; r.ZIndex = 200; r.Parent = parent
    Instance.new("UICorner", r).CornerRadius = UDim.new(1, 0)
    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5
    Tween:Create(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1}):Play()
    task.delay(0.5, function() r:Destroy() end)
end

local notifStack = Instance.new("Frame")
notifStack.AnchorPoint = Vector2.new(1, 0); notifStack.Position = UDim2.new(1, -20, 0, 20)
notifStack.Size = UDim2.new(0, 280, 1, -40); notifStack.BackgroundTransparency = 1; notifStack.Parent = gui
local nL = Instance.new("UIListLayout", notifStack); nL.Padding = UDim.new(0, 6); nL.SortOrder = Enum.SortOrder.LayoutOrder
local notifOrder = 0
local function notify(title, text, color)
    if not Config.Notifications then return end
    notifOrder += 1
    local n = Instance.new("Frame"); n.Size = UDim2.new(1, 0, 0, 46); n.Position = UDim2.new(1, 80, 0, 0)
    n.BorderSizePixel = 0; n.LayoutOrder = notifOrder; n.Parent = notifStack; reg(n, "bgRow")
    local s = Instance.new("UIStroke", n); s.Thickness = 1.5; s.Color = color or CurrentTheme.accent; s.Parent = n
    local ab = Instance.new("Frame"); ab.Size = UDim2.new(0, 2, 1, 0); ab.BackgroundColor3 = color or CurrentTheme.accent; ab.BorderSizePixel = 0; ab.Parent = n
    local t = Instance.new("TextLabel"); t.Size = UDim2.new(1, -20, 0, 16); t.Position = UDim2.new(0, 14, 0, 6); t.BackgroundTransparency = 1
    t.Text = title:upper(); t.TextColor3 = color or CurrentTheme.accent; t.Font = Enum.Font.GothamBold; t.TextSize = 10; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = n
    local d = Instance.new("TextLabel"); d.Size = UDim2.new(1, -20, 0, 16); d.Position = UDim2.new(0, 14, 0, 22); d.BackgroundTransparency = 1
    d.Text = text; d.Font = Enum.Font.Gotham; d.TextSize = 10; d.TextXAlignment = Enum.TextXAlignment.Left; d.Parent = n; reg(d, "text", "TextColor3")
    Tween:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.delay(3, function()
        if not n.Parent then return end
        Tween:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 80, 0, 0)}):Play()
        task.wait(0.3); n:Destroy()
    end)
end

local wm = Instance.new("TextLabel")
wm.AnchorPoint = Vector2.new(0, 0); wm.Position = UDim2.new(0, 14, 0, 14); wm.Size = UDim2.fromOffset(500, 20); wm.BackgroundTransparency = 1
wm.Font = Enum.Font.Code; wm.Text = "UTOPIA | "; wm.TextSize = 12; wm.TextXAlignment = Enum.TextXAlignment.Left; wm.Parent = gui; reg(wm, "accent", "TextColor3")
wm.Visible = Config.ShowWatermark

local fovCircle = Instance.new("Frame"); fovCircle.AnchorPoint = Vector2.new(0.5, 0.5); fovCircle.Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2)
fovCircle.BackgroundTransparency = 1; fovCircle.Visible = false; fovCircle.ZIndex = 4; fovCircle.Parent = gui
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle); fovStroke.Color = Config.FOVColor; fovStroke.Thickness = 1.5; fovStroke.Transparency = 0.35

local crosshair = Instance.new("Frame"); crosshair.AnchorPoint = Vector2.new(0.5, 0.5); crosshair.Size = UDim2.fromOffset(14, 14)
crosshair.BackgroundTransparency = 1; crosshair.Visible = false; crosshair.ZIndex = 5; crosshair.Parent = gui
local crosshairParts = {}
local function buildCrosshair(style, color)
    for _, p in ipairs(crosshairParts) do p:Destroy() end
    crosshairParts = {}
    if style == "Off" then return end
    if style == "Dot" then
        local d = Instance.new("Frame"); d.Size = UDim2.fromOffset(4, 4); d.AnchorPoint = Vector2.new(0.5, 0.5); d.Position = UDim2.fromScale(0.5, 0.5)
        d.BackgroundColor3 = color; d.BorderSizePixel = 0; d.Parent = crosshair; Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0); table.insert(crosshairParts, d)
    elseif style == "Circle" then
        local c = Instance.new("Frame"); c.Size = UDim2.new(1, 0, 1, 0); c.BackgroundTransparency = 1; c.Parent = crosshair
        Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0); local s = Instance.new("UIStroke", c); s.Color = color; s.Thickness = 1.5; table.insert(crosshairParts, c)
    else
        local gap = (style == "Cross") and 6 or 4
        for _, cfg in ipairs({{Vector2.new(0.5,0), Vector2.new(0.5,0), UDim2.fromOffset(2,gap)},{Vector2.new(0.5,1), Vector2.new(0.5,1), UDim2.fromOffset(2,gap)},{Vector2.new(0,0.5), Vector2.new(0,0.5), UDim2.fromOffset(gap,2)},{Vector2.new(1,0.5), Vector2.new(1,0.5), UDim2.fromOffset(gap,2)}}) do
            local f = Instance.new("Frame"); f.AnchorPoint = cfg[2]; f.Position = UDim2.new(cfg[1].X, 0, cfg[1].Y, 0); f.Size = cfg[3]
            f.BackgroundColor3 = color; f.BorderSizePixel = 0; f.Parent = crosshair; Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0); table.insert(crosshairParts, f)
        end
    end
end
buildCrosshair(Config.CrosshairStyle, Config.CrosshairColor)

local lockGui = Instance.new("Frame"); lockGui.AnchorPoint = Vector2.new(0.5, 0.5); lockGui.Size = UDim2.fromOffset(56, 56)
lockGui.BackgroundTransparency = 1; lockGui.Visible = false; lockGui.ZIndex = 6; lockGui.Parent = gui
local lockParts = {}
for i = 1, 4 do
    local f = Instance.new("Frame"); f.Size = UDim2.fromOffset(9, 2); f.BackgroundColor3 = Config.BracketColor
    f.BorderSizePixel = 0; f.AnchorPoint = Vector2.new(0.5, 0.5); f.ZIndex = 6; f.Parent = lockGui; Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0); table.insert(lockParts, f)
end
local function placeBrackets(r, rot)
    lockParts[1].Position = UDim2.new(0.5, -r, 0.5, -r); lockParts[1].Rotation = rot
    lockParts[2].Position = UDim2.new(0.5, r, 0.5, -r); lockParts[2].Rotation = -rot
    lockParts[3].Position = UDim2.new(0.5, -r, 0.5, r); lockParts[3].Rotation = -rot
    lockParts[4].Position = UDim2.new(0.5, r, 0.5, r); lockParts[4].Rotation = rot
end
placeBrackets(24, 45)

local hitmarker = Instance.new("Frame"); hitmarker.AnchorPoint = Vector2.new(0.5, 0.5); hitmarker.Size = UDim2.fromOffset(24, 24)
hitmarker.BackgroundTransparency = 1; hitmarker.Visible = false; hitmarker.ZIndex = 8; hitmarker.Parent = gui
for _, cfg in ipairs({{Vector2.new(0, 0), 45}, {Vector2.new(1, 0), -45}, {Vector2.new(0, 1), -45}, {Vector2.new(1, 1), 45}}) do
    local l = Instance.new("Frame"); l.AnchorPoint = cfg[1]; l.Position = UDim2.new(cfg[1].X, 0, cfg[1].Y, 0)
    l.Size = UDim2.fromOffset(8, 2); l.BackgroundColor3 = Color3.fromRGB(255, 90, 110); l.BorderSizePixel = 0; l.Rotation = cfg[2]; l.ZIndex = 8; l.Parent = hitmarker
end

local targetInfo = Instance.new("Frame"); targetInfo.AnchorPoint = Vector2.new(1, 1); targetInfo.Position = UDim2.new(1, -20, 1, -180)
targetInfo.Size = UDim2.fromOffset(220, 70); targetInfo.BorderSizePixel = 0; targetInfo.Visible = false; targetInfo.ZIndex = 8; targetInfo.Parent = gui; reg(targetInfo, "bgRow")
local tiStroke = Instance.new("UIStroke", targetInfo); tiStroke.Thickness = 1; tiStroke.Transparency = 0.3; reg(tiStroke, "accent", "Color")
local tiName = Instance.new("TextLabel"); tiName.Size = UDim2.new(1, -16, 0, 16); tiName.Position = UDim2.new(0, 8, 0, 6); tiName.BackgroundTransparency = 1
tiName.Font = Enum.Font.GothamBold; tiName.TextSize = 11; tiName.TextXAlignment = Enum.TextXAlignment.Left; tiName.Parent = targetInfo; reg(tiName, "text", "TextColor3")
local tiHpBg = Instance.new("Frame"); tiHpBg.Size = UDim2.new(1, -16, 0, 4); tiHpBg.Position = UDim2.new(0, 8, 0, 26); tiHpBg.BorderSizePixel = 0; tiHpBg.Parent = targetInfo; reg(tiHpBg, "track")
local tiHpFill = Instance.new("Frame"); tiHpFill.Size = UDim2.new(1, 0, 1, 0); tiHpFill.BackgroundColor3 = Color3.fromRGB(80, 240, 150); tiHpFill.BorderSizePixel = 0; tiHpFill.Parent = tiHpBg
local tiInfo = Instance.new("TextLabel"); tiInfo.Size = UDim2.new(1, -16, 0, 16); tiInfo.Position = UDim2.new(0, 8, 0, 36); tiInfo.BackgroundTransparency = 1
tiInfo.Font = Enum.Font.Code; tiInfo.TextSize = 9; tiInfo.TextXAlignment = Enum.TextXAlignment.Left; tiInfo.Parent = targetInfo; reg(tiInfo, "sub", "TextColor3")

local minimap = Instance.new("Frame"); minimap.AnchorPoint = Vector2.new(1, 1); minimap.Position = UDim2.new(1, -20, 1, -20)
minimap.Size = UDim2.fromOffset(150, 150); minimap.BackgroundTransparency = 0.35; minimap.BorderSizePixel = 0; minimap.ZIndex = 7; minimap.Visible = Config.ShowMinimap; minimap.Parent = gui
Instance.new("UICorner", minimap).CornerRadius = UDim.new(1, 0); reg(minimap, "bgRow")
local mmStroke = Instance.new("UIStroke", minimap); mmStroke.Thickness = 2; mmStroke.Transparency = 0.2; reg(mmStroke, "accent", "Color")
local mmCenter = Instance.new("Frame"); mmCenter.AnchorPoint = Vector2.new(0.5, 0.5); mmCenter.Position = UDim2.new(0.5, 0, 0.5, 0); mmCenter.Size = UDim2.fromOffset(6, 6)
mmCenter.BorderSizePixel = 0; mmCenter.ZIndex = 9; mmCenter.Parent = minimap; Instance.new("UICorner", mmCenter).CornerRadius = UDim.new(1, 0); reg(mmCenter, "accent")
local mmDots = {}
local function ensureDot(i)
    while #mmDots < i do
        local d = Instance.new("Frame"); d.AnchorPoint = Vector2.new(0.5, 0.5); d.Size = UDim2.fromOffset(4, 4)
        d.BackgroundColor3 = Color3.fromRGB(255, 90, 110); d.BorderSizePixel = 0; d.ZIndex = 8; d.Visible = false; d.Parent = minimap
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0); table.insert(mmDots, d)
    end
end

local panel = Instance.new("Frame"); panel.Name = "Panel"; panel.Size = UDim2.fromOffset(420, 560); panel.Position = UDim2.new(0.5, -210, 0.5, -280)
panel.BorderSizePixel = 0; panel.ClipsDescendants = true; panel.Parent = gui; reg(panel, "bg")
local panelStroke = Instance.new("UIStroke", panel); panelStroke.Thickness = 2; panelStroke.Transparency = 0; panelStroke.Parent = panel; reg(panelStroke, "accent", "Color")

local header = Instance.new("TextButton"); header.Size = UDim2.new(1, 0, 0, 52); header.BorderSizePixel = 0; header.Text = ""; header.AutoButtonColor = false; header.Active = true; header.ZIndex = 2; header.Parent = panel; reg(header, "bgHeader")
local titleLbl = Instance.new("TextLabel"); titleLbl.Size = UDim2.new(0, 200, 0, 18); titleLbl.Position = UDim2.new(0, 28, 0, 10); titleLbl.BackgroundTransparency = 1
titleLbl.Text = "UTOPIA"; titleLbl.Font = Enum.Font.GothamBlack; titleLbl.TextSize = 17; titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 3; titleLbl.Parent = header; reg(titleLbl, "text", "TextColor3")
local subtitleLbl = Instance.new("TextLabel"); subtitleLbl.Size = UDim2.new(0, 200, 0, 12); subtitleLbl.Position = UDim2.new(0, 28, 0, 28); subtitleLbl.BackgroundTransparency = 1
subtitleLbl.Text = "v17.0 working logic"; subtitleLbl.Font = Enum.Font.Code; subtitleLbl.TextSize = 9; subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left; subtitleLbl.ZIndex = 3; subtitleLbl.Parent = header; reg(subtitleLbl, "sub", "TextColor3")
local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.fromOffset(24, 24); closeBtn.AnchorPoint = Vector2.new(1, 0.5); closeBtn.Position = UDim2.new(1, -12, 0.5, 0); closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 14; closeBtn.AutoButtonColor = false; closeBtn.ZIndex = 3; closeBtn.Parent = header; reg(closeBtn, "track"); reg(closeBtn, "text", "TextColor3")

local statusStrip = Instance.new("Frame"); statusStrip.Size = UDim2.new(1, 0, 0, 26); statusStrip.Position = UDim2.new(0, 0, 0, 52); statusStrip.BorderSizePixel = 0; statusStrip.ZIndex = 2; statusStrip.Parent = panel; reg(statusStrip, "bgHeader")
local statusDot = Instance.new("Frame"); statusDot.Size = UDim2.fromOffset(6, 6); statusDot.Position = UDim2.new(0, 16, 0.5, -3); statusDot.BackgroundColor3 = Color3.fromRGB(80, 240, 150); statusDot.BorderSizePixel = 0; statusDot.ZIndex = 3; statusDot.Parent = statusStrip
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)
local statusText = Instance.new("TextLabel"); statusText.Size = UDim2.new(1, -180, 1, 0); statusText.Position = UDim2.new(0, 28, 0, 0); statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.Code; statusText.Text = "OFF - press Z"; statusText.TextSize = 9; statusText.TextXAlignment = Enum.TextXAlignment.Left; statusText.ZIndex = 3; statusText.Parent = statusStrip; reg(statusText, "sub", "TextColor3")
local fpsLbl = Instance.new("TextLabel"); fpsLbl.Size = UDim2.new(0, 80, 1, 0); fpsLbl.AnchorPoint = Vector2.new(1, 0); fpsLbl.Position = UDim2.new(1, -14, 0, 0); fpsLbl.BackgroundTransparency = 1
fpsLbl.Font = Enum.Font.Code; fpsLbl.Text = "60 FPS"; fpsLbl.TextSize = 9; fpsLbl.TextXAlignment = Enum.TextXAlignment.Right; fpsLbl.ZIndex = 3; fpsLbl.Parent = statusStrip; reg(fpsLbl, "dim", "TextColor3")

local tabBar = Instance.new("Frame"); tabBar.Size = UDim2.new(1, -16, 0, 28); tabBar.Position = UDim2.new(0, 8, 0, 86); tabBar.BorderSizePixel = 0; tabBar.ZIndex = 2; tabBar.Parent = panel; reg(tabBar, "bg")
local tabBarStroke = Instance.new("UIStroke", tabBar); tabBarStroke.Thickness = 1; tabBarStroke.Transparency = 0.65; tabBarStroke.Parent = tabBar; reg(tabBarStroke, "accent", "Color")
local tabL = Instance.new("UIListLayout", tabBar); tabL.FillDirection = Enum.FillDirection.Horizontal; tabL.SortOrder = Enum.SortOrder.LayoutOrder; tabL.Padding = UDim.new(0, 0)
local pageContainer = Instance.new("Frame"); pageContainer.Size = UDim2.new(1, -16, 1, -120); pageContainer.Position = UDim2.new(0, 8, 0, 118); pageContainer.BackgroundTransparency = 1; pageContainer.ZIndex = 2; pageContainer.Parent = panel

local tabs, tabButtons = {}, {}
local currentTab = nil
local function switchTab(name)
    for tn, sc in pairs(tabs) do sc.Visible = (tn == name) end
    for tn, btn in pairs(tabButtons) do
        local a = tn == name
        Tween:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = a and CurrentTheme.accent or CurrentTheme.bg, TextColor3 = a and Color3.new(1,1,1) or CurrentTheme.sub}):Play()
    end
    currentTab = name
end
local function createTab(name)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1/5, 0, 1, 0); btn.BackgroundColor3 = CurrentTheme.bg; btn.BorderSizePixel = 0; btn.Text = name
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.AutoButtonColor = false; btn.ZIndex = 3; btn.Parent = tabBar; reg(btn, "sub", "TextColor3")
    tabButtons[name] = btn; btn.MouseButton1Click:Connect(function() switchTab(name) end)
    addRefresh(function()
        local a = currentTab == name; btn.BackgroundColor3 = a and CurrentTheme.accent or CurrentTheme.bg; btn.TextColor3 = a and Color3.new(1,1,1) or CurrentTheme.sub
    end)
end
local function createPage(name)
    local scroll = Instance.new("ScrollingFrame"); scroll.Size = UDim2.new(1, 0, 1, 0); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.ScrollBarThickness = 2; scroll.ScrollBarImageTransparency = 0.3; scroll.Visible = false; scroll.ZIndex = 2; scroll.Parent = pageContainer
    reg(scroll, "accent", "ScrollBarImageColor3")
    local layout = Instance.new("UIListLayout", scroll); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 4)
    tabs[name] = scroll
end

local activePage, Y = nil, 0
local sliding = {active=false, fn=nil, vX=0}
local function beginPage(n) activePage = tabs[n]; Y = 2 end
local function section(text)
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -8, 0, 16); l.Position = UDim2.new(0, 4, 0, Y); l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold; l.Text = "- " .. text:upper() .. " -"; l.TextSize = 9; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = activePage; reg(l, "accent", "TextColor3"); Y += 18
end
local function row(h)
    local r = Instance.new("Frame"); r.Size = UDim2.new(1, -8, 0, h); r.Position = UDim2.new(0, 4, 0, Y); r.BackgroundColor3 = CurrentTheme.bgRow; r.BorderSizePixel = 0
    r.Parent = activePage; reg(r, "bgRow"); Y += h + 3; return r
end

local function makeToggle(label, configKey, cb)
    local r = row(30)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = r; reg(lbl, "text", "TextColor3")
    local btn = Instance.new("TextButton"); btn.Size = UDim2.fromOffset(38, 18); btn.AnchorPoint = Vector2.new(1, 0.5); btn.Position = UDim2.new(1, -10, 0.5, 0); btn.BorderSizePixel = 0; btn.Text = ""; btn.AutoButtonColor = false; btn.Parent = r
    local bs = Instance.new("UIStroke", btn); bs.Thickness = 1; bs.Parent = btn; reg(bs, "dim", "Color")
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(12, 12); knob.AnchorPoint = Vector2.new(0, 0.5); knob.BorderSizePixel = 0; knob.Parent = btn; reg(knob, "text")
    local function refreshTog()
        local s = Config[configKey]
        btn.BackgroundColor3 = s and CurrentTheme.accent or CurrentTheme.track
        knob.Position = UDim2.new(0, s and 23 or 3, 0.5, 0)
        knob.BackgroundColor3 = s and Color3.new(1,1,1) or CurrentTheme.dim
    end
    addRefresh(refreshTog); refreshTog()
    btn.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]; refreshTog(); ripple(btn, btn.AbsoluteSize.X * 0.5, btn.AbsoluteSize.Y * 0.5)
        if cb then cb(Config[configKey]) end
    end)
end

local function makeSlider(label, configKey, mn, mx, step, fmt, cb)
    local r = row(46)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -110, 0, 12); lbl.Position = UDim2.new(0, 12, 0, 6); lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = r; reg(lbl, "text", "TextColor3")
    local valLbl = Instance.new("TextLabel"); valLbl.Size = UDim2.new(0, 90, 0, 12); valLbl.AnchorPoint = Vector2.new(1, 0); valLbl.Position = UDim2.new(1, -12, 0, 6); valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold; valLbl.TextSize = 10; valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.Parent = r; reg(valLbl, "accent", "TextColor3")
    local track = Instance.new("Frame"); track.Size = UDim2.new(1, -24, 0, 4); track.Position = UDim2.new(0, 12, 0, 30); track.BorderSizePixel = 0; track.Parent = r; reg(track, "track")
    local fill = Instance.new("Frame"); fill.Size = UDim2.new(0, 0, 1, 0); fill.BorderSizePixel = 0; fill.Parent = track; reg(fill, "accent")
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(10, 14); knob.AnchorPoint = Vector2.new(0.5, 0.5); knob.BorderSizePixel = 0; knob.Parent = track; reg(knob, "text")
    local function refreshSl()
        local v = Config[configKey]; local p = math.clamp((v - mn) / (mx - mn), 0, 1)
        fill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, 0, 0.5, 0); valLbl.Text = fmt(v)
    end
    addRefresh(refreshSl); refreshSl()
    local function apply(px)
        local ax, aw = track.AbsolutePosition.X, track.AbsoluteSize.X
        if aw <= 0 then return end
        local t = math.clamp((px - ax) / aw, 0, 1); local raw = mn + (mx - mn) * t
        if step > 0 then raw = math.floor((raw - mn)/step + 0.5) * step + mn end
        raw = math.clamp(raw, mn, mx); Config[configKey] = raw; refreshSl()
        if cb then cb(raw) end
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding.active = true; sliding.fn = apply; sliding.vX = input.Position.X; apply(input.Position.X)
        end
    end)
end

local function makeCycle(label, configKey, options, cb)
    local r = row(30)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -170, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = r; reg(lbl, "text", "TextColor3")
    local btn = Instance.new("TextButton"); btn.Size = UDim2.fromOffset(150, 20); btn.AnchorPoint = Vector2.new(1, 0.5); btn.Position = UDim2.new(1, -10, 0.5, 0); btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.AutoButtonColor = false; btn.Parent = r; reg(btn, "track"); reg(btn, "accent", "TextColor3")
    local function refreshCy() btn.Text = tostring(Config[configKey]) end
    addRefresh(refreshCy); refreshCy()
    btn.MouseButton1Click:Connect(function()
        local cur = tostring(Config[configKey]); local idx = 1
        for i, o in ipairs(options) do if o == cur then idx = i break end end
        idx = idx % #options + 1; Config[configKey] = options[idx]; refreshCy(); ripple(btn, btn.AbsoluteSize.X * 0.5, btn.AbsoluteSize.Y * 0.5)
        if cb then cb(options[idx]) end
    end)
end

local function makeColorRow(label, configKey, cb)
    local r = row(30)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -190, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = r; reg(lbl, "text", "TextColor3")
    local swatches = {Color3.fromRGB(147,51,234), Color3.fromRGB(60,140,255), Color3.fromRGB(80,240,150), Color3.fromRGB(255,200,90), Color3.fromRGB(255,90,110), Color3.fromRGB(255,140,50), Color3.fromRGB(255,100,200), Color3.fromRGB(240,240,255)}
    local swSize, gap = 16, 2; local strokes = {}
    for i, c in ipairs(swatches) do
        local sw = Instance.new("TextButton"); sw.Size = UDim2.fromOffset(swSize, swSize); sw.AnchorPoint = Vector2.new(1, 0.5); sw.Position = UDim2.new(1, -10 - (#swatches - i) * (swSize + gap), 0.5, 0)
        sw.BackgroundColor3 = c; sw.BorderSizePixel = 0; sw.Text = ""; sw.AutoButtonColor = false; sw.Parent = r
        local ss = Instance.new("UIStroke", sw); ss.Thickness = 1; ss.Transparency = 0.7; table.insert(strokes, {s=ss, c=c})
        sw.MouseButton1Click:Connect(function()
            Config[configKey] = c
            for _, st in ipairs(strokes) do st.s.Transparency = (st.c == c) and 0 or 0.7; st.s.Color = (st.c == c) and Color3.new(1,1,1) or CurrentTheme.dim end
            if cb then cb(c) end
        end)
    end
    addRefresh(function()
        local cur = Config[configKey]
        for _, st in ipairs(strokes) do st.s.Transparency = (st.c == cur) and 0 or 0.7; st.s.Color = (st.c == cur) and Color3.new(1,1,1) or CurrentTheme.dim end
    end)
end

local function makeButton(label, color, cb, isDanger)
    local r = row(30)
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -16, 0, 22); btn.Position = UDim2.new(0, 8, 0, 4); btn.BorderSizePixel = 0; btn.Text = label
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.TextColor3 = Color3.new(1,1,1); btn.AutoButtonColor = false; btn.Parent = r
    if isDanger then btn.BackgroundColor3 = Color3.fromRGB(180,40,60) else btn.BackgroundColor3 = color or CurrentTheme.accent; if not color then reg(btn, "accent") end end
    btn.MouseButton1Click:Connect(function() ripple(btn, btn.AbsoluteSize.X * 0.5, btn.AbsoluteSize.Y * 0.5); if cb then cb() end end)
end

local function makeTextBox(label, placeholder, cb)
    local r = row(46)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -16, 0, 12); lbl.Position = UDim2.new(0, 12, 0, 4); lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = r; reg(lbl, "sub", "TextColor3")
    local box = Instance.new("TextBox"); box.Size = UDim2.new(1, -24, 0, 22); box.Position = UDim2.new(0, 12, 0, 20); box.BackgroundColor3 = CurrentTheme.track; box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham; box.PlaceholderText = placeholder; box.Text = ""; box.TextSize = 11; box.TextXAlignment = Enum.TextXAlignment.Left; box.ClearTextOnFocus = false; box.Parent = r
    reg(box, "track"); reg(box, "text", "TextColor3"); reg(box, "dim", "PlaceholderColor3")
    box.FocusLost:Connect(function() if cb then cb(box.Text) end end)
    return box
end

createTab("AIM"); createTab("VISUALS"); createTab("MISC"); createTab("CONFIGS"); createTab("SETTINGS")
createPage("AIM"); createPage("VISUALS"); createPage("MISC"); createPage("CONFIGS"); createPage("SETTINGS")

-- AIM
beginPage("AIM")
section("Combat")
makeToggle("Enable Aim (or press Z)", "Enabled", function(v)
    notify("Aim", v and "ON" or "OFF", v and Color3.fromRGB(80,240,150) or Color3.fromRGB(255,90,110))
end)
makeToggle("Require RMB (hold to aim)", "RequireRMB")
makeSlider("Smoothness (0=smooth, 1=snap)", "Smoothness", 0, 1, 0.01, function(v) return string.format("%.2f", v) end)
makeSlider("Sensitivity", "Sensitivity", 0.2, 3.0, 0.1, function(v) return string.format("%.1fx", v) end)
makeSlider("FOV Radius", "FOVRadius", 30, 500, 5, function(v) return math.floor(v).."px" end)
makeSlider("Prediction", "Prediction", 0, 0.3, 0.01, function(v) return string.format("%.2fs", v) end)
makeToggle("Wall Check", "WallCheck")
makeToggle("Team Check", "TeamCheck")
makeCycle("Aim Part", "TargetPart", {"Head","HumanoidRootPart","UpperTorso"})
makeCycle("Priority", "TargetPriority", {"FOV","Distance","LowestHP"})
section("Triggerbot")
makeToggle("Enable Triggerbot", "Triggerbot")
makeSlider("Fire Rate", "FireRate", 0.01, 0.2, 0.01, function(v) return string.format("%.2fs", v) end)

-- VISUALS
beginPage("VISUALS")
section("FOV Circle")
makeToggle("Show FOV", "ShowFOV")
makeColorRow("FOV Color", "FOVColor", function(c) fovStroke.Color = c end)
section("Crosshair")
makeToggle("Show Crosshair", "ShowCrosshair")
makeCycle("Style", "CrosshairStyle", {"Plus","Dot","Cross","Circle","Off"}, function(v) buildCrosshair(v, Config.CrosshairColor) end)
makeColorRow("Crosshair Color", "CrosshairColor", function(c) buildCrosshair(Config.CrosshairStyle, c) end)
section("HUD")
makeToggle("Watermark", "ShowWatermark", function(v) wm.Visible = v end)
makeToggle("Target Info", "ShowTargetInfo")
makeToggle("Minimap", "ShowMinimap", function(v) minimap.Visible = v end)
makeToggle("Hitmarker", "Hitmarker")

-- MISC
beginPage("MISC")
section("Environment")
makeToggle("Fullbright", "Fullbright", function(v)
    if v then
        Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.GlobalShadows = false; Lighting.Brightness = 2
    else
        Lighting.Ambient = Orig.Ambient; Lighting.OutdoorAmbient = Orig.Outdoor
        Lighting.GlobalShadows = true; Lighting.Brightness = 1
    end
end)
makeSlider("Time of Day", "TimeOfDay", 0, 24, 1, function(v) Lighting.ClockTime = v; return string.format("%02d:00", v) end)
section("Physics")
makeSlider("WalkSpeed", "WalkSpeed", 16, 200, 1, function(v)
    if LP.Character then local h = LP.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = v end end
    return math.floor(v)
end)
makeSlider("JumpPower", "JumpPower", 50, 200, 5, function(v)
    if LP.Character then local h = LP.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower = v end end
    return math.floor(v)
end)
makeSlider("Gravity", "Gravity", 0, 300, 5, function(v) WS.Gravity = v; return math.floor(v) end)

-- CONFIGS
beginPage("CONFIGS")
local SelectedConfig = nil
local configList = nil
section("Create a Config")
local nameBox = makeTextBox("Config Name", "Enter name...", nil)
makeButton("Create Config", nil, function()
    local n = nameBox.Text
    if n == "" then notify("Error", "Enter a name") return end
    ConfigStore.Save(n, Config); SelectedConfig = n
    if rebuildConfigList then rebuildConfigList() end
    notify("Config", "Created: " .. n)
end)
section("Your Configs")
configList = Instance.new("Frame"); configList.Size = UDim2.new(1, -8, 0, 140); configList.BackgroundTransparency = 1; configList.AutomaticSize = Enum.AutomaticSize.Y; configList.Parent = activePage; Y += 144
local cL = Instance.new("UIListLayout", configList); cL.SortOrder = Enum.SortOrder.LayoutOrder; cL.Padding = UDim.new(0, 3)

function rebuildConfigList()
    for _, c in ipairs(configList:GetChildren()) do if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end end
    local names = ConfigStore.List()
    if #names == 0 then
        local empty = Instance.new("TextLabel"); empty.Size = UDim2.new(1, 0, 0, 30); empty.BackgroundColor3 = CurrentTheme.bgRow
        empty.Text = "no configs yet"; empty.Font = Enum.Font.Gotham; empty.TextSize = 10; empty.TextColor3 = CurrentTheme.sub
        empty.Parent = configList; reg(empty, "bgRow"); return
    end
    for _, n in ipairs(names) do
        local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, 0, 0, 28)
        btn.BackgroundColor3 = (n == SelectedConfig) and CurrentTheme.accent or CurrentTheme.bgRow
        btn.Text = n; btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
        btn.TextColor3 = (n == SelectedConfig) and Color3.new(1,1,1) or CurrentTheme.text
        btn.Parent = configList
        if n ~= SelectedConfig then reg(btn, "bgRow") end
        btn.MouseButton1Click:Connect(function() SelectedConfig = n; rebuildConfigList() end)
    end
end
task.defer(rebuildConfigList)

section("Actions")
makeButton("Save Selected", Color3.fromRGB(0,200,100), function()
    if not SelectedConfig then notify("Error", "Select a config") return end
    ConfigStore.Save(SelectedConfig, Config); notify("Config", "Saved!")
end)
makeButton("Delete Selected", Color3.fromRGB(200,50,50), function()
    if not SelectedConfig then return end
    ConfigStore.Delete(SelectedConfig); SelectedConfig = nil; rebuildConfigList(); notify("Config", "Deleted!")
end)
makeButton("Set Auto Load", nil, function()
    if not SelectedConfig then return end
    Config.AutoLoadConfig = SelectedConfig; saveGlobals(); notify("Config", "Auto Load set!")
end)
makeButton("Clear Auto Load", Color3.fromRGB(200,150,50), function()
    Config.AutoLoadConfig = ""; saveGlobals(); notify("Config", "Cleared!")
end)
makeButton("Refresh", nil, rebuildConfigList)

-- SETTINGS
beginPage("SETTINGS")
section("Theme")
makeCycle("Preset", "ThemeName", {"Utopia","Midnight","Matrix","Blood","Custom"}, function(v) refresh() end)
makeColorRow("Accent 1", "AccentColor", function(c) if Config.ThemeName == "Custom" then refresh() end end)
section("UI")
makeSlider("UI Scale", "UIScale", 0.5, 1.5, 0.05, function(v) uiScale.Scale = v; saveGlobals(); return string.format("%.2fx", v) end)
section("Actions")
makeButton("Unload Script", Color3.fromRGB(200,50,50), function() cleanup() end, true)

--═══════════════════════════════════════════════════════════════
--  TARGETING
--═══════════════════════════════════════════════════════════════
local function isAlive(c) if not c then return false end; local h = c:FindFirstChildOfClass("Humanoid"); return h and h.Health > 0 end
local stats = {targets_seen=0, locks=0, session_start=tick()}
local currentTarget = nil
local lockedTarget = nil
local lockedPlayer = nil

local function getTarget()
    if not Config.Enabled then lockedTarget = nil; lockedPlayer = nil; return nil, 0 end
    local cam = WS.CurrentCamera
    if not cam then return nil, 0 end
    local vp = cam.ViewportSize; local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    local localChar = LP.Character
    if not localChar then return nil, 0 end
    local candidates = {}; local count = 0

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if Config.TeamCheck and LP.Team and plr.Team and LP.Team == plr.Team then continue end
        if not isAlive(plr.Character) then continue end
        local part = plr.Character:FindFirstChild(Config.TargetPart) or plr.Character:FindFirstChild("Head")
        if not part then continue end
        local pos = part.Position
        if Config.Prediction > 0 then
            local root = plr.Character:FindFirstChild("HumanoidRootPart") or part
            local vel = root.AssemblyLinearVelocity or Vector3.zero
            pos = pos + vel * Config.Prediction
        end
        local sp, onScreen = cam:WorldToViewportPoint(pos)
        if not onScreen or sp.Z <= 0 then continue end
        local fovDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if fovDist > Config.FOVRadius then continue end
        if Config.WallCheck then
            local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = {localChar, plr.Character}; rp.IgnoreWater = true
            local res = WS:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, rp)
            if res then continue end
        end
        count += 1
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        table.insert(candidates, {part=part, player=plr, fovDist=fovDist, worldDist=(part.Position-cam.CFrame.Position).Magnitude, health=hum and hum.Health or 100, velocity=part.AssemblyLinearVelocity, predictedPos=pos})
    end

    if #candidates == 0 then lockedTarget = nil; lockedPlayer = nil; return nil, 0 end

    if lockedTarget and lockedPlayer then
        for _, c in ipairs(candidates) do
            if c.part == lockedTarget and c.player == lockedPlayer then return c, count end
        end
    end

    local prio = Config.TargetPriority
    table.sort(candidates, function(a, b)
        if prio == "Distance" then return a.worldDist < b.worldDist end
        if prio == "LowestHP" then return a.health < b.health end
        return a.fovDist < b.fovDist
    end)
    lockedTarget = candidates[1].part; lockedPlayer = candidates[1].player
    return candidates[1], count
end

--═══════════════════════════════════════════════════════════════
--  AIM LOOP — EXACT WORKING LOGIC
--═══════════════════════════════════════════════════════════════
RS.RenderStepped:Connect(function()
    if not active then return end
    if not Config.Enabled then return end
    if Config.RequireRMB and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    
    local cam = WS.CurrentCamera
    if not cam then return end
    
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    local targetInfoData = getTarget()
    if not targetInfoData then return end
    
    local aimPos = targetInfoData.predictedPos or targetInfoData.part.Position
    local screenPos, onScreen = cam:WorldToViewportPoint(aimPos)
    if not onScreen then return end
    
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local delta = Vector2.new(screenPos.X, screenPos.Y) - center
    
    -- FORMULE DU SCRIPT QUI MARCHE : div = (1 - smooth) * 20
    -- smooth=0 → div=20 (smooth), smooth=0.7 → div=6 (défaut working), smooth=1 → div=1 (instant)
    local div = math.max(1, (1 - Config.Smoothness) * 20)
    div = div / math.max(0.1, Config.Sensitivity)
    
    -- Pcall exactement comme le working script
    pcall(function()
        mousemoverel(delta.X / div, delta.Y / div)
    end)
end)

--═══════════════════════════════════════════════════════════════
--  VISUAL LOOP
--═══════════════════════════════════════════════════════════════
local fpsFrames, fpsTime = 0, 0
local lockPulse = 0

RS.RenderStepped:Connect(function(dt)
    if not active then return end
    local cam = WS.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    
    fpsFrames += 1; fpsTime += dt
    if fpsTime >= 0.5 then fpsLbl.Text = math.floor(fpsFrames/fpsTime) .. " FPS"; fpsFrames, fpsTime = 0, 0 end

    fovCircle.Position = UDim2.fromOffset(vp.X * 0.5, vp.Y * 0.5)
    crosshair.Position = UDim2.fromOffset(vp.X * 0.5, vp.Y * 0.5)
    local fovSize = Config.FOVRadius * 2
    if Config.FOVPulse and currentTarget then lockPulse += dt * 8; fovSize += math.sin(lockPulse) * 3 end
    fovCircle.Size = UDim2.fromOffset(fovSize, fovSize)
    fovStroke.Color = Config.FOVColor
    fovCircle.Visible = Config.ShowFOV and Config.Enabled

    local rmbHeld = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    local activeAim = Config.Enabled and (not Config.RequireRMB or rmbHeld)
    crosshair.Visible = Config.ShowCrosshair and activeAim and Config.CrosshairStyle ~= "Off"

    local stateColor = Config.CrosshairColor
    if currentTarget then stateColor = Config.CrosshairColorLock elseif activeAim then stateColor = Config.CrosshairColorScan end
    for _, p in ipairs(crosshairParts) do
        if p:FindFirstChildOfClass("UIStroke") then p:FindFirstChildOfClass("UIStroke").Color = stateColor
        else p.BackgroundColor3 = stateColor end
    end

    if not activeAim then
        currentTarget = nil; lockGui.Visible = false; targetInfo.Visible = false
        statusDot.BackgroundColor3 = Color3.fromRGB(255,90,110)
        statusText.Text = "OFF - press Z"; return
    end

    local targetInfoData, count = getTarget()
    stats.targets_seen = math.max(stats.targets_seen, count)

    if not targetInfoData then
        currentTarget = nil; lockGui.Visible = false; targetInfo.Visible = false
        statusDot.BackgroundColor3 = Color3.fromRGB(255,200,90)
        statusText.Text = string.format("scanning - targets: %d", count); return
    end

    currentTarget = targetInfoData.part
    if lockedPlayer ~= targetInfoData.player then
        stats.locks += 1; lockedPlayer = targetInfoData.player
        playSound("rbxassetid://4590662766", 0.4, 1.0)
    end
    statusDot.BackgroundColor3 = Color3.fromRGB(80,240,150)
    statusText.Text = string.format("LOCKED - targets: %d", count)

    if Config.ShowTargetInfo then
        targetInfo.Visible = true; tiName.Text = targetInfoData.player.Name
        local hp = targetInfoData.health; tiHpFill.Size = UDim2.new(math.clamp(hp/100, 0, 1), 0, 1, 0)
        tiHpFill.BackgroundColor3 = Color3.fromRGB(80,240,150):Lerp(Color3.fromRGB(255,90,110), 1 - math.clamp(hp/100,0,1))
        tiInfo.Text = string.format("dist: %dm - hp: %d", math.floor(targetInfoData.worldDist), math.floor(hp))
    else targetInfo.Visible = false end

    if Config.ShowBrackets then
        local sp, onScreen = cam:WorldToViewportPoint(targetInfoData.part.Position)
        if onScreen and sp.Z > 0 then
            lockGui.Visible = true; lockGui.Position = UDim2.fromOffset(sp.X, sp.Y); lockGui.Rotation = math.sin(tick() * 3) * 8
            for _, b in ipairs(lockParts) do b.BackgroundColor3 = Config.BracketColor end
        else lockGui.Visible = false end
    else lockGui.Visible = false end

    if Config.ShowMinimap then
        local myPos = cam.CFrame.Position; local range = 200; local idx = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LP then continue end
            if Config.TeamCheck and LP.Team and plr.Team and LP.Team == plr.Team then continue end
            if not isAlive(plr.Character) then continue end
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local rel = hrp.Position - myPos; local d = rel.Magnitude; if d > range then continue end
            idx += 1; ensureDot(idx); local dot = mmDots[idx]
            if dot then
                dot.Visible = true; dot.Position = UDim2.new(0.5 + rel.X / range * 0.5, 0, 0.5 + rel.Z / range * 0.5, 0)
                dot.BackgroundColor3 = (plr.Character == targetInfoData.part.Parent) and Color3.fromRGB(255,90,110) or Color3.fromRGB(180,180,220)
            end
        end
        for i = idx + 1, #mmDots do mmDots[i].Visible = false end
    end
end)

-- Triggerbot
task.spawn(function()
    while active do
        task.wait(Config.FireRate)
        if Config.Triggerbot and Config.Enabled and currentTarget then
            local cam = WS.CurrentCamera
            if cam then
                local vp = cam.ViewportSize
                pcall(function()
                    local VIM = game:GetService("VirtualInputManager")
                    VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, true, game, 1)
                    task.wait(0.02)
                    VIM:SendMouseButtonEvent(vp.X/2, vp.Y/2, 0, false, game, 1)
                end)
            end
        end
    end
end)

-- Toggle key Z (like working script)
UIS.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Config.ToggleKey then
        Config.Enabled = not Config.Enabled
        notify("Aim", Config.Enabled and "ON" or "OFF", Config.Enabled and Color3.fromRGB(80,240,150) or Color3.fromRGB(255,90,110))
    end
end)

-- Drag system
local dragActive = false; local dragOffset = nil; local altHeld = false
header.MouseButton1Down:Connect(function()
    dragActive = true
    if UIS.MouseBehavior == Enum.MouseBehavior.Default then dragOffset = Vector2.new(Mouse.X - panel.AbsolutePosition.X, Mouse.Y - panel.AbsolutePosition.Y) end
end)
UIS.InputBegan:Connect(function(input) if input.KeyCode == Config.DragModifier then altHeld = true end end)
UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Config.DragModifier then altHeld = false end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragActive = false; dragOffset = nil; sliding.active = false; sliding.fn = nil end
end)
UIS.InputChanged:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local d = input.Delta
    if sliding.active and sliding.fn then
        if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then sliding.vX += d.X; sliding.fn(sliding.vX) else sliding.fn(input.Position.X) end
        return
    end
    if altHeld or dragActive then
        local c = panel.Position; panel.Position = UDim2.new(c.X.Scale, c.X.Offset + d.X, c.Y.Scale, c.Y.Offset + d.Y)
    end
end)
RS.RenderStepped:Connect(function()
    if dragActive and dragOffset and UIS.MouseBehavior == Enum.MouseBehavior.Default then panel.Position = UDim2.fromOffset(Mouse.X - dragOffset.X, Mouse.Y - dragOffset.Y) end
end)

closeBtn.MouseButton1Click:Connect(function() panel.Visible = false end)
UIS.InputBegan:Connect(function(input) if input.KeyCode == Config.ToggleMenuKey then panel.Visible = not panel.Visible end end)

-- Auto-load
if Config.AutoLoadConfig ~= "" then
    local cfg = ConfigStore.Load(Config.AutoLoadConfig)
    if cfg then for k, v in pairs(cfg) do if Config[k] ~= nil then Config[k] = v end end; refresh() end
end

switchTab("AIM")
refresh()

notify("Utopia v17.0", "Working logic loaded | Press Z to toggle", CurrentTheme.accent)
