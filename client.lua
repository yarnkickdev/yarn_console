
local CommandConfig = {
    help = {
        command = "help",
        action = function()
            return listCommands()
        end,
        subcommands = {}
    },
    clear = {
        command = "clear",
        action = function()
            SendNUIMessage({ action = "clear" })
            -- return listCommands()
        end,
        -- subcommands = {}
    },
    list = {
        command = "list",
        subcommands = {
            devices = {
                action = function()
                    local laptopId, devices = exports.fd_laptop:getDevices()
                    -- local list = {}
                    local strRet = ("Listing devices connected to %s..."):format(laptopId)
                    for _, item in pairs(devices) do
                        -- list[_] = item.metadata.deviceUsb
                        strRet = ("%s\n(%s) %s"):format(strRet, item.slot, item.metadata.deviceUsb or '...')
                        -- strRet = strRet .. '\n' .. item.metadata.deviceUsb
                    end
                    return strRet
                end,
            },
            wifi = {
                action = function()
                    return "Listing available Wi-Fi networks..."
                end,
            },
        }
    },
    run = {
        command = "run",
        subcommands = {}
        -- get subcommands that each device allows to add from laptop storeage
    },
    -- Networking Commands
    ping = {
        command = "ping",
        action = function()
            local isConnected = exports.fd_laptop:isConnected()
            local vpnStatus = exports.fd_laptop:vpnStatus()
            if not isConnected then
                return "No internet connection?? dumb fuck connect to internet"
            end
            local connectedTo = exports.fd_laptop:getConnectedNetwork()
            local IP = not vpnStatus and GetNetworkIP(connectedTo.ssid) or GetNetworkIP(("vpn_%s_vpn_very_very_%s_secure"):format(connectedTo.ssid, math.random(1000000000, 9999999999)))

            return ("Pinging %s... Response time: %s ms"):format(IP, not vpnStatus and math.random(10,100) or math.random(100,350)) --This is currently fake lols good enough
        end,
        -- subcommands = {}
    },
    --Random
    joke = {
        command = "joke",
        action = function()
            -- Add some random jokes to display
            local jokes = {
                "Why don't skeletons fight each other? They don't have the guts.",
                "What do you call fake spaghetti? An impasta!",
                "Why did the scarecrow win an award? Because he was outstanding in his field."
            }
            local randomIndex = math.random(#jokes)
            return jokes[randomIndex]
        end,
        -- subcommands = {}
    },
    quote = {
        command = "quote",
        action = function()
            -- Add some random inspirational quotes
            local quotes = {
                "The best way to predict the future is to invent it. - Alan Kay",
                "Do what you can, with what you have, where you are. - Theodore Roosevelt",
                "The only limit to our realization of tomorrow is our doubts of today. - Franklin D. Roosevelt"
            }
            local randomIndex = math.random(#quotes)
            return quotes[randomIndex]
        end,
        -- subcommands = {}
    },
}

local resourceName = GetCurrentResourceName()

local _canCrack = false
local _successCooldown = {}

function GetNetworkIP(inputString) -- Thanks AI I couldnt be fucked writing this shit
   -- Use a simple hash function (for illustration purposes)
   local hash = 0
   for i = 1, #inputString do
       hash = hash + string.byte(inputString, i)
   end

   -- Map the hash to an IP address format in the 192.168.1.x range
   local ip1 = (hash % 234)
   local ip2 = (hash % 123)
   local ip3 = (hash % 543)
   local ip4 = (hash % 256)  -- Fourth octet is based on the hash

   return string.format("%d.%d.%d.%d", ip1, ip2, ip3, ip4)
end


function IsCrackAllowed(deviceUsb)
    -- Code logic for this later
    return _canCrack and not _successCooldown[deviceUsb] or false
end

function SetCanCrack(boolean)
    _canCrack = boolean
end
exports("SetCanCrack", SetCanCrack) -- export for other scripts

--[[]]

local poly = lib.zones.sphere({
    coords = vector3(-111.7742, -8.7017, 70.5196),
    radius = 2,
    onEnter = function(self)
        exports.fd_laptop:addNetwork({
            ssid = "telephone_hotspot_apartment",
            label = "Apartment Hotspot",
        })
    end,
    onExit = function(self)
        exports.fd_laptop:removeNetwork('telephone_hotspot_apartment')
    end
})

local poly = lib.zones.sphere({
    coords = vector3(-111.7742, -8.7017, 70.5196),
    radius = 2,
    onEnter = function(self)
        exports.fd_laptop:addNetwork({
            ssid = "mission_row_secure_network",
            label = "Apartment Hotspot 2",
        })
    end,
    onExit = function(self)
        exports.fd_laptop:removeNetwork('mission_row_secure_network')
    end
})

-- local poly = lib.zones.poly({
--     points = {
--         vec(413.8, -1026.1, 29),
--         vec(411.6, -1023.1, 29),
--         vec(412.2, -1018.0, 29),
--         vec(417.2, -1016.3, 29),
--         vec(422.3, -1020.0, 29),
--         vec(426.8, -1015.9, 29),
--         vec(431.8, -1013.0, 29),
--         vec(437.3, -1018.4, 29),
--         vec(432.4, -1027.2, 29),
--         vec(424.7, -1023.5, 29),
--         vec(420.0, -1030.2, 29),
--         vec(409.8, -1028.4, 29),
--     },
--     thickness = 2,
--     debug = true,
--     onEnter = function(self)
--         exports.fd_laptop:addNetwork({
--             ssid = "mission_row_secure_network",
--             label = "Mission Row WiFi69420",
--             password = "123456"
--         })
--     end,
--     onExit = function(self)
--         exports.fd_laptop:removeNetwork('mission_row_secure_network')
--     end
-- })

CreateThread(function()
    local inZone = false
    local zone = vector3(-227.8261, -1327.8838, 30.8904)
    while true do
        Wait(0)
        local myCoords = GetEntityCoords(PlayerPedId())
        if #(zone - myCoords) < 5 then
            if not inZone then
                inZone = true
                exports.yarn_hacking:SetCanCrack(true)
            end
        elseif inZone then
            inZone = false
            exports.yarn_hacking:SetCanCrack(false)
        end
    end
end)
--]]

function SetDeviceCooldown(deviceUsb)
    _successCooldown[deviceUsb] = true
    Citizen.SetTimeout(math.random(10000,50000), function()
        InputConsole(("%s is now available!"):format(deviceUsb))
        _successCooldown[deviceUsb] = nil
    end)
end

local prefixStrings = {
    ["CRACK_"] = function(laptopId, item)
        local deviceUsb = item.metadata.deviceUsb
        return {
            hack = {
                action = function()
                    if not IsCrackAllowed(deviceUsb) then
                        if _successCooldown and _successCooldown[deviceUsb] then return ("%s is not available!"):format(deviceUsb) end
                        return "Device is not connected to anything for the crack to run"
                    end
                    local success = RandomMinigameHack(laptopId, item)
                    if success then
                        -- Successful
                        _successCooldown[deviceUsb] = true
                        Citizen.SetTimeout(math.random(10000,50000), function()
                            InputConsole(("%s is now available!"):format(deviceUsb))
                            _successCooldown[deviceUsb] = nil
                        end)

                        SetDeviceCooldown(deviceUsb)
                        return "Successfully cracked the system"
                    else
                        -- Fail
                        return "Failed to cracked the system, try again"
                    end
                end,
            }
        }
    end,
}

function AddPreFixStrings(prefix, data)
    if prefixStrings[prefix] then print("[Error] Prefix is already registered") return false end
    prefixStrings[prefix] = data
    return true
end
exports("AddPreFixStrings", AddPreFixStrings) -- export for other scripts

--[[
exports.yarn_hacking:AddPreFixStrings("BOOST_", function(laptopId, item) -- Example Export 
    return {
        hack = {
            action = function()
                local success = exports.yarn_hacking:SelectMinigame(laptopId, item)
                if success then
                    -- Successful
                    _successCooldown = true
                    Citizen.SetTimeout(math.random(10000,50000), function()
                        _successCooldown = false
                    end)
                    return "Successfully cracked the system"
                else
                    -- Fail
                    return "Failed to cracked the system, try again"
                end
            end,
        }
    }
end)
--]]


function openUI()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })

    -- Update Shit
    local laptopId, devices = exports.fd_laptop:getDevices()
    for _, item in pairs(devices) do

        for prefix, UseHack in pairs(prefixStrings) do
            if item.metadata.deviceUsb and string.find(item.metadata.deviceUsb, prefix) then
                CommandConfig.run.subcommands[item.metadata.deviceUsb] = UseHack(laptopId, item)
            end
        end

        -- if item.metadata.deviceUsb and string.find(item.metadata.deviceUsb, "CRACK_") then
        --     CommandConfig.run.subcommands[item.metadata.deviceUsb] = {
        --         hack = {
        --             action = function()
        --                if not IsCrackAllowed() then return InputConsole("Device is not connected to anything for the crack to run") end
        --                RandomMinigameHack(laptopId, item)
        --             end,
        --         }
        --     }
        -- end
        -- if item.metadata.deviceUsb and string.find(item.metadata.deviceUsb, "BOOST_") then 
        --     CommandConfig.run.subcommands[item.metadata.deviceUsb] = {
        --         hack = {
        --             action = function()
        --                if not IsBoostAllowed() then return InputConsole("Device is not connected to any jam GPS signal") end
        --                RandomMinigameHack(laptopId, item)
        --             end,
        --         }
        --     }
        -- end
    end
end
RegisterNetEvent(("%s:openUI"):format(resourceName), openUI)

function InputConsole(text)
    SendNUIMessage({ action = "write", response = text})
end
RegisterNetEvent(("%s:InputConsole"):format(resourceName), InputConsole)
exports("InputConsole", InputConsole)

function closeUI()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

function split(str, delimiter)
    local result = {}
    for match in string.gmatch(str, "([^"..delimiter.."]+)") do
        table.insert(result, match)
    end
    return result
end


function populateHelpSubcommands()
    for commandName, commandConfig in pairs(CommandConfig) do
        if commandName ~= "help" then
            CommandConfig.help.subcommands[commandName] = {
                description = "Shows help for the " .. commandName .. " command.",
                action = function()
                    return "Usage: " .. commandName .. " <command>\n" .. "Available commands: " .. listSubcommands(commandName)
                end
            }
        end
    end
end

function listSubcommands(commandName)
    local subcommands = CommandConfig[commandName].subcommands
    local subcommandList = {}
    for subcommand, _ in pairs(subcommands) do
        table.insert(subcommandList, subcommand)
    end
    return table.concat(subcommandList, ", ")
end

function listCommands()
    local commandList = {}
    for _, command in pairs(CommandConfig) do
        if command then
            table.insert(commandList, command.command)
            -- for subcommand, _ in pairs(command.subcommands) do
            --     table.insert(commandList, command.command .. " " .. subcommand)
            -- end
        end
    end
    return "Available commands: " .. table.concat(commandList, ", ")
end

populateHelpSubcommands()

function processCommand(input)
    local args = split(input, " ")
    local cmd = args[1]
    local subcmd = args[2]
    local extracmd = args[3]

    -- Check if the command exists in the configuration
    if CommandConfig[cmd] then
        -- Special case for 'help' command
        if cmd == "help" then
            if subcmd then
                if CommandConfig.help.subcommands[subcmd] then
                    return CommandConfig.help.subcommands[subcmd].action()
                else
                    return "Unknown command for help: " .. subcmd
                end
            else
                return CommandConfig.help.action()
            end
        end

        if cmd == "run" then
            if subcmd and extracmd then
                if CommandConfig.run.subcommands[subcmd] then
                    return CommandConfig.run.subcommands[subcmd][extracmd].action()
                else
                    return ("Unknown command for %s: %s"):format(subcmd, extracmd)
                end
            end
        end
        print(not subcmd, not CommandConfig[cmd].subcommands)
        -- Handle the rest of the commands with subcommands
        -- if subcmd then
            if subcmd and CommandConfig[cmd].action then
                return CommandConfig[cmd].action(subcmd)
            elseif not subcmd and CommandConfig[cmd].action then
                return CommandConfig[cmd].action()
            elseif subcmd and CommandConfig[cmd].subcommands[subcmd] then
                return CommandConfig[cmd].subcommands[subcmd].action()
            elseif not subcmd then
                return "Usage: " .. cmd .. " <command>"
            else
                return "Unknown command: " .. subcmd
            end
        -- end
    else
        return "Unknown command: " .. cmd
    end
end
RegisterNUICallback("executeCommand", function(data, cb)
    local command = data.command
    print("Command received: " .. command)
    
    -- Here you can process the command and simulate a response
    local response = processCommand(command)
    
    -- Send response back to the NUI
    cb({ response = response })
end)

-- Create a table to map hack names to function calls
local function randomRange(min, max)
    return math.random(min, max)
end

local function randomDuration()
    return randomRange(3000, 10000) -- Random duration between 3 and 10 seconds
end

local function randomLength()
    return randomRange(3, 6) -- Random length between 3 and 6
end

local function randomGrid()
    return randomRange(3, 6) -- Random grid size between 3x3 and 6x6
end

local function randomTarget()
    return randomRange(3, 6) -- Random target count between 3 and 6
end

local function randomNodes()
    return randomRange(5, 15) -- Random number of nodes between 5 and 15
end

local function randomLevel()
    return randomRange(1, 3) -- Random level between 1 and 3
end

-- Define a table for minigames and their randomized configurations
local minigames = {
    CircleSum = function()
        return exports.bl_ui:CircleSum(3, {
            length = randomLength(),
            duration = randomDuration(),
        })
    end,
    DigitDazzle = function()
        return exports.bl_ui:DigitDazzle(3, {
            length = randomLength(),
            duration = randomDuration(),
        })
    end,
    LightsOut = function()
        return exports.bl_ui:LightsOut(3, {
            level = randomLevel(),
            duration = randomDuration(),
        })
    end,
    MineSweeper = function()
        return exports.bl_ui:MineSweeper(3, {
            grid = randomGrid(), -- Random grid size
            duration = randomDuration(), -- Random time to fail
            target = randomTarget(), -- Random target to remember
            previewDuration = randomRange(1000, 3000) -- Random preview duration
        })
    end,
    PathFind = function()
        return exports.bl_ui:PathFind(3, {
            numberOfNodes = randomNodes(),
            duration = randomDuration(),
        })
    end,
    PrintLock = function()
        return exports.bl_ui:PrintLock(3, {
            grid = randomGrid(),
            duration = randomDuration(),
            target = randomTarget(),
        })
    end,
    Untangle = function()
        return exports.bl_ui:Untangle(3, {
            numberOfNodes = randomNodes(),
            duration = randomDuration(),
        })
    end,
    WaveMatch = function()
        return exports.bl_ui:WaveMatch(3, {
            duration = randomDuration(),
        })
    end,
    WordWiz = function()
        return exports.bl_ui:WordWiz(3, {
            length = randomLength(),
            duration = randomRange(10000, 60000), -- Random duration between 10 and 60 seconds
        })
    end
}

function FailHack(laptopId, item)
    local count = lib.callback.await(('%s:FailHack'):format(resourceName), false, item, laptopId)
    return count
end
exports("FailHack", FailHack)

function SelectMinigame(minigame, laptopId, item)
    local slot = item.slot
    local durability = item.metadata.durability or 100
    if durability <= 0 then
        PlaySoundFromEntity(-1, "Sparks", PlayerPedId(), "DLC_HEIST_BIOLAB_MUSIC_SOUNDSET", 0, 0)
        InputConsole(("%s is broken you need to replace it"):format(item.metadata.deviceUsb))
        return false
    end
    local deviceId = laptopId
    if type(minigame) == "function" then
        return minigame() -- needs to be true of false
    end
    -- Execute the selected minigame
    local success = minigames[minigame]()
    if not success then
        FailHack(deviceId, item)
    end
    return success
end
exports("SelectMinigame", SelectMinigame)

--[[
exports.yarn_hacking:SelectMinigame("MineSweeper")
exports.yarn_hacking:SelectMinigame(function()
    -- time: Time in seconds which player has. Min is 10, Max is 60
    -- result: Reason is the reason of result. Result is an integer code which represents result.
    -- 	   0: Hack failed by player
    -- 	   1: Hack successful
    -- 	   2: Time ran out and hack failed
    -- 	  -1: Error occured i.e. passed input or contents in config is wrong
    local voltLab

    TriggerEvent('ultra-voltlab', math.random(10,60), function(result, reason)
        if result == 0 then
            voltLab = false
            print('Hack failed', reason)
        elseif result == 1 then
            voltLab = true
            print('Hack successful')
        elseif result == 2 then
            voltLab = false
            print('Timed out')
        elseif result == -1 then
            voltLab = false
            print('Error occured',reason)
        end
    end)
    while not voltLab do Wait(0) end
    return voltLab
end)
--]]

-- Create a command to randomly select and execute a minigame with random parameters
function RandomMinigameHack(laptopId, item) -- this is only for the crack minigames
    local slot = item.slot
    local durability = item.metadata.durability or 100
    if durability <= 0 then
        PlaySoundFromEntity(-1, "Sparks", PlayerPedId(), "DLC_HEIST_BIOLAB_MUSIC_SOUNDSET", 0, 0)
        InputConsole(("%s is broken you need to replace it"):format(item.metadata.deviceUsb))
        return false
    end
    local deviceId = laptopId
    -- Get all minigame names
    local minigameNames = {}
    for name in pairs(minigames) do
        table.insert(minigameNames, name)
    end

    -- Select a random minigame
    local randomIndex = math.random(1, #minigameNames)
    local selectedMinigame = minigameNames[randomIndex]

    -- Execute the selected minigame
    local success = minigames[selectedMinigame]()
    if success then
        -- exports.fd_laptop:sendNotification({
        --     summary = 'Crack Successful',
        --     detail = 'Congratulations! You have successfully bypassed the system.'
        -- })
        -- InputConsole("Cracked that shit my g")
    else
        FailHack(deviceId, item)
        -- local count = lib.callback.await(('%s:FailHack'):format(resourceName), false, item, deviceId)
        -- InputConsole("Crack failed mother fucker try aga)in skid script kidded whatever lad sounds?")
    end
    return success
end
exports("RandomMinigameHack", RandomMinigameHack)