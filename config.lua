Config = {}
Config.DynamicWeather = false -- Set this to false if you don't want the weather to change automatically every 10 minutes.

-- On server start
Config.StartWeather = 'FOGGY' -- Default weather                       default: 'EXTRASUNNY'
Config.BaseTime = 8 -- Time                                             default: 8
Config.TimeOffset = 0 -- Time offset                                      default: 0
Config.FreezeTime = false -- freeze time                                  default: false
Config.Blackout = true -- Set blackout                                 default: false
Config.BlackoutVehicle = false -- Set blackout affects vehicles                default: false
Config.NewWeatherTimer = 10 -- Time (in minutes) between each weather change   default: 10
Config.Disabled = false -- Set weather disabled                         default: false

Config.AvailableWeatherTypes = { -- DON'T TOUCH EXCEPT IF YOU KNOW WHAT YOU ARE DOING
    'EXTRASUNNY',
    'CLEAR',
    'NEUTRAL',
    'SMOG',
    'FOGGY',
    'OVERCAST',
    'CLOUDS',
    'CLEARING',
    'RAIN',
    'THUNDER',
    'SNOW',
    'BLIZZARD',
    'SNOWLIGHT',
    'XMAS',
    'HALLOWEEN',
}

Config.blackoutZones = {
    {coords = vector3(457.77, -777.99, 27.79), radius = 80.0}, -- chinatown
    {coords = vector3(362.65, -1598.47, 36.95), radius = 80.0}, -- davis avenue
    -- Add more zones as needed
}
