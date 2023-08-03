--// Module Script
local signal = require(signal)

local module = {}

module.signal = signal.new()
module.signal:Fire("Hello")

return module

--// Script

local module = require(module)

module.signal:Connect(function(parameter)
    print(parameter)
end)

--[[
  Output: Hello
--]]