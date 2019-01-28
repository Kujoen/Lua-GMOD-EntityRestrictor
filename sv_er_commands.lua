--[[
Copyright [2019] [Kujoen - https://github.com/Kujoen]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]
----------------------------------------------------------------------------------------------------------|
--                                                                                                        |
--                                          MAIN  HOOK                                                    |
--                                                                                                        |
----------------------------------------------------------------------------------------------------------|

--Command has form: /restrict [P] A/W/B [Z] | reason
local function er_commandhook(ply, message, team)

    -- PERMISSIONS ---------------------------------------------------------|
    local hasPermissions = false

    if (isAllowAdmin == true and ply:IsAdmin()) then
        hasPermissions = true
        print("Permissions granted, user is admin ")
    end
    
    if ply:IsSuperAdmin() then 
        hasPermissions = true
        print("Permissions granted, user is superadmin ")
    end
    ------------------------------------------------------------------------|


    if hasPermissions == true then 

        -- Jump out if not restriction command
        if string.find(message, "/restrict") then 

            -- INIT ----------------------------------------------------------|
            local hasReason = false

            local fullCommand = string.Split(message, "|")

            local restrictionReason = fullCommand[2]

            local restrictionCommands = string.Split(fullCommand[1], " ")

            local commandKeyword = restrictionCommands[1]
            local targetPlayerId = restrictionCommands[2]
            local restrictionTypes = restrictionCommands[3]
            local restrictionLength = restrictionCommands[4] 
            ------------------------------------------------------------------|

            -- Check for restriction reason, it doesn't have to be set
            if isValidMessageSegment(restrictionReason) then
                hasReason = true
            end 

            if commandKeyword == "/restrict" then

                if isValidMessageSegment(targetPlayerId) then 

                    local plyToRestrict

                    for k ,v in pairs(player.GetAll()) do
                        if (v:UserID() == tonumber(targetPlayerId)) then 
                            plyToRestrict = v   
                        end
                    end

                    if plyToRestrict != nil then 

                        if isValidMessageSegment(tonumber(restrictionLength)) then
                            -- Convert into seconds
                            restrictionLength = tonumber(restrictionLength) * 3600

                            if isValidMessageSegment(restrictionTypes) then 
                                local timeStamp = os.time()
                                
                                -- Vehicles
                                if string.find(restrictionTypes, "A") then 
                                    restrictVehicles(ply, plyToRestrict, restrictionLength, timeStamp, hasReason, restrictionReason)
                                end 

                                -- Weapons 
                                if string.find(restrictionTypes, "W") then 
                                    restrictWeapons(plyToRestrict, restrictionLength, timeStamp)
                                end 

                                --BuildTools
                                if string.find(restrictionTypes, "B") then 
                                    restrictBuildtools(plyToRestrict, restrictionLength, timeStamp)
                                end 
                            end 
                        end 
                    end 
                end
            end 
        end
    end 
end

hook.Add("PlayerSay", "er_commandhook", er_commandhook)

----------------------------------------------------------------------------------------------------------|
----------------------------------------------------------------------------------------------------------|

function isValidMessageSegment(messageSegment)
    if (messageSegment != nil && messageSegment != '') then 
        return true
    else 
        return false 
    end
end

----------------------------------------------------------------------------------------------------------|
--                                                                                                        |  
-- RESTRICTION HANDLING                                                                                   |
--                                                                                                        |  
----------------------------------------------------------------------------------------------------------|

function restrictVehicles(admin, targetPly, restrictionLength, curTimeStamp, hasReason, reason)
    -- SAVE THE RESTRICTION TO DATA
    local playerSteamID = string.Replace(tostring(targetPly:SteamID()), ":", "_")
    if hasReason then 
        file.Write("entityrestrictor/"..playerSteamID.."_A.txt", curTimeStamp.."_"..restrictionLength.."_"..admin:Nick().."_"..reason)
    else 
        file.Write("entityrestrictor/"..playerSteamID.."_A.txt", curTimeStamp.."_"..restrictionLength.."_"..admin:Nick())
    end 
    
    -- KICK PLAYER OUT OF ANY CURRENT VEHICLES
    if targetPly:InVehicle() then 
        targetPly:ExitVehicle()
    end

    -- PRINT TO CHAT
    PrintMessage(HUD_PRINTTALK, targetPly:Nick().." has been restricted by "..admin:Nick().." from using vehicles for "..tostring(restrictionLength / 3600).." hours.")
    if hasReason then 
        PrintMessage(HUD_PRINTTALK, "Reason: "..reason)
    end
end

function restrictWeapons(player, restrictionLength, curTimeStamp)
end

function restrictBuildtools(player, restrictionLength, curTimeStamp)
end

----------------------------------------------------------------------------------------------------------|




