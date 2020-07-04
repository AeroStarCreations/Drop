--Requires

--Precalls
local TimerBank

-- Local Values --------------------------------------------------------------[
local function onComplete(event)
    local tmr = event.source.params
    tmr.listener(event)
    if event.count == tmr.iterations then
        tmr.status = "expired"
        tmr.parentBank:cancel(event.source)
    end
end

local function pauseTimer(timerId)
    if timerId.params.status == "active" then
        timerId.params.status = "paused"
        return timer.pause(timerId)
    end
    return 0
end

local function resumeTimer(timerId)
    if timerId.params.status == "paused" then
        timerId.params.status = "active"
        return timer.resume(timerId)
    end
    return 0
end

local function cancelTimer(timerId)
    if timerId.params.status ~= "expired" then
        timer.cancel(timerId)
        timerId.params.status = "expired"
    end
end
------------------------------------------------------------------------------]

-- Returned values/table -----------------------------------------------------[
TimerBank = {}
local TimerBank_mt = {__index = TimerBank}

function TimerBank:new()
    local self = {}

    setmetatable(self, TimerBank_mt)

    self.timers = {}

    return self
end

---iterations: optional
function TimerBank:createTimer(duration, listener, iterations)
    if not iterations then
        iterations = 1
    end

    local timerId = timer.performWithDelay(duration, onComplete, iterations)
    timerId.params = {
        duration = duration,
        listener = listener,
        iterations = iterations,
        parentBank = self,
        status = "active"
    }

    table.insert(self.timers, timerId)

    return timerId
end

---Returns the new timer ID
function TimerBank:restartTimer(id)
    local didCancel = self:cancel(id)
    if didCancel then
        local p = id.params
        return self:createTimer(p.duration, p.listener, p.iterations)
    end
    return nil
end

function TimerBank:exists(id)
    if not id then return false end
    for i = 1, table.getn(self.timers) do
        if self.timers[i] == id then
            return i
        end
    end
    return false
end

function TimerBank:cancelAllTimers()
    for i = 1, table.getn(self.timers) do
        cancelTimer(self.timers[i])
    end
    self.timers = {}
end

function TimerBank:pauseAllTimers()
    for i = 1, table.getn(self.timers) do
        pauseTimer(self.timers[i])
    end
end

function TimerBank:resumeAllTimers()
    for i = 1, table.getn(self.timers) do
        resumeTimer(self.timers[i])
    end
end

function TimerBank:pause(id)
    if id and self:exists(id) then
        return pauseTimer(id)
    end
    return 0
end

function TimerBank:resume(id)
    if id and self:exists(id) then
        return resumeTimer(id)
    end
    return 0
end

function TimerBank:cancel(id)
    if not id then return false end
    local index = self:exists(id)
    if index then
        cancelTimer(id)
        table.remove(self.timers, index)
        return true
    end
    return false
end

return TimerBank
-------------------------------------------------------------------------------]
