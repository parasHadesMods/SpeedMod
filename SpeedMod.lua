ModUtil.RegisterMod("SpeedMod")

--[[ Feature list:
 - 2 sack
 - No tiny vermin
 - No thanatos
 - No barge of death
 - Always the same cutscene
]]

ModUtil.LoadOnce(function()
  -- no tiny vermin
  RoomDataStyx.D_MiniBoss03.LegalEncounters = { "MiniBossHeavyRangedForked" } 
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
  local results = baseFunc( currentRun, currentRoom, nextRoomData, args )
  if not result then
    return false
  elseif nextEncounterData.Name == "ThanatosTartarus" then
    return false
  elseif nextEncounterData.Name == "ThanatosAsphodel" then
    return false
  elseif nextEncounterData.Name == "ThanatosElysium" then
    return false
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
end, RemoveOutroMod) 

-- Remove starting cutscene
ModUtil.BaseOverride("ShowRunIntro", function()
  return
end)
