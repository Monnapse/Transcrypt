--[[
    Monnapse's Signal Script
    @0.1.0
--]]

local signal = {}
signal.__index = signal

--[=[
    @class signal
    @client
    @server
    Send signals over scripts easily
]=]
export type signal = {}

--[=[
    Create a new signal

    @client
    @server
]=]
function signal.new(): signal
    local self = setmetatable({}, signal)
    self.CallbackEvents = {}
    return self
end

--[=[
    Fire an event to a signal

    @client
    @server

    @param ... any -- Parameters that will be sent to the signal
]=]
function signal:Fire(...: any)
    for index, CallbackEvent in pairs(self.CallbackEvents) do
        CallbackEvent(...)
    end
end

--[=[
    Connect to the signal to get callbacks

    @client
    @server

    @param CallbackEvent function -- The event that will be called when the signal is fired
]=]
function signal:Connect(CallbackEvent)
    table.insert(self.CallbackEvents,CallbackEvent)
end

--[=[
    Destroy the signal

    @client
    @server
]=]
function signal:Destroy()
    setmetatable(self,nil)
end

return signal