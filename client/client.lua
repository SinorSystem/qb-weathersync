local CurrentWeather = Config.StartWeather
local lastWeather = CurrentWeather
local baseTime = Config.BaseTime
local timeOffset = Config.TimeOffset
local timer = 0
local freezeTime = Config.FreezeTime
local blackout = Config.Blackout
local blackoutVehicle = Config.BlackoutVehicle
local disable = Config.Disabled

local isBlackoutOverridden = false
local currentPlayerInZone = false

local function isInBlackoutZone()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, zone in ipairs(Config.blackoutZones) do
        if #(playerCoords - zone.coords) < zone.radius then
            return true
        end
    end
    return false
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    disable = false
    TriggerServerEvent('qb-weathersync:server:RequestStateSync')
end)

RegisterNetEvent('qb-weathersync:client:EnableSync', function()
    disable = false
    TriggerServerEvent('qb-weathersync:server:RequestStateSync')
end)

RegisterNetEvent('qb-weathersync:client:DisableSync', function()
    disable = true
    CreateThread(function()
        while disable do
            SetRainLevel(0.0)
            SetWeatherTypePersist('CLEAR')
            SetWeatherTypeNow('CLEAR')
            SetWeatherTypeNowPersist('CLEAR')
            NetworkOverrideClockTime(18, 0, 0)
            Wait(5000)
        end
    end)
end)

RegisterNetEvent('qb-weathersync:client:SyncWeather', function(NewWeather, newblackout)
    CurrentWeather = NewWeather
    blackout = newblackout
end)

RegisterNetEvent('qb-weathersync:client:SyncTime', function(base, offset, freeze)
    freezeTime = freeze
    timeOffset = offset
    baseTime = base
end)

CreateThread(function()
    while true do
        if not disable then
            if lastWeather ~= CurrentWeather then
                lastWeather = CurrentWeather
                SetWeatherTypeOverTime(CurrentWeather, 15.0)
                Wait(15000)
            end
            Wait(100) -- Wait 0 seconds to prevent crashing.
            if blackout then
                local inBlackoutZone = isInBlackoutZone()
                if inBlackoutZone and not currentPlayerInZone then
                    SetArtificialLightsState(false)
                    SetArtificialLightsStateAffectsVehicles(false)
                    isBlackoutOverridden = true
                    currentPlayerInZone = true
                elseif not inBlackoutZone and currentPlayerInZone then
                    SetArtificialLightsState(true)
                    SetArtificialLightsStateAffectsVehicles(true)
                    isBlackoutOverridden = false
                    currentPlayerInZone = false
                elseif not inBlackoutZone and not isBlackoutOverridden then
                    SetArtificialLightsState(blackout)
                    SetArtificialLightsStateAffectsVehicles(blackoutVehicle)
                end
            else
                if isBlackoutOverridden then
                    SetArtificialLightsState(true)
                    SetArtificialLightsStateAffectsVehicles(true)
                    isBlackoutOverridden = false
                    currentPlayerInZone = false
                else
                    SetArtificialLightsState(blackout)
                    SetArtificialLightsStateAffectsVehicles(blackoutVehicle)
                end
            end
            ClearOverrideWeather()
            ClearWeatherTypePersist()
            SetWeatherTypePersist(lastWeather)
            SetWeatherTypeNow(lastWeather)
            SetWeatherTypeNowPersist(lastWeather)
            if lastWeather == 'XMAS' then
                SetForceVehicleTrails(true)
                SetForcePedFootstepsTracks(true)
            else
                SetForceVehicleTrails(false)
                SetForcePedFootstepsTracks(false)
            end
            if lastWeather == 'RAIN' then
                SetRainLevel(0.3)
            elseif lastWeather == 'THUNDER' then
                SetRainLevel(0.5)
            else
                SetRainLevel(0.0)
            end
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    local hour
    local minute = 0
    local second = 0        --Add seconds for shadow smoothness
    while true do
        if not disable then
            Wait(0)
            local newBaseTime = baseTime
            if GetGameTimer() - 22  > timer then    --Generate seconds in client side to avoid communiation
                second = second + 1                 --Minutes are sent from the server every 2 seconds to keep sync
                timer = GetGameTimer()
            end
            if freezeTime then
                timeOffset = timeOffset + baseTime - newBaseTime
                second = 0
            end
            baseTime = newBaseTime
            hour = math.floor(((baseTime+timeOffset)/60)%24)
            if minute ~= math.floor((baseTime+timeOffset)%60) then  --Reset seconds to 0 when new minute
                minute = math.floor((baseTime+timeOffset)%60)
                second = 0
            end
            NetworkOverrideClockTime(hour, minute, second)          --Send hour included seconds to network clock time
        else
            Wait(1000)
        end
    end
end)
