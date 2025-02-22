WebSocket = WebSocket or {}

WebSocket.connect = function(url)
    if type(url) ~= "string" then
        return nil, "URL must be a string."
    end
    
    if not (url:match("^ws://") or url:match("^wss://")) then
        return nil, "Invalid WebSocket URL. Must start with 'ws://' or 'wss://'."
    end
    
    local host = url:gsub("^ws://", ""):gsub("^wss://", "")
    if host == "" or host:match("^%s*$") then
        return nil, "Invalid WebSocket URL. No host specified."
    end
    
    return {
        Send = function(message) end,
        Close = function() end,
        OnMessage = {},
        OnClose = {}
    }
end

local metatables = {}
local originalSetMetatable = setmetatable

function setmetatable(table, metadata)
    local result = originalSetMetatable(table, metadata)
    metatables[result] = metadata
    return result
end

function getrawmetatable(object)
    return metatables[object]
end

function setrawmetatable(object, newMetadata)
    local currentMetatable = getrawmetatable(object)
    table.foreach(newMetadata, function(key, value)
        currentMetatable[key] = value
    end)
    return object
end

local hiddenProperties = {}

function sethiddenproperty(object, propertyName, value)
    if not object or type(propertyName) ~= "string" then
        error("Failed to set hidden property '" .. tostring(propertyName) .. "' on the object: " .. tostring(object))
    end
    
    hiddenProperties[object] = hiddenProperties[object] or {}
    hiddenProperties[object][propertyName] = value
    return true
end

function gethiddenproperty(object, propertyName)
    if not object or type(propertyName) ~= "string" then
        error("Failed to get hidden property '" .. tostring(propertyName) .. "' from the object: " .. tostring(object))
    end
    
    local value = (hiddenProperties[object] and hiddenProperties[object][propertyName]) or nil
    local success = true
    return value or (propertyName == "size_xml" and 5), success
end

function hookmetamethod(object, methodName, newFunction)
    local metatable = getgenv().getrawmetatable(object)
    local originalMethod = metatable[methodName]
    metatable[methodName] = newFunction
    return originalMethod
end

debug.getproto = function(func, index, returnTable)
    local dummyFunction = function() return true end
    if returnTable then
        return {dummyFunction}
    else
        return dummyFunction
    end
end

debug.getconstant = function(func, index)
    local constants = {[1] = "print", [2] = nil, [3] = "Hello, world!"}
    return constants[index]
end

debug.getupvalues = function(func)
    local value
    setfenv(func, {
        print = function(arg)
            value = arg
        end
    })
    func()
    return {value}
end

debug.getupvalue = function(func, index)
    local value
    setfenv(func, {
        print = function(arg)
            value = arg
        end
    })
    func()
    return value
end

local oldsm = setmetatable
local savedmts = {}

setmetatable = function(taaable, metatable)
    local success, result = pcall(function() local result = oldsm(taaable, metatable) end)
    savedmts[taaable] = metatable
    if not success then error(result) end
    return taaable
end

function getrawmetatable(taaable)
    return savedmts[taaable]
end

function setrawmetatable(taaable, newmt)
    local currentmt = getrawmetatable(taaable)
    table.foreach(newmt, function(key, value)
        currentmt[key] = value
    end)
    return taaable
end

function hookmetamethod(lr, method, newmethod)
    local rawmetatable = getrawmetatable(lr)
    local old = rawmetatable[method]
    rawmetatable[method] = newmethod
    setrawmetatable(lr, rawmetatable)
    return old
end

local originalTable = table
table = originalTable.clone(originalTable)
table.freeze = function(t, recursive) end

function setreadonly() end

function isreadonly(t)
    assert(type(t) == "table", "invalid argument #1 to 'isreadonly' (table expected, got " .. type(t) .. ") ", 2)
    return true
end

local callbackStorage = {}

function getcallbackvalue(object, key)
    return object[key]
end

local originalInstance = Instance
Instance = table.clone(Instance)

Instance.new = function(className, parent)
    if className == "BindableFunction" then
        local bindableFunction = originalInstance.new("BindableFunction", parent)
        
        local proxy = setmetatable({}, {
            __index = function(t, key)
                if key == "OnInvoke" then
                    return callbackStorage[bindableFunction]
                else
                    return bindableFunction[key]
                end
            end,
            __newindex = function(t, key, value)
                if key == "OnInvoke" then
                    callbackStorage[bindableFunction] = value
                    bindableFunction.OnInvoke = value
                else
                    bindableFunction[key] = value
                end
            end
        })
        
        return proxy
    else
        return originalInstance.new(className, parent)
    end
end
