local NAME, ADDON = ...
ADDON.local_savedPlayers = {}

ADDON.local_colours = {
    class = {
        druid = "FF7D0A", hunter = "ABD473", mage = "69CCF0", paladin = "F58CBA", priest = "FFFFFF",
        rogue = "FFF569", shaman = "0070DE", warlock = "9482C9", warrior = "C79C6E"
    },
    faction = {
        alliance = "00ff00", horde = "ff0000"
    },
    guild = { "a40e0e", "f4ac27", "ffdf13", "bdf531", "52f531", "31f585", "31f5e4", "31c3f5" },
    level = { "bbbbbb", "14bb00", "f7df1a", "f7891a", "d10d00" },
    rank = { "ffffff" , "d1d1d1", "979797", "585858", "beff90", "61c619", "60eae0", "2f42be", "ff8585", "d41919", "dc5000", "e6b312", "926bb5", "6c1cb4", "360066"}
}

-- Scale func
local scaleInt = function(preMinMax, postMinMax, inputValue)
    if ( type(inputValue) ~= 'number' ) and ( inputValue ~= nil )then
        inputValue = tonumber(inputValue)
        return scaleInt(preMinMax, postMinMax, inputValue)
    end
    if ( #preMinMax == 2 ) and ( #postMinMax == 2 ) then
       local preMin, preMax = unpack(preMinMax)
       local postMin, postMax = unpack(postMinMax)
       local preRange = ( preMax - preMin ) 
       local postRange = ( postMax - postMin )
    
       if ( preRange == 0 ) then
           return postMin
       else
           return (((inputValue - preMin) * postRange ) / preRange ) + postMin
       end

    else
        error("Incorrect number of values passed to scale function")
    end
end

ADDON.local_lookup = function(optUnitID)
    local faction, factionID, username, unitID, className, level, levelDiff, rankName, rankID
    local guildDetails, playerDetails = {}

    if ( optUnitID ) then
        unitID = optUnitID
    else
        unitID = "target"
    end
    
    if not ( UnitIsPlayer(unitID) ) then
        return nil 
    end
  
    
    username = UnitName(unitID)
    
    for key, value in pairs(ADDON.local_savedPlayers) do
        if ( key ~= nil ) and ( username ~= nil ) then
            if ( key:lower() == username:lower() ) then
                return { key, value }
            end
        end
    end      
   
    if not ( UnitIsEnemy("player", unitID) ) then 
        faction = "Alliance"
        factionID = 1
    else 
        faction = "Horde"
        factionID = 0
    end
    local guildName, guildRank, guildRankIndex = GetGuildInfo(unitID)
    if ( guildName == nil ) then
        guildDetails = { guildName = "No guild", guildRank = { 7, "Guildless" } }
    else    
        guildDetails = { guildName = guildName, guildRank = { guildRankIndex, guildRank} } 
    end

    className = UnitClass(unitID)
    rankName, rankID = GetPVPRankInfo(UnitPVPRank(unitID), factionID)
    level = UnitLevel(unitID) 
    levelDiff = (level - UnitLevel("player"))
    if ( level < 0 ) then
        level = "??"
        levelDiff = 10
    end
    
    -- Smallest value is -59, largest value is +59.
    -- CB0000 [+10+]
    -- fc8f13 [+4 to 9]
    -- fcea13 [+/-0 to 3]
    -- 3CC400 [-4 to 9]
    -- bbbbbb [-10+]

    local minLevelDiff = 0
    local maxLevelDiff = 20
    if ( levelDiff < -10 ) then 
        levelDiff = minLevelDiff 
    elseif ( levelDiff > 10 ) then
        levelDiff = maxLevelDiff
    else
        levelDiff = levelDiff + 10
    end

    local scaledLevelDiff = scaleInt({minLevelDiff, maxLevelDiff}, {1, (#ADDON.local_colours.level)}, levelDiff)
    levelDiff = math.floor(scaledLevelDiff+0.5)
    playerDetails = { 
        faction = faction, guild = guildDetails, class = className, 
        level = {level, levelDiff}, rank = {rankName, rankID} }

    ADDON.local_savedPlayers[username] = playerDetails
    return { username, playerDetails }

end

