local isServer = IsDuplicityVersion()
local appId = 'consoleapp'

if isServer then
    CreateThread(function()
        while GetResourceState("fd_laptop") ~= "started" do
            Wait(500)
        end

        local added, errorMessage = exports.fd_laptop:addCustomApp({
            id = appId,
            name = "Yarn OS Console",
            isDefaultApp = true,
            needsUpdate = false,
            icon = ("https://cfx-nui-%s/web/console.svg"):format(GetCurrentResourceName()),
            ui = ("https://cfx-nui-%s/web/index.html"):format(GetCurrentResourceName()),
            keepAlive = true,
            windowDimensions = {
                width = "500",
                height = "200",
                minWidth = "500",
                minHeight = "200",
            },
            ignoreInternalLoading = true,
            windowActions = {
                isResizable = true,
                isMaximizable = true,
                isClosable = true,
                isMinimizable = true,
                isDraggable = true
            },
            windowDefaultStates = {
                isMaximized = false,
                isMinimized = false
            },
            onUseServer = function(source)
                SetTimeout(1000, function()
                    TriggerClientEvent(("%s:openUI"):format(GetCurrentResourceName()), source)
                end)
            end,
        })

        if not added then
            print("Could not add app:", errorMessage)
        end
    end)
end

if not isServer then
    function SetNuiFocus(hasCursor, disableInput) end

    function SendNUIMessage(data)
        if data.action == 'showMenu' or data.action == 'hideMenu' then
            return
        end

        exports.fd_laptop:sendAppMessage(appId, data)
    end
end
