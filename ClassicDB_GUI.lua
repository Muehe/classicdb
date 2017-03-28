local backdrop = {
    bgFile = "Interface\\AddOns\\ClassicDB\\img\\background",
    tile = true,
    tileSize = 8,
    edgeFile = "Interface\\AddOns\\ClassicDB\\img\\border",
    edgeSize = 8,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local backdrop_noborder = {
    bgFile = "Interface\\AddOns\\ClassicDB\\img\\background",
    tile = true,
    tileSize = 8,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
}

if not CdbFavourites then CdbFavourites = {} end
if not CdbFavourites["spawn"] then CdbFavourites["spawn"] = {} end
if not CdbFavourites["object"] then CdbFavourites["object"] = {} end
if not CdbFavourites["item"] then CdbFavourites["item"] = {} end
if not CdbFavourites["quest"] then CdbFavourites["quest"] = {} end


------------------------------------------------------------
-- Auxiliary frame for registering events and initialization
------------------------------------------------------------
CdbAuxiliaryFrame = CreateFrame("Frame", "CdbAuxiliaryFrame", UIParent)
CdbAuxiliaryFrame:SetScript("OnLoad", function() CdbInit() end)
CdbAuxiliaryFrame:SetScript("OnEvent", function() CdbOnEvent(self, event) end)
-- Register Events (some unused)
CdbAuxiliaryFrame:RegisterEvent("PLAYER_LOGIN");
CdbAuxiliaryFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
CdbAuxiliaryFrame:RegisterEvent("QUEST_WATCH_UPDATE");
CdbAuxiliaryFrame:RegisterEvent("QUEST_LOG_UPDATE");
CdbAuxiliaryFrame:RegisterEvent("QUEST_PROGRESS");
CdbAuxiliaryFrame:RegisterEvent("QUEST_FINISHED");
CdbAuxiliaryFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
CdbAuxiliaryFrame:RegisterEvent("WORLD_MAP_UPDATE");

------------------------------
-- Create the search GUI frame
------------------------------
CdbSearchGui = CreateFrame("Frame","CdbSearchGui",UIParent)
tinsert(UISpecialFrames, "CdbSearchGui")
CdbSearchGui:Hide()
CdbSearchGui:SetFrameStrata("DIALOG")
CdbSearchGui:SetWidth(500)
CdbSearchGui:SetHeight(445)
CdbSearchGui:SetBackdrop(backdrop)
CdbSearchGui:SetBackdropColor(0,0,0,.85);
CdbSearchGui:SetPoint("CENTER",0,0)
CdbSearchGui:SetMovable(true)
CdbSearchGui:EnableMouse(true)
CdbSearchGui:SetScript("OnMouseDown",function()
    CdbSearchGui:StartMoving()
end)
CdbSearchGui:SetScript("OnMouseUp",function()
    CdbSearchGui:StopMovingOrSizing()
end)

----------------------------
-- Minimap button definition
----------------------------
CdbSearchGui.minimapButton = CreateFrame('Button', "CdbMinimap", Minimap)
CdbSearchGui.minimapButton:SetMovable(true)
CdbSearchGui.minimapButton:EnableMouse(true)
CdbSearchGui.minimapButton:SetFrameStrata('HIGH')
CdbSearchGui.minimapButton:SetWidth(31)
CdbSearchGui.minimapButton:SetHeight(31)
CdbSearchGui.minimapButton:SetFrameLevel(9)
CdbSearchGui.minimapButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
-- The lines below will always set the button to default position 125, since
-- CdbMinimapPosition is not yet loaded from SavedVariables at this point. The
-- actual position is set above by an event. This condition is needed for first
-- time users.
if (CdbMinimapPosition == nil) then
    CdbMinimapPosition = 125
end
CdbSearchGui.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(CdbMinimapPosition)),(80*sin(CdbMinimapPosition))-52)
CdbSearchGui.minimapButton.overlay = CdbSearchGui.minimapButton:CreateTexture(nil, 'OVERLAY')
CdbSearchGui.minimapButton.overlay:SetWidth(53)
CdbSearchGui.minimapButton.overlay:SetHeight(53)
CdbSearchGui.minimapButton.overlay:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
CdbSearchGui.minimapButton.overlay:SetPoint('TOPLEFT', 0,0)
CdbSearchGui.minimapButton.icon = CdbSearchGui.minimapButton:CreateTexture(nil, 'BACKGROUND')
CdbSearchGui.minimapButton.icon:SetWidth(20)
CdbSearchGui.minimapButton.icon:SetHeight(20)
CdbSearchGui.minimapButton.icon:SetTexture('Interface\\AddOns\\ClassicDB\\symbols\\sq')
CdbSearchGui.minimapButton.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
CdbSearchGui.minimapButton.icon:SetPoint('CENTER',1,1)

------------------------
-- Minimap button clicks
------------------------
CdbSearchGui.minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
CdbSearchGui.minimapButton:SetScript("OnClick", function()
    if ( arg1 == "LeftButton" ) then
        if IsShiftKeyDown() then
             CdbResetMapAndIconSize()
        else
            if (CdbSearchGui:IsShown()) then
                CdbSearchGui:Hide();
            else
                CdbSearchGui:Show();
            end
        end
    end
    if (arg1 == "RightButton") then
        if IsShiftKeyDown() then
            CdbResetGui();
        else
            if (CdbControlGui:IsShown()) then
                CdbControlGui:Hide()
            else
                CdbControlGui:Show()
            end
        end
    end
end)

-------------------------
-- Minimap button tooltip
-------------------------
CdbSearchGui.minimapButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(CdbSearchGui.minimapButton, "ANCHOR_BOTTOMLEFT");
    GameTooltip:ClearLines();
    GameTooltip:SetText("ClassicDB\n\n<LeftClick>: Toggle search window\n<RightClick>: Toggle control window\n<Shift>+<LeftClick>: Reset Map and Icon Size\n<Shift>+<RightClick>: Reset and show both windows");
    GameTooltip:Show();
end)
CdbSearchGui.minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide();
end)

--------------------------
-- Minimap button dragging
--------------------------
CdbSearchGui.minimapButton:RegisterForDrag('LeftButton')
CdbSearchGui.minimapButton:SetScript("OnDragStart", function()
    this:LockHighlight();
    CdbSearchGui.minimapButton.draggingFrame:Show();
end)
CdbSearchGui.minimapButton:SetScript("OnDragStop", function()
    this:UnlockHighlight();
    CdbSearchGui.minimapButton.draggingFrame:Hide();
end)
CdbSearchGui.minimapButton.draggingFrame = CreateFrame("Frame", "CdbMinimapDragging", CdbSearchGui.minimapButton)
CdbSearchGui.minimapButton.draggingFrame:Hide()
CdbSearchGui.minimapButton.draggingFrame:SetScript("OnUpdate", function()
    local xpos,ypos = GetCursorPosition()
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

    xpos = xmin-xpos/UIParent:GetScale()+70
    ypos = ypos/UIParent:GetScale()-ymin-70

    CdbMinimapPosition = math.deg(math.atan2(ypos,xpos))
    CdbSearchGui.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(CdbMinimapPosition)),(80*sin(CdbMinimapPosition))-52)
end)

------------------
-- Fill search GUI
------------------
CdbSearchGui.closeButton = CreateFrame("Button", nil, CdbSearchGui, "UIPanelCloseButton")
CdbSearchGui.closeButton:SetWidth(30)
CdbSearchGui.closeButton:SetHeight(30) -- width, height
CdbSearchGui.closeButton:SetPoint("TOPRIGHT", -5,-5)
CdbSearchGui.closeButton:SetScript("OnClick", function()
    CdbSearchGui:Hide()
end)

CdbSearchGui.titlebar = CreateFrame("Frame", nil, CdbSearchGui)
CdbSearchGui.titlebar:ClearAllPoints()
CdbSearchGui.titlebar:SetWidth(494)
CdbSearchGui.titlebar:SetHeight(35)
CdbSearchGui.titlebar:SetPoint("TOP", 0, -3)
CdbSearchGui.titlebar:SetBackdrop(backdrop_noborder)
CdbSearchGui.titlebar:SetBackdropColor(1,1,1,.10)

CdbSearchGui.text = CdbSearchGui:CreateFontString("Status", "LOW", "GameFontNormal")
CdbSearchGui.text:ClearAllPoints()
CdbSearchGui.text:SetPoint("TOPLEFT", 12, -12)
CdbSearchGui.text:SetFontObject(GameFontWhite)
CdbSearchGui.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
CdbSearchGui.text:SetText("|cff33ffccClassic|cffffffffDB |cffaaaaaaoooVersionooo")

CdbSearchGui.input = CreateFrame("Frame", nil, CdbSearchGui)
--CdbSearchGui.input:ClearAllPoints()
CdbSearchGui.input:SetWidth(494)
CdbSearchGui.input:SetHeight(40)
CdbSearchGui.input:SetPoint("BOTTOM", 0, 3)
CdbSearchGui.input:SetBackdrop(backdrop_noborder)
--CdbSearchGui.input:SetBackdropColor(.2,1,.8,1)
CdbSearchGui.input:SetBackdropColor(1,1,1,.10)

CdbSearchGui.inputField = CreateFrame("EditBox", "InputBoxTemplate", CdbSearchGui.input, "InputBoxTemplate")
InputBoxTemplateLeft:SetTexture(1,1,1,.15);
InputBoxTemplateMiddle:SetTexture(1,1,1,.15);
InputBoxTemplateRight:SetTexture(1,1,1,.15);
CdbSearchGui.inputField:SetParent(CdbSearchGui.input)
CdbSearchGui.inputField:SetTextColor(.2,1.1,1)

CdbSearchGui.inputField:SetWidth(375)
CdbSearchGui.inputField:SetHeight(20)
CdbSearchGui.inputField:SetPoint("TOPLEFT", 15, -10)
CdbSearchGui.inputField:SetFontObject(GameFontNormal)
CdbSearchGui.inputField:SetAutoFocus(false)
CdbSearchGui.inputField:SetText("Search")
CdbSearchGui.inputField.updateSearch = function()
    CdbSearchGui:HideButtons()
    local query = CdbSearchGui.inputField:GetText()
    if query ~= "Search" then
        CdbSearchGui:SearchSpawn(query)
        CdbSearchGui:SearchObject(query)
        CdbSearchGui:SearchItem(query)
        CdbSearchGui:SearchQuest(query)
    else
        CdbSearchGui:SearchSpawn("")
        CdbSearchGui:SearchObject("")
        CdbSearchGui:SearchItem("")
        CdbSearchGui:SearchQuest("")
    end
end

CdbSearchGui.inputField:SetScript("OnTextChanged", function(self)
    CdbSearchGui.inputField:updateSearch()
end)

CdbSearchGui.inputField:SetScript("OnEditFocusGained", function(self)
    if this:GetText() == "Search" then this:SetText("") end
end)
CdbSearchGui.inputField:SetScript("OnEditFocusLost", function(self)
    if this:GetText() == "" then this:SetText("Search") end
end)

CdbSearchGui.cleanButton = CreateFrame("Button", nil, CdbSearchGui.input)
CdbSearchGui.cleanButton:SetParent(CdbSearchGui.input)
CdbSearchGui.cleanButton:SetWidth(65)
CdbSearchGui.cleanButton:SetHeight(24) -- width, height
CdbSearchGui.cleanButton:SetPoint("TOPRIGHT", -10,-8)
CdbSearchGui.cleanButton.text = CdbSearchGui.cleanButton:CreateFontString("Status", "LOW", "GameFontNormal")
CdbSearchGui.cleanButton.text:ClearAllPoints()
CdbSearchGui.cleanButton.text:SetAllPoints(CdbSearchGui.cleanButton)
CdbSearchGui.cleanButton.text:SetPoint("LEFT", 0, 0)
CdbSearchGui.cleanButton.text:SetFontObject(GameFontWhite)
CdbSearchGui.cleanButton.text:SetText("Clean")
CdbSearchGui.cleanButton:SetBackdrop(backdrop)
CdbSearchGui.cleanButton:SetBackdropColor(0,0,0,.15)
CdbSearchGui.cleanButton:SetBackdropBorderColor(1,1,1,.25)

CdbSearchGui.cleanButton:SetScript("OnClick", function()
    CdbCleanMapAndPreventRedraw();
end)

CdbSearchGui.buttonSpawn = CreateFrame("Button", nil, CdbSearchGui)
--CdbSearchGui.buttonSpawn:ClearAllPoints()
CdbSearchGui.buttonSpawn:SetWidth(100)
CdbSearchGui.buttonSpawn:SetHeight(25)
CdbSearchGui.buttonSpawn:SetPoint("TOPLEFT", 13, -50)
CdbSearchGui.buttonSpawn:SetBackdrop(backdrop_noborder)
CdbSearchGui.buttonSpawn.text = CdbSearchGui.buttonSpawn:CreateFontString("Status", "LOW", "GameFontNormal")
CdbSearchGui.buttonSpawn.text:ClearAllPoints()
CdbSearchGui.buttonSpawn.text:SetAllPoints(CdbSearchGui.buttonSpawn)
CdbSearchGui.buttonSpawn.text:SetPoint("LEFT", 0, 0)
CdbSearchGui.buttonSpawn.text:SetFontObject(GameFontWhite)
CdbSearchGui.buttonSpawn.text:SetText("Mobs")
CdbSearchGui.buttonSpawn:SetBackdropColor(1,1,1,.05)
CdbSearchGui.buttonSpawn:SetScript("OnClick", function()
    CdbSearchGui.buttonSpawn:SetBackdropColor(1,1,1,.15)
    CdbSearchGui.buttonObject:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonItem:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonQuest:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonSettings:SetBackdropColor(1,1,1,.05)

    CdbSearchGui.spawn:Show()
    CdbSearchGui.object:Hide()
    CdbSearchGui.item:Hide()
    CdbSearchGui.quest:Hide()
    CdbSearchGui.settings:Hide()
end)

CdbSearchGui.buttonObject = CreateFrame("Button", nil, CdbSearchGui)
--CdbSearchGui.buttonObject:ClearAllPoints()
CdbSearchGui.buttonObject:SetWidth(100)
CdbSearchGui.buttonObject:SetHeight(25)
CdbSearchGui.buttonObject:SetPoint("TOPLEFT", 113, -50)
CdbSearchGui.buttonObject:SetBackdrop(backdrop_noborder)
CdbSearchGui.buttonObject.text = CdbSearchGui.buttonObject:CreateFontString("Status", "LOW", "GameFontNormal")
CdbSearchGui.buttonObject.text:ClearAllPoints()
CdbSearchGui.buttonObject.text:SetAllPoints(CdbSearchGui.buttonObject)
CdbSearchGui.buttonObject.text:SetPoint("LEFT", 0, 0)
CdbSearchGui.buttonObject.text:SetFontObject(GameFontWhite)
CdbSearchGui.buttonObject.text:SetText("Objects")
CdbSearchGui.buttonObject:SetBackdropColor(1,1,1,.05)
CdbSearchGui.buttonObject:SetScript("OnClick", function()
    CdbSearchGui.buttonObject:SetBackdropColor(1,1,1,.15)
    CdbSearchGui.buttonSpawn:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonItem:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonQuest:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonSettings:SetBackdropColor(1,1,1,.05)

    CdbSearchGui.object:Show()
    CdbSearchGui.spawn:Hide()
    CdbSearchGui.item:Hide()
    CdbSearchGui.quest:Hide()
    CdbSearchGui.settings:Hide()
end)

CdbSearchGui.buttonItem = CreateFrame("Button", nil, CdbSearchGui)
--CdbSearchGui.buttonItem:ClearAllPoints()
CdbSearchGui.buttonItem:SetWidth(100)
CdbSearchGui.buttonItem:SetHeight(25)
CdbSearchGui.buttonItem:SetPoint("TOPLEFT", 213, -50)
CdbSearchGui.buttonItem:SetBackdrop(backdrop_noborder)
CdbSearchGui.buttonItem.text = CdbSearchGui.buttonItem:CreateFontString("Status", "LOW", "GameFontNormal")
CdbSearchGui.buttonItem.text:ClearAllPoints()
CdbSearchGui.buttonItem.text:SetAllPoints(CdbSearchGui.buttonItem)
CdbSearchGui.buttonItem.text:SetPoint("LEFT", 0, 0)
CdbSearchGui.buttonItem.text:SetFontObject(GameFontWhite)
CdbSearchGui.buttonItem.text:SetText("Items")
CdbSearchGui.buttonItem:SetBackdropColor(1,1,1,.15)
CdbSearchGui.buttonItem:SetScript("OnClick", function()
    CdbSearchGui.buttonItem:SetBackdropColor(1,1,1,.15)
    CdbSearchGui.buttonSpawn:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonObject:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonQuest:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonSettings:SetBackdropColor(1,1,1,.05)

    CdbSearchGui.item:Show()
    CdbSearchGui.object:Hide()
    CdbSearchGui.spawn:Hide()
    CdbSearchGui.quest:Hide()
    CdbSearchGui.settings:Hide()
end)

CdbSearchGui.buttonQuest = CreateFrame("Button", nil, CdbSearchGui)
--CdbSearchGui.buttonQuest:ClearAllPoints()
CdbSearchGui.buttonQuest:SetWidth(100)
CdbSearchGui.buttonQuest:SetHeight(25)
CdbSearchGui.buttonQuest:SetPoint("TOPLEFT", 313, -50)
CdbSearchGui.buttonQuest:SetBackdrop(backdrop_noborder)
CdbSearchGui.buttonQuest.text = CdbSearchGui.buttonQuest:CreateFontString("Status", "LOW", "GameFontNormal")
CdbSearchGui.buttonQuest.text:ClearAllPoints()
CdbSearchGui.buttonQuest.text:SetAllPoints(CdbSearchGui.buttonQuest)
CdbSearchGui.buttonQuest.text:SetPoint("LEFT", 0, 0)
CdbSearchGui.buttonQuest.text:SetFontObject(GameFontWhite)
CdbSearchGui.buttonQuest.text:SetText("Quests")
CdbSearchGui.buttonQuest:SetBackdropColor(1,1,1,.05)
CdbSearchGui.buttonQuest:SetScript("OnClick", function()
    CdbSearchGui.buttonQuest:SetBackdropColor(1,1,1,.15)
    CdbSearchGui.buttonSpawn:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonObject:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonItem:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonSettings:SetBackdropColor(1,1,1,.05)

    CdbSearchGui.quest:Show()
    CdbSearchGui.object:Hide()
    CdbSearchGui.item:Hide()
    CdbSearchGui.spawn:Hide()
    CdbSearchGui.settings:Hide()
end)

CdbSearchGui.buttonSettings = CreateFrame("Button", nil, CdbSearchGui)
--CdbSearchGui.buttonSettings:ClearAllPoints()
CdbSearchGui.buttonSettings:SetWidth(75)
CdbSearchGui.buttonSettings:SetHeight(25)
CdbSearchGui.buttonSettings:SetPoint("TOPLEFT", 413, -50)
CdbSearchGui.buttonSettings:SetBackdrop(backdrop_noborder)
CdbSearchGui.buttonSettings.text = CdbSearchGui.buttonSettings:CreateFontString("Status", "LOW", "GameFontNormal")
CdbSearchGui.buttonSettings.text:ClearAllPoints()
CdbSearchGui.buttonSettings.text:SetAllPoints(CdbSearchGui.buttonSettings)
CdbSearchGui.buttonSettings.text:SetPoint("LEFT", 0, 0)
CdbSearchGui.buttonSettings.text:SetFontObject(GameFontWhite)
CdbSearchGui.buttonSettings.text:SetText("Settings")

CdbSearchGui.buttonSettings:SetBackdropColor(1,1,1,.05)
CdbSearchGui.buttonSettings:SetScript("OnClick", function()
    CdbSearchGui.buttonSettings:SetBackdropColor(1,1,1,.15)
    CdbSearchGui.buttonSpawn:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonObject:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonItem:SetBackdropColor(1,1,1,.05)
    CdbSearchGui.buttonQuest:SetBackdropColor(1,1,1,.05)

    CdbSearchGui.settings:Show()
    CdbSearchGui.object:Hide()
    CdbSearchGui.item:Hide()
    CdbSearchGui.spawn:Hide()
    CdbSearchGui.quest:Hide()

    for name, data in pairs(CdbSearchGui.settings.values) do
        if data.position > 0 then
            if (CdbSearchGui.settings.buttons[data.position]) then
                CdbSearchGui.settings.buttons[data.position]:SetText(data.title)
                CdbSearchGui.settings.buttons[data.position]:Show();
            end
        end
    end
end)

CdbSearchGui.spawn = CreateFrame("Frame",nil,CdbSearchGui)
CdbSearchGui.spawn:SetPoint("TOP", 0, -75)
CdbSearchGui.spawn:SetWidth(475)
CdbSearchGui.spawn:SetHeight(315)
CdbSearchGui.spawn:SetBackdrop(backdrop_noborder)
CdbSearchGui.spawn:SetBackdropColor(1,1,1,.15)
--CdbSearchGui.spawn:SetFrameStrata("DIALOG")
CdbSearchGui.spawn:Hide()
CdbSearchGui.spawn.buttons = {}

CdbSearchGui.object = CreateFrame("Frame",nil,CdbSearchGui)
CdbSearchGui.object:SetPoint("TOP", 0, -75)
CdbSearchGui.object:SetWidth(475)
CdbSearchGui.object:SetHeight(315)
CdbSearchGui.object:SetBackdrop(backdrop_noborder)
CdbSearchGui.object:SetBackdropColor(1,1,1,.15)
--CdbSearchGui.object:SetFrameStrata("DIALOG")
CdbSearchGui.object:Hide()
CdbSearchGui.object.buttons = {}

CdbSearchGui.item = CreateFrame("Frame",nil,CdbSearchGui)
CdbSearchGui.item:SetPoint("TOP", 0, -75)
CdbSearchGui.item:SetWidth(475)
CdbSearchGui.item:SetHeight(315)
CdbSearchGui.item:SetBackdrop(backdrop_noborder)
CdbSearchGui.item:SetBackdropColor(1,1,1,.15)
--CdbSearchGui.item:SetFrameStrata("DIALOG")
CdbSearchGui.item.buttons = {}

CdbSearchGui.quest = CreateFrame("Frame",nil,CdbSearchGui)
CdbSearchGui.quest:SetPoint("TOP", 0, -75)
CdbSearchGui.quest:SetWidth(475)
CdbSearchGui.quest:SetHeight(315)
CdbSearchGui.quest:SetBackdrop(backdrop_noborder)
CdbSearchGui.quest:SetBackdropColor(1,1,1,.15)
--CdbSearchGui.quest:SetFrameStrata("DIALOG")
CdbSearchGui.quest:Hide()
CdbSearchGui.quest.buttons = {}

------------------------------------
-- Definition for the settings frame
------------------------------------
CdbSearchGui.settings = CreateFrame("Frame",nil,CdbSearchGui)
CdbSearchGui.settings:SetPoint("TOP", 0, -75)
CdbSearchGui.settings:SetWidth(475)
CdbSearchGui.settings:SetHeight(315)
CdbSearchGui.settings:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings:SetBackdropColor(1,1,1,.15)
--CdbSearchGui.settings:SetFrameStrata("DIALOG")
CdbSearchGui.settings:Hide()

---------------------------------
-- Definition for the button data
---------------------------------
CdbSearchGui.settings.values = {}
CdbSearchGui.settings.values.dbMode = {
    position = 1,
    title = CdbSettingsText.dbMode,
    OnEnterFunction = function(self)
        this:SetBackdropColor(1,1,1,.25)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting("dbMode")..
                           "\n\n|cffffffff"..
                           "When enabled, this option prevents ClassicDB from cleaning quests\n"..
                           "for other classes and the opposite faction from the quest DB.\n"..
                           "Not recommended for normal users, as it adds many unatainable\n"..
                           "quest starts to the map.|r");
        GameTooltip:Show();
    end,
}
CdbSearchGui.settings.values.questStarts = {
    position = 2,
    title = CdbSettingsText.questStarts,
    OnEnterFunction = function(self)
        this:SetBackdropColor(1,1,1,.25)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting("questStarts")..
                           "\n\n|cffffffff"..
                           "When enabled, this option shows notes for all quests starts\n"..
                           "in the currently displayed zone. If it doesn't load immediately\n"..
                           "reopen the map.|r");
        GameTooltip:Show();
    end,
}
CdbSearchGui.settings.values.filterPreQuest = {
    position = 3,
    title = CdbSettingsText.filterPreQuest,
    OnEnterFunction = function(self)
        this:SetBackdropColor(1,1,1,.25)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting("filterPreQuest")..
                           "\n\n|cffffffff"..
                           "When enabled, this option filter quests starts based on\n"..
                           "their finished status according to ClassicDB. To mark a\n"..
                           "quest as finished use the search or right-click it's\n"..
                           "start icon on the map.|r");
        GameTooltip:Show();
    end,
}
CdbSearchGui.settings.values.filterReqLevel = {
    position = 4,
    title = CdbSettingsText.filterReqLevel,
    OnEnterFunction = function(self)
        this:SetBackdropColor(1,1,1,.25)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting("filterReqLevel")..
                           "\n\n|cffffffff"..
                           "When enabled, this option prevents quest starts from being marked\n"..
                           "if the player doesn't meet the minimum level requirements.|r");
        GameTooltip:Show();
    end,
}
CdbSearchGui.settings.values.reqLevel = {
    position = 5,
    title = CdbSettingsText.reqLevel,
    OnEnterFunction = function(self)
        this:SetBackdropColor(1,1,1,.25)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting("reqLevel")..
                           "\n\n|cffffffff"..
                           "When enabled, this option shows the required level"..
                           "in the quest start tooltips.|r");
        GameTooltip:Show();
    end,
}
CdbSearchGui.settings.values.item_item = {
    position = 6,
    title = CdbSettingsText.item_item,
    OnEnterFunction = function(self)
        this:SetBackdropColor(1,1,1,.25)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting("item_item")..
                           "\n\n|cffffffff"..
                           "When enabled, this option shows item drops from other items.|r\n"..
                           "|cFFFF1A1A!WARNING! This option might be unstable!\n"..
                           "It is recommended to leave it turned of if not needed.|r");
        GameTooltip:Show();
    end,
}
CdbSearchGui.settings.values.waypoints = {
    position = 7,
    title = CdbSettingsText.waypoints,
    OnEnterFunction = function(self)
        this:SetBackdropColor(1,1,1,.25)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting("waypoints")..
                           "\n\n|cffffffff"..
                           "When enabled, mob waypoints are shown on the map.\n"..
                           "Due to script spawns not yet being included in the DB\n"..
                           "this can also be helpful in finding some special mobs.|r");
        GameTooltip:Show();
    end,
}
CdbSearchGui.settings.values.auto_plot = {
    position = 8,
    title = CdbSettingsText.auto_plot,
    OnEnterFunction = function(self)
        this:SetBackdropColor(1,1,1,.25)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting("auto_plot")..
                           "\n\n|cffffffff"..
                           "When enabled, this option shows notes for all quests in the log.\n"..
                           "It will update automatically every time there is a quest\n"..
                           "event, like looting. If you experience lags when finishing\n"..
                           "a quest objective, disable and use the 'Show all notes'\n"..
                           "button as long as the quest drawing too many notes is in\n"..
                           "in your quest log.|r");
        GameTooltip:Show();
    end,
}
CdbSearchGui.settings.values.questIds = {
    position = 0,
    title = CdbSettingsText.questIds,
    OnEnterFunction = function(self)
        this:SetBackdropColor(1,1,1,.25)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting("questIds")..
                           "\n\n|cffffffff"..
                           "When enabled, this option shows the quest ID in the quest start tooltips.|r");
                           -- TODO: Update text once this setting has been fixed. Quest IDs in quest start tooltips are needed for their context menu.
        GameTooltip:Show();
    end,
}

----------------------------------------------------------------
-- This function adds the data defined above to the button table
----------------------------------------------------------------
CdbSearchGui.settings.addLine = function(settingName, position, title, OnEnterFunction)
    CdbSearchGui.settings.buttons[position] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
    CdbSearchGui.settings.buttons[position]:SetPoint("TOP", 0, -position*21+11)
    CdbSearchGui.settings.buttons[position]:SetWidth(450)
    CdbSearchGui.settings.buttons[position]:SetHeight(20)
    CdbSearchGui.settings.buttons[position]:SetFont("Fonts\\FRIZQT__.TTF", 10)
    CdbSearchGui.settings.buttons[position]:SetTextColor(1,1,1,1)
    CdbSearchGui.settings.buttons[position]:SetNormalTexture(nil)
    CdbSearchGui.settings.buttons[position]:SetPushedTexture(nil)
    CdbSearchGui.settings.buttons[position]:SetHighlightTexture(nil)
    CdbSearchGui.settings.buttons[position]:SetBackdrop(backdrop_noborder)
    if math.mod(position,2) == 0 then
        CdbSearchGui.settings.buttons[position]:SetBackdropColor(1,1,1,.05)
        CdbSearchGui.settings.buttons[position].even = true
    else
        CdbSearchGui.settings.buttons[position]:SetBackdropColor(1,1,1,.10)
        CdbSearchGui.settings.buttons[position].even = false
    end
    CdbSearchGui.settings.buttons[position]:SetScript("OnEnter", OnEnterFunction)
    CdbSearchGui.settings.buttons[position]:SetScript("OnLeave", function(self)
        if this.even == true then
            this:SetBackdropColor(1,1,1,.05)
        else
            this:SetBackdropColor(1,1,1,.10)
        end
        GameTooltip:Hide();
    end)
    CdbSearchGui.settings.buttons[position].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[position],"UICheckButtonTemplate")
    CdbSearchGui.settings.buttons[position].enabled:SetPoint("RIGHT", -25, 0)
    CdbSearchGui.settings.buttons[position].enabled:SetWidth(20)
    CdbSearchGui.settings.buttons[position].enabled:SetHeight(20)
    CdbSearchGui.settings.buttons[position].enabled:SetScript("OnShow", function(self)
        if (CdbSettings[settingName] ~= true) then
            CdbSearchGui.settings.buttons[position].enabled:SetChecked(false);
        else
            CdbSearchGui.settings.buttons[position].enabled:SetChecked(true);
        end
    end)
    CdbSearchGui.settings.buttons[position].enabled:SetScript("OnClick", function(self)
        CdbSwitchSetting(settingName);
        if (CdbSettings[settingName] ~= true) then
            CdbSearchGui.settings.buttons[position].enabled:SetChecked(false);
        else
            CdbSearchGui.settings.buttons[position].enabled:SetChecked(true);
        end
    end)
end

-------------------------------------------
-- Create the button table and add the data
-------------------------------------------
CdbSearchGui.settings.buttons = {}
for name, data in pairs(CdbSearchGui.settings.values) do
    if data.position > 0 then
        CdbSearchGui.settings.addLine(name, data.position, data.title, data.OnEnterFunction)
    end
end

function CdbSearchGui.HideButtons()
    for i=1,14 do
        if (CdbSearchGui.spawn.buttons[i]) then
            CdbSearchGui.spawn.buttons[i]:Hide();
        end
        if (CdbSearchGui.object.buttons[i]) then
            CdbSearchGui.object.buttons[i]:Hide();
        end
        if (CdbSearchGui.item.buttons[i]) then
            CdbSearchGui.item.buttons[i]:Hide();
        end
        if (CdbSearchGui.quest.buttons[i]) then
            CdbSearchGui.quest.buttons[i]:Hide();
        end
    end
end
function CdbSearchGui:SearchSpawn(search)
    local spawnCount = 1;
    local database = CdbFavourites["spawn"]
    if ((strlen(search) > 2) or (tonumber(search) ~= nil)) then database = npcData end
    for id, spawn in pairs(database) do
        local npc;
        if type(spawn) == "boolean" then
            npc = npcData[id];
        else
            npc = spawn;
        end
        -- TODO Make a separate function for this search and the the whole button drawing. It's redundant with the object/item/quest search, apart from a few things that can be handeled with if conditions.
        if npc ~= nil and ((tonumber(search) == nil and (strlen(search) <= 2 or strfind(strlower(npc[DB_NAME]), strlower(search)))) or (tonumber(search) ~= nil and strfind(tostring(id), search))) then
            if ( spawnCount <= 14) then
                local name = npc[DB_NAME];
                CdbSearchGui.spawn.buttons[spawnCount] = CreateFrame("Button","mybutton",CdbSearchGui.spawn,"UIPanelButtonTemplate")
                CdbSearchGui.spawn.buttons[spawnCount]:SetPoint("TOP", 0, -spawnCount*21+11)
                CdbSearchGui.spawn.buttons[spawnCount]:SetWidth(450)
                CdbSearchGui.spawn.buttons[spawnCount]:SetHeight(20)
                CdbSearchGui.spawn.buttons[spawnCount]:SetFont("Fonts\\FRIZQT__.TTF", 10)
                CdbSearchGui.spawn.buttons[spawnCount]:SetTextColor(1,1,1,1)
                CdbSearchGui.spawn.buttons[spawnCount]:SetNormalTexture(nil)
                CdbSearchGui.spawn.buttons[spawnCount]:SetPushedTexture(nil)
                CdbSearchGui.spawn.buttons[spawnCount]:SetHighlightTexture(nil)
                CdbSearchGui.spawn.buttons[spawnCount]:SetBackdrop(backdrop_noborder)
                if math.mod(spawnCount,2) == 0 then
                    CdbSearchGui.spawn.buttons[spawnCount]:SetBackdropColor(1,1,1,.05)
                    CdbSearchGui.spawn.buttons[spawnCount].even = true
                else
                CdbSearchGui.spawn.buttons[spawnCount]:SetBackdropColor(1,1,1,.10)
                    CdbSearchGui.spawn.buttons[spawnCount].even = false
                end
                CdbSearchGui.spawn.buttons[spawnCount]:SetTextColor(1,1,1)
                if npc[DB_LEVEL] ~= "" then
                    CdbSearchGui.spawn.buttons[spawnCount]:SetText(name .. " |cffaaaaaa(Lv." .. npc[DB_LEVEL] .. ", ID:" .. id .. ")")
                else
                    CdbSearchGui.spawn.buttons[spawnCount]:SetText(name)
                end
                CdbSearchGui.spawn.buttons[spawnCount].spawnName = name
                CdbSearchGui.spawn.buttons[spawnCount].spawnId = id;
                CdbSearchGui.spawn.buttons[spawnCount]:SetScript("OnClick", function(self)
                    CdbMapNotes = {};
                    CdbPrepareForDrawing(DB_NPC, this.spawnName, this.spawnName, "Spawnpoint", 0);
                    CdbShowMap();
                end)
                CdbSearchGui.spawn.buttons[spawnCount]:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                end)
                CdbSearchGui.spawn.buttons[spawnCount]:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                end)
                -- show faction icons (deactivated until faction is added to NPC data)
                local faction = "HA" --spawnDB[CdbSearchGui.spawn.buttons[spawnCount].spawnName]['faction']
                if strfind(faction, "H") and faction ~= "HA" then
                    CdbSearchGui.spawn.buttons[spawnCount].horde = CreateFrame("Frame", nil, CdbSearchGui.spawn.buttons[spawnCount])
                    CdbSearchGui.spawn.buttons[spawnCount].horde:SetPoint("RIGHT", -5, 0)
                    CdbSearchGui.spawn.buttons[spawnCount].horde:SetWidth(20)
                    CdbSearchGui.spawn.buttons[spawnCount].horde:SetHeight(20)
                    CdbSearchGui.spawn.buttons[spawnCount].horde.icon = CdbSearchGui.spawn.buttons[spawnCount].horde:CreateTexture(nil,"BACKGROUND")
                    CdbSearchGui.spawn.buttons[spawnCount].horde.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_horde")
                    CdbSearchGui.spawn.buttons[spawnCount].horde.icon:SetAllPoints(CdbSearchGui.spawn.buttons[spawnCount].horde)
                end
                if strfind(faction, "A") and faction ~= "HA" then
                    CdbSearchGui.spawn.buttons[spawnCount].alliance = CreateFrame("Frame", nil, CdbSearchGui.spawn.buttons[spawnCount])
                    if CdbSearchGui.spawn.buttons[spawnCount].horde then
                        CdbSearchGui.spawn.buttons[spawnCount].alliance:SetPoint("RIGHT", -30, 0)
                    else
                        CdbSearchGui.spawn.buttons[spawnCount].alliance:SetPoint("RIGHT", -5, 0)
                    end
                    CdbSearchGui.spawn.buttons[spawnCount].alliance:SetWidth(20)
                    CdbSearchGui.spawn.buttons[spawnCount].alliance:SetHeight(20)
                    CdbSearchGui.spawn.buttons[spawnCount].alliance.icon = CdbSearchGui.spawn.buttons[spawnCount].alliance:CreateTexture(nil,"BACKGROUND")
                    CdbSearchGui.spawn.buttons[spawnCount].alliance.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_alliance")
                    CdbSearchGui.spawn.buttons[spawnCount].alliance.icon:SetAllPoints(CdbSearchGui.spawn.buttons[spawnCount].alliance)
                end
                -- show fav button
                CdbSearchGui.spawn.buttons[spawnCount].fav = CreateFrame("Button","mybutton",CdbSearchGui.spawn.buttons[spawnCount],"UIPanelButtonTemplate")
                CdbSearchGui.spawn.buttons[spawnCount].fav:SetPoint("LEFT", 5, 0)
                CdbSearchGui.spawn.buttons[spawnCount].fav:SetWidth(20)
                CdbSearchGui.spawn.buttons[spawnCount].fav:SetHeight(20)
                CdbSearchGui.spawn.buttons[spawnCount].fav:SetNormalTexture(nil)
                CdbSearchGui.spawn.buttons[spawnCount].fav:SetPushedTexture(nil)
                CdbSearchGui.spawn.buttons[spawnCount].fav:SetHighlightTexture(nil)
                CdbSearchGui.spawn.buttons[spawnCount].fav.icon = CdbSearchGui.spawn.buttons[spawnCount].fav:CreateTexture(nil,"BACKGROUND")
                CdbSearchGui.spawn.buttons[spawnCount].fav.icon:SetTexture("Interface\\AddOns\\ClassicDB\\img\\fav")
                if CdbFavourites["spawn"][id] then
                    CdbSearchGui.spawn.buttons[spawnCount].fav.icon:SetVertexColor(1,1,1,1)
                else
                    CdbSearchGui.spawn.buttons[spawnCount].fav.icon:SetVertexColor(0,0,0,1)
                end
                CdbSearchGui.spawn.buttons[spawnCount].fav.icon:SetAllPoints(CdbSearchGui.spawn.buttons[spawnCount].fav)
                CdbSearchGui.spawn.buttons[spawnCount].fav:SetScript("OnClick", function(self)
                if CdbFavourites["spawn"][this:GetParent().spawnId] then
                    CdbFavourites["spawn"][this:GetParent().spawnId] = nil
                    this.icon:SetVertexColor(0,0,0,1)
                    CdbSearchGui.inputField:updateSearch()
                else
                    CdbFavourites["spawn"][this:GetParent().spawnId] = true
                    this.icon:SetVertexColor(1,1,1,1)
                end
            end)
        end
        spawnCount = spawnCount + 1
      end
    end
    spawnCount = spawnCount -1
    if spawnCount == 0 then
        CdbSearchGui.buttonSpawn.text:SetText("Mobs")
    else
        CdbSearchGui.buttonSpawn.text:SetText("Mobs |cffaaaaaa(" .. spawnCount .. ")")
    end
end
function CdbSearchGui:SearchObject(search)
    local objectCount = 1;
    local database = CdbFavourites["object"]
    if ((strlen(search) > 2) or (tonumber(search) ~= nil)) then database = objData end
    for id, object in pairs(database) do
        local obj;
        if type(object) == "boolean" then
            obj = objData[id];
        else
            obj = object;
        end
        if obj ~= nil and ((tonumber(search) == nil and (strlen(search) <= 2 or strfind(strlower(obj[DB_NAME]), strlower(search)))) or (tonumber(search) ~= nil and strfind(tostring(id), search))) then
            if ( objectCount <= 14) then
                local name = obj[DB_NAME];
                CdbSearchGui.object.buttons[objectCount] = CreateFrame("Button","mybutton",CdbSearchGui.object,"UIPanelButtonTemplate")
                CdbSearchGui.object.buttons[objectCount]:SetPoint("TOP", 0, -objectCount*21+11)
                CdbSearchGui.object.buttons[objectCount]:SetWidth(450)
                CdbSearchGui.object.buttons[objectCount]:SetHeight(20)
                CdbSearchGui.object.buttons[objectCount]:SetFont("Fonts\\FRIZQT__.TTF", 10)
                CdbSearchGui.object.buttons[objectCount]:SetTextColor(1,1,1,1)
                CdbSearchGui.object.buttons[objectCount]:SetNormalTexture(nil)
                CdbSearchGui.object.buttons[objectCount]:SetPushedTexture(nil)
                CdbSearchGui.object.buttons[objectCount]:SetHighlightTexture(nil)
                CdbSearchGui.object.buttons[objectCount]:SetBackdrop(backdrop_noborder)
                if math.mod(objectCount,2) == 0 then
                    CdbSearchGui.object.buttons[objectCount]:SetBackdropColor(1,1,1,.05)
                    CdbSearchGui.object.buttons[objectCount].even = true
                else
                    CdbSearchGui.object.buttons[objectCount]:SetBackdropColor(1,1,1,.10)
                    CdbSearchGui.object.buttons[objectCount].even = false
                end
                CdbSearchGui.object.buttons[objectCount]:SetTextColor(1,1,1)
                CdbSearchGui.object.buttons[objectCount]:SetText(name .. " |cffaaaaaa(ID:" .. id .. ")")
                CdbSearchGui.object.buttons[objectCount].objectName = name
                CdbSearchGui.object.buttons[objectCount].objectId = id
                CdbSearchGui.object.buttons[objectCount]:SetScript("OnClick", function(self)
                    CdbMapNotes = {};
                    CdbPrepareForDrawing(DB_OBJ, this.objectName, this.objectName, "Spawnpoint", 0);
                    CdbShowMap();
                end)
                CdbSearchGui.object.buttons[objectCount]:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                end)
                CdbSearchGui.object.buttons[objectCount]:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                end)
                -- show faction icons (deactivated - do objects even have a faction?)
                local faction = "HA" --objectDB[CdbSearchGui.object.buttons[objectCount].objectName]['faction']
                if strfind(faction, "H") and faction ~= "HA" then
                    CdbSearchGui.object.buttons[objectCount].horde = CreateFrame("Frame", nil, CdbSearchGui.object.buttons[objectCount])
                    CdbSearchGui.object.buttons[objectCount].horde:SetPoint("RIGHT", -5, 0)
                    CdbSearchGui.object.buttons[objectCount].horde:SetWidth(20)
                    CdbSearchGui.object.buttons[objectCount].horde:SetHeight(20)
                    CdbSearchGui.object.buttons[objectCount].horde.icon = CdbSearchGui.object.buttons[objectCount].horde:CreateTexture(nil,"BACKGROUND")
                    CdbSearchGui.object.buttons[objectCount].horde.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_horde")
                    CdbSearchGui.object.buttons[objectCount].horde.icon:SetAllPoints(CdbSearchGui.object.buttons[objectCount].horde)
                end
                if strfind(faction, "A") and faction ~= "HA" then
                    CdbSearchGui.object.buttons[objectCount].alliance = CreateFrame("Frame", nil, CdbSearchGui.object.buttons[objectCount])
                    if CdbSearchGui.object.buttons[objectCount].horde then
                        CdbSearchGui.object.buttons[objectCount].alliance:SetPoint("RIGHT", -30, 0)
                    else
                        CdbSearchGui.object.buttons[objectCount].alliance:SetPoint("RIGHT", -5, 0)
                    end
                    CdbSearchGui.object.buttons[objectCount].alliance:SetWidth(20)
                    CdbSearchGui.object.buttons[objectCount].alliance:SetHeight(20)
                    CdbSearchGui.object.buttons[objectCount].alliance.icon = CdbSearchGui.object.buttons[objectCount].alliance:CreateTexture(nil,"BACKGROUND")
                    CdbSearchGui.object.buttons[objectCount].alliance.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_alliance")
                    CdbSearchGui.object.buttons[objectCount].alliance.icon:SetAllPoints(CdbSearchGui.object.buttons[objectCount].alliance)
                end
                -- show fav button
                CdbSearchGui.object.buttons[objectCount].fav = CreateFrame("Button","mybutton",CdbSearchGui.object.buttons[objectCount],"UIPanelButtonTemplate")
                CdbSearchGui.object.buttons[objectCount].fav:SetPoint("LEFT", 5, 0)
                CdbSearchGui.object.buttons[objectCount].fav:SetWidth(20)
                CdbSearchGui.object.buttons[objectCount].fav:SetHeight(20)
                CdbSearchGui.object.buttons[objectCount].fav:SetNormalTexture(nil)
                CdbSearchGui.object.buttons[objectCount].fav:SetPushedTexture(nil)
                CdbSearchGui.object.buttons[objectCount].fav:SetHighlightTexture(nil)
                CdbSearchGui.object.buttons[objectCount].fav.icon = CdbSearchGui.object.buttons[objectCount].fav:CreateTexture(nil,"BACKGROUND")
                CdbSearchGui.object.buttons[objectCount].fav.icon:SetTexture("Interface\\AddOns\\ClassicDB\\img\\fav")
                if CdbFavourites["object"][id] then
                    CdbSearchGui.object.buttons[objectCount].fav.icon:SetVertexColor(1,1,1,1)
                else
                    CdbSearchGui.object.buttons[objectCount].fav.icon:SetVertexColor(0,0,0,1)
                end
                CdbSearchGui.object.buttons[objectCount].fav.icon:SetAllPoints(CdbSearchGui.object.buttons[objectCount].fav)
                CdbSearchGui.object.buttons[objectCount].fav:SetScript("OnClick", function(self)
                    if CdbFavourites["object"][this:GetParent().objectId] then
                        CdbFavourites["object"][this:GetParent().objectId] = nil
                        this.icon:SetVertexColor(0,0,0,1)
                        CdbSearchGui.inputField:updateSearch()
                    else
                        CdbFavourites["object"][this:GetParent().objectId] = true
                        this.icon:SetVertexColor(1,1,1,1)
                    end
                end)
            end
            objectCount = objectCount + 1
        end
    end
    objectCount = objectCount -1
    if objectCount == 0 then
        CdbSearchGui.buttonObject.text:SetText("Objects")
    else
        CdbSearchGui.buttonObject.text:SetText("Objects |cffaaaaaa(" .. objectCount .. ")")
    end
end
function CdbSearchGui:SearchItem(search)
    local itemCount = 1;
    local database = CdbFavourites["item"]
    if ((strlen(search) > 2) or (tonumber(search) ~= nil)) then database = itemData end
    for id, item in pairs(database) do
        local itm;
        if type(item) == "boolean" then
            itm = itemData[id];
        else
            itm = item;
        end
        if itm ~= nil and ((tonumber(search) == nil and (strlen(search) <= 2 or strfind(strlower(itm[DB_ITM_NAME]), strlower(search)))) or (tonumber(search) ~= nil and strfind(tostring(id), search))) then
            if ( itemCount <= 14) then
                local name = itm[DB_ITM_NAME];
                local itemColor
                GameTooltip:SetHyperlink("item:" .. id .. ":0:0:0")
                GameTooltip:Hide()
                local _, itemLink, itemQuality, _, _, _, _, _, itemTexture = GetItemInfo(id)
                if itemQuality then itemColor = "|c" .. string.format("%02x%02x%02x%02x", 255,
                                                ITEM_QUALITY_COLORS[itemQuality].r * 255,
                                                ITEM_QUALITY_COLORS[itemQuality].g * 255,
                                                ITEM_QUALITY_COLORS[itemQuality].b * 255)
                else itemColor = "|cffffffff" end
                CdbSearchGui.item.buttons[itemCount] = CreateFrame("Button","mybutton",CdbSearchGui.item,"UIPanelButtonTemplate")
                CdbSearchGui.item.buttons[itemCount]:SetPoint("TOP", 0, -itemCount*21+11)
                CdbSearchGui.item.buttons[itemCount]:SetWidth(450)
                CdbSearchGui.item.buttons[itemCount]:SetHeight(20)
                CdbSearchGui.item.buttons[itemCount]:SetFont("Fonts\\FRIZQT__.TTF", 10)
                CdbSearchGui.item.buttons[itemCount]:SetNormalTexture(nil)
                CdbSearchGui.item.buttons[itemCount]:SetPushedTexture(nil)
                CdbSearchGui.item.buttons[itemCount]:SetHighlightTexture(nil)
                CdbSearchGui.item.buttons[itemCount]:SetBackdrop(backdrop_noborder)
                if math.mod(itemCount,2) == 0 then
                    CdbSearchGui.item.buttons[itemCount]:SetBackdropColor(1,1,1,.05)
                    CdbSearchGui.item.buttons[itemCount].even = true
                else
                    CdbSearchGui.item.buttons[itemCount]:SetBackdropColor(1,1,1,.10)
                    CdbSearchGui.item.buttons[itemCount].even = false
                end
                CdbSearchGui.item.buttons[itemCount].itemName = name
                CdbSearchGui.item.buttons[itemCount].itemColor = itemColor
                CdbSearchGui.item.buttons[itemCount].itemId = id
                CdbSearchGui.item.buttons[itemCount].itemLink = itemLink
                CdbSearchGui.item.buttons[itemCount]:SetText(itemColor .."|Hitem:"..id..":0:0:0|h["..name.."]|h|r |cffaaaaaa(ID:" .. id .. ")")
                CdbSearchGui.item.buttons[itemCount]:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                    GameTooltip:SetOwner(CdbSearchGui, "ANCHOR_CURSOR")
                    GameTooltip:SetHyperlink("item:" .. this.itemId .. ":0:0:0")
                    GameTooltip:Show()
                end)
                CdbSearchGui.item.buttons[itemCount]:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                end)
                CdbSearchGui.item.buttons[itemCount]:SetScript("OnClick", function(self)
                    if IsShiftKeyDown() then
                        if not ChatFrameEditBox:IsVisible() then
                            ChatFrameEditBox:Show()
                        end
	                   ChatFrameEditBox:Insert(this.itemColor .."|Hitem:"..this.itemId..":0:0:0|h["..this.itemName.."]|h|r")
                    elseif IsControlKeyDown() then
                        DressUpItemLink(this.itemId);
                    else
                        ShowUIPanel(ItemRefTooltip);
                        if ( not ItemRefTooltip:IsVisible() ) then
                            ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
                        end
                        ItemRefTooltip:SetHyperlink("item:" .. this.itemId .. ":0:0:0")
                    end
                end)
                -- show npc button
                if CdbGetTableLength(itm[DB_NPC]) ~= 0 then
                    CdbSearchGui.item.buttons[itemCount].lootNpc = CreateFrame("Button","mybutton",CdbSearchGui.item.buttons[itemCount],"UIPanelButtonTemplate")
                    CdbSearchGui.item.buttons[itemCount].lootNpc:SetPoint("RIGHT", -5, 0)
                    CdbSearchGui.item.buttons[itemCount].lootNpc:SetWidth(20)
                    CdbSearchGui.item.buttons[itemCount].lootNpc:SetHeight(20)
                    CdbSearchGui.item.buttons[itemCount].lootNpc:SetNormalTexture(nil)
                    CdbSearchGui.item.buttons[itemCount].lootNpc:SetPushedTexture(nil)
                    CdbSearchGui.item.buttons[itemCount].lootNpc:SetHighlightTexture(nil)
                    CdbSearchGui.item.buttons[itemCount].lootNpc.icon = CdbSearchGui.item.buttons[itemCount].lootNpc:CreateTexture(nil,"BACKGROUND")
                    CdbSearchGui.item.buttons[itemCount].lootNpc.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_npc")
                    CdbSearchGui.item.buttons[itemCount].lootNpc.icon:SetAllPoints(CdbSearchGui.item.buttons[itemCount].lootNpc)
                    CdbSearchGui.item.buttons[itemCount].lootNpc:SetScript("OnClick", function(self)
                        CdbMapNotes = {};
                        CdbPrepareItemNotes(this:GetParent().itemId, "Location for: "..this:GetParent().itemName, "Drops item: "..this:GetParent().itemName, cMark, {DB_NPC});
                        CdbNextMark();
                        CdbShowMap();
                    end)
                end
                -- show object button
                if CdbGetTableLength(itm[DB_OBJ]) ~= 0 then
                    CdbSearchGui.item.buttons[itemCount].lootObj = CreateFrame("Button","mybutton",CdbSearchGui.item.buttons[itemCount],"UIPanelButtonTemplate")
                    if CdbSearchGui.item.buttons[itemCount].lootNpc then
                        CdbSearchGui.item.buttons[itemCount].lootObj:SetPoint("RIGHT", -30, 0)
                    else
                        CdbSearchGui.item.buttons[itemCount].lootObj:SetPoint("RIGHT", -5, 0)
                    end
                    CdbSearchGui.item.buttons[itemCount].lootObj:SetWidth(20)
                    CdbSearchGui.item.buttons[itemCount].lootObj:SetHeight(20)
                    CdbSearchGui.item.buttons[itemCount].lootObj:SetNormalTexture(nil)
                    CdbSearchGui.item.buttons[itemCount].lootObj:SetPushedTexture(nil)
                    CdbSearchGui.item.buttons[itemCount].lootObj:SetHighlightTexture(nil)
                    CdbSearchGui.item.buttons[itemCount].lootObj.icon = CdbSearchGui.item.buttons[itemCount].lootObj:CreateTexture(nil,"BACKGROUND")
                    CdbSearchGui.item.buttons[itemCount].lootObj.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_object")
                    CdbSearchGui.item.buttons[itemCount].lootObj.icon:SetAllPoints(CdbSearchGui.item.buttons[itemCount].lootObj)
                    CdbSearchGui.item.buttons[itemCount].lootObj:SetScript("OnClick", function(self)
                        CdbMapNotes = {};
                        CdbPrepareItemNotes(this:GetParent().itemId, "Location for: "..this:GetParent().itemName, "Contains item: "..this:GetParent().itemName, "CdbObject", {DB_OBJ});
                        CdbNextMark();
                        CdbShowMap();
                    end)
                end
                -- show vendor button
                if CdbGetTableLength(itm[DB_VENDOR]) ~= 0 then
                    CdbSearchGui.item.buttons[itemCount].vendor = CreateFrame("Button","mybutton",CdbSearchGui.item.buttons[itemCount],"UIPanelButtonTemplate")
                    if CdbSearchGui.item.buttons[itemCount].lootNpc and CdbSearchGui.item.buttons[itemCount].lootObj then
                        CdbSearchGui.item.buttons[itemCount].vendor:SetPoint("RIGHT", -55, 0)
                    elseif CdbSearchGui.item.buttons[itemCount].lootNpc or CdbSearchGui.item.buttons[itemCount].lootObj then
                        CdbSearchGui.item.buttons[itemCount].vendor:SetPoint("RIGHT", -30, 0)
                    else
                        CdbSearchGui.item.buttons[itemCount].vendor:SetPoint("RIGHT", -5, 0)
                    end
                    CdbSearchGui.item.buttons[itemCount].vendor:SetWidth(20)
                    CdbSearchGui.item.buttons[itemCount].vendor:SetHeight(20)
                    CdbSearchGui.item.buttons[itemCount].vendor:SetNormalTexture(nil)
                    CdbSearchGui.item.buttons[itemCount].vendor:SetPushedTexture(nil)
                    CdbSearchGui.item.buttons[itemCount].vendor:SetHighlightTexture(nil)
                    CdbSearchGui.item.buttons[itemCount].vendor.icon = CdbSearchGui.item.buttons[itemCount].vendor:CreateTexture(nil,"BACKGROUND")
                    CdbSearchGui.item.buttons[itemCount].vendor.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_vendor")
                    CdbSearchGui.item.buttons[itemCount].vendor.icon:SetAllPoints(CdbSearchGui.item.buttons[itemCount].vendor)
                    CdbSearchGui.item.buttons[itemCount].vendor:SetScript("OnClick", function(self)
                        CdbMapNotes = {};
                        CdbPrepareItemNotes(this:GetParent().itemId, "Location for: "..this:GetParent().itemName, "Sells item: "..this:GetParent().itemName, "CdbVendor", {DB_VENDOR});
                        CdbNextMark();
                        CdbShowMap();
                    end)
                end
                -- show fav button
                CdbSearchGui.item.buttons[itemCount].fav = CreateFrame("Button","mybutton",CdbSearchGui.item.buttons[itemCount],"UIPanelButtonTemplate")
                CdbSearchGui.item.buttons[itemCount].fav:SetPoint("LEFT", 5, 0)
                CdbSearchGui.item.buttons[itemCount].fav:SetWidth(20)
                CdbSearchGui.item.buttons[itemCount].fav:SetHeight(20)
                CdbSearchGui.item.buttons[itemCount].fav:SetNormalTexture(nil)
                CdbSearchGui.item.buttons[itemCount].fav:SetPushedTexture(nil)
                CdbSearchGui.item.buttons[itemCount].fav:SetHighlightTexture(nil)
                CdbSearchGui.item.buttons[itemCount].fav.icon = CdbSearchGui.item.buttons[itemCount].fav:CreateTexture(nil,"BACKGROUND")
                CdbSearchGui.item.buttons[itemCount].fav.icon:SetTexture("Interface\\AddOns\\ClassicDB\\img\\fav")
                if CdbFavourites["item"][id] then
                    CdbSearchGui.item.buttons[itemCount].fav.icon:SetVertexColor(1,1,1,1)
                else
                    CdbSearchGui.item.buttons[itemCount].fav.icon:SetVertexColor(0,0,0,1)
                end
                CdbSearchGui.item.buttons[itemCount].fav.icon:SetAllPoints(CdbSearchGui.item.buttons[itemCount].fav)
                CdbSearchGui.item.buttons[itemCount].fav:SetScript("OnClick", function(self)
                    if CdbFavourites["item"][this:GetParent().itemId] then
                        CdbFavourites["item"][this:GetParent().itemId] = nil
                        this.icon:SetVertexColor(0,0,0,1)
                        CdbSearchGui.inputField:updateSearch()
                    else
                        CdbFavourites["item"][this:GetParent().itemId] = true
                        this.icon:SetVertexColor(1,1,1,1)
                    end
                end)
            end
            itemCount = itemCount + 1
        end
    end
    itemCount = itemCount -1
    if itemCount == 0 then
        CdbSearchGui.buttonItem.text:SetText("Items")
    else
        CdbSearchGui.buttonItem.text:SetText("Items |cffaaaaaa(" .. itemCount .. ")")
    end
end
function CdbSearchGui:SearchQuest(search)
    local questCount = 1;
    local database = CdbFavourites["quest"]
    if ((strlen(search) > 2) or (tonumber(search) ~= nil)) then database = qData end
    for id, quest in pairs(database) do
        local q;
        if type(quest) == "boolean" then
            q = qData[id];
        else
            q = quest;
        end
        if q ~= nil and ((tonumber(search) == nil and (strlen(search) <= 2 or strfind(strlower(q[DB_NAME]), strlower(search)))) or (tonumber(search) ~= nil and strfind(tostring(id), search))) then
            if questCount <= 14 then
                local name = q[DB_NAME];
                CdbSearchGui.quest.buttons[questCount] = CreateFrame("Button","mybutton",CdbSearchGui.quest,"UIPanelButtonTemplate")
                CdbSearchGui.quest.buttons[questCount]:SetPoint("TOP", 0, -questCount*22+11)
                CdbSearchGui.quest.buttons[questCount]:SetWidth(450)
                CdbSearchGui.quest.buttons[questCount]:SetHeight(20)
                CdbSearchGui.quest.buttons[questCount]:SetFont("Fonts\\FRIZQT__.TTF", 10)
                CdbSearchGui.quest.buttons[questCount]:SetNormalTexture(nil)
                CdbSearchGui.quest.buttons[questCount]:SetPushedTexture(nil)
                CdbSearchGui.quest.buttons[questCount]:SetHighlightTexture(nil)
                CdbSearchGui.quest.buttons[questCount]:SetBackdrop(backdrop_noborder)
                if math.mod(questCount,2) == 0 then
                    CdbSearchGui.quest.buttons[questCount]:SetBackdropColor(1,1,1,.05)
                    CdbSearchGui.quest.buttons[questCount].even = true
                else
                    CdbSearchGui.quest.buttons[questCount]:SetBackdropColor(1,1,1,.10)
                    CdbSearchGui.quest.buttons[questCount].even = false
                end
                CdbSearchGui.quest.buttons[questCount].questName = name
                CdbSearchGui.quest.buttons[questCount].questId = id
                -- linefeed for tooltip
                -- simplest method choosen for performance reasons
                if q[DB_OBJECTIVES] then
                    CdbSearchGui.quest.buttons[questCount].questObjectives = q[DB_OBJECTIVES];
                end
                CdbSearchGui.quest.buttons[questCount]:SetText("|cffffcc00["..q[DB_LEVEL].."] |Hquest:0:0:0:0|h["..name.."]|h|r|r (ID:"..id..")")
                CdbSearchGui.quest.buttons[questCount]:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                    GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                    GameTooltip:ClearLines();
                    GameTooltip:AddLine(this:GetText())
                    GameTooltip:AddLine("\n")
                    if this.questObjectives then
                        GameTooltip:AddLine("|cffffffffObjectives: |r"..this.questObjectives, 0.7, 0.7, 0.7, true)
                    end
                    GameTooltip:AddLine("|cffffffffMinLevel: |r"..qData[this.questId][DB_MIN_LEVEL], 0.7, 0.7, 0.7)
                    GameTooltip:Show();
                end)
                CdbSearchGui.quest.buttons[questCount]:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                    GameTooltip:Hide()
                end)
                CdbSearchGui.quest.buttons[questCount]:SetScript("OnClick", function(self)
                    if IsShiftKeyDown() then
                        if not ChatFrameEditBox:IsVisible() then
                            ChatFrameEditBox:Show()
                        end
                        ChatFrameEditBox:Insert("|cffffff00|Hquest:0:0:0:0|h["..this.questName.."]|h|r")
                    else
                        CdbMapNotes = {};
                        CdbGetQuestNotesById(this.questId)
                        CdbNextMark();
                        CdbShowMap();
                    end
                end)
                -- show faction icons
                local faction = ""
                --[[
                for monsterName, monsterDrop in pairs(questDB[name]) do
                    if spawnDB[monsterName] and  spawnDB[monsterName]['faction'] then
                    faction = faction .. spawnDB[monsterName]['faction']
                end
                --]]
                if strfind(faction, "H") and faction ~= "HA" then
                    CdbSearchGui.quest.buttons[questCount].horde = CreateFrame("Frame", nil, CdbSearchGui.quest.buttons[questCount])
                    CdbSearchGui.quest.buttons[questCount].horde:SetPoint("RIGHT", -5, 0)
                    CdbSearchGui.quest.buttons[questCount].horde:SetWidth(20)
                    CdbSearchGui.quest.buttons[questCount].horde:SetHeight(20)
                    CdbSearchGui.quest.buttons[questCount].horde.icon = CdbSearchGui.quest.buttons[questCount].horde:CreateTexture(nil,"BACKGROUND")
                    CdbSearchGui.quest.buttons[questCount].horde.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_horde")
                    CdbSearchGui.quest.buttons[questCount].horde.icon:SetAllPoints(CdbSearchGui.quest.buttons[questCount].horde)
                end
                if strfind(faction, "A") and faction ~= "HA" then
                    CdbSearchGui.quest.buttons[questCount].alliance = CreateFrame("Frame", nil, CdbSearchGui.quest.buttons[questCount])
                    if CdbSearchGui.quest.buttons[questCount].horde then
                        CdbSearchGui.quest.buttons[questCount].alliance:SetPoint("RIGHT", -30, 0)
                    else
                        CdbSearchGui.quest.buttons[questCount].alliance:SetPoint("RIGHT", -5, 0)
                    end
                    CdbSearchGui.quest.buttons[questCount].alliance:SetWidth(20)
                    CdbSearchGui.quest.buttons[questCount].alliance:SetHeight(20)
                    CdbSearchGui.quest.buttons[questCount].alliance.icon = CdbSearchGui.quest.buttons[questCount].alliance:CreateTexture(nil,"BACKGROUND")
                    CdbSearchGui.quest.buttons[questCount].alliance.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_alliance")
                    CdbSearchGui.quest.buttons[questCount].alliance.icon:SetAllPoints(CdbSearchGui.quest.buttons[questCount].alliance)
                end
                -- show fav button
                CdbSearchGui.quest.buttons[questCount].fav = CreateFrame("Button","mybutton",CdbSearchGui.quest.buttons[questCount],"UIPanelButtonTemplate")
                CdbSearchGui.quest.buttons[questCount].fav:SetPoint("LEFT", 5, 0)
                CdbSearchGui.quest.buttons[questCount].fav:SetWidth(20)
                CdbSearchGui.quest.buttons[questCount].fav:SetHeight(20)
                CdbSearchGui.quest.buttons[questCount].fav:SetNormalTexture(nil)
                CdbSearchGui.quest.buttons[questCount].fav:SetPushedTexture(nil)
                CdbSearchGui.quest.buttons[questCount].fav:SetHighlightTexture(nil)
                CdbSearchGui.quest.buttons[questCount].fav.icon = CdbSearchGui.quest.buttons[questCount].fav:CreateTexture(nil,"BACKGROUND")
                CdbSearchGui.quest.buttons[questCount].fav.icon:SetTexture("Interface\\AddOns\\ClassicDB\\img\\fav")
                if CdbFavourites["quest"][id] then
                    CdbSearchGui.quest.buttons[questCount].fav.icon:SetVertexColor(1,1,1,1)
                else
                    CdbSearchGui.quest.buttons[questCount].fav.icon:SetVertexColor(0,0,0,1)
                end
                CdbSearchGui.quest.buttons[questCount].fav.icon:SetAllPoints(CdbSearchGui.quest.buttons[questCount].fav)
                CdbSearchGui.quest.buttons[questCount].fav:SetScript("OnClick", function(self)
                    if CdbFavourites["quest"][this:GetParent().questId] then
                        CdbFavourites["quest"][this:GetParent().questId] = nil
                        this.icon:SetVertexColor(0,0,0,1)
                        CdbSearchGui.inputField:updateSearch()
                    else
                        CdbFavourites["quest"][this:GetParent().questId] = true
                        this.icon:SetVertexColor(1,1,1,1)
                    end
                end)
                CdbSearchGui.quest.buttons[questCount].fav:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                    GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                    GameTooltip:ClearLines();
                    GameTooltip:SetText("Mark as Favourite\n\n|cffffffffFavourites are shown when the search bar is empty.|r");
                    GameTooltip:Show();
                end)
                CdbSearchGui.quest.buttons[questCount].fav:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                    GameTooltip:Hide();
                end)
                -- show quest finished buttonQuest
                CdbSearchGui.quest.buttons[questCount].finished = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.quest.buttons[questCount],"UICheckButtonTemplate")
                CdbSearchGui.quest.buttons[questCount].finished.questId = CdbSearchGui.quest.buttons[questCount].questId;
                CdbSearchGui.quest.buttons[questCount].finished:SetPoint("RIGHT", -25, 0)
                CdbSearchGui.quest.buttons[questCount].finished:SetWidth(20)
                CdbSearchGui.quest.buttons[questCount].finished:SetHeight(20)
                if (CdbFinishedQuests[id] ~= true) then
                    CdbSearchGui.quest.buttons[questCount].finished:SetChecked(false);
                else
                    CdbSearchGui.quest.buttons[questCount].finished:SetChecked(true);
                end
                CdbSearchGui.quest.buttons[questCount].finished:SetScript("OnClick", function(self)
                    if (CdbFinishedQuests[this.questId] == true) then
                        CdbFinishedQuests[this.questId] = nil;
                    else
                        CdbFinishedQuests[this.questId] = true;
                    end
                end)
                CdbSearchGui.quest.buttons[questCount].finished:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                    GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                    GameTooltip:ClearLines();
                    GameTooltip:SetText("Mark as finished\n\n|cffffffffQuests that are marked as finished do not appear when Quest Starts are plotted.\nTo refresh your Quest Start display, clean the map and then reenable Quest Starts.|r");
                    GameTooltip:Show();
                end)
                CdbSearchGui.quest.buttons[questCount].finished:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                    GameTooltip:Hide();
                end)
            end
            questCount = questCount + 1
        end
    end
    questCount = questCount -1
    if questCount == 0 then
        CdbSearchGui.buttonQuest.text:SetText("Quests")
    else
        CdbSearchGui.buttonQuest.text:SetText("Quests |cffaaaaaa(" .. questCount .. ")")
    end
end

------------------------------
-- Create the control GUI frame
------------------------------
CdbControlGui = CreateFrame("Frame",nil,UIParent)
CdbControlGui:SetFrameStrata("DIALOG")
CdbControlGui:SetWidth(40)
CdbControlGui:SetHeight(164)
CdbControlGui:SetBackdrop(backdrop)
CdbControlGui:SetBackdropColor(0,0,0,.85)
CdbControlGui:SetMovable(true)
CdbControlGui:EnableMouse(true)
CdbControlGui:RegisterForDrag("LeftButton")
CdbControlGui:SetScript("OnMouseDown",function()
    CdbControlGui:StartMoving()
end)
CdbControlGui:SetScript("OnMouseUp",function()
    CdbControlGui:StopMovingOrSizing()
    local _, _, _, x, y = CdbControlGui:GetPoint()
    CdbSettings.x = x
    CdbSettings.y = y
end)
CdbControlGui:Show()

--------------------------------------------
-- Function for adding buttons with graphics
--------------------------------------------
CdbControlGui.AddButton = function(name, position, textureFile, OnEnterFunctionString, OnClickFunction)
    CdbControlGui.buttons[position] = CreateFrame("Button",name,CdbControlGui,"OptionsButtonTemplate")
    CdbControlGui.buttons[position].nTex = {
        bgFile = textureFile,
        tile = false,
        tileSize = 24,
        insets = {left = 0, right = 0, top = 0, bottom = 0},
    }
    CdbControlGui.buttons[position]:SetPoint("TOP", 0, -position*24-5)
    CdbControlGui.buttons[position]:SetWidth(24)
    CdbControlGui.buttons[position]:SetHeight(24)
    CdbControlGui.buttons[position]:SetBackdrop(CdbControlGui.buttons[position].nTex)
    CdbControlGui.buttons[position]:SetNormalTexture(nil)
    CdbControlGui.buttons[position]:SetPushedTexture(nil)
    CdbControlGui.buttons[position]:SetHighlightTexture(nil)
    CdbControlGui.buttons[position]:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(OnEnterFunctionString);
        GameTooltip:Show();
    end)
    CdbControlGui.buttons[position]:SetScript("OnLeave", function(self)
        GameTooltip:Hide();
    end)
    CdbControlGui.buttons[position]:SetScript("OnClick", OnClickFunction)
end

----------------------------
-- Define the button content
----------------------------
CdbControlGui.buttonValues = {}
CdbControlGui.buttonValues.CleanMap = {
    position = 0,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\Map",
    OnEnterFunctionString = "Clean Map"..
                            "\n\n|cffffffff"..
                            "Clear all ClassicDB notes from the map. This disables the\n"..
                            "settings \"Automatic note update\" and \"Show quest starts\".\n"..
                            "They can be reenabled at the bottom of the control GUI.|r",
    OnClickFunction = function(self)
        CdbCleanMapAndPreventRedraw();
    end,
}
CdbControlGui.buttonValues.ShowAllQuests = {
    position = 1,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\MarkMap",
    OnEnterFunctionString = "Show all current quests"..
                            "\n\n|cffffffff"..
                            "Plot notes on the map for all quest currently in the quest log.\n"..
                            "This draws notes only once, for automatic updates enable the\n"..
                            "corresponding option at the bottom of the control GUI.|r",
    OnClickFunction = function(self)
        CdbGetAllQuestNotes();
        WorldMapFrame:Show();
    end,
}
CdbControlGui.buttonValues.CycleMap = {
    position = 2,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\MapCycle",
    OnEnterFunctionString = "Cycle zones"..
                            "\n\n|cffffffff"..
                            "Cycle through the currently marked zones.|r",
    OnClickFunction = function(self)
        CdbCycleMarkedZones();
    end,
}
CdbControlGui.buttonValues.ShowSelectedQuest = {
    position = 3,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\Log",
    OnEnterFunctionString = "Show currently selected Quest"..
                            "\n\n|cffffffff"..
                            "Plot notes on the map for the quest currently selected\n"..
                            "in the quest log.|r",
    OnClickFunction = function(self)
        CdbGetSelectionQuestNotes();
        WorldMapFrame:Show();
    end,
}
CdbControlGui.buttonValues.ResizeMap = {
    position = 4,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\Arrows",
    OnEnterFunctionString = "Reset map and icons to default size",
    OnClickFunction = function(self)
         CdbResetMapAndIconSize()
    end,
}
CdbControlGui.buttonValues.ShowSearch = {
    position = 5,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\Glass",
    OnEnterFunctionString = "Toggle settings and search window"..
                            "\n\n|cffffffff"..
                            "Show a window where you can adjust the ClassicDB settings\n"..
                            "or search for creatures, objects, items, and quests.|r",
    OnClickFunction = function(self)
        if (CdbSearchGui:IsShown()) then
            CdbSearchGui:Hide()
        else
            CdbSearchGui:Show()
        end
    end,
}

------------------
-- Add the buttons
------------------
CdbControlGui.buttons = {}
for name, data in pairs(CdbControlGui.buttonValues) do
    CdbControlGui.AddButton(name, data.position, data.textureFile, data.OnEnterFunctionString, data.OnClickFunction)
end

------------------------------------
-- Function for adding check buttons
------------------------------------
CdbControlGui.AddCheckButton = function(name, position, OnEnterFunctionString)
    CdbControlGui.checkButtons[position] = CreateFrame("CheckButton", "mycheckbutton", CdbControlGui, "UICheckButtonTemplate")
    CdbControlGui.checkButtons[position].settingName = name
    CdbControlGui.checkButtons[position]:SetPoint("BOTTOMLEFT", position*12+2, 2)
    CdbControlGui.checkButtons[position]:SetWidth(12)
    CdbControlGui.checkButtons[position]:SetHeight(12)
    CdbControlGui.checkButtons[position]:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:SetText(CdbGetSetting(this.settingName)..OnEnterFunctionString);
        GameTooltip:Show();
    end)
    CdbControlGui.checkButtons[position]:SetScript("OnLeave", function(self)
        GameTooltip:Hide();
    end)
    CdbControlGui.checkButtons[position]:SetScript("OnClick", function()
        CdbSwitchSetting(this.settingName)
    end)
end

----------------------------------
-- Define the check button content
----------------------------------
CdbControlGui.checkButtonValues = {}

CdbControlGui.checkButtonValues.auto_plot = {
    position = 0,
    OnEnterFunctionString = "\n\n|cffffffff"..
                            "When enabled, this option shows notes for all quests in the log.\n"..
                            "It will update automatically every time there is a quest\n"..
                            "event, like looting. If you experience lags when finishing\n"..
                            "a quest objective, disable and use the 'Show all notes'\n"..
                            "button as long as the quest drawing too many notes is in\n"..
                            "in your quest log.|r",
}
CdbControlGui.checkButtonValues.questStarts = {
    position = 1,
    OnEnterFunctionString = "\n\n|cffffffff"..
                            "When enabled, this option shows notes for all quests starts\n"..
                            "in the currently displayed zone. If it doesn't load immediately\n"..
                            "reopen the map.|r",
}
CdbControlGui.checkButtonValues.waypoints = {
    position = 2,
    OnEnterFunctionString = "\n\n|cffffffff"..
                            "When enabled, mob waypoints are shown on the map.\n"..
                            "Due to script spawns not yet being included in the DB\n"..
                            "this can also be helpful in finding some special mobs.|r",
}

------------------
-- Add the buttons
------------------
CdbControlGui.checkButtons = {}
for name, data in pairs(CdbControlGui.checkButtonValues) do
    CdbControlGui.AddCheckButton(name, data.position, data.OnEnterFunctionString)
end
