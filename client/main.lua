
local isDead = false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterCommand('tow', function()
	if ESX.PlayerData.job.grade_name == 'Tow' then
		local playerPed = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(playerPed, true)

		local towmodel = GetHashKey('flatbed')
		local isVehicleTow = IsVehicleModel(vehicle, towmodel)

		if isVehicleTow then
			local targetVehicle = ESX.Game.GetVehicleInDirection()

			if CurrentlyTowedVehicle == nil then
				if targetVehicle ~= 0 then
					if not IsPedInAnyVehicle(playerPed, true) then
						if vehicle ~= targetVehicle then
							local timer = 10000
							TriggerEvent("animation:tow")
						    local finished = exports["fu-taskbar"]:taskBar(timer,"Hooking up vehicle.")

						    if finished == 100 then
								AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
								CurrentlyTowedVehicle = targetVehicle
								TriggerEvent('DoLongHudText','Vehicle Attached',1, 8000)
								towingProcess = false
							end
						else
							TriggerEvent('DoLongHudText','No Vehicle Or Is Tow Truck',2, 8000)
						end
					end
				else
					TriggerEvent('DoLongHudText','No Vehicle Or Is Tow Truck',2, 8000)
				end
			else

				local timer = 2000
				TriggerEvent("animation:tow")
				local finished = exports["fu-taskbar"]:taskBar(timer,"Releasing From Tow")

				if finished == 100 then
					AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
					DetachEntity(CurrentlyTowedVehicle, true, true)
					CurrentlyTowedVehicle = nil
					TriggerEvent('DoLongHudText','Vehicle Attached',1, 8000)
					towingProcess = false
				end
			end
		else
			TriggerEvent('DoLongHudText','Need A Flatbed',2, 8000)
		end
	end
end)


RegisterNetEvent('animation:tow')
AddEventHandler('animation:tow', function()
	towingProcess = true
    local lPed = PlayerPedId()
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end
    while towingProcess do

        if not IsEntityPlayingAnim(lPed, "mini@repair", "fixing_a_player", 3) then
            ClearPedSecondaryTask(lPed)
            TaskPlayAnim(lPed, "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end
        Citizen.Wait(1)
    end
    ClearPedTasks(lPed)
end)


RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('esx:onPlayerSpawn', function(spawn)
	isDead = false
end)



RegisterCommand('Impound', function(source)
	TriggerEvent('Delete')
end)


deleteCar = function( entity )
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
end


RegisterNetEvent('Delete')
AddEventHandler( 'Delete', function()
    local ped = GetPlayerPed( -1 )
    local coords = GetEntityCoords(ped)
    local vehicle = GetClosestVehicle(coords, 5)
    if IsPedSittingInAnyVehicle( ped ) then 
        SetEntityAsMissionEntity( vehicle, true, true )
        deleteCar( vehicle )
    end 
end)
