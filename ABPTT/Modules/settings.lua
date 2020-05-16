-- load addon title and table (object)
local NAME, ADDON = ... 

local resetDefaults = function()
    if ( abptt_frameSettings == nil ) then
        abptt_frameSettings = { size = { 155, 55 },
            orientation = { "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0}
        }
    end

    local settingsToReturn = {
        frame = abptt_frameSettings,
        text =  {
            font = "Fonts\\ARIALN.ttf",
            size = 13,
            style = "OUTLINE",
            orientation = { "TOPLEFT", 7, -9 } 
        }
    }

    ADDON.settings = settingsToReturn
    return nil
end

local moveFrame = function() 
    local frame = (ADDON.local_frame)
    frame:Show()
    frame:SetAlpha(1.0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame.isMoving = true
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing) 
end

local stopMoveFrame = function()
    local frame = ADDON.local_frame
    frame:Hide()
    frame:SetAlpha(0.0)
    frame:SetMovable(false)
    frame:EnableMouse(false)
    local point, _, relPoint, ofstX, ofstY = frame:GetPoint()
    ADDON.settings.frame.orientation = { point, relPoint, ofstX, ofstY }
    abptt_frameSettings = ADDON.settings.frame
    local removeScripts = {"OnDragStart", "OnDragStop", "OnMouseDown", "OnMouseUp"}
    for _, v in ipairs(removeScripts) do
        frame:SetScript(v, nil)
    end
end

ADDON.resetDefaults = resetDefaults
ADDON.moveFunctions = {moveFrame, stopMoveFrame}
