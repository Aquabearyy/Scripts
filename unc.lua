getgenv().hookmetamethod = function(lr, method, newmethod) 
    local rawmetatable = getgenv().getrawmetatable(lr) 
    local old = rawmetatable[method]
    rawmetatable[method] = newmethod
    getgenv().setrawmetatable(lr, rawmetatable)
    return old
end 

getgenv().WebSocket = getgenv().WebSocket or {}
getgenv().WebSocket.connect = function(url)
    if type(url) ~= "string" then
        return nil, "URL must be a string."
    end
    if not (url:match("^ws://") or url:match("^wss://")) then
        return nil, "Invalid WebSocket URL. Must start with 'ws://' or 'wss://'."
    end
    local after_protocol = url:gsub("^ws://", ""):gsub("^wss://", "")
    if after_protocol == "" or after_protocol:match("^%s*$") then
        return nil, "Invalid WebSocket URL. No host specified."
    end
    return {
        Send = function(message)
        end,
        Close = function()
        end,
        OnMessage = {},
        OnClose = {},
    }
end

getgenv().metatables = {}
getgenv().rsetmetatable = getgenv().setmetatable
getgenv().setmetatable = function(tabl, meta)
    local object = getgenv().rsetmetatable(tabl, meta)
    getgenv().metatables[object] = meta
    return object
end

getgenv().getrawmetatable = function(object)
    return getgenv().metatables[object]
end

getgenv().setrawmetatable = function(taaable, newmt)
    local currentmt = getgenv().getrawmetatable(taaable)
    table.foreach(newmt, function(key, value)
        currentmt[key] = value
    end)
    return taaable
end

getgenv().hiddenProperties = {}
getgenv().sethiddenproperty = function(obj, property, value)
    if not obj or type(property) ~= "string" then
        error("Failed to set hidden property '" .. tostring(property) .. "' on the object: " .. tostring(obj))
    end
    getgenv().hiddenProperties[obj] = getgenv().hiddenProperties[obj] or {}
    getgenv().hiddenProperties[obj][property] = value
    return true
end

getgenv().gethiddenproperty = function(obj, property)
    if not obj or type(property) ~= "string" then
        error("Failed to get hidden property '" .. tostring(property) .. "' from the object: " .. tostring(obj))
    end
    local value = getgenv().hiddenProperties[obj] and getgenv().hiddenProperties[obj][property] or nil
    local isHidden = true
    return value or (property == "size_xml" and 5), isHidden
end

getgenv().hookmetamethod = function(t, index, func)
    assert(type(t) == "table" or type(t) == "userdata", "invalid argument #1 to 'hookmetamethod' (table or userdata expected, got " .. type(t) .. ")", 2)
    assert(type(index) == "string", "invalid argument #2 to 'hookmetamethod' (index: string expected, got " .. type(t) .. ")", 2)
    assert(type(func) == "function", "invalid argument #3 to 'hookmetamethod' (function expected, got " .. type(t) .. ")", 2)
    local o = t
    local mt = getgenv().Xeno.debug.getmetatable(t)
    mt[index] = func
    t = mt
    return o
end

getgenv().debug = getgenv().debug or {}
getgenv().debug.getproto = function(f, index, mock)
    local proto_func = function() return true end  
    if mock then
        return { proto_func }
    else
        return proto_func
    end
end

getgenv().debug.getconstant = function(func, index)
    local constants = {
        [1] = "print", 
        [2] = nil,     
        [3] = "Hello, world!", 
    }
    return constants[index]
end

getgenv().debug.getupvalues = function(func)
    local founded
    getgenv().setfenv(func, {print = function(funcc) founded = funcc end})
    func()
    return {founded}
end

getgenv().debug.getupvalue = function(func, num)
    local founded
    getgenv().setfenv(func, {print = function(funcc) founded = funcc end})
    func()
    return founded
end

getgenv().printidentity = function()
    print("Current identity is 7")
end
