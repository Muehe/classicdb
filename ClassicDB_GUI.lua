local backdrop = {
    bgFile = "Interface\\AddOns\\ShaguDB\\img\\background",
    tile = true,
    tileSize = 8,
    edgeFile = "Interface\\AddOns\\ShaguDB\\img\\border",
    edgeSize = 8,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local backdrop_noborder = {
    bgFile = "Interface\\AddOns\\ShaguDB\\img\\background",
    tile = true,
    tileSize = 8,
    insets = {left = 0, right = 0, top = 0, bottom = 0},
}

if not CdbFavourites then CdbFavourites = {} end
if not CdbFavourites["spawn"] then CdbFavourites["spawn"] = {} end
if not CdbFavourites["object"] then CdbFavourites["object"] = {} end
if not CdbFavourites["item"] then CdbFavourites["item"] = {} end
if not CdbFavourites["quest"] then CdbFavourites["quest"] = {} end

SDBG = CreateFrame("Frame",nil,UIParent)
SDBG:RegisterEvent("PLAYER_ENTERING_WORLD");
SDBG:SetScript("OnEvent", function(self, event, ...)
    SDBG.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(CdbMinimapPosition)),(80*sin(CdbMinimapPosition))-52)
end)

SDBG:Hide()
SDBG:SetFrameStrata("DIALOG")
SDBG:SetWidth(500)
SDBG:SetHeight(445)

SDBG:SetBackdrop(backdrop)
SDBG:SetBackdropColor(0,0,0,.85);
SDBG:SetPoint("CENTER",0,0)
SDBG:SetMovable(true)
SDBG:EnableMouse(true)
SDBG:SetScript("OnMouseDown",function()
    SDBG:StartMoving()
end)
SDBG:SetScript("OnMouseUp",function()
    SDBG:StopMovingOrSizing()
end)

SDBG.minimapButton = CreateFrame('Button', "ShaguDB_Minimap", Minimap)
if (CdbMinimapPosition == nil) then
    CdbMinimapPosition = 125
end

SDBG.minimapButton:SetMovable(true)
SDBG.minimapButton:EnableMouse(true)
SDBG.minimapButton:RegisterForDrag('LeftButton')
SDBG.minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
SDBG.minimapButton:SetScript("OnDragStop", function()
    local xpos,ypos = GetCursorPosition()
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

    xpos = xmin-xpos/UIParent:GetScale()+70
    ypos = ypos/UIParent:GetScale()-ymin-70

    CdbMinimapPosition = math.deg(math.atan2(ypos,xpos))
    SDBG.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(CdbMinimapPosition)),(80*sin(CdbMinimapPosition))-52)
end)

SDBG.minimapButton:SetFrameStrata('HIGH')
SDBG.minimapButton:SetWidth(31)
SDBG.minimapButton:SetHeight(31)
SDBG.minimapButton:SetFrameLevel(9)
SDBG.minimapButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
SDBG.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(CdbMinimapPosition)),(80*sin(CdbMinimapPosition))-52)
SDBG.minimapButton:SetScript("OnClick", function()
    if ( arg1 == "LeftButton" ) then
        if IsShiftKeyDown() then
            Cartographer_Notes:SetIconSize(1);
            WorldMapFrame:SetScale(1);
            WorldMapFrame:StartMoving();
            WorldMapFrame:SetPoint("CENTER", 0, 0);
            WorldMapFrame:StopMovingOrSizing();
            WorldMapFrame:ClearAllPoints();
            WorldMapFrame:SetAllPoints(UIParent);
        else
            if (SDBG:IsShown()) then
                SDBG:Hide();
            else
                SDBG:Show();
            end
        end
    end
    if (arg1 == "RightButton") then
        if IsShiftKeyDown() then
            ShaguDB_ResetGui();
        else
            if (ShaguDB_Frame:IsShown()) then
                ShaguDB_Frame:Hide()
            else
                ShaguDB_Frame:Show()
            end
        end
    end
end)
SDBG.minimapButton:SetScript("OnEnter", function()
    ShaguDB_Tooltip:SetOwner(SDBG.minimapButton, "ANCHOR_BOTTOMLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText("<LeftClick>: Toggle search window\n<RightClick>: Toggle control window\n<Shift>+<RightClick>: Reset Map and Icon Size\n<Shift>+<RightClick>: Reset and show both windows");
    ShaguDB_Tooltip:Show();
end)
SDBG.minimapButton:SetScript("OnLeave", function()
    ShaguDB_Tooltip:Hide();
end)

SDBG.minimapButton.overlay = SDBG.minimapButton:CreateTexture(nil, 'OVERLAY')
SDBG.minimapButton.overlay:SetWidth(53)
SDBG.minimapButton.overlay:SetHeight(53)
SDBG.minimapButton.overlay:SetTexture('Interface\\Minimap\\MiniMap-TrackingBorder')
SDBG.minimapButton.overlay:SetPoint('TOPLEFT', 0,0)
SDBG.minimapButton.icon = SDBG.minimapButton:CreateTexture(nil, 'BACKGROUND')
SDBG.minimapButton.icon:SetWidth(20)
SDBG.minimapButton.icon:SetHeight(20)
SDBG.minimapButton.icon:SetTexture('Interface\\AddOns\\ShaguDB\\symbols\\sq')
SDBG.minimapButton.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
SDBG.minimapButton.icon:SetPoint('CENTER',1,1)

SDBG.closeButton = CreateFrame("Button", nil, SDBG, "UIPanelCloseButton")
SDBG.closeButton:SetWidth(30)
SDBG.closeButton:SetHeight(30) -- width, height
SDBG.closeButton:SetPoint("TOPRIGHT", -5,-5)
SDBG.closeButton:SetScript("OnClick", function()
    SDBG:Hide()
end)

SDBG.titlebar = CreateFrame("Frame", nil, SDBG)
SDBG.titlebar:ClearAllPoints()
SDBG.titlebar:SetWidth(494)
SDBG.titlebar:SetHeight(35)
SDBG.titlebar:SetPoint("TOP", 0, -3)
SDBG.titlebar:SetBackdrop(backdrop_noborder)
SDBG.titlebar:SetBackdropColor(1,1,1,.10)

SDBG.text = SDBG:CreateFontString("Status", "LOW", "GameFontNormal")
SDBG.text:ClearAllPoints()
SDBG.text:SetPoint("TOPLEFT", 12, -12)
SDBG.text:SetFontObject(GameFontWhite)
SDBG.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
SDBG.text:SetText("|cff33ffccShagu|cffffffffDB |cffaaaaaaoooVersionooo")

SDBG.input = CreateFrame("Frame", nil, SDBG)
--SDBG.input:ClearAllPoints()
SDBG.input:SetWidth(494)
SDBG.input:SetHeight(40)
SDBG.input:SetPoint("BOTTOM", 0, 3)
SDBG.input:SetBackdrop(backdrop_noborder)
--SDBG.input:SetBackdropColor(.2,1,.8,1)
SDBG.input:SetBackdropColor(1,1,1,.10)

SDBG.inputField = CreateFrame("EditBox", "InputBoxTemplate", SDBG.input, "InputBoxTemplate")
InputBoxTemplateLeft:SetTexture(1,1,1,.15);
InputBoxTemplateMiddle:SetTexture(1,1,1,.15);
InputBoxTemplateRight:SetTexture(1,1,1,.15);
SDBG.inputField:SetParent(SDBG.input)
SDBG.inputField:SetTextColor(.2,1.1,1)

SDBG.inputField:SetWidth(375)
SDBG.inputField:SetHeight(20)
SDBG.inputField:SetPoint("TOPLEFT", 15, -10)
SDBG.inputField:SetFontObject(GameFontNormal)
SDBG.inputField:SetAutoFocus(false)
SDBG.inputField:SetText("Search")
SDBG.inputField.updateSearch = function()
    SDBG:HideButtons()
    local query = SDBG.inputField:GetText()
    if query ~= "Search" then
        SDBG:SearchSpawn(query)
        SDBG:SearchObject(query)
        SDBG:SearchItem(query)
        SDBG:SearchQuest(query)
    else
        SDBG:SearchSpawn("")
        SDBG:SearchObject("")
        SDBG:SearchItem("")
        SDBG:SearchQuest("")
    end
end

SDBG.inputField:SetScript("OnTextChanged", function(self)
    SDBG.inputField:updateSearch()
end)

SDBG.inputField:SetScript("OnEditFocusGained", function(self)
    if this:GetText() == "Search" then this:SetText("") end
end)
SDBG.inputField:SetScript("OnEditFocusLost", function(self)
    if this:GetText() == "" then this:SetText("Search") end
end)

SDBG.cleanButton = CreateFrame("Button", nil, SDBG.input)
SDBG.cleanButton:SetParent(SDBG.input)
SDBG.cleanButton:SetWidth(65)
SDBG.cleanButton:SetHeight(24) -- width, height
SDBG.cleanButton:SetPoint("TOPRIGHT", -10,-8)
SDBG.cleanButton.text = SDBG.cleanButton:CreateFontString("Status", "LOW", "GameFontNormal")
SDBG.cleanButton.text:ClearAllPoints()
SDBG.cleanButton.text:SetAllPoints(SDBG.cleanButton)
SDBG.cleanButton.text:SetPoint("LEFT", 0, 0)
SDBG.cleanButton.text:SetFontObject(GameFontWhite)
SDBG.cleanButton.text:SetText("Clean")
SDBG.cleanButton:SetBackdrop(backdrop)
SDBG.cleanButton:SetBackdropColor(0,0,0,.15)
SDBG.cleanButton:SetBackdropBorderColor(1,1,1,.25)

SDBG.cleanButton:SetScript("OnClick", function()
    ShaguDB_DoCleanMap();
end)

SDBG.buttonSpawn = CreateFrame("Button", nil, SDBG)
--SDBG.buttonSpawn:ClearAllPoints()
SDBG.buttonSpawn:SetWidth(100)
SDBG.buttonSpawn:SetHeight(25)
SDBG.buttonSpawn:SetPoint("TOPLEFT", 13, -50)
SDBG.buttonSpawn:SetBackdrop(backdrop_noborder)
SDBG.buttonSpawn.text = SDBG.buttonSpawn:CreateFontString("Status", "LOW", "GameFontNormal")
SDBG.buttonSpawn.text:ClearAllPoints()
SDBG.buttonSpawn.text:SetAllPoints(SDBG.buttonSpawn)
SDBG.buttonSpawn.text:SetPoint("LEFT", 0, 0)
SDBG.buttonSpawn.text:SetFontObject(GameFontWhite)
SDBG.buttonSpawn.text:SetText("Mobs")
SDBG.buttonSpawn:SetBackdropColor(1,1,1,.05)
SDBG.buttonSpawn:SetScript("OnClick", function()
    SDBG.buttonSpawn:SetBackdropColor(1,1,1,.15)
    SDBG.buttonObject:SetBackdropColor(1,1,1,.05)
    SDBG.buttonItem:SetBackdropColor(1,1,1,.05)
    SDBG.buttonQuest:SetBackdropColor(1,1,1,.05)
    SDBG.buttonSettings:SetBackdropColor(1,1,1,.05)

    SDBG.spawn:Show()
    SDBG.object:Hide()
    SDBG.item:Hide()
    SDBG.quest:Hide()
    SDBG.settings:Hide()
end)

SDBG.buttonObject = CreateFrame("Button", nil, SDBG)
--SDBG.buttonObject:ClearAllPoints()
SDBG.buttonObject:SetWidth(100)
SDBG.buttonObject:SetHeight(25)
SDBG.buttonObject:SetPoint("TOPLEFT", 113, -50)
SDBG.buttonObject:SetBackdrop(backdrop_noborder)
SDBG.buttonObject.text = SDBG.buttonObject:CreateFontString("Status", "LOW", "GameFontNormal")
SDBG.buttonObject.text:ClearAllPoints()
SDBG.buttonObject.text:SetAllPoints(SDBG.buttonObject)
SDBG.buttonObject.text:SetPoint("LEFT", 0, 0)
SDBG.buttonObject.text:SetFontObject(GameFontWhite)
SDBG.buttonObject.text:SetText("Objects")
SDBG.buttonObject:SetBackdropColor(1,1,1,.05)
SDBG.buttonObject:SetScript("OnClick", function()
    SDBG.buttonObject:SetBackdropColor(1,1,1,.15)
    SDBG.buttonSpawn:SetBackdropColor(1,1,1,.05)
    SDBG.buttonItem:SetBackdropColor(1,1,1,.05)
    SDBG.buttonQuest:SetBackdropColor(1,1,1,.05)
    SDBG.buttonSettings:SetBackdropColor(1,1,1,.05)

    SDBG.object:Show()
    SDBG.spawn:Hide()
    SDBG.item:Hide()
    SDBG.quest:Hide()
    SDBG.settings:Hide()
end)

SDBG.buttonItem = CreateFrame("Button", nil, SDBG)
--SDBG.buttonItem:ClearAllPoints()
SDBG.buttonItem:SetWidth(100)
SDBG.buttonItem:SetHeight(25)
SDBG.buttonItem:SetPoint("TOPLEFT", 213, -50)
SDBG.buttonItem:SetBackdrop(backdrop_noborder)
SDBG.buttonItem.text = SDBG.buttonItem:CreateFontString("Status", "LOW", "GameFontNormal")
SDBG.buttonItem.text:ClearAllPoints()
SDBG.buttonItem.text:SetAllPoints(SDBG.buttonItem)
SDBG.buttonItem.text:SetPoint("LEFT", 0, 0)
SDBG.buttonItem.text:SetFontObject(GameFontWhite)
SDBG.buttonItem.text:SetText("Items")
SDBG.buttonItem:SetBackdropColor(1,1,1,.15)
SDBG.buttonItem:SetScript("OnClick", function()
    SDBG.buttonItem:SetBackdropColor(1,1,1,.15)
    SDBG.buttonSpawn:SetBackdropColor(1,1,1,.05)
    SDBG.buttonObject:SetBackdropColor(1,1,1,.05)
    SDBG.buttonQuest:SetBackdropColor(1,1,1,.05)
    SDBG.buttonSettings:SetBackdropColor(1,1,1,.05)

    SDBG.item:Show()
    SDBG.object:Hide()
    SDBG.spawn:Hide()
    SDBG.quest:Hide()
    SDBG.settings:Hide()
end)

SDBG.buttonQuest = CreateFrame("Button", nil, SDBG)
--SDBG.buttonQuest:ClearAllPoints()
SDBG.buttonQuest:SetWidth(100)
SDBG.buttonQuest:SetHeight(25)
SDBG.buttonQuest:SetPoint("TOPLEFT", 313, -50)
SDBG.buttonQuest:SetBackdrop(backdrop_noborder)
SDBG.buttonQuest.text = SDBG.buttonQuest:CreateFontString("Status", "LOW", "GameFontNormal")
SDBG.buttonQuest.text:ClearAllPoints()
SDBG.buttonQuest.text:SetAllPoints(SDBG.buttonQuest)
SDBG.buttonQuest.text:SetPoint("LEFT", 0, 0)
SDBG.buttonQuest.text:SetFontObject(GameFontWhite)
SDBG.buttonQuest.text:SetText("Quests")
SDBG.buttonQuest:SetBackdropColor(1,1,1,.05)
SDBG.buttonQuest:SetScript("OnClick", function()
    SDBG.buttonQuest:SetBackdropColor(1,1,1,.15)
    SDBG.buttonSpawn:SetBackdropColor(1,1,1,.05)
    SDBG.buttonObject:SetBackdropColor(1,1,1,.05)
    SDBG.buttonItem:SetBackdropColor(1,1,1,.05)
    SDBG.buttonSettings:SetBackdropColor(1,1,1,.05)

    SDBG.quest:Show()
    SDBG.object:Hide()
    SDBG.item:Hide()
    SDBG.spawn:Hide()
    SDBG.settings:Hide()
end)

SDBG.buttonSettings = CreateFrame("Button", nil, SDBG)
--SDBG.buttonSettings:ClearAllPoints()
SDBG.buttonSettings:SetWidth(75)
SDBG.buttonSettings:SetHeight(25)
SDBG.buttonSettings:SetPoint("TOPLEFT", 413, -50)
SDBG.buttonSettings:SetBackdrop(backdrop_noborder)
SDBG.buttonSettings.text = SDBG.buttonSettings:CreateFontString("Status", "LOW", "GameFontNormal")
SDBG.buttonSettings.text:ClearAllPoints()
SDBG.buttonSettings.text:SetAllPoints(SDBG.buttonSettings)
SDBG.buttonSettings.text:SetPoint("LEFT", 0, 0)
SDBG.buttonSettings.text:SetFontObject(GameFontWhite)
SDBG.buttonSettings.text:SetText("Settings")

SDBG.buttonSettings:SetBackdropColor(1,1,1,.05)
SDBG.buttonSettings:SetScript("OnClick", function()
    SDBG.buttonSettings:SetBackdropColor(1,1,1,.15)
    SDBG.buttonSpawn:SetBackdropColor(1,1,1,.05)
    SDBG.buttonObject:SetBackdropColor(1,1,1,.05)
    SDBG.buttonItem:SetBackdropColor(1,1,1,.05)
    SDBG.buttonQuest:SetBackdropColor(1,1,1,.05)

    SDBG.settings:Show()
    SDBG.object:Hide()
    SDBG.item:Hide()
    SDBG.spawn:Hide()
    SDBG.quest:Hide()

    for i=1,14 do
        SDBG.settings.buttons[1]:SetText("DB Mode")
        SDBG.settings.buttons[2]:SetText("Show Quest Starts")
        SDBG.settings.buttons[3]:SetText("Filter Quest Starts based on finished quests")
        SDBG.settings.buttons[4]:SetText("Filter Quest Starts by required level")
        SDBG.settings.buttons[5]:SetText("Show Quest IDs")
        SDBG.settings.buttons[6]:SetText("Show required level")
        SDBG.settings.buttons[7]:SetText("Items dropped by items")
        SDBG.settings.buttons[8]:SetText("Waypoints")
        SDBG.settings.buttons[9]:SetText("Auto Plot")
        if (SDBG.settings.buttons[i]) then
            SDBG.settings.buttons[i]:Show();
        end
    end
end)

--[[
SDBG.buttonSettings:SetScript("OnEnter", function(self)
  this:SetBackdropColor(1,1,1,.25)
end)

SDBG.buttonSettings:SetScript("OnLeave", function(self)
  if this.even == true then
    this:SetBackdropColor(1,1,1,.05)
  else
    this:SetBackdropColor(1,1,1,.10)
  end
end)--]]

SDBG.spawn = CreateFrame("Frame",nil,SDBG)
SDBG.spawn:SetPoint("TOP", 0, -75)
SDBG.spawn:SetWidth(475)
SDBG.spawn:SetHeight(315)
SDBG.spawn:SetBackdrop(backdrop_noborder)
SDBG.spawn:SetBackdropColor(1,1,1,.15)
--SDBG.spawn:SetFrameStrata("DIALOG")
SDBG.spawn:Hide()
SDBG.spawn.buttons = {}

SDBG.object = CreateFrame("Frame",nil,SDBG)
SDBG.object:SetPoint("TOP", 0, -75)
SDBG.object:SetWidth(475)
SDBG.object:SetHeight(315)
SDBG.object:SetBackdrop(backdrop_noborder)
SDBG.object:SetBackdropColor(1,1,1,.15)
--SDBG.object:SetFrameStrata("DIALOG")
SDBG.object:Hide()
SDBG.object.buttons = {}

SDBG.item = CreateFrame("Frame",nil,SDBG)
SDBG.item:SetPoint("TOP", 0, -75)
SDBG.item:SetWidth(475)
SDBG.item:SetHeight(315)
SDBG.item:SetBackdrop(backdrop_noborder)
SDBG.item:SetBackdropColor(1,1,1,.15)
--SDBG.item:SetFrameStrata("DIALOG")
SDBG.item.buttons = {}

SDBG.quest = CreateFrame("Frame",nil,SDBG)
SDBG.quest:SetPoint("TOP", 0, -75)
SDBG.quest:SetWidth(475)
SDBG.quest:SetHeight(315)
SDBG.quest:SetBackdrop(backdrop_noborder)
SDBG.quest:SetBackdropColor(1,1,1,.15)
--SDBG.quest:SetFrameStrata("DIALOG")
SDBG.quest:Hide()
SDBG.quest.buttons = {}

SDBG.settings = CreateFrame("Frame",nil,SDBG)
SDBG.settings:SetPoint("TOP", 0, -75)
SDBG.settings:SetWidth(475)
SDBG.settings:SetHeight(315)
SDBG.settings:SetBackdrop(backdrop_noborder)
SDBG.settings:SetBackdropColor(1,1,1,.15)
--SDBG.settings:SetFrameStrata("DIALOG")
SDBG.settings:Hide()
SDBG.settings.buttons = {}

SDBG.settings.buttons[1] = CreateFrame("Button","mybutton",SDBG.settings,"UIPanelButtonTemplate")
SDBG.settings.buttons[1]:SetPoint("TOP", 0, -1*21+11)
SDBG.settings.buttons[1]:SetWidth(450)
SDBG.settings.buttons[1]:SetHeight(20)
SDBG.settings.buttons[1]:SetFont("Fonts\\FRIZQT__.TTF", 10)
SDBG.settings.buttons[1]:SetTextColor(1,1,1,1)
SDBG.settings.buttons[1]:SetNormalTexture(nil)
SDBG.settings.buttons[1]:SetPushedTexture(nil)
SDBG.settings.buttons[1]:SetHighlightTexture(nil)
SDBG.settings.buttons[1]:SetBackdrop(backdrop_noborder)
SDBG.settings.buttons[1]:SetBackdropColor(1,1,1,.10)
SDBG.settings.buttons[1]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText(ShaguDB_GetSetting("dbMode")..
                            "\n\n|cffffffff"..
                            "When enabled, this option prevents ShaguDB from cleaning quests\n"..
                            "for other classes and the opposite faction from the quest DB.\n"..
                            "Not recommended for normal users, as it adds many unatainable\n"..
                            "quest starts to the map.|r");
    ShaguDB_Tooltip:Show();
end)
SDBG.settings.buttons[1]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.10)
    ShaguDB_Tooltip:Hide()
end)
SDBG.settings.buttons[1].enabled = CreateFrame("CheckButton","mycheckbutton",SDBG.settings.buttons[1],"UICheckButtonTemplate")
SDBG.settings.buttons[1].enabled:SetPoint("RIGHT", -25, 0)
SDBG.settings.buttons[1].enabled:SetWidth(20)
SDBG.settings.buttons[1].enabled:SetHeight(20)
SDBG.settings.buttons[1].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.dbMode ~= true) then
        SDBG.settings.buttons[1].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[1].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[1].enabled:SetScript("OnClick", function(self)
    ShaguDB_SwitchSetting("dbMode");
    if (CdbSettings.dbMode ~= true) then
        SDBG.settings.buttons[1].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[1].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[2] = CreateFrame("Button","mybutton",SDBG.settings,"UIPanelButtonTemplate")
SDBG.settings.buttons[2]:SetPoint("TOP", 0, -2*21+11)
SDBG.settings.buttons[2]:SetWidth(450)
SDBG.settings.buttons[2]:SetHeight(20)
SDBG.settings.buttons[2]:SetFont("Fonts\\FRIZQT__.TTF", 10)
SDBG.settings.buttons[2]:SetTextColor(1,1,1,1)
SDBG.settings.buttons[2]:SetNormalTexture(nil)
SDBG.settings.buttons[2]:SetPushedTexture(nil)
SDBG.settings.buttons[2]:SetHighlightTexture(nil)
SDBG.settings.buttons[2]:SetBackdrop(backdrop_noborder)
SDBG.settings.buttons[2]:SetBackdropColor(1,1,1,.05)
SDBG.settings.buttons[2]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText(ShaguDB_GetSetting("questStarts")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows notes for all quests starts\n"..
                            "in the currently displayed zone. If it doesn't load immediately\n"..
                            "reopen the map.|r");
    ShaguDB_Tooltip:Show();
end)
SDBG.settings.buttons[2]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    ShaguDB_Tooltip:Hide()
end)
SDBG.settings.buttons[2].enabled = CreateFrame("CheckButton","mycheckbutton",SDBG.settings.buttons[2],"UICheckButtonTemplate")
SDBG.settings.buttons[2].enabled:SetPoint("RIGHT", -25, 0)
SDBG.settings.buttons[2].enabled:SetWidth(20)
SDBG.settings.buttons[2].enabled:SetHeight(20)
SDBG.settings.buttons[2].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.questStarts ~= true) then
        SDBG.settings.buttons[2].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[2].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[2].enabled:SetScript("OnClick", function(self)
    ShaguDB_SwitchSetting("questStarts");
    if (CdbSettings.questStarts ~= true) then
        SDBG.settings.buttons[2].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[2].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[3] = CreateFrame("Button","mybutton",SDBG.settings,"UIPanelButtonTemplate")
SDBG.settings.buttons[3]:SetPoint("TOP", 0, -3*21+11)
SDBG.settings.buttons[3]:SetWidth(450)
SDBG.settings.buttons[3]:SetHeight(20)
SDBG.settings.buttons[3]:SetFont("Fonts\\FRIZQT__.TTF", 10)
SDBG.settings.buttons[3]:SetTextColor(1,1,1,1)
SDBG.settings.buttons[3]:SetNormalTexture(nil)
SDBG.settings.buttons[3]:SetPushedTexture(nil)
SDBG.settings.buttons[3]:SetHighlightTexture(nil)
SDBG.settings.buttons[3]:SetBackdrop(backdrop_noborder)
SDBG.settings.buttons[3]:SetBackdropColor(1,1,1,.05)
SDBG.settings.buttons[3]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText(ShaguDB_GetSetting("questStarts")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows notes for all quests starts\n"..
                            "in the currently displayed zone. If it doesn't load immediately\n"..
                            "reopen the map.|r");
    ShaguDB_Tooltip:Show();
end)
SDBG.settings.buttons[3]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    ShaguDB_Tooltip:Hide()
end)
SDBG.settings.buttons[3].enabled = CreateFrame("CheckButton","mycheckbutton",SDBG.settings.buttons[3],"UICheckButtonTemplate")
SDBG.settings.buttons[3].enabled:SetPoint("RIGHT", -25, 0)
SDBG.settings.buttons[3].enabled:SetWidth(20)
SDBG.settings.buttons[3].enabled:SetHeight(20)
SDBG.settings.buttons[3].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.questStarts ~= true) then
        SDBG.settings.buttons[3].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[3].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[3].enabled:SetScript("OnClick", function(self)
    ShaguDB_SwitchSetting("questStarts");
    if (CdbSettings.questStarts ~= true) then
        SDBG.settings.buttons[3].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[3].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[4] = CreateFrame("Button","mybutton",SDBG.settings,"UIPanelButtonTemplate")
SDBG.settings.buttons[4]:SetPoint("TOP", 0, -4*21+11)
SDBG.settings.buttons[4]:SetWidth(450)
SDBG.settings.buttons[4]:SetHeight(20)
SDBG.settings.buttons[4]:SetFont("Fonts\\FRIZQT__.TTF", 10)
SDBG.settings.buttons[4]:SetTextColor(1,1,1,1)
SDBG.settings.buttons[4]:SetNormalTexture(nil)
SDBG.settings.buttons[4]:SetPushedTexture(nil)
SDBG.settings.buttons[4]:SetHighlightTexture(nil)
SDBG.settings.buttons[4]:SetBackdrop(backdrop_noborder)
SDBG.settings.buttons[4]:SetBackdropColor(1,1,1,.10)
SDBG.settings.buttons[4]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText(ShaguDB_GetSetting("filterReqLevel")..
                            "\n\n|cffffffff"..
                            "When enabled, this option prevents quest starts from being marked\n"..
                            "if the player doesn't meet the minimum level requirements.|r");
    ShaguDB_Tooltip:Show();
end)
SDBG.settings.buttons[4]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.10)
    ShaguDB_Tooltip:Hide()
end)
SDBG.settings.buttons[4].enabled = CreateFrame("CheckButton","mycheckbutton",SDBG.settings.buttons[4],"UICheckButtonTemplate")
SDBG.settings.buttons[4].enabled:SetPoint("RIGHT", -25, 0)
SDBG.settings.buttons[4].enabled:SetWidth(20)
SDBG.settings.buttons[4].enabled:SetHeight(20)
SDBG.settings.buttons[4].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.filterReqLevel ~= true) then
        SDBG.settings.buttons[4].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[4].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[4].enabled:SetScript("OnClick", function(self)
    ShaguDB_SwitchSetting("filterReqLevel");
    if (CdbSettings.filterReqLevel ~= true) then
        SDBG.settings.buttons[4].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[4].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[5] = CreateFrame("Button","mybutton",SDBG.settings,"UIPanelButtonTemplate")
SDBG.settings.buttons[5]:SetPoint("TOP", 0, -5*21+11)
SDBG.settings.buttons[5]:SetWidth(450)
SDBG.settings.buttons[5]:SetHeight(20)
SDBG.settings.buttons[5]:SetFont("Fonts\\FRIZQT__.TTF", 10)
SDBG.settings.buttons[5]:SetTextColor(1,1,1,1)
SDBG.settings.buttons[5]:SetNormalTexture(nil)
SDBG.settings.buttons[5]:SetPushedTexture(nil)
SDBG.settings.buttons[5]:SetHighlightTexture(nil)
SDBG.settings.buttons[5]:SetBackdrop(backdrop_noborder)
SDBG.settings.buttons[5]:SetBackdropColor(1,1,1,.05)
SDBG.settings.buttons[5]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText(ShaguDB_GetSetting("questIds")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows the quest ID in the quest start tooltips.|r");
                            -- TODO: Update text once this setting has been fixed. Quest IDs in quest start tooltips are needed for their context menu.
    ShaguDB_Tooltip:Show();
end)
SDBG.settings.buttons[5]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    ShaguDB_Tooltip:Hide()
end)
SDBG.settings.buttons[5].enabled = CreateFrame("CheckButton","mycheckbutton",SDBG.settings.buttons[5],"UICheckButtonTemplate")
SDBG.settings.buttons[5].enabled:SetPoint("RIGHT", -25, 0)
SDBG.settings.buttons[5].enabled:SetWidth(20)
SDBG.settings.buttons[5].enabled:SetHeight(20)
SDBG.settings.buttons[5].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.questIds ~= true) then
        SDBG.settings.buttons[5].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[5].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[5].enabled:SetScript("OnClick", function(self)
    ShaguDB_SwitchSetting("questIds");
    if (CdbSettings.questIds ~= true) then
        SDBG.settings.buttons[5].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[5].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[6] = CreateFrame("Button","mybutton",SDBG.settings,"UIPanelButtonTemplate")
SDBG.settings.buttons[6]:SetPoint("TOP", 0, -6*21+11)
SDBG.settings.buttons[6]:SetWidth(450)
SDBG.settings.buttons[6]:SetHeight(20)
SDBG.settings.buttons[6]:SetFont("Fonts\\FRIZQT__.TTF", 10)
SDBG.settings.buttons[6]:SetTextColor(1,1,1,1)
SDBG.settings.buttons[6]:SetNormalTexture(nil)
SDBG.settings.buttons[6]:SetPushedTexture(nil)
SDBG.settings.buttons[6]:SetHighlightTexture(nil)
SDBG.settings.buttons[6]:SetBackdrop(backdrop_noborder)
SDBG.settings.buttons[6]:SetBackdropColor(1,1,1,.10)
SDBG.settings.buttons[6]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText(ShaguDB_GetSetting("reqLevel")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows the required level in the quest start tooltips.|r");
    ShaguDB_Tooltip:Show();
end)
SDBG.settings.buttons[6]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.10)
    ShaguDB_Tooltip:Hide()
end)
SDBG.settings.buttons[6].enabled = CreateFrame("CheckButton","mycheckbutton",SDBG.settings.buttons[6],"UICheckButtonTemplate")
SDBG.settings.buttons[6].enabled:SetPoint("RIGHT", -25, 0)
SDBG.settings.buttons[6].enabled:SetWidth(20)
SDBG.settings.buttons[6].enabled:SetHeight(20)
SDBG.settings.buttons[6].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.reqLevel ~= true) then
        SDBG.settings.buttons[6].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[6].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[6].enabled:SetScript("OnClick", function(self)
    ShaguDB_SwitchSetting("reqLevel");
    if (CdbSettings.reqLevel ~= true) then
        SDBG.settings.buttons[6].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[6].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[7] = CreateFrame("Button","mybutton",SDBG.settings,"UIPanelButtonTemplate")
SDBG.settings.buttons[7]:SetPoint("TOP", 0, -7*21+11)
SDBG.settings.buttons[7]:SetWidth(450)
SDBG.settings.buttons[7]:SetHeight(20)
SDBG.settings.buttons[7]:SetFont("Fonts\\FRIZQT__.TTF", 10)
SDBG.settings.buttons[7]:SetTextColor(1,1,1,1)
SDBG.settings.buttons[7]:SetNormalTexture(nil)
SDBG.settings.buttons[7]:SetPushedTexture(nil)
SDBG.settings.buttons[7]:SetHighlightTexture(nil)
SDBG.settings.buttons[7]:SetBackdrop(backdrop_noborder)
SDBG.settings.buttons[7]:SetBackdropColor(1,1,1,.05)
SDBG.settings.buttons[7]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText(ShaguDB_GetSetting("item_item")..
                            "\n\n|cffffffff"..
                            "When enabled, this option enables showing item drops from other items.|r\n"..
                            "|cFFFF1A1A!WARNING! This option might be unstable!\n"..
                            "It is recommended to leave it turned of if not needed.|r");
    ShaguDB_Tooltip:Show();
end)
SDBG.settings.buttons[7]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    ShaguDB_Tooltip:Hide()
end)
SDBG.settings.buttons[7].enabled = CreateFrame("CheckButton","mycheckbutton",SDBG.settings.buttons[7],"UICheckButtonTemplate")
SDBG.settings.buttons[7].enabled:SetPoint("RIGHT", -25, 0)
SDBG.settings.buttons[7].enabled:SetWidth(20)
SDBG.settings.buttons[7].enabled:SetHeight(20)
SDBG.settings.buttons[7].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.item_item ~= true) then
        SDBG.settings.buttons[7].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[7].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[7].enabled:SetScript("OnClick", function(self)
    ShaguDB_SwitchSetting("item_item");
    if (CdbSettings.item_item ~= true) then
        SDBG.settings.buttons[7].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[7].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[8] = CreateFrame("Button","mybutton",SDBG.settings,"UIPanelButtonTemplate")
SDBG.settings.buttons[8]:SetPoint("TOP", 0, -8*21+11)
SDBG.settings.buttons[8]:SetWidth(450)
SDBG.settings.buttons[8]:SetHeight(20)
SDBG.settings.buttons[8]:SetFont("Fonts\\FRIZQT__.TTF", 10)
SDBG.settings.buttons[8]:SetTextColor(1,1,1,1)
SDBG.settings.buttons[8]:SetNormalTexture(nil)
SDBG.settings.buttons[8]:SetPushedTexture(nil)
SDBG.settings.buttons[8]:SetHighlightTexture(nil)
SDBG.settings.buttons[8]:SetBackdrop(backdrop_noborder)
SDBG.settings.buttons[8]:SetBackdropColor(1,1,1,.10)
SDBG.settings.buttons[8]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText(ShaguDB_GetSetting("waypoints")..
                            "\n\n|cffffffff"..
                            "When enabled, mob waypoints are shown on the map.\n"..
                            "Due to script spawns not yet being included in the DB\n"..
                            "this can be helpful in finding some special mobs.|r");
    ShaguDB_Tooltip:Show();
end)
SDBG.settings.buttons[8]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.10)
    ShaguDB_Tooltip:Hide()
end)
SDBG.settings.buttons[8].enabled = CreateFrame("CheckButton","mycheckbutton",SDBG.settings.buttons[8],"UICheckButtonTemplate")
SDBG.settings.buttons[8].enabled:SetPoint("RIGHT", -25, 0)
SDBG.settings.buttons[8].enabled:SetWidth(20)
SDBG.settings.buttons[8].enabled:SetHeight(20)
SDBG.settings.buttons[8].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.waypoints ~= true) then
        SDBG.settings.buttons[8].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[8].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[8].enabled:SetScript("OnClick", function(self)
    ShaguDB_SwitchSetting("waypoints");
    if (CdbSettings.waypoints ~= true) then
        SDBG.settings.buttons[8].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[8].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[9] = CreateFrame("Button","mybutton",SDBG.settings,"UIPanelButtonTemplate")
SDBG.settings.buttons[9]:SetPoint("TOP", 0, -9*21+11)
SDBG.settings.buttons[9]:SetWidth(450)
SDBG.settings.buttons[9]:SetHeight(20)
SDBG.settings.buttons[9]:SetFont("Fonts\\FRIZQT__.TTF", 10)
SDBG.settings.buttons[9]:SetTextColor(1,1,1,1)
SDBG.settings.buttons[9]:SetNormalTexture(nil)
SDBG.settings.buttons[9]:SetPushedTexture(nil)
SDBG.settings.buttons[9]:SetHighlightTexture(nil)
SDBG.settings.buttons[9]:SetBackdrop(backdrop_noborder)
SDBG.settings.buttons[9]:SetBackdropColor(1,1,1,.05)
SDBG.settings.buttons[9]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    ShaguDB_Tooltip:ClearLines();
    ShaguDB_Tooltip:SetText(ShaguDB_GetSetting("auto_plot")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows notes for all quests in the log.\n"..
                            "It will update automatically every time there is a quest\n"..
                            "event, like looting. If you experience lags when finishing\n"..
                            "a quest objective, disable and use the 'Show all notes'\n"..
                            "button as long as the quest drawing too many notes is in\n"..
                            "in your quest log.|r");
    ShaguDB_Tooltip:Show();
end)
SDBG.settings.buttons[9]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    ShaguDB_Tooltip:Hide()
end)
SDBG.settings.buttons[9].enabled = CreateFrame("CheckButton","mycheckbutton",SDBG.settings.buttons[9],"UICheckButtonTemplate")
SDBG.settings.buttons[9].enabled:SetPoint("RIGHT", -25, 0)
SDBG.settings.buttons[9].enabled:SetWidth(20)
SDBG.settings.buttons[9].enabled:SetHeight(20)
SDBG.settings.buttons[9].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.auto_plot ~= true) then
        SDBG.settings.buttons[9].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[9].enabled:SetChecked(true);
    end
end)
SDBG.settings.buttons[9].enabled:SetScript("OnClick", function(self)
    ShaguDB_SwitchSetting("auto_plot");
    if (CdbSettings.auto_plot ~= true) then
        SDBG.settings.buttons[9].enabled:SetChecked(false);
    else
        SDBG.settings.buttons[9].enabled:SetChecked(true);
    end
end)
function SDBG.HideButtons()
    for i=1,14 do
        if (SDBG.spawn.buttons[i]) then
            SDBG.spawn.buttons[i]:Hide();
        end
        if (SDBG.object.buttons[i]) then
            SDBG.object.buttons[i]:Hide();
        end
        if (SDBG.item.buttons[i]) then
            SDBG.item.buttons[i]:Hide();
        end
        if (SDBG.quest.buttons[i]) then
            SDBG.quest.buttons[i]:Hide();
        end
        if (SDBG.settings.buttons[i]) then
            SDBG.settings.buttons[i]:Hide();
        end
    end
end
function SDBG:SearchSpawn(search)
    local spawnCount = 1;
    local database = CdbFavourites["spawn"]
    if strlen(search) > 2 then database = npcData end
    for id, spawn in pairs(database) do
        local npc;
        if type(spawn) == "boolean" then
            npc = npcData[id];
        else
            npc = spawn;
        end
        if (npc ~= nil) and (strfind(strlower(npc[DB_NAME]), strlower(search))) or strlen(search) <= 2 then
            if ( spawnCount <= 14) then
                local name = npc[DB_NAME];
                SDBG.spawn.buttons[spawnCount] = CreateFrame("Button","mybutton",SDBG.spawn,"UIPanelButtonTemplate")
                SDBG.spawn.buttons[spawnCount]:SetPoint("TOP", 0, -spawnCount*21+11)
                SDBG.spawn.buttons[spawnCount]:SetWidth(450)
                SDBG.spawn.buttons[spawnCount]:SetHeight(20)
                SDBG.spawn.buttons[spawnCount]:SetFont("Fonts\\FRIZQT__.TTF", 10)
                SDBG.spawn.buttons[spawnCount]:SetTextColor(1,1,1,1)
                SDBG.spawn.buttons[spawnCount]:SetNormalTexture(nil)
                SDBG.spawn.buttons[spawnCount]:SetPushedTexture(nil)
                SDBG.spawn.buttons[spawnCount]:SetHighlightTexture(nil)
                SDBG.spawn.buttons[spawnCount]:SetBackdrop(backdrop_noborder)
                if math.mod(spawnCount,2) == 0 then
                    SDBG.spawn.buttons[spawnCount]:SetBackdropColor(1,1,1,.05)
                    SDBG.spawn.buttons[spawnCount].even = true
                else
                SDBG.spawn.buttons[spawnCount]:SetBackdropColor(1,1,1,.10)
                    SDBG.spawn.buttons[spawnCount].even = false
                end
                SDBG.spawn.buttons[spawnCount]:SetTextColor(1,1,1)
                if npc[DB_LEVEL] ~= "" then
                    SDBG.spawn.buttons[spawnCount]:SetText(name .. " |cffaaaaaa(Lv." .. npc[DB_LEVEL] .. ", ID:" .. id .. ")")
                else
                    SDBG.spawn.buttons[spawnCount]:SetText(name)
                end
                SDBG.spawn.buttons[spawnCount].spawnName = name
                SDBG.spawn.buttons[spawnCount].spawnId = id;
                SDBG.spawn.buttons[spawnCount]:SetScript("OnClick", function(self)
                    ShaguDB_MAP_NOTES = {};
                    ShaguDB_MarkForPlotting(DB_NPC, this.spawnName, this.spawnName, "Spawnpoint", 0);
                    ShaguDB_ShowMap();
                end)
                SDBG.spawn.buttons[spawnCount]:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                end)
                SDBG.spawn.buttons[spawnCount]:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                end)
                -- show faction icons (deactivated until faction is added to NPC data)
                local faction = "HA" --spawnDB[SDBG.spawn.buttons[spawnCount].spawnName]['faction']
                if strfind(faction, "H") and faction ~= "HA" then
                    SDBG.spawn.buttons[spawnCount].horde = CreateFrame("Frame", nil, SDBG.spawn.buttons[spawnCount])
                    SDBG.spawn.buttons[spawnCount].horde:SetPoint("RIGHT", -5, 0)
                    SDBG.spawn.buttons[spawnCount].horde:SetWidth(20)
                    SDBG.spawn.buttons[spawnCount].horde:SetHeight(20)
                    SDBG.spawn.buttons[spawnCount].horde.icon = SDBG.spawn.buttons[spawnCount].horde:CreateTexture(nil,"BACKGROUND")
                    SDBG.spawn.buttons[spawnCount].horde.icon:SetTexture("Interface\\AddOns\\ShaguDB\\symbols\\icon_horde")
                    SDBG.spawn.buttons[spawnCount].horde.icon:SetAllPoints(SDBG.spawn.buttons[spawnCount].horde)
                end
                if strfind(faction, "A") and faction ~= "HA" then
                    SDBG.spawn.buttons[spawnCount].alliance = CreateFrame("Frame", nil, SDBG.spawn.buttons[spawnCount])
                    if SDBG.spawn.buttons[spawnCount].horde then
                        SDBG.spawn.buttons[spawnCount].alliance:SetPoint("RIGHT", -30, 0)
                    else
                        SDBG.spawn.buttons[spawnCount].alliance:SetPoint("RIGHT", -5, 0)
                    end
                    SDBG.spawn.buttons[spawnCount].alliance:SetWidth(20)
                    SDBG.spawn.buttons[spawnCount].alliance:SetHeight(20)
                    SDBG.spawn.buttons[spawnCount].alliance.icon = SDBG.spawn.buttons[spawnCount].alliance:CreateTexture(nil,"BACKGROUND")
                    SDBG.spawn.buttons[spawnCount].alliance.icon:SetTexture("Interface\\AddOns\\ShaguDB\\symbols\\icon_alliance")
                    SDBG.spawn.buttons[spawnCount].alliance.icon:SetAllPoints(SDBG.spawn.buttons[spawnCount].alliance)
                end
                -- show fav button
                SDBG.spawn.buttons[spawnCount].fav = CreateFrame("Button","mybutton",SDBG.spawn.buttons[spawnCount],"UIPanelButtonTemplate")
                SDBG.spawn.buttons[spawnCount].fav:SetPoint("LEFT", 5, 0)
                SDBG.spawn.buttons[spawnCount].fav:SetWidth(20)
                SDBG.spawn.buttons[spawnCount].fav:SetHeight(20)
                SDBG.spawn.buttons[spawnCount].fav:SetNormalTexture(nil)
                SDBG.spawn.buttons[spawnCount].fav:SetPushedTexture(nil)
                SDBG.spawn.buttons[spawnCount].fav:SetHighlightTexture(nil)
                SDBG.spawn.buttons[spawnCount].fav.icon = SDBG.spawn.buttons[spawnCount].fav:CreateTexture(nil,"BACKGROUND")
                SDBG.spawn.buttons[spawnCount].fav.icon:SetTexture("Interface\\AddOns\\ShaguDB\\img\\fav")
                if CdbFavourites["spawn"][id] then
                    SDBG.spawn.buttons[spawnCount].fav.icon:SetVertexColor(1,1,1,1)
                else
                    SDBG.spawn.buttons[spawnCount].fav.icon:SetVertexColor(0,0,0,1)
                end
                SDBG.spawn.buttons[spawnCount].fav.icon:SetAllPoints(SDBG.spawn.buttons[spawnCount].fav)
                SDBG.spawn.buttons[spawnCount].fav:SetScript("OnClick", function(self)
                if CdbFavourites["spawn"][this:GetParent().spawnId] then
                    CdbFavourites["spawn"][this:GetParent().spawnId] = nil
                    this.icon:SetVertexColor(0,0,0,1)
                    SDBG.inputField:updateSearch()
                else
                    CdbFavourites["spawn"][this:GetParent().spawnId] = true
                    this.icon:SetVertexColor(1,1,1,1)
                end
            end)
            spawnCount = spawnCount + 1
        end
      end
    end
    if spawnCount >= 14 then spawnCount = "*" else spawnCount = spawnCount -1 end
    if spawnCount == 0 then
        SDBG.buttonSpawn.text:SetText("Mobs")
    else
        SDBG.buttonSpawn.text:SetText("Mobs |cffaaaaaa(" .. spawnCount .. ")")
    end
end
function SDBG:SearchObject(search)
    local objectCount = 1;
    local database = CdbFavourites["object"]
    if strlen(search) > 2 then database = objData end
    for id, object in pairs(database) do
        local obj;
        if type(object) == "boolean" then
            obj = objData[id];
        else
            obj = object;
        end
        if (strfind(strlower(obj[DB_NAME]), strlower(search))) or strlen(search) <= 2 then
            if ( objectCount <= 14) then
                local name = obj[DB_NAME];
                SDBG.object.buttons[objectCount] = CreateFrame("Button","mybutton",SDBG.object,"UIPanelButtonTemplate")
                SDBG.object.buttons[objectCount]:SetPoint("TOP", 0, -objectCount*21+11)
                SDBG.object.buttons[objectCount]:SetWidth(450)
                SDBG.object.buttons[objectCount]:SetHeight(20)
                SDBG.object.buttons[objectCount]:SetFont("Fonts\\FRIZQT__.TTF", 10)
                SDBG.object.buttons[objectCount]:SetTextColor(1,1,1,1)
                SDBG.object.buttons[objectCount]:SetNormalTexture(nil)
                SDBG.object.buttons[objectCount]:SetPushedTexture(nil)
                SDBG.object.buttons[objectCount]:SetHighlightTexture(nil)
                SDBG.object.buttons[objectCount]:SetBackdrop(backdrop_noborder)
                if math.mod(objectCount,2) == 0 then
                    SDBG.object.buttons[objectCount]:SetBackdropColor(1,1,1,.05)
                    SDBG.object.buttons[objectCount].even = true
                else
                    SDBG.object.buttons[objectCount]:SetBackdropColor(1,1,1,.10)
                    SDBG.object.buttons[objectCount].even = false
                end
                SDBG.object.buttons[objectCount]:SetTextColor(1,1,1)
                SDBG.object.buttons[objectCount]:SetText(name .. " |cffaaaaaa(ID:" .. id .. ")")
                SDBG.object.buttons[objectCount].objectName = name
                SDBG.object.buttons[objectCount].objectId = id
                SDBG.object.buttons[objectCount]:SetScript("OnClick", function(self)
                    ShaguDB_MAP_NOTES = {};
                    ShaguDB_MarkForPlotting(DB_OBJ, this.objectName, this.objectName, "Spawnpoint", 0);
                    ShaguDB_ShowMap();
                end)
                SDBG.object.buttons[objectCount]:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                end)
                SDBG.object.buttons[objectCount]:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                end)
                -- show faction icons (deactivated - do objects even have a faction?)
                local faction = "HA" --objectDB[SDBG.object.buttons[objectCount].objectName]['faction']
                if strfind(faction, "H") and faction ~= "HA" then
                    SDBG.object.buttons[objectCount].horde = CreateFrame("Frame", nil, SDBG.object.buttons[objectCount])
                    SDBG.object.buttons[objectCount].horde:SetPoint("RIGHT", -5, 0)
                    SDBG.object.buttons[objectCount].horde:SetWidth(20)
                    SDBG.object.buttons[objectCount].horde:SetHeight(20)
                    SDBG.object.buttons[objectCount].horde.icon = SDBG.object.buttons[objectCount].horde:CreateTexture(nil,"BACKGROUND")
                    SDBG.object.buttons[objectCount].horde.icon:SetTexture("Interface\\AddOns\\ShaguDB\\symbols\\icon_horde")
                    SDBG.object.buttons[objectCount].horde.icon:SetAllPoints(SDBG.object.buttons[objectCount].horde)
                end
                if strfind(faction, "A") and faction ~= "HA" then
                    SDBG.object.buttons[objectCount].alliance = CreateFrame("Frame", nil, SDBG.object.buttons[objectCount])
                    if SDBG.object.buttons[objectCount].horde then
                        SDBG.object.buttons[objectCount].alliance:SetPoint("RIGHT", -30, 0)
                    else
                        SDBG.object.buttons[objectCount].alliance:SetPoint("RIGHT", -5, 0)
                    end
                    SDBG.object.buttons[objectCount].alliance:SetWidth(20)
                    SDBG.object.buttons[objectCount].alliance:SetHeight(20)
                    SDBG.object.buttons[objectCount].alliance.icon = SDBG.object.buttons[objectCount].alliance:CreateTexture(nil,"BACKGROUND")
                    SDBG.object.buttons[objectCount].alliance.icon:SetTexture("Interface\\AddOns\\ShaguDB\\symbols\\icon_alliance")
                    SDBG.object.buttons[objectCount].alliance.icon:SetAllPoints(SDBG.object.buttons[objectCount].alliance)
                end
                -- show fav button
                SDBG.object.buttons[objectCount].fav = CreateFrame("Button","mybutton",SDBG.object.buttons[objectCount],"UIPanelButtonTemplate")
                SDBG.object.buttons[objectCount].fav:SetPoint("LEFT", 5, 0)
                SDBG.object.buttons[objectCount].fav:SetWidth(20)
                SDBG.object.buttons[objectCount].fav:SetHeight(20)
                SDBG.object.buttons[objectCount].fav:SetNormalTexture(nil)
                SDBG.object.buttons[objectCount].fav:SetPushedTexture(nil)
                SDBG.object.buttons[objectCount].fav:SetHighlightTexture(nil)
                SDBG.object.buttons[objectCount].fav.icon = SDBG.object.buttons[objectCount].fav:CreateTexture(nil,"BACKGROUND")
                SDBG.object.buttons[objectCount].fav.icon:SetTexture("Interface\\AddOns\\ShaguDB\\img\\fav")
                if CdbFavourites["object"][id] then
                    SDBG.object.buttons[objectCount].fav.icon:SetVertexColor(1,1,1,1)
                else
                    SDBG.object.buttons[objectCount].fav.icon:SetVertexColor(0,0,0,1)
                end
                SDBG.object.buttons[objectCount].fav.icon:SetAllPoints(SDBG.object.buttons[objectCount].fav)
                SDBG.object.buttons[objectCount].fav:SetScript("OnClick", function(self)
                    if CdbFavourites["object"][this:GetParent().objectId] then
                        CdbFavourites["object"][this:GetParent().objectId] = nil
                        this.icon:SetVertexColor(0,0,0,1)
                        SDBG.inputField:updateSearch()
                    else
                        CdbFavourites["object"][this:GetParent().objectId] = true
                        this.icon:SetVertexColor(1,1,1,1)
                    end
                end)
                objectCount = objectCount + 1
            end
        end
    end
    if objectCount >= 14 then objectCount = "*" else objectCount = objectCount -1 end
    if objectCount == 0 then
        SDBG.buttonObject.text:SetText("Objects")
    else
        SDBG.buttonObject.text:SetText("Objects |cffaaaaaa(" .. objectCount .. ")")
    end
end
function SDBG:SearchItem(search)
    local itemCount = 1;
    local database = CdbFavourites["item"]
    if strlen(search) > 2 then database = itemData end
    for id, item in pairs(database) do
        local itm;
        if type(item) == "boolean" then
            itm = itemData[id];
        else
            itm = item;
        end
        if (strfind(strlower(itm[DB_ITM_NAME]), strlower(search))) or strlen(search) <= 2 then
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
                SDBG.item.buttons[itemCount] = CreateFrame("Button","mybutton",SDBG.item,"UIPanelButtonTemplate")
                SDBG.item.buttons[itemCount]:SetPoint("TOP", 0, -itemCount*21+11)
                SDBG.item.buttons[itemCount]:SetWidth(450)
                SDBG.item.buttons[itemCount]:SetHeight(20)
                SDBG.item.buttons[itemCount]:SetFont("Fonts\\FRIZQT__.TTF", 10)
                SDBG.item.buttons[itemCount]:SetNormalTexture(nil)
                SDBG.item.buttons[itemCount]:SetPushedTexture(nil)
                SDBG.item.buttons[itemCount]:SetHighlightTexture(nil)
                SDBG.item.buttons[itemCount]:SetBackdrop(backdrop_noborder)
                if math.mod(itemCount,2) == 0 then
                    SDBG.item.buttons[itemCount]:SetBackdropColor(1,1,1,.05)
                    SDBG.item.buttons[itemCount].even = true
                else
                    SDBG.item.buttons[itemCount]:SetBackdropColor(1,1,1,.10)
                    SDBG.item.buttons[itemCount].even = false
                end
                SDBG.item.buttons[itemCount].itemName = name
                SDBG.item.buttons[itemCount].itemColor = itemColor
                SDBG.item.buttons[itemCount].itemId = id
                SDBG.item.buttons[itemCount].itemLink = itemLink
                SDBG.item.buttons[itemCount]:SetText(itemColor .."|Hitem:"..id..":0:0:0|h["..name.."]|h|r |cffaaaaaa(ID:" .. id .. ")")
                SDBG.item.buttons[itemCount]:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                    GameTooltip:SetOwner(SDBG, "ANCHOR_CURSOR")
                    GameTooltip:SetHyperlink("item:" .. this.itemId .. ":0:0:0")
                    GameTooltip:Show()
                end)
                SDBG.item.buttons[itemCount]:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                end)
                SDBG.item.buttons[itemCount]:SetScript("OnClick", function(self)
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
                if ShaguDB_GetTableLength(itm[DB_NPC]) ~= 0 then
                    SDBG.item.buttons[itemCount].lootNpc = CreateFrame("Button","mybutton",SDBG.item.buttons[itemCount],"UIPanelButtonTemplate")
                    SDBG.item.buttons[itemCount].lootNpc:SetPoint("RIGHT", -5, 0)
                    SDBG.item.buttons[itemCount].lootNpc:SetWidth(20)
                    SDBG.item.buttons[itemCount].lootNpc:SetHeight(20)
                    SDBG.item.buttons[itemCount].lootNpc:SetNormalTexture(nil)
                    SDBG.item.buttons[itemCount].lootNpc:SetPushedTexture(nil)
                    SDBG.item.buttons[itemCount].lootNpc:SetHighlightTexture(nil)
                    SDBG.item.buttons[itemCount].lootNpc.icon = SDBG.item.buttons[itemCount].lootNpc:CreateTexture(nil,"BACKGROUND")
                    SDBG.item.buttons[itemCount].lootNpc.icon:SetTexture("Interface\\AddOns\\ShaguDB\\symbols\\icon_npc")
                    SDBG.item.buttons[itemCount].lootNpc.icon:SetAllPoints(SDBG.item.buttons[itemCount].lootNpc)
                    SDBG.item.buttons[itemCount].lootNpc:SetScript("OnClick", function(self)
                        ShaguDB_MAP_NOTES = {};
                        ShaguDB_PrepareItemNotes(this:GetParent().itemId, "Location for: "..this:GetParent().itemName, "Drops item: "..this:GetParent().itemName, cMark, {DB_NPC});
                        ShaguDB_NextCMark();
                        ShaguDB_ShowMap();
                    end)
                end
                -- show object button
                if ShaguDB_GetTableLength(itm[DB_OBJ]) ~= 0 then
                    SDBG.item.buttons[itemCount].lootObj = CreateFrame("Button","mybutton",SDBG.item.buttons[itemCount],"UIPanelButtonTemplate")
                    if SDBG.item.buttons[itemCount].lootNpc then
                        SDBG.item.buttons[itemCount].lootObj:SetPoint("RIGHT", -30, 0)
                    else
                        SDBG.item.buttons[itemCount].lootObj:SetPoint("RIGHT", -5, 0)
                    end
                    SDBG.item.buttons[itemCount].lootObj:SetWidth(20)
                    SDBG.item.buttons[itemCount].lootObj:SetHeight(20)
                    SDBG.item.buttons[itemCount].lootObj:SetNormalTexture(nil)
                    SDBG.item.buttons[itemCount].lootObj:SetPushedTexture(nil)
                    SDBG.item.buttons[itemCount].lootObj:SetHighlightTexture(nil)
                    SDBG.item.buttons[itemCount].lootObj.icon = SDBG.item.buttons[itemCount].lootObj:CreateTexture(nil,"BACKGROUND")
                    SDBG.item.buttons[itemCount].lootObj.icon:SetTexture("Interface\\AddOns\\ShaguDB\\symbols\\icon_object")
                    SDBG.item.buttons[itemCount].lootObj.icon:SetAllPoints(SDBG.item.buttons[itemCount].lootObj)
                    SDBG.item.buttons[itemCount].lootObj:SetScript("OnClick", function(self)
                        ShaguDB_MAP_NOTES = {};
                        ShaguDB_PrepareItemNotes(this:GetParent().itemId, "Location for: "..this:GetParent().itemName, "Contains item: "..this:GetParent().itemName, "Object", {DB_OBJ});
                        ShaguDB_NextCMark();
                        ShaguDB_ShowMap();
                    end)
                end
                -- show vendor button
                if ShaguDB_GetTableLength(itm[DB_VENDOR]) ~= 0 then
                    SDBG.item.buttons[itemCount].vendor = CreateFrame("Button","mybutton",SDBG.item.buttons[itemCount],"UIPanelButtonTemplate")
                    if SDBG.item.buttons[itemCount].lootNpc and SDBG.item.buttons[itemCount].lootObj then
                        SDBG.item.buttons[itemCount].vendor:SetPoint("RIGHT", -55, 0)
                    elseif SDBG.item.buttons[itemCount].lootNpc or SDBG.item.buttons[itemCount].lootObj then
                        SDBG.item.buttons[itemCount].vendor:SetPoint("RIGHT", -30, 0)
                    else
                        SDBG.item.buttons[itemCount].vendor:SetPoint("RIGHT", -5, 0)
                    end
                    SDBG.item.buttons[itemCount].vendor:SetWidth(20)
                    SDBG.item.buttons[itemCount].vendor:SetHeight(20)
                    SDBG.item.buttons[itemCount].vendor:SetNormalTexture(nil)
                    SDBG.item.buttons[itemCount].vendor:SetPushedTexture(nil)
                    SDBG.item.buttons[itemCount].vendor:SetHighlightTexture(nil)
                    SDBG.item.buttons[itemCount].vendor.icon = SDBG.item.buttons[itemCount].vendor:CreateTexture(nil,"BACKGROUND")
                    SDBG.item.buttons[itemCount].vendor.icon:SetTexture("Interface\\AddOns\\ShaguDB\\symbols\\icon_vendor")
                    SDBG.item.buttons[itemCount].vendor.icon:SetAllPoints(SDBG.item.buttons[itemCount].vendor)
                    SDBG.item.buttons[itemCount].vendor:SetScript("OnClick", function(self)
                        ShaguDB_MAP_NOTES = {};
                        ShaguDB_PrepareItemNotes(this:GetParent().itemId, "Location for: "..this:GetParent().itemName, "Sells item: "..this:GetParent().itemName, "Vendor", {DB_VENDOR});
                        ShaguDB_NextCMark();
                        ShaguDB_ShowMap();
                    end)
                end
                -- show fav button
                SDBG.item.buttons[itemCount].fav = CreateFrame("Button","mybutton",SDBG.item.buttons[itemCount],"UIPanelButtonTemplate")
                SDBG.item.buttons[itemCount].fav:SetPoint("LEFT", 5, 0)
                SDBG.item.buttons[itemCount].fav:SetWidth(20)
                SDBG.item.buttons[itemCount].fav:SetHeight(20)
                SDBG.item.buttons[itemCount].fav:SetNormalTexture(nil)
                SDBG.item.buttons[itemCount].fav:SetPushedTexture(nil)
                SDBG.item.buttons[itemCount].fav:SetHighlightTexture(nil)
                SDBG.item.buttons[itemCount].fav.icon = SDBG.item.buttons[itemCount].fav:CreateTexture(nil,"BACKGROUND")
                SDBG.item.buttons[itemCount].fav.icon:SetTexture("Interface\\AddOns\\ShaguDB\\img\\fav")
                if CdbFavourites["item"][id] then
                    SDBG.item.buttons[itemCount].fav.icon:SetVertexColor(1,1,1,1)
                else
                    SDBG.item.buttons[itemCount].fav.icon:SetVertexColor(0,0,0,1)
                end
                SDBG.item.buttons[itemCount].fav.icon:SetAllPoints(SDBG.item.buttons[itemCount].fav)
                SDBG.item.buttons[itemCount].fav:SetScript("OnClick", function(self)
                    if CdbFavourites["item"][this:GetParent().itemId] then
                        CdbFavourites["item"][this:GetParent().itemId] = nil
                        this.icon:SetVertexColor(0,0,0,1)
                        SDBG.inputField:updateSearch()
                    else
                        CdbFavourites["item"][this:GetParent().itemId] = true
                        this.icon:SetVertexColor(1,1,1,1)
                    end
                end)
                itemCount = itemCount + 1
            end
        end
    end
    if itemCount >= 14 then itemCount = "*" else itemCount = itemCount -1 end
    if itemCount == 0 then
        SDBG.buttonItem.text:SetText("Items")
    else
        SDBG.buttonItem.text:SetText("Items |cffaaaaaa(" .. itemCount .. ")")
    end
end
function SDBG:SearchQuest(search)
    local questCount = 1;
    local database = CdbFavourites["quest"]
    if strlen(search) > 2 then database = qData end
    for id, quest in pairs(database) do
        local q;
        if type(quest) == "boolean" then
            q = qData[id];
        else
            q = quest;
        end
        if (strfind(strlower(q[DB_NAME]), strlower(search))) or strlen(search) <= 2 then
            if questCount <= 14 then
                local name = q[DB_NAME];
                SDBG.quest.buttons[questCount] = CreateFrame("Button","mybutton",SDBG.quest,"UIPanelButtonTemplate")
                SDBG.quest.buttons[questCount]:SetPoint("TOP", 0, -questCount*22+11)
                SDBG.quest.buttons[questCount]:SetWidth(450)
                SDBG.quest.buttons[questCount]:SetHeight(20)
                SDBG.quest.buttons[questCount]:SetFont("Fonts\\FRIZQT__.TTF", 10)
                SDBG.quest.buttons[questCount]:SetNormalTexture(nil)
                SDBG.quest.buttons[questCount]:SetPushedTexture(nil)
                SDBG.quest.buttons[questCount]:SetHighlightTexture(nil)
                SDBG.quest.buttons[questCount]:SetBackdrop(backdrop_noborder)
                if math.mod(questCount,2) == 0 then
                    SDBG.quest.buttons[questCount]:SetBackdropColor(1,1,1,.05)
                    SDBG.quest.buttons[questCount].even = true
                else
                    SDBG.quest.buttons[questCount]:SetBackdropColor(1,1,1,.10)
                    SDBG.quest.buttons[questCount].even = false
                end
                SDBG.quest.buttons[questCount].questName = name
                SDBG.quest.buttons[questCount].questId = id
                -- linefeed for tooltip
                -- simplest method choosen for performance reasons
                if q[DB_OBJECTIVES] then
                    SDBG.quest.buttons[questCount].questObjectives = "";
                    local rest = q[DB_OBJECTIVES];
                    while string.len(rest) > 100 do
                        SDBG.quest.buttons[questCount].questObjectives = SDBG.quest.buttons[questCount].questObjectives..string.sub(rest, 1, 99).."-\n";
                        rest = string.sub(rest, 100)
                    end
                    SDBG.quest.buttons[questCount].questObjectives = SDBG.quest.buttons[questCount].questObjectives..rest;
                end
                SDBG.quest.buttons[questCount]:SetText("|cffffcc00["..q[DB_LEVEL].."] |Hquest:0:0:0:0|h["..name.."]|h|r|r (ID:"..id..")")
                SDBG.quest.buttons[questCount]:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                    if this.questObjectives then
                        ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                        ShaguDB_Tooltip:ClearLines();
                        ShaguDB_Tooltip:SetText(this:GetText().."\n|cFFffffffObjectives:|r\n|cFFa6a6a6"..this.questObjectives.."|r");
                        ShaguDB_Tooltip:Show();
                    end
                end)
                SDBG.quest.buttons[questCount]:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                    if this.questObjectives then ShaguDB_Tooltip:Hide(); end
                end)
                SDBG.quest.buttons[questCount]:SetScript("OnClick", function(self)
                    if IsShiftKeyDown() then
                        if not ChatFrameEditBox:IsVisible() then
                            ChatFrameEditBox:Show()
                        end
                        ChatFrameEditBox:Insert("|cffffff00|Hquest:0:0:0:0|h["..this.questName.."]|h|r")
                    else
                        ShaguDB_MAP_NOTES = {};
                        ShaguDB_GetQuestNotesById(this.questId)
                        ShaguDB_NextCMark();
                        ShaguDB_ShowMap();
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
                    SDBG.quest.buttons[questCount].horde = CreateFrame("Frame", nil, SDBG.quest.buttons[questCount])
                    SDBG.quest.buttons[questCount].horde:SetPoint("RIGHT", -5, 0)
                    SDBG.quest.buttons[questCount].horde:SetWidth(20)
                    SDBG.quest.buttons[questCount].horde:SetHeight(20)
                    SDBG.quest.buttons[questCount].horde.icon = SDBG.quest.buttons[questCount].horde:CreateTexture(nil,"BACKGROUND")
                    SDBG.quest.buttons[questCount].horde.icon:SetTexture("Interface\\AddOns\\ShaguDB\\symbols\\icon_horde")
                    SDBG.quest.buttons[questCount].horde.icon:SetAllPoints(SDBG.quest.buttons[questCount].horde)
                end
                if strfind(faction, "A") and faction ~= "HA" then
                    SDBG.quest.buttons[questCount].alliance = CreateFrame("Frame", nil, SDBG.quest.buttons[questCount])
                    if SDBG.quest.buttons[questCount].horde then
                        SDBG.quest.buttons[questCount].alliance:SetPoint("RIGHT", -30, 0)
                    else
                        SDBG.quest.buttons[questCount].alliance:SetPoint("RIGHT", -5, 0)
                    end
                    SDBG.quest.buttons[questCount].alliance:SetWidth(20)
                    SDBG.quest.buttons[questCount].alliance:SetHeight(20)
                    SDBG.quest.buttons[questCount].alliance.icon = SDBG.quest.buttons[questCount].alliance:CreateTexture(nil,"BACKGROUND")
                    SDBG.quest.buttons[questCount].alliance.icon:SetTexture("Interface\\AddOns\\ShaguDB\\symbols\\icon_alliance")
                    SDBG.quest.buttons[questCount].alliance.icon:SetAllPoints(SDBG.quest.buttons[questCount].alliance)
                end
                -- show fav button
                SDBG.quest.buttons[questCount].fav = CreateFrame("Button","mybutton",SDBG.quest.buttons[questCount],"UIPanelButtonTemplate")
                SDBG.quest.buttons[questCount].fav:SetPoint("LEFT", 5, 0)
                SDBG.quest.buttons[questCount].fav:SetWidth(20)
                SDBG.quest.buttons[questCount].fav:SetHeight(20)
                SDBG.quest.buttons[questCount].fav:SetNormalTexture(nil)
                SDBG.quest.buttons[questCount].fav:SetPushedTexture(nil)
                SDBG.quest.buttons[questCount].fav:SetHighlightTexture(nil)
                SDBG.quest.buttons[questCount].fav.icon = SDBG.quest.buttons[questCount].fav:CreateTexture(nil,"BACKGROUND")
                SDBG.quest.buttons[questCount].fav.icon:SetTexture("Interface\\AddOns\\ShaguDB\\img\\fav")
                if CdbFavourites["quest"][id] then
                    SDBG.quest.buttons[questCount].fav.icon:SetVertexColor(1,1,1,1)
                else
                    SDBG.quest.buttons[questCount].fav.icon:SetVertexColor(0,0,0,1)
                end
                SDBG.quest.buttons[questCount].fav.icon:SetAllPoints(SDBG.quest.buttons[questCount].fav)
                SDBG.quest.buttons[questCount].fav:SetScript("OnClick", function(self)
                    if CdbFavourites["quest"][this:GetParent().questId] then
                        CdbFavourites["quest"][this:GetParent().questId] = nil
                        this.icon:SetVertexColor(0,0,0,1)
                        SDBG.inputField:updateSearch()
                    else
                        CdbFavourites["quest"][this:GetParent().questId] = true
                        this.icon:SetVertexColor(1,1,1,1)
                    end
                end)
                SDBG.quest.buttons[questCount].fav:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                    ShaguDB_Tooltip:ClearLines();
                    ShaguDB_Tooltip:SetText("Mark as Favourite\n\n|cffffffffFavourites are shown when the search bar is empty.|r");
                    ShaguDB_Tooltip:Show();
                end)
                SDBG.quest.buttons[questCount].fav:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                    ShaguDB_Tooltip:Hide();
                end)
                -- show quest finished buttonQuest
                SDBG.quest.buttons[questCount].finished = CreateFrame("CheckButton","mycheckbutton",SDBG.quest.buttons[questCount],"UICheckButtonTemplate")
                SDBG.quest.buttons[questCount].finished.questId = SDBG.quest.buttons[questCount].questId;
                SDBG.quest.buttons[questCount].finished:SetPoint("RIGHT", -25, 0)
                SDBG.quest.buttons[questCount].finished:SetWidth(20)
                SDBG.quest.buttons[questCount].finished:SetHeight(20)
                if (CdbFinishedQuests[id] ~= true) then
                    SDBG.quest.buttons[questCount].finished:SetChecked(false);
                else
                    SDBG.quest.buttons[questCount].finished:SetChecked(true);
                end
                SDBG.quest.buttons[questCount].finished:SetScript("OnClick", function(self)
                    if (CdbFinishedQuests[this.questId] == true) then
                        CdbFinishedQuests[this.questId] = nil;
                    else
                        CdbFinishedQuests[this.questId] = true;
                    end
                end)
                SDBG.quest.buttons[questCount].finished:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                    ShaguDB_Tooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                    ShaguDB_Tooltip:ClearLines();
                    ShaguDB_Tooltip:SetText("Mark as finished\n\n|cffffffffQuests that are marked as finished do not appear when Quest Starts are plotted.\nTo refresh your Quest Start display, clean the map and then reenable Quest Starts.|r");
                    ShaguDB_Tooltip:Show();
                end)
                SDBG.quest.buttons[questCount].finished:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                    ShaguDB_Tooltip:Hide();
                end)
                questCount = questCount + 1
            end
        end
    end
    if questCount >= 14 then questCount = "*" else questCount = questCount -1 end
    if questCount == 0 then
        SDBG.buttonQuest.text:SetText("Quests")
    else
        SDBG.buttonQuest.text:SetText("Quests |cffaaaaaa(" .. questCount .. ")")
    end
end
