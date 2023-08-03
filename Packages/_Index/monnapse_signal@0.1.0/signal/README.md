# Signal
Send signals to other scripts

## Getting Started
To create a signal do ```signal.new()```.
Once you have your signal you can now add connections for callbacks when your signal is fired to do this ```signal:Connect(callbackevent)```.
Now you can fire your signal ```signal:Fire(YourParameters)```.

Here is a complete example
```
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
```