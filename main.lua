repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

if identifyexecutor then
    if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
        getgenv().setthreadidentity = nil
    end
end

local vape
local loadstring = function(...)
    local res, err = loadstring(...)
    if err and vape then
        vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
    end
    return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
    local suc, res = pcall(function()
        return readfile(file)
    end)
    return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
    return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
    if not isfile(path) then
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/R12sa/Triplevape/main/'..select(1, path:gsub('newvape/', '')), true)
        end)
        if not suc or res == '404: Not Found' then
            error(res)
        end
        writefile(path, res)
    end
    return (func or readfile)(path)
end

local function finishLoading()
    vape.Init = nil
    vape:Load()
    task.spawn(function()
        repeat
            vape:Save()
            task.wait(10)
        until not vape.Loaded
    end)

    local teleportedServers
    vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
        if (not teleportedServers) and (not shared.VapeIndependent) then
            teleportedServers = true
            local teleportScript = [[
                shared.vapereload = true
                loadstring(game:HttpGet('https://raw.githubusercontent.com/R12sa/Triplevape/main/loader.lua', true), 'loader')()
            ]]
            if shared.VapeCustomProfile then
                teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
            end
            vape:Save()
            queue_on_teleport(teleportScript)
        end
    end))

    if not shared.vapereload then
        if not vape.Categories then return end
        if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
            vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
        end
    end
end

if not isfile('newvape/profiles/gui.txt') then
    writefile('newvape/profiles/gui.txt', 'new')
end
local gui = readfile('newvape/profiles/gui.txt')

if not isfolder('newvape/assets/'..gui) then
    makefolder('newvape/assets/'..gui)
end
vape = loadstring(downloadFile('newvape/guis/'..gui..'.lua'), 'gui')()

local XFunctions = loadstring(downloadFile('newvape/libraries/XFunctions.lua'), 'XFunctions')()
XFunctions:SetGlobalData('XFunctions', XFunctions)
XFunctions:SetGlobalData('vape', vape)

local PerformanceModule = loadstring(downloadFile('newvape/libraries/performance.lua'), 'Performance')()
XFunctions:SetGlobalData('Performance', PerformanceModule)

local utils_functions = loadstring(downloadFile('newvape/libraries/utils.lua'), 'Utils')()
for i, v in utils_functions do
    getfenv()[i] = v
end

getgenv().InfoNotification = function(title, msg, dur)
    warn('info', tostring(title), tostring(msg), tostring(dur))
    vape:CreateNotification(title, msg, dur)
end
getgenv().warningNotification = function(title, msg, dur)
    warn('warn', tostring(title), tostring(msg), tostring(dur))
    vape:CreateNotification(title, msg, dur, 'warning')
end
getgenv().errorNotification = function(title, msg, dur)
    warn("error", tostring(title), tostring(msg), tostring(dur))
    vape:CreateNotification(title, msg, dur, 'alert')
end

if not shared.VapeIndependent then
    loadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
    loadstring(downloadFile('newvape/games/modules.lua'), 'modules')()
    if isfile('newvape/games/'..game.PlaceId..'.lua') then
        loadstring(readfile('newvape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
    else
        local suc, res = pcall(function()
            return game:HttpGet('https://raw.githubusercontent.com/R12sa/Triplevape/main/games/'..game.PlaceId..'.lua', true)
        end)
        if suc and res ~= '404: Not Found' then
            loadstring(downloadFile('newvape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
        end
    end
    finishLoading()
else
    vape.Init = finishLoading
    return vape
end

shared.VapeFullyLoaded = true
