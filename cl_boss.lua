ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local PlayerData = {}
local societycardealermoney = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
     PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	Citizen.Wait(5000) 
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
    end
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end
    if ESX.IsPlayerLoaded() then

		ESX.PlayerData = ESX.GetPlayerData()

    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


---------------- FONCTIONS ------------------

function BossConcess()
  local BConcess = RageUI.CreateMenu("Actions Patron", "Concessionnaire")

    RageUI.Visible(BConcess, not RageUI.Visible(BConcess))

            while BConcess do
                Citizen.Wait(0)
                    RageUI.IsVisible(BConcess, true, true, true, function()

                    if societycardealermoney ~= nil then
                        RageUI.ButtonWithStyle("Argent société :", nil, {RightLabel = "$" .. societycardealermoney}, true, function()
                        end)
                    end

                    RageUI.ButtonWithStyle("Retirer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local amount = KeyboardInput("Montant", "", 10)
                            amount = tonumber(amount)
                            if amount == nil then
                                RageUI.Popup({message = "Montant invalide"})
                            else
                                TriggerServerEvent('esx_society:withdrawMoney', 'cardealer', amount)
                                RefreshcardealerMoney()
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("Déposer argent de société",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local amount = KeyboardInput("Montant", "", 10)
                            amount = tonumber(amount)
                            if amount == nil then
                                RageUI.Popup({message = "Montant invalide"})
                            else
                                TriggerServerEvent('esx_society:depositMoney', 'cardealer', amount)
                                RefreshcardealerMoney()
                            end
                        end
                    end) 

                    RageUI.ButtonWithStyle("Accéder aux actions de Management",nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                        if Selected then
                            aboss()
                            RageUI.CloseAll()
                        end
                    end)
                end, function()
            end)
            if not RageUI.Visible(BConcess) then
            BConcess = RMenu:DeleteType("BConcess", true)
        end
    end
end   

---------------------------------------------

Citizen.CreateThread(function()
    while true do
        local Timer = 500
        if ESX.PlayerData.job and ESX.PlayerData.job.name == 'cardealer' and ESX.PlayerData.job.grade_name == 'boss' then
        local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
        local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, Concess.pos.boss.position.x, Concess.pos.boss.position.y, Concess.pos.boss.position.z)
        if dist3 <= 10.0 and Concess.jeveuxmarker then
            Timer = 0
            DrawMarker(20, Concess.pos.boss.position.x, Concess.pos.boss.position.y, Concess.pos.boss.position.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 255, 255, 255, 255, 0, 1, 2, 0, nil, nil, 0)
            end
            if dist3 <= 3.0 then
                Timer = 0   
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder aux actions patron", time_display = 1 })
                        if IsControlJustPressed(1,51) then           
                            RefreshcardealerMoney()
                            BossConcess()
                    end   
                end
            end 
        Citizen.Wait(Timer)
    end
end)

function RefreshcardealerMoney()
    if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
        ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
            UpdateSocietycardealerMoney(money)
        end, ESX.PlayerData.job.name)
    end
end

function UpdateSocietycardealerMoney(money)
    societycardealermoney = ESX.Math.GroupDigits(money)
end

function aboss()
    TriggerEvent('esx_society:openBossMenu', 'cardealer', function(data, menu)
        menu.close()
    end, {wash = false})
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end