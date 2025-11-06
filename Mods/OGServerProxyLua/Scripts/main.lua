-- UEHelpers = require("UEHelpers")
-- local UWorld = UEHelpers.GetWorld()

---@type ATslGameState
GameState = nil
---@type UWorld
World = nil
---@type ATslGameMode
GameMode = nil
---@type UGameplayStatics
GamePlayStatics = nil
---@type UAirborneMatchPreparer
AirbroneMatchPreparer = nil
---@type ATransportAircraftVehicle
GlobalTransportAirplane = nil
---@type UTask_GasWarning_C
TaskGasWarning = nil
---@type UTask_GasRelease_C
TaskGasRelease = nil
IsServer = true
LastWarningTime = 0
LastReleaseTime = 0
FNameAvailablie = false

GameStarted = false
GameEnded = false

Debug = true

ZERO_VECTOR = {
    ["X"] = 0.0,
    ["Y"] = 0.0,
    ["Z"] = 0.0
}

ZERO_ROTATION = {
    ["Pitch"] = 0.0,
    ["Yaw"] = 0.0,
    ["Roll"] = 0.0
}

function FRotator(Pitch, Yaw, Roll)
    return {
        ["Pitch"] = Pitch,
        ["Yaw"] = Yaw,
        ["Roll"] = Roll
    }
end

-- Custom implementation of atan2, as it's missing from the game's Lua environment.
function atan2_custom(y, x)
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 and y >= 0 then
        return math.atan(y / x) + 3.14159
    elseif x < 0 and y < 0 then
        return math.atan(y / x) - 3.14159
    elseif x == 0 and y > 0 then
        return 3.14159 / 2
    elseif x == 0 and y < 0 then
        return -3.14159 / 2
    end
    return 0 -- x == 0 and y == 0
end

function FVector(X, Y, Z)
    return {
        ["X"] = X,
        ["Y"] = Y,
        ["Z"] = Z
    }
end

function DisableCullingForAllActors(World)
    World.StreamingLevels:ForEach(
        function(index, param)
            local streamLevel = param:get()
            local levelName = tostring(streamLevel:GetFullName())
			
		    if string.find(levelName, "320") then
                goto continue
            end
			
		    if string.find(levelName, "321") then
                goto continue
            end

            if string.find(levelName, "322") then
                goto continue
            end

            if string.find(levelName, "323") then
                goto continue
            end

            if string.find(levelName, "324") then
                goto continue
            end

            if string.find(levelName, "325") then
                goto continue
            end

            if string.find(levelName, "326") then
                goto continue
            end

            if string.find(levelName, "327") then
                goto continue
            end

            if string.find(levelName, "328") then
                goto continue
            end

            if string.find(levelName, "329") then
                goto continue
            end

            if string.find(levelName, "330") then
                goto continue
            end

            if string.find(levelName, "331") then
                goto continue
            end

            if string.find(levelName, "332") then
                goto continue
            end

            -- enable these levels
            streamLevel.bShouldBeLoaded = true
            streamLevel.bShouldBeVisible = true
            streamLevel.bDisableDistanceStreaming = true
            streamLevel.bShouldBlockOnLoad = true
            ::continue::
			
        end
    )
end

function Init()
    print("=== OG Server Proxy ===")
    print("Checking FName Availbility...")
    print("if this fails, delete the next line in the lua file and restart the server")
    -- if FName not available, delete the next line
    local fname = FName("Testing")
    if (fname ~= nil) then
        FNameAvailablie = true
    end
    -- start init game
    RegisterInitGameStatePostHook(
        function(gameMode)
            print("GameMode = " .. tostring(gameMode:get():GetFullName()))
            local mode = gameMode:get()
            mode.PlayerRespawn = true
            -- setup the warmup time
            mode.WarmupTime = 200
            mode.bCanAllSpectate = false
            mode.MultiplierBlueZone = 1
            -- Set the match to Airbrone
            mode.MatchStartType = 1

            local static = StaticFindObject("/Script/Engine.GameplayStatics")
            local world = FindFirstOf("World")

            GamePlayStatics = static:GetCDO()
            print("GamePlayStatics: " .. tostring(static:GetCDO():GetFullName()))

            print(tostring(world) .. ", name=" .. tostring(world:GetFullName()))
            LoopAsync(
                100,
                function()
                    DisableCullingForAllActors(world)

                    if world.GameState:GetFullName() == nil then
                        print("Waiting for GameState to be valid...")
                        return false
                    else
                        print("state= " .. tostring(world.GameState:GetFullName()))

                        -- Init the gamestate
                        ---@type ATslGameState
                        GameState = world.GameState
                        GameState.bIsTeamMatch = true
                        World = world

                        GameMode = mode
                        print("GameMode: " .. tostring(GameMode:GetFullName()))

                        local serverPlayer = FindFirstOf("TslPlayerController")
                        if serverPlayer:IsValid() and serverPlayer:HasAuthority() then
                            print("We are a server, continue to do our stuff")
                            -- GlobalTransportAirplane = SpawnAircraft()
                            -- GlobalTransportAirplane:EnterAtEjectionArea()
                            -- SpawnTestingPlayerPawn()

                            LoopAsync(
                                100,
                                function()
                                    -- print("Spawning Bot...")
                                    -- serverPlayer.CheatManager:SpawnBot()
                                    if (GameState ~= nil) then
                                        if (GameState.TotalWarningDuration ~= 0) then
                                            if (GameState.TotalWarningDuration ~= LastWarningTime) then
                                                print(
                                                    "WarningDuration is changed, teleporting plane to the BlueZone center..."
                                                )
                                                GlobalTransportAirplane:K2_TeleportTo(
                                                    FVector(
                                                        GameState.PoisonGasWarningPosition.X,
                                                        GameState.PoisonGasWarningPosition.Y,
                                                        AirbroneMatchPreparer.AircraftAltitude
                                                    ),
                                                    ZERO_ROTATION
                                                )
                                                print(
                                                    "WarningDuration is " ..
                                                        tostring(GameState.TotalWarningDuration) ..
                                                            "s, Fixing BlueZone Duration to " ..
                                                                tostring(GameState.TotalWarningDuration / 2) .. "s..."
                                                )
                                                GameState.TotalWarningDuration = GameState.TotalWarningDuration / 2
                                                if (TaskGasWarning ~= nil) then
                                                    TaskGasWarning.TotalRemainDuration = GameState.TotalWarningDuration
                                                    TaskGasWarning.RemainDuration = GameState.TotalWarningDuration
                                                end
                                                LastWarningTime = GameState.TotalWarningDuration
                                            end
                                        end

                                        if (GameState.TotalReleaseDuration ~= 0) then
                                            if (GameState.TotalReleaseDuration ~= LastReleaseTime) then
                                                print("Gas is released, eject all players..")
                                                DropoutPlayerInAirplane()
                                                print(
                                                    "ReleaseDuration is " ..
                                                        tostring(GameState.TotalReleaseDuration) ..
                                                            "s, Fixing RedZone Duration to " ..
                                                                tostring(GameState.TotalReleaseDuration / 2) .. "s..."
                                                )
                                                GameState.TotalReleaseDuration = GameState.TotalReleaseDuration / 2
                                                LastReleaseTime = GameState.TotalReleaseDuration
                                            end
                                        end

                                        if (TaskGasRelease ~= nil) then
                                            TaskGasRelease.TotalDuration = GameState.TotalReleaseDuration
                                        end
                                    end
                                    return false
                                end
                            )
                        else
                            print("We are a client")
                        end

                        return true
                    end
                end
            )
        end
    )
end

-- Not working
function SpawnTestingPlayerPawn()
    local static = GamePlayStatics
    local world = World
    local botControllerClass = StaticFindObject("/Script/TslGame.TslBotAIController")
    local defaultBot = StaticFindObject("/Script/TslGame.Default__TslBot")
    local playerStateClass = StaticFindObject("/Script/TslGame.TslPlayerState")

    print("botControllerClass: " .. tostring(botControllerClass:GetFullName()))
    print("defaultPawn: " .. tostring(defaultBot:GetFullName()))

    ---@type ATslBotAIController
    local controller =
        world:SpawnActor(
        botControllerClass,
        {
            ["X"] = 338062.06,
            ["Y"] = 170761.37,
            ["Z"] = 2200.10
        },
        {
            ["Pitch"] = 0.0,
            ["Yaw"] = 0.0,
            ["Roll"] = 0.0
        }
    )

    print("controller = " .. tostring(controller:GetFullName()))

    ---@type ATslCharacter
    local pawn =
        world:SpawnActor(
        defaultBot:GetClass(),
        {
            ["X"] = 338062.06,
            ["Y"] = 170761.37,
            ["Z"] = 2200.10
        },
        {
            ["Pitch"] = 0.0,
            ["Yaw"] = 0.0,
            ["Roll"] = 0.0
        }
    )

    print("pawn = " .. tostring(pawn:GetFullName()))

    controller:Possess(pawn)

end

--- Get all player pawn instance
--- @return table<ATslCharacter> | nil
function GetAllPlayerPawns()
    local playerPawns = {}
    if (GameState ~= nil) then
        GameState.PlayerArray:ForEach(
            function(index, param)
                local playerPawn = param:get().Owner.Pawn
                playerPawns[index] = playerPawn
            end
        )
        return playerPawns
    else
        print("GameState is nil")
        return nil
    end
end

--- Get all player controller instance
--- @return table<ATslPlayerController> | nil
function GetAllPlayerControllers()
    local playerPawns = {}
    if (GameState ~= nil) then
        GameState.PlayerArray:ForEach(
            function(index, param)
                local playerPawn = param:get().Owner
                playerPawns[index] = playerPawn
            end
        )
        return playerPawns
    else
        print("GameState is nil")
        return nil
    end
end

--- Get all player state instance
--- @return table<ATslPlayerState> | nil
function GetAllPlayerStates()
    local playerPawns = {}
    if (GameState ~= nil) then
        GameState.PlayerArray:ForEach(
            function(index, param)
                local playerPawn = param:get()
                playerPawns[index] = playerPawn
            end
        )
        return playerPawns
    else
        print("GameState is nil")
        return nil
    end
end

function TeleportPlayersToStartPoint()
    local pawns = GetAllPlayerPawns()
    if (pawns ~= nil) then
        print("Teleporting players to start point")
        for i = 1, #pawns do
            local pawn = pawns[i]
            print("Teleporting player " .. pawn:GetFullName())
            pawn:K2_TeleportTo(
                {
                    ["X"] = 338062.06,
                    ["Y"] = 170761.37,
                    ["Z"] = 2200.10
                },
                {
                    ["Pitch"] = 0.0,
                    ["Yaw"] = 0.0,
                    ["Roll"] = 0.0
                }
            )
        end
    end
end

function DropoutPlayerInAirplane()
    if (GlobalTransportAirplane ~= nil and GlobalTransportAirplane:IsValid()) then
        print("Dropout player in airplane!!!!")
        local seats = GlobalTransportAirplane.VehicleSeatComponent:GetSeats()
        for index, seatparam in pairs(seats) do
            ---@type UVehicleSeatInteractionComponent
            local seat = seatparam:get()
            if (seat:IsValid() and (seat.Rider:IsValid() == true)) then
                print("Found a valid seat #" .. index .. ", trying to drop player on aircraft...")
                GlobalTransportAirplane.VehicleSeatComponent:Leave(seat.Rider, seat, false)
                seat.Rider:ResetParachute()
                seat.Rider:SendSystemMessage(2, FText("Dropping!"))
            end
        end
    end
end

---@return ATransportAircraftVehicle | nil
--- Spawn an aircraft
function SpawnAircraft()
    if (GameMode ~= nil) then
        -- Spawn the preparer
        if (AirbroneMatchPreparer == nil) then
            ---@type UClass
            local AirbronePreparerClass = GameMode.MatchPreparerClasses[2].Class
            print("AirbronePreparerClass is " .. AirbronePreparerClass:GetFullName())
            AirbroneMatchPreparer = GamePlayStatics:SpawnObject(AirbronePreparerClass, World.PersistentLevel)
        end

        print("preparer = " .. AirbroneMatchPreparer:GetFullName())
        print("aircraft Class = " .. AirbroneMatchPreparer.AircraftClass:GetFullName())

        -- Spawn the aircraft
        local aircraft =
            World:SpawnActor(
            AirbroneMatchPreparer.AircraftClass,
            {
                ["X"] = 338062.06,
                ["Y"] = 170761.37,
                ["Z"] = AirbroneMatchPreparer.AircraftAltitude
            },
            {
                ["Pitch"] = 0.0,
                ["Yaw"] = 0.0,
                ["Roll"] = 0.0
            }
        )
        print("Aircraft spawned: " .. tostring(aircraft:IsValid()) .. "Aircraft = " .. aircraft:GetFullName())
        return aircraft
    else
        print("GameMode is nil")
        return nil
    end
end

function StartManualFlightPath()
    if (GlobalTransportAirplane == nil or not GlobalTransportAirplane:IsValid()) then
        print("Cannot start manual flight, airplane is not valid.")
        return
    end

    print("Starting manual flight path...")

    local startPos = {
        X = 338062.06,
        Y = 170761.37,
        Z = AirbroneMatchPreparer.AircraftAltitude
    }

    -- Define an end point on the other side of the map
    local endPos = {
        X = 650000.0,
        Y = 650000.0,
        Z = AirbroneMatchPreparer.AircraftAltitude
    }

    local speed = 2222 -- cm/s (approx 80 km/h)
    local interval = 0.1 -- Loop runs every 100ms

    local deltaX = endPos.X - startPos.X
    local deltaY = endPos.Y - startPos.Y
    local totalDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    local totalFlightTime = totalDistance / speed

    -- Calculate yaw for the aircraft to face the destination using our custom atan2
    local flightYaw = (atan2_custom(deltaY, deltaX) * 180) / 3.14159
    local flightRotation = FRotator(0.0, flightYaw, 0.0)

    local flightProgress = 0.0 -- 0.0 at start, 1.0 at end

    LoopAsync(100, function()
        if (GlobalTransportAirplane == nil or not GlobalTransportAirplane:IsValid()) then
            print("Airplane disappeared, stopping flight loop.")
            return true -- Stop loop
        end

        local elapsedTime = interval
        flightProgress = flightProgress + (elapsedTime / totalFlightTime)

        if flightProgress >= 1.0 then
            print("Flight path finished.")
            return true -- Stop loop
        end

        local currentPos = {
            X = startPos.X + (deltaX * flightProgress),
            Y = startPos.Y + (deltaY * flightProgress),
            Z = startPos.Z
        }

        GlobalTransportAirplane:K2_TeleportTo(currentPos, flightRotation)

        return false -- Continue loop
    end)
end

function Hook_K2_OnRestartPlayer(object, func, param)
    local player = param:get()
    print("K2_OnRestartPlayer::before" .. player:K2_GetPawn():GetFName():ToString())
    ---@type ATslCharacter
    local playerPawn = player:K2_GetPawn()
    if (GameStarted) then
        if (GlobalTransportAirplane ~= nil and GlobalTransportAirplane:IsValid()) then
            print("Trying to spawn player on aircraft...")
            local seats = GlobalTransportAirplane.VehicleSeatComponent:GetSeats()
            -- print("Seats = " .. tostring(seats))
            for index, seatparam in pairs(seats) do
                ---@type UVehicleSeatInteractionComponent
                local seat = seatparam:get()
                if (seat:IsValid() and (seat.Rider:IsValid() == false)) then
                    print("Found a valid seat #" .. index .. ", trying to spawn player on aircraft...")
                    GlobalTransportAirplane.VehicleSeatComponent:Ride(playerPawn, seat)
                    seat.Rider = playerPawn
                    -- playerPawn.
                    return
                end
            end
        else
            player:K2_GetPawn():K2_TeleportTo(
                {
                    ["X"] = 796360.19,
                    ["Y"] = 19990.86,
                    ["Z"] = 528.53
                },
                {
                    ["Pitch"] = 0.0,
                    ["Yaw"] = 0.0,
                    ["Roll"] = 0.0
                }
            )
        end
    else
        if (Debug) then
            player:K2_GetPawn():K2_TeleportTo(
                {
                    ["X"] = 796360.19,
                    ["Y"] = 19990.86,
                    ["Z"] = 528.53
                },
                {
                    ["Pitch"] = 0.0,
                    ["Yaw"] = 0.0,
                    ["Roll"] = 0.0
                }
            )
        end
    end
end

function Hook_GameStarted()
    -- GameStarted, we are going to find the Task_GasWarning and Task_GasRelease to fix the bluezone
    local taskGasWarningList = FindAllOf("Task_GasWarning_C")
    if not taskGasWarningList then
        print("Task_GasWarning_C not found")
        return
    else
        ---@param taskGasWarning UTask_GasWarning_C
        for _, taskGasWarning in ipairs(taskGasWarningList) do
            if (taskGasWarning.ActorOwner:IsValid()) then
                print(
                    "Task_GasWarning_C found, name = " ..
                        taskGasWarning:GetFullName() .. ", ActorOwner = " .. taskGasWarning.ActorOwner:GetFullName()
                )
                TaskGasWarning = taskGasWarning
            end
        end
    end

    local taskGasReleaseList = FindAllOf("Task_GasRelease_C")
    if not taskGasReleaseList then
        print("Task_GasRelease_C not found")
        return
    else
        ---@param taskGasRelease UTask_GasRelease_C
        for _, taskGasRelease in ipairs(taskGasReleaseList) do
            if (taskGasRelease.ActorOwner:IsValid()) then
                print(
                    "Task_GasRelease_C found, name = " ..
                        taskGasRelease:GetFullName() .. ", ActorOwner = " .. taskGasRelease.ActorOwner:GetFullName()
                )
                TaskGasRelease = taskGasRelease
            end
        end
    end
end

function Hook_K2_OnSetMatchState(object, func, param)
    local state = param:get():ToString()
    print("K2_OnSetMatchState::before, state=" .. state)

    if state == "InProgress" then
        print("Game is in progress, we can start our stuff")
        GameStarted = true
        if (GlobalTransportAirplane == nil) then
            GlobalTransportAirplane = SpawnAircraft()
        end
        if (GlobalTransportAirplane ~= nil and GlobalTransportAirplane:IsValid()) then
            -- Put players into the aircraft
            local playerPawns = GetAllPlayerPawns()
            if (playerPawns ~= nil and #playerPawns > 0) then
                print("Putting " .. #playerPawns .. " players into aircraft...")
                local seats = GlobalTransportAirplane.VehicleSeatComponent:GetSeats()
                local seatIndex = 1
                for i = 1, #playerPawns do
                    local pawn = playerPawns[i]
                    if (pawn:IsValid()) then
                        -- Find an empty seat
                        local seatFound = false
                        while (seatIndex <= #seats) do
                            local seat = seats[seatIndex]:get()
                            if (seat:IsValid() and not seat.Rider:IsValid()) then
                                print("Putting player " .. pawn:GetFullName() .. " into a seat.")
                                GlobalTransportAirplane.VehicleSeatComponent:Ride(pawn, seat)
                                seat.Rider = pawn
                                seatIndex = seatIndex + 1
                                seatFound = true
                                break
                            end
                            seatIndex = seatIndex + 1
                        end
                        if not seatFound then
                            print("No more seats available.")
                            break
                        end
                    end
                end
            else
                print("No players found to put into aircraft.")
            end

            -- Start the manual flight path
            StartManualFlightPath()

            print("Enabling ejection")
            GlobalTransportAirplane:EnterAtEjectionArea()
        end
        Hook_GameStarted()
    -- TeleportPlayersToStartPoint()
    end

    if state == "WaitingPostMatch" then
        print("Game Ended.Do Restarting...")
        GameEnded = true
        if (GameMode ~= nil) then
        -- GameMode:RestartGame()
        end
    end
end

Init()
