ESX = exports['es_extended']:getSharedObject()

local cratePos = nil


local objectData = {}
local timer = 0
local distance = 300.0

local options = {
	label = "Open Crate",
	name = "crate",
	icon = "fas fa-user-secret",
	distance = 1.5,
	event = "eth-airdrop:openCrate"
}
			
local function spawnAirdrop(v)
	if v.spawned then return end

	RequestModel(v.model)
	while not HasModelLoaded(v.model) do
		Citizen.Wait(10)
	end
	
	local object = CreateObject(v.model, v.coords, false, false, false)
	Citizen.Wait(0)

	if DoesEntityExist(object) then
		v.entity, v.spawned = object, true
		SetEntityRotation(v.entity, v.rotation, 2, true)
		PlaceObjectOnGroundProperly(v.entity)
		FreezeEntityPosition(v.entity, true)
		SetEntityInvincible(v.entity, true)
		table.insert(objectData, v.entity)

		if v.model == 'ex_prop_crate_closed_bc' then
			SetEntityAsMissionEntity(v.entity, true, true)
			exports["ox_target"]:addLocalEntity(v.entity, options)		
		end
	end

	SetModelAsNoLongerNeeded(v.model)
end

local function deleteAirdrop(v)
	if not v.spawned then return end

	if DoesEntityExist(v.entity) then
		if v.model == 'ex_prop_crate_closed_bc' then
			exports.ox_target:removeLocalEntity(v.entity, options)			
		end
		DeleteEntity(v.entity)
	end
end

RegisterNetEvent("eth-airdrop:createAirdrop", function(randomPosition)
	for k, v in pairs(objectData) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
			exports.ox_target:removeLocalEntity(v)			
		end
	end
	
	objectData = {}	
	cratePos = randomPosition
	timer = 15 * 60
	
	Citizen.CreateThread(function()
		while timer > 0 do
			timer = timer - 1
			Citizen.Wait(1000)
		end
	end)
		
	Citizen.CreateThread(function()
		while timer > 0 do
			local dist = #(GetEntityCoords(PlayerPedId()) - cratePos.crate_position.coords)
			if dist < 15.0 then
				DrawTimerText(cratePos.crate_position.coords)
			end
			Citizen.Wait(0)
		end
	end)	

	while cratePos do
		local sleep = 1000
		local playerPed = cache.ped
		local pedCoords = GetEntityCoords(playerPed)

		for k, v in pairs(cratePos) do
			local dist = #(pedCoords - v.coords)
			if dist <= distance and not v.spawned then
				spawnAirdrop(v)
			elseif dist > distance and v.spawned then
				deleteAirdrop(v)
			end
		end
		Wait(sleep)
	end
end)

function DrawTimerText(coords)
	local minutes = math.floor(timer / 60)
	local seconds = timer % 60
	local timerText = string.format("Time Left: %02d:%02d", minutes, seconds)

	local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.0)
	if onScreen then
		SetTextFont(4)
		SetTextProportional(1)
		SetTextScale(0.5, 0.5)
		SetTextColour(255, 255, 255, 255)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(timerText)
		DrawText(_x, _y)
	end
end

RegisterNetEvent('eth-airdrop:startSmoke', function(coords)
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Citizen.Wait(1)
        end
    end

    SetPtfxAssetNextCall("core")
    local smoke = StartParticleFxLoopedAtCoord("exp_grd_flare", coords + 1.7, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
    SetParticleFxLoopedAlpha(smoke, 0.8)
    SetParticleFxLoopedColour(smoke, 0.0, 0.0, 0.0, 0)
	local Blips = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(Blips, 90)
	SetBlipDisplay(Blips, 4)
	SetBlipScale(Blips, 1.0)
	SetBlipColour(Blips, 40)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Air Drop')
    EndTextCommandSetBlipName(Blips)	
    Citizen.Wait(1200000)
    StopParticleFxLooped(smoke, 0)
	RemoveBlip(Blips)
end)

RegisterNetEvent("eth-airdrop:openCrate", function(target, cData)
    
	if timer > 0 then 
        exports['es_extended']:Notify('error', 5000, 'You can not open the crate yet', 'SYSTEM')
        return 
    end
	
    lib.requestAnimDict('mini@repair', 100)
    TaskPlayAnim(PlayerPedId(), 'mini@repair', 'fixing_a_player', 1.0, -1.0, -1, 49, 1, false, false, false)
    exports['ps-ui']:Circle(function(success)
        ClearPedTasks(PlayerPedId())
        lockpickingcrate = false
        
        if success then
            exports['es_extended']:Notify('success', 5000, 'You successfully opened the crate.', 'SYSTEM')
            exports.ox_inventory:openInventory('stash', {id = GlobalState.crateInventory})
        else
            exports['es_extended']:Notify('error', 5000, 'Failed Opening Crate', 'SYSTEM')
        end
    end, 4, math.random(6, 10))
end)

lib.callback.register('eth-airdrop:getStreetLocationLabel', function(location)
    local zoneName = GetLabelText(GetNameOfZone(location.x, location.y, location.z))
    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(location.x, location.y, location.z, currentStreetHash, intersectStreetHash)
    local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    local intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
    
    return currentStreetName .. ', ' .. zoneName
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == "eth-airdrop" then
        for k, v in pairs(objectData) do
            if DoesEntityExist(v) then
                DeleteEntity(v)
				exports.ox_target:removeLocalEntity(v)			
            end
        end
    end
end)

-- MISC

local ActiveParticles = {}
local BlacklistedParticles = {}

TriggerServerEvent("particles:player:ready")

function LoadParticleDictionary(dictionary)
    if not HasNamedPtfxAssetLoaded(dictionary) then
        RequestNamedPtfxAsset(dictionary)
        while not HasNamedPtfxAssetLoaded(dictionary) do
            Citizen.Wait(0)
        end
    end
end

function AddBlacklistedParticle(pDict, pName)
    BlacklistedParticles[('%s@%s'):format(pDict, pName)] = true
end

exports('AddBlacklistedParticle', AddBlacklistedParticle)

function RemoveBlacklistedParticle(pDict, pName)
    BlacklistedParticles[('%s@%s'):format(pDict, pName)] = nil
end

exports('RemoveBlacklistedParticle', RemoveBlacklistedParticle)

function IsParticleBlacklisted(pDict, pName)
    return BlacklistedParticles[('%s@%s'):format(pDict, pName)]
end

exports('IsParticleBlacklisted', IsParticleBlacklisted)

function StartParticleAtCoord(ptDict, ptName, looped, coords, rot, scale, alpha, color, duration)
    LoadParticleDictionary(ptDict)

    UseParticleFxAssetNextCall(ptDict)
    SetPtfxAssetNextCall(ptDict)

    local particleHandle

    if looped then
        particleHandle = StartParticleFxLoopedAtCoord(ptName, coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, scale or 1.0)

        if color then
            SetParticleFxLoopedColour(particleHandle, color.r, color.g, color.b, false)
        end

        SetParticleFxLoopedAlpha(particleHandle, alpha or 10.0)

        if duration then
            Citizen.Wait(duration)
            StopParticleFxLooped(particleHandle, 0)
        end
    else
        SetParticleFxNonLoopedAlpha(alpha or 10.0)

        if color then
            SetParticleFxNonLoopedColour(color.r, color.g, color.b)
        end

        StartParticleFxNonLoopedAtCoord(ptName, coords.x, coords.y, coords.z, rot.x, rot.y, rot.z, scale or 1.0)
    end

    return particleHandle
end

function StartParticleOnEntity(ptDict, ptName, looped, entity, bone, offset, rot, scale, alpha, color, evolution, duration)
    LoadParticleDictionary(ptDict)

    UseParticleFxAssetNextCall(ptDict)

    local particleHandle, boneID

    if bone and GetEntityType(entity) == 1 then
        boneID = GetPedBoneIndex(entity, bone)
    elseif bone then
        boneID = GetEntityBoneIndexByName(entity, bone)
    end

    if looped then
        if bone then
            particleHandle = StartParticleFxLoopedOnEntityBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale)
        else
            particleHandle = StartParticleFxLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale)
        end

        if evolution then
            SetParticleFxLoopedEvolution(particleHandle, evolution.name, evolution.amount, false)
        end

        if color then
            SetParticleFxLoopedColour(particleHandle, color.r, color.g, color.b, false)
        end

        SetParticleFxLoopedAlpha(particleHandle, alpha)

        if duration then
            Citizen.Wait(duration)
            StopParticleFxLooped(particleHandle, 0)
        end
    else
        SetParticleFxNonLoopedAlpha(alpha or 10.0)

        if color then
            SetParticleFxNonLoopedColour(color.r, color.g, color.b)
        end

        if bone then
            StartParticleFxNonLoopedOnPedBone(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, boneID, scale)
        else
            StartParticleFxNonLoopedOnEntity(ptName, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale)
        end
    end

    return particleHandle
end

RegisterNetEvent("eth-airdrop:sync:smoke")
AddEventHandler("eth-airdrop:sync:smoke", function(ptDict, ptName, looped, position, duration, ptID)
    if type(position.coords) == "table" then
        local particles = {}

        if IsParticleBlacklisted(ptDict, ptName) then return end

        for _, coords in ipairs(position.coords) do
            local particle = promise:new()

            Citizen.CreateThread(function()
                local particleHandle = StartParticleAtCoord(ptDict, ptName, looped, coords, position.rot, position.scale, position.alpha, position.color, duration)
                particle:resolve(particleHandle)
            end)

            particles[#particles + 1] = particle
        end

        if not duration and ptID then
            ActiveParticles[ptID] = particles
        end
    else
        local particleHandle = StartParticleAtCoord(ptDict, ptName, looped, position.coords, position.rot, position.scale, position.alpha, position.color, duration)

        if not duration and ptID then
            ActiveParticles[ptID] = particleHandle
        end
    end
end)

-- Handle custom notification event
RegisterNetEvent("eth-airdrop:notifyPlayers")
AddEventHandler("eth-airdrop:notifyPlayers", function(data)
    local sender = data.sender
    local subject = data.subject
    local message = data.message

    -- Display a notification on the player's screen
    exports['es_extended']:Notify('info', 5000, message, sender)
end)
