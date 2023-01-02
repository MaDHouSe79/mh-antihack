local QBCore = exports['qb-core']:GetCoreObject()
local freezed = false

local function DisableActions(state)
    SetNuiFocus(false, false)
    DisableAllControlActions(0)
    DisableFrontendThisFrame()
    DisablePlayerFiring(PlayerId(), state) -- Disable weapon firing
    DisableControlAction(0, 1, state) -- LookLeftRight
    DisableControlAction(0, 2, state) -- LookUpDown
    DisableControlAction(0, 106, state) -- VehicleMouseControlOverride
    DisableControlAction(0, 30, state) -- disable left/right
    --DisableControlAction(0, 31, state) -- disable forward/back
    DisableControlAction(0, 36, state) -- INPUT_DUCK
    DisableControlAction(0, 21, state) -- disable sprint
    DisableControlAction(0, 63, state) -- veh turn left
    DisableControlAction(0, 64, state) -- veh turn right
    DisableControlAction(0, 71, state) -- veh forward
    DisableControlAction(0, 72, state) -- veh backwards
    DisableControlAction(0, 75, state) -- disable exit vehicle
    DisableControlAction(0, 86, state) -- INPUT_VEH_HORN
    DisableControlAction(0, 24, state) -- disable attack
    DisableControlAction(0, 25, state) -- disable aim
    DisableControlAction(1, 37, state) -- disable weapon select
    DisableControlAction(0, 47, state) -- disable weapon
    DisableControlAction(0, 58, state) -- disable weapon
    DisableControlAction(0, 140, state) -- disable melee
    DisableControlAction(0, 141, state) -- disable melee
    DisableControlAction(0, 142, state) -- disable melee
    DisableControlAction(0, 143, state) -- disable melee
    DisableControlAction(0, 202, state) -- BACKSPACE / ESC
    DisableControlAction(0, 155, state) -- LEFT SHIFT
    DisableControlAction(0, 263, state) -- disable melee
    DisableControlAction(0, 264, state) -- disable melee
    DisableControlAction(0, 257, state) -- disable melee
end

local function KickBanHacker()
    local id = PlayerPedId()
    Wait(2000)
    if Config.UseJumpScare then
        TriggerEvent('qb-jumpscares:client:jumpscareplayer')
    end
    Wait(1000)
    if Config.UseExplosion then
        FreezeEntityPosition(id, true)
        local coords = GetEntityCoords(id)
        if Config.ClearArea then
            ClearAreaOfPeds(vector3(coords.x, coords.y, coords.z), 9999999.0, 1)
            ClearAreaOfVehicles(vector3(coords.x, coords.y, coords.z), 9999999.0, false, false, false, false, false)
        end
        AddExplosion(vector3(coords.x, coords.y, coords.z), 5, 50.0, true, false, true)
        FreezeEntityPosition(id, false)
    end
    Wait(4000)
    TriggerServerEvent('qb-admin:server:ban', id, 99999999, "Hackertje")
    TriggerServerEvent('mh-antihack:server:drop')
end

local function FreezePlayer()
    local id = PlayerPedId()
    local coords = GetEntityCoords(id)
    SetNuiFocus(false, false)
    SetEntityVisible(id, true, 0)
    DisablePlayerFiring(id, true)
    ClearAreaOfPeds(vector3(coords.x, coords.y, coords.z), 9999999.0, 1)
    ClearAreaOfVehicles(vector3(coords.x, coords.y, coords.z), 9999999.0, false, false, false, false, false)
end

local function UnFreezePlayer()
    local id = PlayerPedId()
    local coords = GetEntityCoords(id)
    SetNuiFocus(false, false)
    FreezeEntityPosition(id, false)
    SetEntityVisible(id, true, 0)
    DisablePlayerFiring(id, false)
    DisableActions(false)
end

RegisterNetEvent("mh-antihack:client:freezehacker", function()
    FreezePlayer()
    freezed = true
end)

RegisterNetEvent("mh-antihack:client:unfreezehacker", function()
    UnFreezePlayer()
    freezed = false
end)

RegisterNetEvent("mh-antihack:client:blowhacker", function()
    KickBanHacker()
end)

RegisterNetEvent("mh-antihack:client:killhacker", function()
    local id = PlayerPedId()
    SetEntityHealth(id, 0.0)
end)

RegisterNetEvent("mh-antihack:client:bancrashhacker", function()
    local id = PlayerPedId()
    local coords = GetEntityCoords(id)
    TriggerServerEvent('mh-antihack:server:ban')
    AddExplosion(vector3(coords.x, coords.y, coords.z), 5, 50.0, true, false, true)
    CrashHacker()
end)

RegisterNetEvent("mh-antihack:client:crashhacker", function()
    local id = PlayerPedId()
    local coords = GetEntityCoords(id)
    AddExplosion(vector3(coords.x, coords.y, coords.z), 5, 50.0, true, false, true)
    Wait(1000)
    CrashHacker()
end)

RegisterNetEvent('mh-antihack:client:antiHackMenu', function()
    local playerlist = {}
    QBCore.Functions.TriggerCallback('mh-antihack:server:GetOnlinePlayers', function(online)
        for key, v in pairs(online) do
            playerlist[#playerlist + 1] = {value = v.source, text = "(ID:"..v.source..") "..v.fullname}
        end
        local menu = exports["qb-input"]:ShowInput({
            header = "Anti Hackers",
            submitText = "Have fun with the hacker",
            inputs = {
                {
                    text = "Selecteer speler",
                    name = "id",
                    type = "select",
                    options = playerlist,
                    isRequired = true
                },
                {
                    text = "Selecteer Optie",
                    name = "mode",
                    type = "select",
                    options = {
                        { value = "bancrash", text = "Ban en Crash Hacker" },
                        { value = "crash", text = "Crash Hacker" },
                        { value = "freeze", text = "Troll Hacker" },
                        { value = "unfreeze", text = "UnFreeze Hacker"},
                        { value = "blowup", text = "Blowup Hacker" },
                        { value = "kill", text = "Kill Hacker" },
                    },
                    isRequired = true
                }
            }
        })
        if menu then
            if not menu.id and not menu.mode then
                return
            else
                TriggerServerEvent('mh-antihack:server:action', tonumber(menu.id), tostring(menu.mode))
            end
        end
    end)
end)

RegisterNetEvent('qb-radialmenu:client:onRadialmenuOpen', function()
    QBCore.Functions.TriggerCallback("mh-antihack:server:isAdmin", function(isAdmin)
        if isAdmin then
            if MenuItemId ~= nil then
                exports['qb-radialmenu']:RemoveOption(MenuItemId)
                MenuItemId = nil
            end
            MenuItemId = exports['qb-radialmenu']:AddOption({
                id = 'antihack0001',
                title = "Anti Hacker",
                icon = 'angry',
                type = 'client',
                event = 'mh-antihack:client:antiHackMenu',
                shouldClose = true
            }, MenuItemId)
        else
            MenuItemId = nil
        end
    end)
end)

local function IsPressingButton()
    local isPressed = false
    for i = 1, 360 do
        if IsControlJustReleased(0, i) then
            isPressed = true
        end
    end
    return isPressed
end

local canUse = true
CreateThread(function()
    while true do
        if freezed then
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsUsing(ped)
            SetFollowPedCamViewMode(4)
            SetEntityHealth(ped, 100.0)
            -- W or Left Alt or BACKSPACE / ESC
            if IsPressingButton() and canUse then 
                canUse = false
                SetNuiFocus(false, false)
                local forcecount = 0 -- Slap function from OFRP
                if IsPedInAnyVehicle(ped, true) then
                    repeat
                        ApplyForceToEntity(veh, 1, 9500.0, 25.0, 7100.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
                        forcecount = forcecount + 1
                        Wait(0)
                    until(forcecount > 10)
                else
                    ApplyForceToEntity(ped, 1, 3000.0, 25.0, 3000.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
                    Wait(100)
                    SetPedToRagdoll(ped, 500, 500, 0, false, false, false)
                end
                local coords = GetEntityCoords(PlayerPedId())
                ClearAreaOfPeds(vector3(coords.x, coords.y, coords.z), 500.0, 1)
                ClearAreaOfVehicles(vector3(coords.x, coords.y, coords.z), 500.0, false, false, false, false, false)
                forcecount = 0
            end
            -- S -- Black screen
            if IsControlJustReleased(0, 33) and canUse then
                canUse = false
                SetNuiFocus(false, false)
                DoScreenFadeOut(5)
                Wait(6000)
                DoScreenFadeIn(0)
            end
            if not canUse then
                SetTimeout(500, function()
                    canUse = true     
                end)
            end
        end
        Wait(0)
    end
end)

CreateThread(function()
	while true do
        local sleep = 1000
        if freezed then
            PlayerData = QBCore.Functions.GetPlayerData()
            if PlayerData.metadata['isdead'] or PlayerData.metadata['inlaststand'] and not updated then
                updated = true
                sleep = 5
                TriggerEvent("hospital:client:Revive")
            end
            if not PlayerData.metadata['isdead'] or not PlayerData.metadata['inlaststand'] and updated then
                sleep = 1000
                updated = false
            end
        end
        Wait(sleep)
    end
end)

function CrashHacker()
    CreateThread(function()
        while true do
            print("Buy Buy...")
        end
    end)
end