local repS = cloneref(game:GetService("ReplicatedStorage"))
local plrs = cloneref(game:GetService("Players"))
local runS = cloneref(game:GetService("RunService"))
local ws = cloneref(game:GetService("Workspace"))
local uis = cloneref(game:GetService("UserInputService"))

local lplr = plrs.LocalPlayer

-- Sécurité de chargement initial : on attend que les modules et le joueur soient prêts
task.wait(20)

local util, enum, FighterController, SpectateController, MatchmakingController

pcall(function()
    local modules = repS:WaitForChild("Modules", 15)
    util = require(modules:WaitForChild("Utility", 10))
    enum = require(modules:WaitForChild("EnumLibrary", 10))
    
    local playerScripts = lplr:WaitForChild("PlayerScripts", 15)
    local controllers = playerScripts:WaitForChild("Controllers", 15)
    
    FighterController = require(controllers:WaitForChild("FighterController", 10))
    SpectateController = require(controllers:WaitForChild("SpectateController", 10))
    MatchmakingController = require(controllers:WaitForChild("MatchmakingController", 10))
end)

getgenv().Config = {
    Enabled = true,
    FireRate = 0.0002,
    DesyncEnabled = true,
    DesyncAngles = { Yaw = 180, Pitch = 44, Roll = 0 },
    DesyncJitter = 4.5,
    DesyncHeight = 3,
    DesyncDistance = 2,
    
    AutoQueueEnabled = true,
    QueueType = "1v1",
}

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

--------------------------------------------------------------------------------
-- AUTO QUEUE 1V1 SÉCURISÉ
--------------------------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(3)
        if getgenv().Config.AutoQueueEnabled then
            pcall(function()
                -- Récupération dynamique si recréé lors d'une téléportation
                if not MatchmakingController then
                    local controllers = lplr:FindFirstChild("PlayerScripts") and lplr.PlayerScripts:FindFirstChild("Controllers")
                    if controllers and controllers:FindFirstChild("MatchmakingController") then
                        MatchmakingController = require(controllers.MatchmakingController)
                    end
                end

                local isSpectating = SpectateController and SpectateController.CurrentDuelSubject ~= nil
                local char = lplr.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local isDead = not humanoid or humanoid.Health <= 0
                
                if isSpectating or isDead then
                    if MatchmakingController and type(MatchmakingController.QueueInto) == "function" then
                        MatchmakingController:QueueInto(getgenv().Config.QueueType)
                    end
                end
            end)
        end
    end
end)

runS.Heartbeat:Connect(function()
    pcall(function()
        updateDeflection()
        local targetPlayer, targetRoot, targetHead = getClosestTarget()

        if targetRoot and targetHead then
            local desyncPos = targetRoot.Position +
                targetRoot.CFrame.LookVector * getgenv().Config.DesyncDistance +
                Vector3.new(0, getgenv().Config.DesyncHeight, 0)
            currentDesyncCF = CFrame.lookAt(desyncPos, targetHead.Position)
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
            if not item or not util or not enum then return end

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

print("Auto Queue 1v1 sécurisé activé !")
