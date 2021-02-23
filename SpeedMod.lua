ModUtil.RegisterMod("SpeedMod")

--[[ Feature list:
 - 2 sack
 - No tiny vermin
 - No thanatos (unless configured for in-game time)
 - No barge of death
 - No cutscenes
]]

local config = {
  ModName = "Speed Mod",
  InGameTime = false
}
if ModConfigMenu then
  ModConfigMenu.Register(config)
end

ModUtil.LoadOnce(function()
  -- no tiny vermin
  RoomData.D_MiniBoss03.LegalEncounters = { "MiniBossHeavyRangedForked" } 
end)

-- 2 sack
ModUtil.WrapBaseFunction("IsRoomForced", function( baseFunc, currentRun, currentRoom, nextRoomData, args )
  local result = baseFunc( currentRun, currentRoom, nextRoomData, args )
  if result then
    return true
  elseif nextRoomData.ForceChanceByRemainingWings and currentRun.CompletedStyxWings > 0 then
    return true
  else
    return false
  end
end)

-- no than
ModUtil.WrapBaseFunction("IsEncounterEligible", function( baseFunc, currentRun, room, nextEncounterData )
  local result = baseFunc( currentRun, room, nextEncounterData )
  if not result then
    return false
  elseif nextEncounterData.Name == "ThanatosTartarus" then
    return config.InGameTime
  elseif nextEncounterData.Name == "ThanatosAsphodel" then
    return config.InGameTime
  elseif nextEncounterData.Name == "ThanatosElysium" then
    return config.InGameTime
  else
    return true
  end
end)

-- no barge
ModUtil.WrapBaseFunction("IsRoomEligible", function( baseFunc, currentRun, currentRoom, nextRoomData, args )
  local result = baseFunc( currentRun, currentRoom, nextRoomData, args )
  if not result then
    return false
  elseif nextRoomData.Name == "B_Wrapping01" then
    return false
  else
    return true
  end
end)

-- Remove ending cutscene
ModUtil.BaseOverride("EndEarlyAccessPresentation", function()
  CurrentRun.ActiveBiomeTimer = false

  thread( Kill, CurrentRun.Hero )
  wait( 0.15 )

  FadeIn({ Duration = 0.5 })
end) 

-- Remove starting cutscene
ModUtil.BaseOverride("ShowRunIntro", function()
  return
end)

-- Modded game warning, (c) museus
function ShowModdedWarning()
    local obstacleName = "ModdedGame"
    local text_config_table = DeepCopyTable(UIData.CurrentRunDepth.TextFormat)
    local x_pos = 1905
    local y_pos = 90

    -- If this anchor was already created, just modify the existing textbox
    if ScreenAnchors[obstacleName] ~= nil then
        ModifyTextBox({
            Id = ScreenAnchors[obstacleName],
            Text = text
        })
    else -- create a new anchor/textbox and fade it in
        ScreenAnchors[obstacleName] = CreateScreenObstacle({
            Name = "BlankObstacle",
            X = x_pos,
            Y = y_pos,
            Group = "Combat_Menu_Overlay"
        })

        CreateTextBox(
            MergeTables(
                text_config_table,
                {
                    Id = ScreenAnchors[obstacleName],
                    Text = "MODDED GAME"
                }
            )
        )

        ModifyTextBox({
            Id = ScreenAnchors[obstacleName],
            FadeTarget = 1,
            FadeDuration = 0.0
        })
    end
end

-- Scripts/RoomManager.lua : 1874
ModUtil.WrapBaseFunction("StartRoom", function ( baseFunc, currentRun, currentRoom )
    ShowModdedWarning()

    baseFunc(currentRun, currentRoom)
end, ShowChamberNumber)

-- Scripts/UIScripts.lua : 145
ModUtil.WrapBaseFunction("ShowCombatUI", function ( baseFunc, flag )
    ShowModdedWarning()

    baseFunc(flag)
end, ShowChamberNumber)
