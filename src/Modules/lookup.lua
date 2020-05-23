-- Lookup.lua: Responsible for background lookups of player info using the World of Warcraft API function calls.

local NAME, ADDON = ...
ADDON.local_savedPlayers = {} -- Table used to store lookup parameters so that they don't need to be queried twice.

ADDON.local_colours = { -- Colour schema for each string/data type.
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

-- Simple scale function.
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
	-- Lookup function; queries username, guild info, level, class, and pvp rank. Return as table to main.lua
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
				-- If player is out of range, causing "Unknown" guild type, check values again.
				if ( type(value.guild) == "table" ) then
					return { key, value }
				else
					break
				end
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
	local isVisible = UnitIsVisible(unitID)
	-- Will be set to nil, nil, 0 if no guild is present OR target is out of range.
	if ( guildName == nil ) then
		if ( isVisible ) then 
			guildDetails = { guildName = "No guild", guildRank = { 7, "Guildless" } }
		else
			guildDetails = "|cff909090" .. "Unknown" .. "|r"
		end
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

