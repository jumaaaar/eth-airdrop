ESX = exports['es_extended']:getSharedObject()
GlobalState.crateInventory = 'Plan5eCrate'
local isAirdropOngoing = false


local function StartAirdropFuck()

    if isAirdropOngoing then
        print("An airdrop is already ongoing.")
        return
    end

    isAirdropOngoing = true
 
    if #Config.DropPositions == 0 then
        print("Drop Pos is empty. Cannot start airdrop.")
        isAirdropOngoing = false  -- Reset the flag if no positions are available
        return
    end

    -- Select a random position from Config.DropPositions
    local pos = math.random(1, #Config.DropPositions)
    local randomPosition = Config.DropPositions[pos]

    -- Trigger the airdrop creation event
    TriggerClientEvent('eth-airdrop:createAirdrop', -1, randomPosition)
    TriggerClientEvent('eth-airdrop:startSmoke', -1, randomPosition.plane_position.coords)
    
    -- PTFX: Create visual effect
    local ptDict, ptName = "core", "exp_grd_grenade_smoke"
    local position = {
        coords = vector3(randomPosition.plane_position.coords.x, randomPosition.plane_position.coords.y, randomPosition.plane_position.coords.z + 0.8),
        rot = { x = 0.0, y = 0.0, z = 0.0 },
        scale = 5.0,
        alpha = 0.4,
        color = { r = 175 / 255, g = 182 / 255, b = 179 / 255 }
    }
    TriggerClientEvent("eth-airdrop:sync:smoke", -1, ptDict, ptName, true, position, 300000, 'plane_drop_crate')

    exports.ox_inventory:ClearInventory({ id = GlobalState.crateInventory })
    
    local stash = {
        id = GlobalState.crateInventory,
        label = 'Plane Crate',
        slots = 10,
        weight = 100000,
    }

    exports.ox_inventory:RegisterStash(stash.id, stash.label, stash.slots, stash.weight, false)


    
    local randomValue = math.random(1, 100)

    for _, reward in ipairs(Config.rewards) do
        if reward.percentage > randomValue then
            exports.ox_inventory:AddItem(GlobalState.crateInventory, reward.item, math.random(reward.min_qty, reward.max_qty))
        end
    end
    -- Select a random player and get the street name
    local players = ESX.GetPlayers()
    if #players == 0 then
        print("No players online.")
        return
    end
    
    local randomIndex = math.random(1, #players)

    local randomPlayer = ESX.GetPlayerFromId(players[randomIndex])
    local streetName = lib.callback.await('eth-airdrop:getStreetLocationLabel', randomPlayer.source, randomPosition.plane_position.coords)

    -- Send notification
    local success, result = pcall(function()
        local message = "Attention everyone in the area: there is a plane crashed near "..streetName..". This is a time-sensitive opportunity, so act quickly if you are interested. Please be safe and mindful of others while you make your way to the location."
        local subject = 'AIRDROP'
        TriggerClientEvent('chat:addMessage', -1, {
            template = '<div class="chat-message airdrop"><b><span class="" style="color: #e1e1e1">[{1}]</span>&nbsp;</span></b><div style="margin-top: 5px; font-weight: 300;">{0}</div></div>',
            args = {message, subject}
        })
    end)
end


RegisterCommand("air" , function()
    StartAirdropFuck()
end)


local function ScheduleNextAirdrop()
    local planeCooldown = Config.AirdropTimer 
    Citizen.SetTimeout(planeCooldown * 60000, function() 
        StartAirdropFuck()
        ScheduleNextAirdrop() 
    end)
end

ScheduleNextAirdrop()






















