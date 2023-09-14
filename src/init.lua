--[[
    TRANSCRYPT
    Easily send signals to the server or server to client, let transcrypt take care of all of the remotes for you.

    Made by Monnapse
--]]

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// Packages
local Signal = require(script.Parent.signal)

--// Type
export type EventPush = {
    Name: string,
    args: {}
}

--[=[
    @class connection
    @client
    @server
]=]
local connection = {}
connection.__index = connection

--[=[
    Fire an event to either the client or the server, if on the client then this sends to the server, if your on server then to client.

    @server
    @client

    @param Name string -- Name of the Plug
    @param ... any -- The parameters you want to pass
]=]
function connection:Fire(Name: string, ...)
    if RunService:IsClient() then
        self.remote:FireServer(Name,...)
    elseif RunService:IsServer() then
        self.globalRemote:FireAllClients(Name, ...)
    end
end

--[=[
    Fire an event to the client

    @server

    @param Player Player -- The player you want to send an event to
    @param Name string -- the name of the plug
    @param ... any -- The parameters you want to pass
]=]
function connection:FireAClient(Player: Player, Name: string, ...)
    if RunService:IsServer() then
        self.remotes[Player.UserId]:FireClient(Player, Name, ...)
    end
end

--[=[
    Create a plug, this is where you add events

    @client
    @server

    @param Name string -- the name of the plug
    @param Callback function -- callback function for when the plug is called
]=]
function connection:Plug(Name: string, Callback)
    self.Plugs[Name] = Callback

    if self.Queue and #self.Queues > 0 then
        self:HandleEvents()
    end

    return self
end

--[=[
    Where the Events are handled
    @client
    @server
    @private
]=]
function connection:HandleEvents()
    if self.Queue and #self.Plugs > 0 then
        for Index, Event: EventPush in ipairs(self.Queues) do
            for Name, Callback in pairs(self.Plugs) do
                if Event.Name == Name then
                    Callback(table.unpack(Event.args))
                    table.remove(self.Queues, Index)
                end
            end
        end
    else
        for Name, Callback in pairs(self.Plugs) do
            if self.argsName == Name then
                Callback(table.unpack(self.args))
            end
        end
    end
end

--[=[
    Where Events Queues are handled
    @client
    @server
    @private
]=]
function connection:HandleQueue()
    if self.Queue and self.Plugs[self.argsName] == nil then--and self.Plugs[self.argsName] == nil then
        local Event: EventPush = {
            Name = self.argsName,
            args = self.args,
        }
        table.insert(self.Queues, Event)
    end
end

--[=[
    @class transcrypt
    @client
    @server
    Easily send signals to the server or server to client, let transcrypt take care of all of the remotes for you.
]=]
local transcrypt = {}
transcrypt.__index = transcrypt

--[=[
    To initialize transcrypt

    @client
    @server

    @param Folder Folder -- The folder where you want the remote events to be stored
]=]
function transcrypt.init(Folder: Folder?)
    if not Folder and not game.ReplicatedStorage:FindFirstChild("Events") then
        Folder = Instance.new("Folder",game.ReplicatedStorage)
        Folder.Name = "Events"
    end

    local self = connection
    self.Plugs = {}

    --// If remote is fired and no plugs then wait for a plug and then fire plug
    self.Queue = true
    self.Queues = {}

    self.OnEvent = Signal.new()
    
    self.OnEvent:Connect(function()
        --// Just incase there is no signal connections
        self:HandleQueue()
        self:HandleEvents()
    end)

    if RunService:IsClient() then
        local UserId = game.Players.LocalPlayer.UserId

        for Index, Remote in pairs(Folder:GetChildren()) do
            if Remote.Name ~= tostring(UserId) and Remote.Name ~= "GlobalRemote" then
                Remote:Destroy()
            end
        end

        self.remote = Folder:FindFirstChild(tostring(UserId))
        self.globalRemote = Folder.GlobalRemote

        self.remote.OnClientEvent:Connect(function(Name, ...)
            local args = {...}
            self.argsName = Name
            self.args = args
            
            self.OnEvent:Fire()
        end)

        self.globalRemote.OnClientEvent:Connect(function(Name, ...)
            local args = {...}
            self.argsName = Name
            self.args = args
            
            self.OnEvent:Fire()
        end)
    elseif RunService:IsServer() then
        self.PlayerAdded = Signal.new()
        self.globalRemote = Instance.new("RemoteEvent", Folder)
        self.globalRemote.Name = "GlobalRemote"
        self.remotes = {}

        Players.PlayerAdded:Connect(function(Player)
            self.PlayerAdded:Fire(Player)
            self.remotes[Player.UserId] = Instance.new("RemoteEvent", Folder)
            self.remotes[Player.UserId].Name = Player.UserId

            self.remotes[Player.UserId].OnServerEvent:Connect(function(Player, Name, ...)
                local args = {Player, ...}

                self.Player = Player
                self.argsName = Name
                self.args = args
                
                self.OnEvent:Fire()
            end)
        end)
    end

    return self
end

return transcrypt