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
    level = { "ff0000", "ff4600", "ffdc00", "68ff00", "e0e0e0" },
    rank = { "ffffff" , "d1d1d1", "979797", "585858", "beff90", "61c619", "60eae0", "2f42be", "ff8585", "d41919", "dc5000", "e6b312", "926bb5", "6c1cb4", "360066"}
}

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
    
    if ( levelDiff > 9 ) then
        levelDiff = 1
    elseif ( levelDiff > 4 ) then
        levelDiff = 2
    elseif ( levelDiff >= 0 ) then
        levelDiff = 3
    elseif ( levelDiff < -4 ) then 
        levelDiff = 4
    elseif ( levelDiff < -9 ) then
        levelDiff = 5
    end
    -- TODO: Replace above with arithmetical.
    
    playerDetails = { 
        faction = faction, guild = guildDetails, class = className, 
        level = {level, levelDiff}, rank = {rankName, rankID} }

    ADDON.local_savedPlayers[username] = playerDetails
    return { username, playerDetails }

end

