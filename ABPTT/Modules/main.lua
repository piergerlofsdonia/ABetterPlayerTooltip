local NAME, ADDON = ...
print("Running main")
ADDON.local_frame = CreateFrame("Frame", "local_Tooltip", nil, "GameTooltipTemplate")
ADDON.local_frame.time_struct = { interval = 3, elapsed = 0, fade = 1 }
ADDON.allowMouseOver = true

local lines = {}
local stringKeys = { "name", "class", "guild", "level", "rank" }; -- Named keys to iterate through (lua does not pull key, value pairs in the written order).
local initBool = false


local configureFrame = function(args)
    local point, relPoint, offsetX, offsetY = unpack(args.orientation)
    ADDON.local_frame:SetSize(args.size[1], args.size[2])
    ADDON.local_frame:SetPoint(point, UIParent, relPoint, offsetX, offsetY)
    ADDON.local_frame:Hide()
end

local configureText = function(fontString, fontSettings)
    fontString:SetFont(fontSettings.font, fontSettings.size, fontSettings.style)
    fontString:SetPoint(unpack(fontSettings.orientation))
    return fontString
end

local colourFormat = function(inputString, args) 
    if ( #args < 1 ) then
        error("Incorrect number of arguments supplied to string formatter")
    end 
    
    local colours = ADDON.local_colours
    local priKey, secKey = unpack(args)

    if ( type(secKey) == "number" ) then
        if ( secKey > #colours.guild ) then
            secKey = secKey - (secKey - #colours.guild)
        end
    end
    
    return "|cff" .. colours[priKey][secKey] .. inputString .. "|r"
end

local formatFontString = function(linesTable)
    local i, cap
    cap = 5 
    i = 1
    local frameWidth = ADDON.settings.frame.size[1]
    local fontSize = linesTable.settings.size
    linesTable.fontString = configureText(linesTable.fontString, linesTable.settings) 
    linesTable.fontString:SetText(linesTable.string)
    local fsWidth = linesTable.fontString:GetStringWidth() + linesTable.settings.orientation[2]
    while ( fsWidth > frameWidth ) do
        -- Reduce font size.
        fontSize = math.floor(fontSize - (( fsWidth - frameWidth ) / fontSize ))
        linesTable.settings.size = fontSize
        linesTable.fontString = configureText(linesTable.fontString, linesTable.settings)
        fsWidth = linesTable.fontString:GetStringWidth() + linesTable.settings.orientation[2] 
        if ( i > cap ) then break else i = i + 1 end
        -- Added numerical loop cap to stop infinite loops which crash the game, not sure of minimum fontSize.
    end
    
    return linesTable 
end

local initFrame = function()
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
end

local playerTarget =  function(unitID)
    -- Don't make fontstrings every time - preload into lines
    local i = 1
    ADDON.local_frame.time_struct.elapsed = 0
    
    local userData = ADDON.local_lookup(unitID)
    if ( userData == nil ) then return userData end
    
    local username, details  = unpack(userData)
    local stringTable =  { 
        name = colourFormat(username, {'faction', details.faction:lower()}),
        class = colourFormat(details.class, {'class', details.class:lower()}),
        guild = colourFormat(details.guild.guildRank[2], {'guild', details.guild.guildRank[1]+1}) .. " of " .. details.guild.guildName,
        level = colourFormat(("Level " .. details.level[1]), {'level', details.level[2]}), 
        rank = colourFormat(("Rank: " .. details.rank[2]), {'rank', details.rank[2]+1})
    }
    
    for i=1, #stringKeys, 1 do
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
    if ( ADDON.frameInMotion ) then
        return nil
    end

    if ( ADDON.local_frame:IsShown() == true ) then
        ADDON.local_frame.time_struct.elapsed = ADDON.local_frame.time_struct.elapsed + elapsed
      
        if ( ADDON.local_frame.time_struct.elapsed >= ADDON.local_frame.time_struct.interval ) then
            UIFrameFadeOut(ADDON.local_frame, ADDON.local_frame.time_struct.fade, 1.0, 0.0)
            -- Time to show to the user has elapsed, the frame will fade out. 
            ADDON.local_frame.time_struct.elapsed = 0
        end

        if ( ADDON.local_frame:GetAlpha() <= 0 ) then 
            ADDON.local_frame:Hide()
        end
    end
end

local function eventTrigger(self, event, ...)
    if ( event == "ADDON_LOADED" ) then
        initFrame()
    elseif ( event == "PLAYER_TARGET_CHANGED") then
        playerTarget('target')
    else
        if ( ADDON.allowMouseOver ) then playerTarget('mouseover') end
    end
end

ADDON.local_frame:RegisterEvent("PLAYER_TARGET_CHANGED")
ADDON.local_frame:RegisterEvent("ADDON_LOADED")
ADDON.local_frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
ADDON.local_frame:SetScript("OnEvent", eventTrigger) 
ADDON.local_frame:SetScript("OnUpdate", hideTooltip)
print(NAME .. " loaded!") 
