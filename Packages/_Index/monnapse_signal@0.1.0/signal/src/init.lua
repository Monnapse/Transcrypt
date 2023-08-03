--[[
    Monnapse's Signal Script
    @0.1.0
--]]

local signal = {}
signal.__index = signal

export type signal = {}

function signal.new(): signal
    local self = setmetatable({}, signal)
    self.CallbackEvents = {}
    return self
end

function signal:Fire(...)
    for index, CallbackEvent in pairs(self.CallbackEvents) do
        CallbackEvent(...)
    end
end

--// Connect to the signal to get callbacks
function signal:Connect(CallbackEvent)
    table.insert(self.CallbackEvents,CallbackEvent)
end

--// Destroy the signal
function signal:Destroy()
    setmetatable(self,nil)
end

return signal