--[[

	A Better Player Tooltip:
		Replaces the traditional tooltip when targeting players - this tooltip can be moved, permanently hidden, and shows additional
		details regarding guild rank/name and PVP rank.

]]

local NAME, ADDON = ...

-- Create tooltip frame and store in ADDON global table.
ADDON.local_frame = CreateFrame("Frame", "local_Tooltip", nil, "GameTooltipTemplate")
ADDON.local_frame.time_struct = { interval = 3, elapsed = 0, fade = 1 }
-- allowMouseOver used to track whether the mouseover functionality is disabled or not
ADDON.allowMouseOver = true

-- Lines table used to set and format a fontstring for each type of data provided by the API.
local lines = {}
-- Data types are as follows:
local stringKeys = { "name", "class", "guild", "level", "rank" }; -- Named keys to iterate through (lua does not pull key, value pairs in the written order).
-- initBool tracks whether the frame has been setup or not.
local initBool = false
local defaultFontSize

local configureFrame = function(args)
	-- Take input table and set the frame using these input arguments.
	local point, relPoint, offsetX, offsetY = unpack(args.orientation)
    ADDON.local_frame:SetSize(args.size[1], args.size[2])
    ADDON.local_frame:SetPoint(point, UIParent, relPoint, offsetX, offsetY)
	-- Do not show the frame by default if it is not triggered.
    ADDON.local_frame:Hide()
end

local configureText = function(fontString, fontSettings)
	-- Take a fontstring object and a table containing various font settings; set the fontstring accordingly.
	fontString:SetFont(fontSettings.font, fontSettings.size, fontSettings.style)
    fontString:SetPoint(unpack(fontSettings.orientation))
    return fontString
end

local colourFormat = function(inputString, args) 
	-- Format the input string using the arguments provided according to the colour scheme outlined in 'lookup.lua'.
    if ( #args < 1 ) then
        error("Incorrect number of arguments supplied to string formatter")
    end 
    
    local colours = ADDON.local_colours
    local priKey, secKey = unpack(args)
	
	-- Guilds do not have a set range of 'guildRank' numbers, however most seems to have <=7 ranks, truncate if outside this range.
    if ( type(secKey) == "number" ) then
        if ( secKey > #colours.guild ) then
            secKey = secKey - (secKey - #colours.guild)
        end
    end
    
	-- Lookup the colour, apply it plus a 255 alpha and return it.
    return "|cff" .. colours[priKey][secKey] .. inputString .. "|r"
end

local function resizeFont(lineTable, fontSize, recdepth)
	-- Resize font until it either fits within the frame or we break the recurrsion depths (erroneous edge case)
	lineTable.settings.size = fontSize
	lineTable.fontString = configureText(lineTable.fontString, lineTable.settings)
	local fsWidth = lineTable.fontString:GetStringWidth() + lineTable.settings.orientation[2]
	local frameWidth = ADDON.settings.frame.size[1]

    while ( fsWidth > frameWidth ) do
		-- Numeric loop break just to stop the game from crashing in the event an edge-case bug occurs here.
		if ( recdepth > 6 ) then error("Recurrsion error") end
		-- Round down fontsize and re-measure until we've recurred to the max (erroneous) or the font fits in the frame. 
		fontSize = math.floor(fontSize - (( fsWidth - frameWidth ) / fontSize ))
		recdepth = recdepth + 1
		return resizeFont(lineTable, fontSize, recdepth)
    end
 
	return true
end

local formatFontString = function(lineTable)
	--[[
		Read the lines table (containing a fontstring, a string, and its settings), for each line set the correct padding, fontsize, 
		width (if relevant), and, if the set size exceeds the size of the frame, reduce the size until it fits within the frame width. 
	]]

    local fontSize = lineTable.settings.size
    lineTable.fontString = configureText(lineTable.fontString, lineTable.settings) 
    lineTable.fontString:SetText(lineTable.string)
	if ( resizeFont(lineTable, lineTable.settings.size, 1) == true ) then
		return lineTable
	else
		error("Error resizing fontstring")
	end
end

local initFrame = function()
	-- Initalise the frame by resetting the settings to default and configuring the frame and lines table (setting correct orientation, etc).
    if ( initBool ) then return nil end
    ADDON.resetDefaults()
    configureFrame(ADDON.settings.frame)
    for i=1, #stringKeys, 1 do 
        lines[i] = {
            string = "",
            settings = {},
            fontString = ADDON.local_frame:CreateFontString(nil, "ARTWORK")
        }

        ADDON.resetDefaults()
        lines[i].settings = ADDON.settings.text

        if ( i == 5 ) then
                lines[i].settings.orientation[3] = (lines[i-1].settings.orientation[3])
                lines[i].settings.orientation[1] = "TOPRIGHT"
                lines[i].settings.orientation[2] = (lines[i].settings.orientation[2] * -1)
        elseif ( i == 2 ) then
            lines[i].settings.orientation[1] = "TOPRIGHT"
            lines[i].settings.orientation[2] = (lines[2].settings.orientation[2] * -1)
        end
    end

    initBool = true
    defaultFontSize = ADDON.settings.text.size
end

local playerTarget =  function(unitID)
	--[[
		Main function: Get user data, scrape it into usable strings, set each line table with these strings and the correct settings
		before fading in the frame.
	]]

	local i = 1
    ADDON.local_frame.time_struct.elapsed = 0
    
    local userData = ADDON.local_lookup(unitID)
    if ( userData == nil ) then return userData end
   
    local username, details  = unpack(userData)
	
	-- Format guild string in case of OOR issues.
	local guildString
	if ( type(details.guild) == "table" ) then 
		guildString = colourFormat(details.guild.guildRank[2], {'guild', details.guild.guildRank[1]+1}) .. " of " .. details.guild.guildName
	else
		guildString = details.guild
	end

	local stringTable =  {
        name = colourFormat(username, {'faction', details.faction:lower()}),
        class = colourFormat(details.class, {'class', details.class:lower()}),
		guild = guildString,
        level = colourFormat(("Level " .. details.level[1]), {'level', details.level[2]}), 
        rank = colourFormat(("Rank: " .. details.rank[2]), {'rank', details.rank[2]+1})
    }
    
    for i=1, #stringKeys, 1 do
        lines[i].settings.size = defaultFontSize
        lines[i].string = stringTable[stringKeys[i]]
        
        if ( i > 2 ) then
            if ( i == 5 ) then
                lines[i].settings.orientation[3] = lines[i-1].settings.orientation[3]
            else
                local vertPlacement = lines[i-1].settings.orientation[3]
                lines[i].settings.orientation[3] = ((lines[i-1].fontString:GetStringHeight() * -1) + vertPlacement )
            end
        end
        
        lines[i] = formatFontString(lines[i])
    end

    if ( ADDON.local_frame:IsShown() ) then
        UIFrameFadeIn(ADDON.local_frame, 0.01, ADDON.local_frame:GetAlpha(), 1.0) 
    else
        ADDON.local_frame:Hide()
        ADDON.local_frame:Show()
        ADDON.local_frame:SetAlpha(1.0)
    end

end

local hideTooltip = function(event, elapsed)
    -- If the frame is not in motion and is being shown to the user, hide it when a time period has elapsed. 
	if ( ADDON.frameInMotion ) then
        return nil
    end

    if ( ADDON.local_frame:IsShown() == true ) then
        ADDON.local_frame.time_struct.elapsed = ADDON.local_frame.time_struct.elapsed + elapsed
         
        if ( ADDON.local_frame.time_struct.elapsed >= ADDON.local_frame.time_struct.interval ) then
            UIFrameFadeOut(ADDON.local_frame, ADDON.local_frame.time_struct.fade, 1.0, 0.0)
            ADDON.local_frame.time_struct.elapsed = 0
        end

        if ( ADDON.local_frame:GetAlpha() <= 0 ) then 
			-- When alpha reaches zero, hide the frame (this is not done automatically by UIFrameFadeOut).
            ADDON.local_frame:Hide()
        end
    end
end

local function eventTrigger(self, event, ...)
	-- Assess the event, if its the relevant one (target change), run playerTarget routine with corresponding userID input.    
    if ( ADDON.local_frame.isDisabled == nil ) then ADDON.local_frame.isDisabled = false end

    if ( event == "ADDON_LOADED" ) then
        initFrame()
    elseif ( event == "PLAYER_TARGET_CHANGED") then
        if ( ADDON.local_frame.isDisabled == true ) then return nil end
        playerTarget('target')
    else
        if ( ADDON.local_frame.isDisabled == true ) then return nil end
        if ( ADDON.allowMouseOver ) then playerTarget('mouseover') end
    end
end

-- Register events and set scripts.
ADDON.local_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
ADDON.local_frame:RegisterEvent("ADDON_LOADED")
ADDON.local_frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
ADDON.local_frame:SetScript("OnEvent", eventTrigger) 
ADDON.local_frame:SetScript("OnUpdate", hideTooltip)
