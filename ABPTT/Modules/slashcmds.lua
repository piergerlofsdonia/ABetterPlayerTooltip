local NAME, ADDON = ...

SLASH_ABPTT1, SLASH_ABPTT2, SLASH_ABPTT3 = "/abptt", "/ttmove", "/tt"
SLASH_DISABLEFEAT1, SLASH_DISABLEFEAT2 = "/nomo", "/nomouseover"
SLASH_CHANGEFADE1, SLASH_CHANGEFADE2 = "/ttf", "/ttfade"

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
