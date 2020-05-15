local NAME, ADDON = ...

SLASH_ABPTT1, SLASH_ABPTT2, SLASH_ABPTT3 = "/abptt", "/ttmove", "/tt"
SLASH_DISABLEFEAT1, SLASH_DISABLEFEAT2 = "/nomo", "/nomouseover"
SLASH_CHANGEFADE1, SLASH_CHANGEFADE2 = "/ttf", "/ttfade"
SLASH_DISABLETOOLTIP1, SLASH_DISABLETOOLTIP2 = "/ttd", "ttdisable"

local disableFrame = function()
    print(NAME .. " is disabled!")
    ADDON.local_frame.isDisabled = true;
    ADDON.local_frame:Hide()
end

local enableFrame = function()
    print(NAME .. " is enabled!")
    ADDON.local_frame.isDisabled = false;
    ADDON.local_frame:Show()
end

SlashCmdList.ABPTT = function()
    if ( ADDON.frameInMotion ) then
        ADDON.moveFunctions[2]()
    else
        ADDON.moveFunctions[1]()
    end

    ADDON.frameInMotion = not(frameInMotion)
end

SlashCmdList.DISABLEFEAT = function()
    if ADDON.allowMouseOver then ADDON.allowMouseOver = false else ADDON.allowMouseOver = true end
    print(ADDON.allowMouseOver)
end

SlashCmdList.CHANGEFADE = function(msg, ...)
    local timeAsStr = msg:gsub("%s+", "")
    local timeAsInt = tonumber(timeAsStr)
    if ( timeAsInt == nil ) then
        print("Provide a number to /ttf to change the fade time of the tooltip")
    else
        print("Tooltip 'fade-out' time changed to " .. timeAsStr .. " seconds!")
        ADDON.local_frame.time_struct.interval = tonumber(timeAsInt)
    end

    return nil
end

SlashCmdList.DISABLETOOLTIP = function()
    if ( ADDON.local_frame.isDisabled == nil ) then
        disableFrame()
    else
        if ( ADDON.local_frame.isDisabled ) then 
            enableFrame()
        else 
            disableFrame()
        end
    end
    
    return nil
end
