local json = require( "json" )

local timers = {}

local v = {}

v.cancel = function( id )
    if not id then return false end
    for i = 1, table.maxn(timers) do
        if timers[i] == id then
            timer.cancel( id )
            table.remove( timers, i )
            return true
        end
    end
    return false
end

local function onComplete( event )
    local t = event.source.params
    t.listener()
    if event.count == t.iterations then
        v.cancel( event.source )
    end
end

v.createTimer = function( duration, listener, name, iterations )
    if not iterations then iterations = 1 end

    local id = timer.performWithDelay( duration, onComplete, iterations )
    id.params = {
        iterations = iterations,
        listener = listener,
        name = name
    }

    table.insert( timers, id )

    return id
end

v.exists = function( id )
    for i = 1, table.maxn(timers) do
        if timers[i] == id then
            return true
        end
    end
    return false
end

v.flushAllTimers = function()
    for i = 1, table.maxn( timers ) do
        if timers[i] then
            timer.cancel( timers[i] )
            table.remove( timers, i )
        end
    end
end

v.pauseAllTimers = function()
    for i = 1, table.maxn( timers ) do
        timer.pause( timers[i] )
    end
end

v.resumeAllTimers = function()
    for i = 1, table.maxn( timers ) do
        timer.resume( timers[i] )
    end
end

v.pause = function( id )
    if id and v.exists(id) then
        return timer.pause( id )
    end
    return 0
end

v.resume = function( id )
    if id and v.exists(id) then
        return timer.resume( id )
    end
    return 0
end

return v