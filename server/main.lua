local QBCore = exports['qb-core']:GetCoreObject()

local function GetOnlinePlayers()
    local sources = {}	
    for k, id in pairs(QBCore.Functions.GetPlayers()) do
		local target = QBCore.Functions.GetPlayer(id)
		local info = {
			source = target.PlayerData.source,
			fullname = target.PlayerData.charinfo.firstname.." "..target.PlayerData.charinfo.lastname,
		}
        sources[#sources+1] = info
    end
    return sources
end

QBCore.Functions.CreateCallback("mh-antihack:server:GetOnlinePlayers", function(source, cb)
	cb(GetOnlinePlayers())
end)

QBCore.Functions.CreateCallback('mh-antihack:server:isAdmin', function(source, cb)
    local src = source
    local isAllowed = false
    if IsPlayerAceAllowed(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        isAllowed = true
    end
    cb(isAllowed)
end)

QBCore.Commands.Add('antihack', "", {}, true, function(source)
    local src = source
	TriggerClientEvent('mh-antihack:client:antiHackMenu', src)
end, 'admin')

RegisterServerEvent('mh-antihack:server:action', function(id, mode)
	local src = source
	if IsPlayerAceAllowed(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
		if mode == "freeze" then TriggerClientEvent("mh-antihack:client:freezehacker", id) end
		if mode == "unfreeze" then TriggerClientEvent("mh-antihack:client:unfreezehacker", id) end
		if mode == "blowup" then TriggerClientEvent("mh-antihack:client:blowhacker", id) end
		if mode == "kill" then TriggerClientEvent("mh-antihack:client:killhacker", id) end
        if mode == "crash" then TriggerClientEvent("mh-antihack:client:crashhacker", id) end
        if mode == "bancrash" then TriggerClientEvent("mh-antihack:client:bancrashhacker", id) end       
	end
end)

RegisterServerEvent('mh-antihack:server:ban', function()
    local src = source
    local banTime = tonumber(os.time() + tonumber(99999999999))
    if banTime > 2147483647 then banTime = 2147483647 end
	MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
         GetPlayerName(src),
        QBCore.Functions.GetIdentifier(src, 'license'),
        QBCore.Functions.GetIdentifier(src, 'discord'),
        QBCore.Functions.GetIdentifier(src, 'ip'),
        Config.KickBanMessage,
        banTime,
        "mh-antihacker"
    })
    TriggerClientEvent('chat:addMessage', -1, {
        template = "<div class=chat-message server'><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>",
        args = {GetPlayerName(src), "(BANNED)"}
    })
end)


RegisterServerEvent('mh-antihack:server:drop', function()
	local src = source
	if Config.DropPlayer then
		time = tonumber(99999999999)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then banTime = 2147483647 end
		MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            GetPlayerName(src),
            QBCore.Functions.GetIdentifier(src, 'license'),
            QBCore.Functions.GetIdentifier(src, 'discord'),
            QBCore.Functions.GetIdentifier(src, 'ip'),
            Config.KickBanMessage,
            banTime,
            "mh-antihacker"
        })
        TriggerClientEvent('chat:addMessage', -1, {
            template = "<div class=chat-message server'><strong>ANNOUNCEMENT | {0} has been banned:</strong> {1}</div>",
            args = {GetPlayerName(src), "(BANNED)"}
        })
		Wait(5000)
		DropPlayer(src, Config.KickBanMessage)
	end
end)