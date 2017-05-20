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

---------------------------------------------
-- Set up SavedVariables if they do not exist
---------------------------------------------
if not CdbFavourites then CdbFavourites = {} end
if not CdbFavourites["spawn"] then CdbFavourites["spawn"] = {} end
if not CdbFavourites["object"] then CdbFavourites["object"] = {} end
if not CdbFavourites["item"] then CdbFavourites["item"] = {} end
if not CdbFavourites["quest"] then CdbFavourites["quest"] = {} end

--------------------------
-- Set up global variables
--------------------------
CDB_MAX_SEARCH_PAGE_LINES = 14;
CDB_MIN_SEARCH_CHARS = 3;
CDB_MIN_SEARCH_INTS = 1;
CdbLastSearchQuery = ""
CdbLastSearchResults = {}
CdbLastSearchResults.spawn = {}
CdbLastSearchResults.object = {}
CdbLastSearchResults.item = {}
CdbLastSearchResults.quest = {}


------------------------------------------------------------
-- Auxiliary frame for registering events and initialization
------------------------------------------------------------
CdbAuxiliaryFrame = CreateFrame("Frame", "CdbAuxiliaryFrame", UIParent)
CdbAuxiliaryFrame:SetScript("OnEvent", function() CdbOnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) end)
CdbAuxiliaryFrame:RegisterEvent("PLAYER_LOGIN");
CdbAuxiliaryFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
CdbAuxiliaryFrame:RegisterEvent("QUEST_LOG_UPDATE");
CdbAuxiliaryFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
CdbAuxiliaryFrame:RegisterEvent("WORLD_MAP_UPDATE");

------------------------------
-- Create the search GUI frame
------------------------------
CdbSearchGui = CreateFrame("Frame","CdbSearchGui",UIParent)
tinsert(UISpecialFrames, "CdbSearchGui")
CdbSearchGui:Hide()
CdbSearchGui:SetFrameStrata('FULLSCREEN_DIALOG')
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
CdbSearchGui.minimapButton:SetFrameStrata('FULLSCREEN_DIALOG')
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
    GameTooltip:AddLine("ClassicDB");
    GameTooltip:AddLine("\n|cffffffffLeftClick:|r Toggle search window"..
                        "\n|cffffffffRightClick:|r Toggle control window"..
                        "\n|cffffffffShift + LeftClick:|r Reset Map and Icon Size"..
                        "\n|cffffffffShift + RightClick:|r Reset and show both windows");
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
    local query = CdbSearchGui.inputField:GetText();
    if query == "Search" then
        query = "";
    end
    -- Clear the last results if the search query got shorter
    if (strlen(query) < strlen(CdbLastSearchQuery)) or (CdbLastSearchQuery == "") then
        CdbClearTable(CdbLastSearchResults.spawn);
        CdbClearTable(CdbLastSearchResults.object);
        CdbClearTable(CdbLastSearchResults.item);
        CdbClearTable(CdbLastSearchResults.quest);
    end
    CdbSearchGui:Search(query, "spawn");
    CdbSearchGui:Search(query, "object");
    CdbSearchGui:Search(query, "item");
    CdbSearchGui:Search(query, "quest");
    -- This update needs to be done last, so the search function can use it above
    CdbLastSearchQuery = query;
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

-- Create the result frames
function CdbCreateResultFrame(searchType)
    CdbSearchGui[searchType] = CreateFrame("ScrollFrame",nil,CdbSearchGui)
    CdbSearchGui[searchType]:SetPoint("TOP", 0, -75)
    CdbSearchGui[searchType]:SetWidth(475)
    CdbSearchGui[searchType]:SetHeight(315)
    CdbSearchGui[searchType]:SetBackdrop(backdrop_noborder)
    CdbSearchGui[searchType]:SetBackdropColor(1,1,1,.15)
    CdbSearchGui[searchType]:EnableMouseWheel(1)
    CdbSearchGui[searchType]:SetScript("OnMouseWheel", function()
        this.scrollBar:SetValue(this.scrollBar:GetValue() - arg1);
    end)
    CdbSearchGui[searchType]:Hide()
    CdbSearchGui[searchType].buttons = {}
    CdbSearchGui[searchType].scrollBar = CreateFrame("Slider",nil,CdbSearchGui[searchType],"UIPanelScrollBarTemplate")
    CdbSearchGui[searchType].scrollBar:SetPoint("TOPRIGHT",CdbSearchGui[searchType],"TOPRIGHT",0,-27)
    CdbSearchGui[searchType].scrollBar:SetPoint("BOTTOMRIGHT",CdbSearchGui[searchType],"BOTTOMRIGHT",0,28)
    CdbSearchGui[searchType].scrollBar:SetWidth(16)
    CdbSearchGui[searchType].scrollBar:SetMinMaxValues(1,1)
    CdbSearchGui[searchType].scrollBar:SetValue(1)
    CdbSearchGui[searchType].scrollBar:SetValueStep(1)
    if (searchType == "spawn") then
        CdbSearchGui[searchType].scrollBar.database = npcData;
        CdbSearchGui[searchType].scrollBar.NAME_KEY = DB_NAME;
    elseif (searchType == "object") then
        CdbSearchGui[searchType].scrollBar.database = objData;
        CdbSearchGui[searchType].scrollBar.NAME_KEY = DB_NAME;
    elseif (searchType == "item") then
        CdbSearchGui[searchType].scrollBar.database = itemData;
        CdbSearchGui[searchType].scrollBar.NAME_KEY = DB_ITM_NAME;
    elseif (searchType == "quest") then
        CdbSearchGui[searchType].scrollBar.database = qData;
        CdbSearchGui[searchType].scrollBar.NAME_KEY = DB_NAME;
    end
    CdbSearchGui[searchType].scrollBar:SetScript("OnValueChanged", function()
        CdbUpdateResultButtons(searchType);
    end)
end

CdbCreateResultFrame("spawn")
CdbCreateResultFrame("object")
CdbCreateResultFrame("item")
CdbSearchGui.item:Show()
CdbCreateResultFrame("quest")

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
        GameTooltip:AddLine(CdbGetSetting("dbMode"));
        GameTooltip:AddLine("\n|cffffffffWhen enabled, this option prevents ClassicDB from cleaning quests for other classes and the opposite faction from the quest DB. Not recommended for normal users, as it adds many unatainable quest starts to the map.|r", nil, nil, nil, true);
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
        GameTooltip:AddLine(CdbGetSetting("questStarts"));
        GameTooltip:AddLine("\n|cffffffffWhen enabled, the map will show quests starts. There are further options controlling which quest starts are shown in the search GUI.|r", nil, nil, nil, true);
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
        GameTooltip:AddLine(CdbGetSetting("filterPreQuest"));
        GameTooltip:AddLine("\n|cffffffffWhen enabled, this option filter quests starts based on their finished status according to ClassicDB. To mark a quest as finished use the search or right-click its start icon on the map.|r", nil, nil, nil, true);
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
        GameTooltip:AddLine(CdbGetSetting("filterReqLevel"));
        GameTooltip:AddLine("\n|cffffffffWhen enabled, this option prevents quest starts from being marked if the player doesn't meet the minimum level requirements.|r", nil, nil, nil, true);
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
        GameTooltip:AddLine(CdbGetSetting("reqLevel"));
        GameTooltip:AddLine("\n|cffffffffWhen enabled, this option shows the required level in the quest start tooltips.|r", nil, nil, nil, true);
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
        GameTooltip:AddLine(CdbGetSetting("item_item"));
        GameTooltip:AddLine("\n|cffffffffWhen enabled, this option shows item drops from other items. Experimental.|r\n\n|cFFFF1A1AWARNING! This option might crash your client! It is recommended to leave it turned off.|r", nil, nil, nil, true);
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
        GameTooltip:AddLine(CdbGetSetting("waypoints"))
        GameTooltip:AddLine("\n|cffffffffWhen enabled, creature waypoints are shown on the map. Due to script spawns not yet being included in the DB this may also be helpful in finding some special mobs.|r", nil, nil, nil, true);
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
        GameTooltip:AddLine(CdbGetSetting("auto_plot"));
        GameTooltip:AddLine("\n|cffffffffWhen enabled, this option shows notes for all quests in the log. It will update automatically every time there is a quest event, like looting. If you experience lags when finishing a quest objective, disable this and use the |rShow all current quests|cffffffff button in the control GUI, as long as the quest drawing too many notes is in your quest log.|r", nil, nil, nil, true);
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
        GameTooltip:AddLine(CdbGetSetting("questIds"));
        GameTooltip:AddLine("\n|cffffffffWhen enabled, this option shows the quest ID in the quest start tooltips.|r", nil, nil, nil, true);
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

---------------------------
-- Search related functions
---------------------------
function CdbSearchGui.HideButtons()
    for i=1, CDB_MAX_SEARCH_PAGE_LINES do
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

-- Create a single search result button with additional sub-buttons, depending on the searchType
-- TODO: Reuse frames?
function CdbCreateResultButtons(searchType, searchCount, dbEntry, id, NAME_KEY)
    -- General button setup
    local name = dbEntry[NAME_KEY];
    CdbSearchGui[searchType].buttons[searchCount] = CreateFrame("Button","mybutton",CdbSearchGui[searchType],"UIPanelButtonTemplate");
    CdbSearchGui[searchType].buttons[searchCount]:Show();
    CdbSearchGui[searchType].buttons[searchCount]:SetPoint("TOP", 0, -searchCount*21+11);
    CdbSearchGui[searchType].buttons[searchCount]:SetWidth(440);
    CdbSearchGui[searchType].buttons[searchCount]:SetHeight(20);
    CdbSearchGui[searchType].buttons[searchCount]:SetFont("Fonts\\FRIZQT__.TTF", 10);
    CdbSearchGui[searchType].buttons[searchCount]:SetTextColor(1,1,1,1);
    CdbSearchGui[searchType].buttons[searchCount]:SetNormalTexture(nil);
    CdbSearchGui[searchType].buttons[searchCount]:SetPushedTexture(nil);
    CdbSearchGui[searchType].buttons[searchCount]:SetHighlightTexture(nil);
    CdbSearchGui[searchType].buttons[searchCount]:SetBackdrop(backdrop_noborder);
    if math.mod(searchCount,2) == 0 then
        CdbSearchGui[searchType].buttons[searchCount]:SetBackdropColor(1,1,1,.05);
        CdbSearchGui[searchType].buttons[searchCount].even = true;
    else
        CdbSearchGui[searchType].buttons[searchCount]:SetBackdropColor(1,1,1,.10);
        CdbSearchGui[searchType].buttons[searchCount].even = false;
    end
    CdbSearchGui[searchType].buttons[searchCount]:SetTextColor(1,1,1);
    CdbSearchGui[searchType].buttons[searchCount].name = name;
    CdbSearchGui[searchType].buttons[searchCount].id = id;

    -- Type specific setup
    if searchType == "spawn" then
        if dbEntry[DB_LEVEL] ~= "" then
            CdbSearchGui[searchType].buttons[searchCount]:SetText(name .. " |cffaaaaaa(Lv." .. dbEntry[DB_LEVEL] .. ", ID:" .. id .. ")")
        else
            CdbSearchGui[searchType].buttons[searchCount]:SetText(name)
        end
        CdbSearchGui[searchType].buttons[searchCount]:SetScript("OnClick", function(self)
            CdbMapNotes = {};
            CdbPrepareForDrawing(DB_NPC, this.name, this.name, "Spawnpoint", 0);
            CdbDrawNotesAndShowMap();
        end)
    elseif searchType == "object" then
        CdbSearchGui[searchType].buttons[searchCount]:SetText(name .. " |cffaaaaaa(ID:" .. id .. ")")
        CdbSearchGui.object.buttons[searchCount]:SetScript("OnClick", function(self)
            CdbMapNotes = {};
            CdbPrepareForDrawing(DB_OBJ, this.name, this.name, "Object Spawnpoint", 0);
            CdbDrawNotesAndShowMap();
        end)
    elseif searchType == "item" then
        local itemColor
        GameTooltip:SetHyperlink("item:" .. id .. ":0:0:0")
        GameTooltip:Hide()
        local _, itemLink, itemQuality, _, _, _, _, _, itemTexture = GetItemInfo(id)
        if itemQuality then itemColor = "|c" .. string.format("%02x%02x%02x%02x", 255,
                                        ITEM_QUALITY_COLORS[itemQuality].r * 255,
                                        ITEM_QUALITY_COLORS[itemQuality].g * 255,
                                        ITEM_QUALITY_COLORS[itemQuality].b * 255)
        else itemColor = "|cffffffff"
        end
        CdbSearchGui[searchType].buttons[searchCount].itemColor = itemColor
        CdbSearchGui[searchType].buttons[searchCount].itemLink = itemLink
        CdbSearchGui[searchType].buttons[searchCount]:SetText(itemColor .."|Hitem:"..id..":0:0:0|h["..name.."]|h|r |cffaaaaaa(ID:" .. id .. ")")
        CdbSearchGui[searchType].buttons[searchCount]:SetScript("OnClick", function(self)
            if IsShiftKeyDown() then
                if not ChatFrameEditBox:IsVisible() then
                    ChatFrameEditBox:Show()
                end
               ChatFrameEditBox:Insert(this.itemColor .."|Hitem:"..this.id..":0:0:0|h["..this.name.."]|h|r")
            elseif IsControlKeyDown() then
                DressUpItemLink(this.id);
            else
                ShowUIPanel(ItemRefTooltip);
                if ( not ItemRefTooltip:IsVisible() ) then
                    ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
                end
                ItemRefTooltip:SetHyperlink("item:" .. this.id .. ":0:0:0")
            end
        end)
        CdbSearchGui[searchType].buttons[searchCount]:SetScript("OnEnter", function(self)
            this:SetBackdropColor(1,1,1,.25)
            GameTooltip:SetOwner(CdbSearchGui, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink("item:" .. this.id .. ":0:0:0")
            GameTooltip:Show()
        end)
        -- show npc button
        if CdbGetTableLength(dbEntry[DB_NPC]) ~= 0 then
            CdbSearchGui[searchType].buttons[searchCount].lootNpc = CreateFrame("Button","mybutton",CdbSearchGui[searchType].buttons[searchCount],"UIPanelButtonTemplate")
            CdbSearchGui[searchType].buttons[searchCount].lootNpc:SetPoint("RIGHT", -5, 0)
            CdbSearchGui[searchType].buttons[searchCount].lootNpc:SetWidth(20)
            CdbSearchGui[searchType].buttons[searchCount].lootNpc:SetHeight(20)
            CdbSearchGui[searchType].buttons[searchCount].lootNpc:SetNormalTexture(nil)
            CdbSearchGui[searchType].buttons[searchCount].lootNpc:SetPushedTexture(nil)
            CdbSearchGui[searchType].buttons[searchCount].lootNpc:SetHighlightTexture(nil)
            CdbSearchGui[searchType].buttons[searchCount].lootNpc.icon = CdbSearchGui[searchType].buttons[searchCount].lootNpc:CreateTexture(nil,"BACKGROUND")
            CdbSearchGui[searchType].buttons[searchCount].lootNpc.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_npc")
            CdbSearchGui[searchType].buttons[searchCount].lootNpc.icon:SetAllPoints(CdbSearchGui[searchType].buttons[searchCount].lootNpc)
            CdbSearchGui[searchType].buttons[searchCount].lootNpc:SetScript("OnClick", function(self)
                CdbMapNotes = {};
                CdbPrepareItemNotes(this:GetParent().id, "Location for: "..this:GetParent().name, "Drops item: "..this:GetParent().name, cMark, {DB_NPC});
                CdbNextMark();
                CdbDrawNotesAndShowMap();
            end)
        end
        -- show object button
        if CdbGetTableLength(dbEntry[DB_OBJ]) ~= 0 then
            CdbSearchGui[searchType].buttons[searchCount].lootObj = CreateFrame("Button","mybutton",CdbSearchGui[searchType].buttons[searchCount],"UIPanelButtonTemplate")
            if CdbSearchGui[searchType].buttons[searchCount].lootNpc then
                CdbSearchGui[searchType].buttons[searchCount].lootObj:SetPoint("RIGHT", -30, 0)
            else
                CdbSearchGui[searchType].buttons[searchCount].lootObj:SetPoint("RIGHT", -5, 0)
            end
            CdbSearchGui[searchType].buttons[searchCount].lootObj:SetWidth(20)
            CdbSearchGui[searchType].buttons[searchCount].lootObj:SetHeight(20)
            CdbSearchGui[searchType].buttons[searchCount].lootObj:SetNormalTexture(nil)
            CdbSearchGui[searchType].buttons[searchCount].lootObj:SetPushedTexture(nil)
            CdbSearchGui[searchType].buttons[searchCount].lootObj:SetHighlightTexture(nil)
            CdbSearchGui[searchType].buttons[searchCount].lootObj.icon = CdbSearchGui[searchType].buttons[searchCount].lootObj:CreateTexture(nil,"BACKGROUND")
            CdbSearchGui[searchType].buttons[searchCount].lootObj.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_object")
            CdbSearchGui[searchType].buttons[searchCount].lootObj.icon:SetAllPoints(CdbSearchGui[searchType].buttons[searchCount].lootObj)
            CdbSearchGui[searchType].buttons[searchCount].lootObj:SetScript("OnClick", function(self)
                CdbMapNotes = {};
                CdbPrepareItemNotes(this:GetParent().id, "Location for: "..this:GetParent().name, "Contains item: "..this:GetParent().name, "CdbObject", {DB_OBJ});
                CdbNextMark();
                CdbDrawNotesAndShowMap();
            end)
        end
        -- show vendor button
        if CdbGetTableLength(dbEntry[DB_VENDOR]) ~= 0 then
            CdbSearchGui[searchType].buttons[searchCount].vendor = CreateFrame("Button","mybutton",CdbSearchGui[searchType].buttons[searchCount],"UIPanelButtonTemplate")
            if CdbSearchGui[searchType].buttons[searchCount].lootNpc and CdbSearchGui[searchType].buttons[searchCount].lootObj then
                CdbSearchGui[searchType].buttons[searchCount].vendor:SetPoint("RIGHT", -55, 0)
            elseif CdbSearchGui[searchType].buttons[searchCount].lootNpc or CdbSearchGui[searchType].buttons[searchCount].lootObj then
                CdbSearchGui[searchType].buttons[searchCount].vendor:SetPoint("RIGHT", -30, 0)
            else
                CdbSearchGui[searchType].buttons[searchCount].vendor:SetPoint("RIGHT", -5, 0)
            end
            CdbSearchGui[searchType].buttons[searchCount].vendor:SetWidth(20)
            CdbSearchGui[searchType].buttons[searchCount].vendor:SetHeight(20)
            CdbSearchGui[searchType].buttons[searchCount].vendor:SetNormalTexture(nil)
            CdbSearchGui[searchType].buttons[searchCount].vendor:SetPushedTexture(nil)
            CdbSearchGui[searchType].buttons[searchCount].vendor:SetHighlightTexture(nil)
            CdbSearchGui[searchType].buttons[searchCount].vendor.icon = CdbSearchGui[searchType].buttons[searchCount].vendor:CreateTexture(nil,"BACKGROUND")
            CdbSearchGui[searchType].buttons[searchCount].vendor.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_vendor")
            CdbSearchGui[searchType].buttons[searchCount].vendor.icon:SetAllPoints(CdbSearchGui[searchType].buttons[searchCount].vendor)
            CdbSearchGui[searchType].buttons[searchCount].vendor:SetScript("OnClick", function(self)
                CdbMapNotes = {};
                CdbPrepareItemNotes(this:GetParent().id, "Location for: "..this:GetParent().name, "Sells item: "..this:GetParent().name, "CdbVendor", {DB_VENDOR});
                CdbNextMark();
                CdbDrawNotesAndShowMap();
            end)
        end
    elseif searchType == "quest" then
        if dbEntry[DB_OBJECTIVES] then
            CdbSearchGui[searchType].buttons[searchCount].questObjectives = dbEntry[DB_OBJECTIVES];
        end
        CdbSearchGui[searchType].buttons[searchCount]:SetText("|cffffcc00["..dbEntry[DB_LEVEL].."] |Hquest:0:0:0:0|h["..name.."]|h|r|r (ID:"..id..")")
        CdbSearchGui[searchType].buttons[searchCount]:SetScript("OnClick", function(self)
            if IsShiftKeyDown() then
                if not ChatFrameEditBox:IsVisible() then
                    ChatFrameEditBox:Show()
                end
                ChatFrameEditBox:Insert("|cffffff00|Hquest:0:0:0:0|h["..this.name.."]|h|r")
            else
                CdbMapNotes = {};
                CdbGetQuestNotesById(this.id)
                CdbNextMark();
                CdbDrawNotesAndShowMap();
            end
        end)
        CdbSearchGui[searchType].buttons[searchCount]:SetScript("OnEnter", function(self)
            this:SetBackdropColor(1,1,1,.25)
            GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
            GameTooltip:ClearLines();
            GameTooltip:AddLine(this:GetText())
            GameTooltip:AddLine("\n")
            if this.questObjectives then
                GameTooltip:AddLine("|cffffffffObjectives: |r"..this.questObjectives, 0.7, 0.7, 0.7, true)
            end
            GameTooltip:AddLine("|cffffffffMinLevel: |r"..qData[this.id][DB_MIN_LEVEL], 0.7, 0.7, 0.7)
            GameTooltip:Show();
        end)
        -- show quest finished check-button
        CdbSearchGui[searchType].buttons[searchCount].finished = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui[searchType].buttons[searchCount],"UICheckButtonTemplate")
        CdbSearchGui[searchType].buttons[searchCount].finished.id = CdbSearchGui[searchType].buttons[searchCount].id;
        CdbSearchGui[searchType].buttons[searchCount].finished:SetPoint("RIGHT", -25, 0)
        CdbSearchGui[searchType].buttons[searchCount].finished:SetWidth(20)
        CdbSearchGui[searchType].buttons[searchCount].finished:SetHeight(20)
        if (CdbFinishedQuests[id] ~= true) then
            CdbSearchGui[searchType].buttons[searchCount].finished:SetChecked(false);
        else
            CdbSearchGui[searchType].buttons[searchCount].finished:SetChecked(true);
        end
        CdbSearchGui[searchType].buttons[searchCount].finished:SetScript("OnClick", function()
            if this:GetChecked() then
                CdbFinishedQuests[this.id] = true;
            else
                CdbFinishedQuests[this.id] = nil;
            end
        end)
    end
    -- Common setup. Spawns and objects are missing a tooltip.
    if searchType == "spawn" or searchType == "object" then
        CdbSearchGui[searchType].buttons[searchCount]:SetScript("OnEnter", function(self)
            this:SetBackdropColor(1,1,1,.25)
        end)
    end
    CdbSearchGui[searchType].buttons[searchCount]:SetScript("OnLeave", function(self)
        if this.even == true then
            this:SetBackdropColor(1,1,1,.05)
        else
            this:SetBackdropColor(1,1,1,.10)
        end
        GameTooltip:Hide();
    end)
    --[[
    -- type specific
    -- show faction icons (deactivated until faction is added to NPC data)
    local faction = "HA" --spawnDB[CdbSearchGui[searchType].buttons[searchCount].name]['faction']
    if strfind(faction, "H") and faction ~= "HA" then
        CdbSearchGui[searchType].buttons[searchCount].horde = CreateFrame("Frame", nil, CdbSearchGui[searchType].buttons[searchCount])
        CdbSearchGui[searchType].buttons[searchCount].horde:SetPoint("RIGHT", -5, 0)
        CdbSearchGui[searchType].buttons[searchCount].horde:SetWidth(20)
        CdbSearchGui[searchType].buttons[searchCount].horde:SetHeight(20)
        CdbSearchGui[searchType].buttons[searchCount].horde.icon = CdbSearchGui[searchType].buttons[searchCount].horde:CreateTexture(nil,"BACKGROUND")
        CdbSearchGui[searchType].buttons[searchCount].horde.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_horde")
        CdbSearchGui[searchType].buttons[searchCount].horde.icon:SetAllPoints(CdbSearchGui[searchType].buttons[searchCount].horde)
    end
    if strfind(faction, "A") and faction ~= "HA" then
        CdbSearchGui[searchType].buttons[searchCount].alliance = CreateFrame("Frame", nil, CdbSearchGui[searchType].buttons[searchCount])
        if CdbSearchGui[searchType].buttons[searchCount].horde then
            CdbSearchGui[searchType].buttons[searchCount].alliance:SetPoint("RIGHT", -30, 0)
        else
            CdbSearchGui[searchType].buttons[searchCount].alliance:SetPoint("RIGHT", -5, 0)
        end
        CdbSearchGui[searchType].buttons[searchCount].alliance:SetWidth(20)
        CdbSearchGui[searchType].buttons[searchCount].alliance:SetHeight(20)
        CdbSearchGui[searchType].buttons[searchCount].alliance.icon = CdbSearchGui[searchType].buttons[searchCount].alliance:CreateTexture(nil,"BACKGROUND")
        CdbSearchGui[searchType].buttons[searchCount].alliance.icon:SetTexture("Interface\\AddOns\\ClassicDB\\symbols\\icon_alliance")
        CdbSearchGui[searchType].buttons[searchCount].alliance.icon:SetAllPoints(CdbSearchGui[searchType].buttons[searchCount].alliance)
    end
    --]]
    -- Show favourite button
    CdbSearchGui[searchType].buttons[searchCount].fav = CreateFrame("Button","mybutton",CdbSearchGui[searchType].buttons[searchCount],"UIPanelButtonTemplate")
    CdbSearchGui[searchType].buttons[searchCount].fav:SetPoint("LEFT", 5, 0)
    CdbSearchGui[searchType].buttons[searchCount].fav:SetWidth(20)
    CdbSearchGui[searchType].buttons[searchCount].fav:SetHeight(20)
    CdbSearchGui[searchType].buttons[searchCount].fav:SetNormalTexture(nil)
    CdbSearchGui[searchType].buttons[searchCount].fav:SetPushedTexture(nil)
    CdbSearchGui[searchType].buttons[searchCount].fav:SetHighlightTexture(nil)
    CdbSearchGui[searchType].buttons[searchCount].fav.icon = CdbSearchGui[searchType].buttons[searchCount].fav:CreateTexture(nil,"BACKGROUND")
    CdbSearchGui[searchType].buttons[searchCount].fav.icon:SetTexture("Interface\\AddOns\\ClassicDB\\img\\fav")
    if CdbFavourites[searchType][id] then
        CdbSearchGui[searchType].buttons[searchCount].fav.icon:SetVertexColor(1,1,1,1)
    else
        CdbSearchGui[searchType].buttons[searchCount].fav.icon:SetVertexColor(0,0,0,1)
    end
    CdbSearchGui[searchType].buttons[searchCount].fav.icon:SetAllPoints(CdbSearchGui[searchType].buttons[searchCount].fav)
    CdbSearchGui[searchType].buttons[searchCount].fav:SetScript("OnClick", function(self)
        if CdbFavourites[searchType][this:GetParent().id] then
            CdbFavourites[searchType][this:GetParent().id] = nil
            this.icon:SetVertexColor(0,0,0,1)
            CdbSearchGui.inputField:updateSearch()
        else
            CdbFavourites[searchType][this:GetParent().id] = true
            this.icon:SetVertexColor(1,1,1,1)
        end
    end)
end

-- This function (re-)draws the search result page
function CdbUpdateResultButtons(searchType, query)
    if (not query) then
        query = CdbLastSearchQuery;
    end
    for i=1, CDB_MAX_SEARCH_PAGE_LINES do
        if (CdbSearchGui[searchType].buttons[i]) and (CdbSearchGui[searchType].buttons[i]:IsShown()) then
            CdbSearchGui[searchType].buttons[i]:Hide();
        end
    end
    local resultCount = 1;
    local searchCount = 1;
    local max = (CdbSearchGui[searchType].scrollBar:GetValue() * CDB_MAX_SEARCH_PAGE_LINES) + 1;
    local min = max - CDB_MAX_SEARCH_PAGE_LINES;
    local db = CdbFavourites[searchType];
    if  ((strlen(query) >= CDB_MIN_SEARCH_CHARS)
        or
        ((tonumber(query) ~= nil) and (strlen(query) >= CDB_MIN_SEARCH_INTS)))
    then
        db = CdbLastSearchResults[searchType];
    end
    for id, _ in pairsByKeys(db) do
        if (resultCount >= min) and (resultCount < max) then
            CdbCreateResultButtons(searchType, searchCount, CdbSearchGui[searchType].scrollBar.database[id], id, CdbSearchGui[searchType].scrollBar.NAME_KEY);
            searchCount = searchCount + 1;
        end
        resultCount = resultCount + 1;
    end
end

-- Do a search or display favourites
function CdbSearchGui:Search(query, searchType)
    -- Search type specific preparations
    local actualDatabase;
    local NAME_KEY;
    if searchType == "spawn" then
        actualDatabase = npcData;
        NAME_KEY = DB_NAME;
    elseif searchType == "object" then
        actualDatabase = objData;
        NAME_KEY = DB_NAME;
    elseif searchType == "item" then
        actualDatabase = itemData;
        NAME_KEY = DB_ITM_NAME;
    elseif searchType == "quest" then
        actualDatabase = qData;
        NAME_KEY = DB_NAME;
    end
    -- By default the favourites are displayed
    local database = CdbFavourites[searchType];
    local queryLength = strlen(query)
    -- We have a query meeting the minimal search length criteria, change to actualDatabase
    if  (queryLength >= CDB_MIN_SEARCH_CHARS)
        or
        ((tonumber(query) ~= nil) and (queryLength >= CDB_MIN_SEARCH_INTS))
    then
        database = actualDatabase;
        -- We had a previous whole database search, we can use the smaller CdbLastSearchResults to search now
        if  ((tonumber(query) ~= nil) and (queryLength > CDB_MIN_SEARCH_INTS))
            or
            ((queryLength > CDB_MIN_SEARCH_CHARS) and (queryLength > strlen(CdbLastSearchQuery)))
        then
            database = CdbLastSearchResults[searchType];
        end
    end
    -- iterate the seleceted database
    local searchCount = 0;
    for id, entryOrBoolean in pairs(database) do
        local dbEntry;
         -- No search (displaying favourites), or search within previous set of results
        if type(entryOrBoolean) == "boolean" then
            dbEntry = actualDatabase[id];
        -- Search in whole database
        else
            dbEntry = entryOrBoolean;
        end
        -- This condition does the actual comparison for the search
        if  (dbEntry ~= nil)
            and
            (
                ( -- text search
                    (tonumber(query) == nil)
                    and
                    (
                        (strlen(query) < CDB_MIN_SEARCH_CHARS) -- Too short, display favourites
                        or
                        (strfind(strlower(dbEntry[NAME_KEY]), strlower(query))) -- Perform search
                    )
                )
                or
                ( -- id search
                    (tonumber(query) ~= nil)
                    and
                    (
                        (strlen(query) < CDB_MIN_SEARCH_INTS) -- Too short, display favourites
                        or
                        (strfind(tostring(id), query)) -- Perform search
                    )
                )
            )
        then -- We have a search result or a favourite to display
            searchCount = searchCount + 1;
            CdbLastSearchResults[searchType][id] = true;
        else -- This entry doesn't meet the search criteria, removed from the last results
            CdbLastSearchResults[searchType][id] = nil;
        end
    end
    -- Reset scroll bar
    CdbSearchGui[searchType].scrollBar:SetValue(1);
    CdbSearchGui[searchType].scrollBar:Hide();
    -- Update tab button text
    if searchCount == 0 then
        if searchType == "spawn" then
            CdbSearchGui.buttonSpawn.text:SetText("Mobs")
        elseif searchType == "object" then
            CdbSearchGui.buttonObject.text:SetText("Objects")
        elseif searchType == "item" then
            CdbSearchGui.buttonItem.text:SetText("Items")
        elseif searchType == "quest" then
            CdbSearchGui.buttonQuest.text:SetText("Quests")
        end
    else
        if searchType == "spawn" then
            CdbSearchGui.buttonSpawn.text:SetText("Mobs |cffaaaaaa(" .. searchCount .. ")")
        elseif searchType == "object" then
            CdbSearchGui.buttonObject.text:SetText("Objects |cffaaaaaa(" .. searchCount .. ")")
        elseif searchType == "item" then
            CdbSearchGui.buttonItem.text:SetText("Items |cffaaaaaa(" .. searchCount .. ")")
        elseif searchType == "quest" then
            CdbSearchGui.buttonQuest.text:SetText("Quests |cffaaaaaa(" .. searchCount .. ")")
        end
        -- Set max scroll value
        local max = math.ceil(searchCount/CDB_MAX_SEARCH_PAGE_LINES);
        CdbSearchGui[searchType].scrollBar:SetMinMaxValues(1, max);
        -- Show scroll bar if needed
        if max > 1 then
            CdbSearchGui[searchType].scrollBar:Show();
        end
    end
    -- Update the displayed buttons
    CdbUpdateResultButtons(searchType, query);
end

------------------------------
-- Create the control GUI frame
------------------------------
CdbControlGui = CreateFrame("Frame",nil,UIParent)
CdbControlGui:SetFrameStrata('FULLSCREEN_DIALOG')
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
CdbControlGui.AddButton = function(name, position, textureFile, OnEnterFunctionTitle, OnEnterFunctionString, OnClickFunction)
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
    CdbControlGui.buttons[position]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    CdbControlGui.buttons[position]:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
        GameTooltip:ClearLines();
        GameTooltip:AddLine(OnEnterFunctionTitle);
        if OnEnterFunctionString ~= nil then
            GameTooltip:AddLine(OnEnterFunctionString, nil, nil, nil, true);
        end
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
    OnEnterFunctionTitle = "Clean Map",
    OnEnterFunctionString = "\n|cffffffffClear all ClassicDB notes from the map. This disables the settings |r"..CdbSettingsText["auto_plot"].."|cffffffff and |r"..CdbSettingsText["questStarts"].."|cffffffff. They can be reenabled at the bottom of the control GUI.|r",
    OnClickFunction = function(self)
        CdbCleanMapAndPreventRedraw();
    end,
}
CdbControlGui.buttonValues.ShowAllQuests = {
    position = 2,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\MapMarkAll",
    OnEnterFunctionTitle = "Show all current quests",
    OnEnterFunctionString = "\n|cffffffffPlot notes on the map for all quest currently in the quest log. This draws notes only once, for automatic updates enable the corresponding option at the bottom of the control GUI.|r",
    OnClickFunction = function(self)
        CdbGetAllQuestNotes();
        WorldMapFrame:Show();
    end,
}
CdbControlGui.buttonValues.CycleMap = {
    position = 3,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\MapCycle",
    OnEnterFunctionTitle = "Cycle zones",
    OnEnterFunctionString = "\nLeftClick|cffffffff to cycle through the currently marked zones.|r RightClick|cffffffff to cycle backwards.",
    OnClickFunction = function(self)
        if arg1 == "LeftButton" then
            CdbCycleMarkedZones();
        elseif arg1 == "RightButton" then
            CdbCycleMarkedZones(true)
        end
    end,
}
CdbControlGui.buttonValues.ShowSelectedQuest = {
    position = 1,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\MapMarkOne",
    OnEnterFunctionTitle = "Show currently selected quest",
    OnEnterFunctionString = "\n|cffffffffPlot notes on the map for the quest currently selected in the quest log.|r",
    OnClickFunction = function(self)
        CdbGetSelectionQuestNotes();
        WorldMapFrame:Show();
    end,
}
CdbControlGui.buttonValues.ResizeMap = {
    position = 4,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\Arrows",
    OnEnterFunctionTitle = "Reset map and icons to default size",
    OnEnterFunctionString = nil,
    OnClickFunction = function(self)
         CdbResetMapAndIconSize()
    end,
}
CdbControlGui.buttonValues.ShowSearch = {
    position = 5,
    textureFile = "Interface\\Addons\\ClassicDB\\symbols\\Glass",
    OnEnterFunctionTitle = "Toggle settings and search window",
    OnEnterFunctionString = "\n|cffffffffShow a window where you can adjust the ClassicDB settings or search for creatures, objects, items, and quests.|r",
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
    CdbControlGui.AddButton(name, data.position, data.textureFile, data.OnEnterFunctionTitle, data.OnEnterFunctionString, data.OnClickFunction)
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
        GameTooltip:AddLine(CdbGetSetting(this.settingName));
        GameTooltip:AddLine(OnEnterFunctionString, nil, nil, nil, true);
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
    OnEnterFunctionString = "\n|cffffffffWhen enabled, this option shows notes for all quests in the log. It will update automatically every time there is a quest event, like looting. If you experience lags when finishing a quest objective, disable and use the |rShow all current quests|cffffffff button as long as the quest drawing too many notes is in in your quest log.|r",
}
CdbControlGui.checkButtonValues.questStarts = {
    position = 1,
    OnEnterFunctionString = "\n|cffffffffWhen enabled, the map will show quests starts. There are further options controlling which quest starts are shown in the search GUI.|r",
}
CdbControlGui.checkButtonValues.waypoints = {
    position = 2,
    OnEnterFunctionString = "\n|cffffffffWhen enabled, mob waypoints are shown on the map. Due to script spawns not yet being included in the DB this can also be helpful in finding some special mobs.|r",
}

------------------
-- Add the buttons
------------------
CdbControlGui.checkButtons = {}
for name, data in pairs(CdbControlGui.checkButtonValues) do
    CdbControlGui.AddCheckButton(name, data.position, data.OnEnterFunctionString)
end
