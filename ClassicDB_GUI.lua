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

CdbSearchGui = CreateFrame("Frame",nil,UIParent)
CdbSearchGui:RegisterEvent("PLAYER_ENTERING_WORLD");
CdbSearchGui:SetScript("OnEvent", function(self, event, ...)
    CdbSearchGui.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(CdbMinimapPosition)),(80*sin(CdbMinimapPosition))-52)
end)

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

CdbSearchGui.minimapButton = CreateFrame('Button', "CdbMinimap", Minimap)
if (CdbMinimapPosition == nil) then
    CdbMinimapPosition = 125
end

CdbSearchGui.minimapButton:SetMovable(true)
CdbSearchGui.minimapButton:EnableMouse(true)
CdbSearchGui.minimapButton:RegisterForDrag('LeftButton')
CdbSearchGui.minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp");
CdbSearchGui.minimapButton:SetScript("OnDragStop", function()
    local xpos,ypos = GetCursorPosition()
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

    xpos = xmin-xpos/UIParent:GetScale()+70
    ypos = ypos/UIParent:GetScale()-ymin-70

    CdbMinimapPosition = math.deg(math.atan2(ypos,xpos))
    CdbSearchGui.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(CdbMinimapPosition)),(80*sin(CdbMinimapPosition))-52)
end)

CdbSearchGui.minimapButton:SetFrameStrata('HIGH')
CdbSearchGui.minimapButton:SetWidth(31)
CdbSearchGui.minimapButton:SetHeight(31)
CdbSearchGui.minimapButton:SetFrameLevel(9)
CdbSearchGui.minimapButton:SetHighlightTexture('Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight')
CdbSearchGui.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(CdbMinimapPosition)),(80*sin(CdbMinimapPosition))-52)
CdbSearchGui.minimapButton:SetScript("OnClick", function()
    if ( arg1 == "LeftButton" ) then
        if IsShiftKeyDown() then
            Cartographer_Notes:SetIconSize(1);
            Cartographer_LookNFeel:SetScale(1);
            local size = 1;
            if Cartographer_LookNFeel.db.profile.largePlayer then
                size = size*1.5;
            end
            Cartographer_LookNFeel.playerModel:SetModelScale(size);
            WorldMapFrame:StartMoving();
            WorldMapFrame:SetPoint("CENTER", 0, 0);
            WorldMapFrame:StopMovingOrSizing();
            WorldMapFrame:ClearAllPoints();
            WorldMapFrame:SetAllPoints(UIParent);
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
CdbSearchGui.minimapButton:SetScript("OnEnter", function()
    CdbTooltip:SetOwner(CdbSearchGui.minimapButton, "ANCHOR_BOTTOMLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText("ClassicDB\n\n<LeftClick>: Toggle search window\n<RightClick>: Toggle control window\n<Shift>+<LeftClick>: Reset Map and Icon Size\n<Shift>+<RightClick>: Reset and show both windows");
    CdbTooltip:Show();
end)
CdbSearchGui.minimapButton:SetScript("OnLeave", function()
    CdbTooltip:Hide();
end)

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

    for i=1,14 do
        CdbSearchGui.settings.buttons[1]:SetText("DB Mode")
        CdbSearchGui.settings.buttons[2]:SetText("Show Quest Starts")
        CdbSearchGui.settings.buttons[3]:SetText("Filter Quest Starts based on finished quests")
        CdbSearchGui.settings.buttons[4]:SetText("Filter Quest Starts by required level")
        CdbSearchGui.settings.buttons[5]:SetText("Show Quest IDs")
        CdbSearchGui.settings.buttons[6]:SetText("Show required level")
        CdbSearchGui.settings.buttons[7]:SetText("Items dropped by items")
        CdbSearchGui.settings.buttons[8]:SetText("Waypoints")
        CdbSearchGui.settings.buttons[9]:SetText("Auto Plot")
        if (CdbSearchGui.settings.buttons[i]) then
            CdbSearchGui.settings.buttons[i]:Show();
        end
    end
end)

--[[
CdbSearchGui.buttonSettings:SetScript("OnEnter", function(self)
  this:SetBackdropColor(1,1,1,.25)
end)

CdbSearchGui.buttonSettings:SetScript("OnLeave", function(self)
  if this.even == true then
    this:SetBackdropColor(1,1,1,.05)
  else
    this:SetBackdropColor(1,1,1,.10)
  end
end)--]]

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

CdbSearchGui.settings = CreateFrame("Frame",nil,CdbSearchGui)
CdbSearchGui.settings:SetPoint("TOP", 0, -75)
CdbSearchGui.settings:SetWidth(475)
CdbSearchGui.settings:SetHeight(315)
CdbSearchGui.settings:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings:SetBackdropColor(1,1,1,.15)
--CdbSearchGui.settings:SetFrameStrata("DIALOG")
CdbSearchGui.settings:Hide()
CdbSearchGui.settings.buttons = {}

CdbSearchGui.settings.buttons[1] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
CdbSearchGui.settings.buttons[1]:SetPoint("TOP", 0, -1*21+11)
CdbSearchGui.settings.buttons[1]:SetWidth(450)
CdbSearchGui.settings.buttons[1]:SetHeight(20)
CdbSearchGui.settings.buttons[1]:SetFont("Fonts\\FRIZQT__.TTF", 10)
CdbSearchGui.settings.buttons[1]:SetTextColor(1,1,1,1)
CdbSearchGui.settings.buttons[1]:SetNormalTexture(nil)
CdbSearchGui.settings.buttons[1]:SetPushedTexture(nil)
CdbSearchGui.settings.buttons[1]:SetHighlightTexture(nil)
CdbSearchGui.settings.buttons[1]:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings.buttons[1]:SetBackdropColor(1,1,1,.10)
CdbSearchGui.settings.buttons[1]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText(CdbGetSetting("dbMode")..
                            "\n\n|cffffffff"..
                            "When enabled, this option prevents ClassicDB from cleaning quests\n"..
                            "for other classes and the opposite faction from the quest DB.\n"..
                            "Not recommended for normal users, as it adds many unatainable\n"..
                            "quest starts to the map.|r");
    CdbTooltip:Show();
end)
CdbSearchGui.settings.buttons[1]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.10)
    CdbTooltip:Hide()
end)
CdbSearchGui.settings.buttons[1].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[1],"UICheckButtonTemplate")
CdbSearchGui.settings.buttons[1].enabled:SetPoint("RIGHT", -25, 0)
CdbSearchGui.settings.buttons[1].enabled:SetWidth(20)
CdbSearchGui.settings.buttons[1].enabled:SetHeight(20)
CdbSearchGui.settings.buttons[1].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.dbMode ~= true) then
        CdbSearchGui.settings.buttons[1].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[1].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[1].enabled:SetScript("OnClick", function(self)
    CdbSwitchSetting("dbMode");
    if (CdbSettings.dbMode ~= true) then
        CdbSearchGui.settings.buttons[1].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[1].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[2] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
CdbSearchGui.settings.buttons[2]:SetPoint("TOP", 0, -2*21+11)
CdbSearchGui.settings.buttons[2]:SetWidth(450)
CdbSearchGui.settings.buttons[2]:SetHeight(20)
CdbSearchGui.settings.buttons[2]:SetFont("Fonts\\FRIZQT__.TTF", 10)
CdbSearchGui.settings.buttons[2]:SetTextColor(1,1,1,1)
CdbSearchGui.settings.buttons[2]:SetNormalTexture(nil)
CdbSearchGui.settings.buttons[2]:SetPushedTexture(nil)
CdbSearchGui.settings.buttons[2]:SetHighlightTexture(nil)
CdbSearchGui.settings.buttons[2]:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings.buttons[2]:SetBackdropColor(1,1,1,.05)
CdbSearchGui.settings.buttons[2]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText(CdbGetSetting("questStarts")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows notes for all quests starts\n"..
                            "in the currently displayed zone. If it doesn't load immediately\n"..
                            "reopen the map.|r");
    CdbTooltip:Show();
end)
CdbSearchGui.settings.buttons[2]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    CdbTooltip:Hide()
end)
CdbSearchGui.settings.buttons[2].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[2],"UICheckButtonTemplate")
CdbSearchGui.settings.buttons[2].enabled:SetPoint("RIGHT", -25, 0)
CdbSearchGui.settings.buttons[2].enabled:SetWidth(20)
CdbSearchGui.settings.buttons[2].enabled:SetHeight(20)
CdbSearchGui.settings.buttons[2].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.questStarts ~= true) then
        CdbSearchGui.settings.buttons[2].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[2].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[2].enabled:SetScript("OnClick", function(self)
    CdbSwitchSetting("questStarts");
    if (CdbSettings.questStarts ~= true) then
        CdbSearchGui.settings.buttons[2].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[2].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[3] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
CdbSearchGui.settings.buttons[3]:SetPoint("TOP", 0, -3*21+11)
CdbSearchGui.settings.buttons[3]:SetWidth(450)
CdbSearchGui.settings.buttons[3]:SetHeight(20)
CdbSearchGui.settings.buttons[3]:SetFont("Fonts\\FRIZQT__.TTF", 10)
CdbSearchGui.settings.buttons[3]:SetTextColor(1,1,1,1)
CdbSearchGui.settings.buttons[3]:SetNormalTexture(nil)
CdbSearchGui.settings.buttons[3]:SetPushedTexture(nil)
CdbSearchGui.settings.buttons[3]:SetHighlightTexture(nil)
CdbSearchGui.settings.buttons[3]:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings.buttons[3]:SetBackdropColor(1,1,1,.05)
CdbSearchGui.settings.buttons[3]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText(CdbGetSetting("questStarts")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows notes for all quests starts\n"..
                            "in the currently displayed zone. If it doesn't load immediately\n"..
                            "reopen the map.|r");
    CdbTooltip:Show();
end)
CdbSearchGui.settings.buttons[3]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    CdbTooltip:Hide()
end)
CdbSearchGui.settings.buttons[3].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[3],"UICheckButtonTemplate")
CdbSearchGui.settings.buttons[3].enabled:SetPoint("RIGHT", -25, 0)
CdbSearchGui.settings.buttons[3].enabled:SetWidth(20)
CdbSearchGui.settings.buttons[3].enabled:SetHeight(20)
CdbSearchGui.settings.buttons[3].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.questStarts ~= true) then
        CdbSearchGui.settings.buttons[3].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[3].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[3].enabled:SetScript("OnClick", function(self)
    CdbSwitchSetting("questStarts");
    if (CdbSettings.questStarts ~= true) then
        CdbSearchGui.settings.buttons[3].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[3].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[4] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
CdbSearchGui.settings.buttons[4]:SetPoint("TOP", 0, -4*21+11)
CdbSearchGui.settings.buttons[4]:SetWidth(450)
CdbSearchGui.settings.buttons[4]:SetHeight(20)
CdbSearchGui.settings.buttons[4]:SetFont("Fonts\\FRIZQT__.TTF", 10)
CdbSearchGui.settings.buttons[4]:SetTextColor(1,1,1,1)
CdbSearchGui.settings.buttons[4]:SetNormalTexture(nil)
CdbSearchGui.settings.buttons[4]:SetPushedTexture(nil)
CdbSearchGui.settings.buttons[4]:SetHighlightTexture(nil)
CdbSearchGui.settings.buttons[4]:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings.buttons[4]:SetBackdropColor(1,1,1,.10)
CdbSearchGui.settings.buttons[4]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText(CdbGetSetting("filterReqLevel")..
                            "\n\n|cffffffff"..
                            "When enabled, this option prevents quest starts from being marked\n"..
                            "if the player doesn't meet the minimum level requirements.|r");
    CdbTooltip:Show();
end)
CdbSearchGui.settings.buttons[4]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.10)
    CdbTooltip:Hide()
end)
CdbSearchGui.settings.buttons[4].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[4],"UICheckButtonTemplate")
CdbSearchGui.settings.buttons[4].enabled:SetPoint("RIGHT", -25, 0)
CdbSearchGui.settings.buttons[4].enabled:SetWidth(20)
CdbSearchGui.settings.buttons[4].enabled:SetHeight(20)
CdbSearchGui.settings.buttons[4].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.filterReqLevel ~= true) then
        CdbSearchGui.settings.buttons[4].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[4].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[4].enabled:SetScript("OnClick", function(self)
    CdbSwitchSetting("filterReqLevel");
    if (CdbSettings.filterReqLevel ~= true) then
        CdbSearchGui.settings.buttons[4].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[4].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[5] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
CdbSearchGui.settings.buttons[5]:SetPoint("TOP", 0, -5*21+11)
CdbSearchGui.settings.buttons[5]:SetWidth(450)
CdbSearchGui.settings.buttons[5]:SetHeight(20)
CdbSearchGui.settings.buttons[5]:SetFont("Fonts\\FRIZQT__.TTF", 10)
CdbSearchGui.settings.buttons[5]:SetTextColor(1,1,1,1)
CdbSearchGui.settings.buttons[5]:SetNormalTexture(nil)
CdbSearchGui.settings.buttons[5]:SetPushedTexture(nil)
CdbSearchGui.settings.buttons[5]:SetHighlightTexture(nil)
CdbSearchGui.settings.buttons[5]:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings.buttons[5]:SetBackdropColor(1,1,1,.05)
CdbSearchGui.settings.buttons[5]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText(CdbGetSetting("questIds")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows the quest ID in the quest start tooltips.|r");
                            -- TODO: Update text once this setting has been fixed. Quest IDs in quest start tooltips are needed for their context menu.
    CdbTooltip:Show();
end)
CdbSearchGui.settings.buttons[5]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    CdbTooltip:Hide()
end)
CdbSearchGui.settings.buttons[5].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[5],"UICheckButtonTemplate")
CdbSearchGui.settings.buttons[5].enabled:SetPoint("RIGHT", -25, 0)
CdbSearchGui.settings.buttons[5].enabled:SetWidth(20)
CdbSearchGui.settings.buttons[5].enabled:SetHeight(20)
CdbSearchGui.settings.buttons[5].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.questIds ~= true) then
        CdbSearchGui.settings.buttons[5].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[5].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[5].enabled:SetScript("OnClick", function(self)
    CdbSwitchSetting("questIds");
    if (CdbSettings.questIds ~= true) then
        CdbSearchGui.settings.buttons[5].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[5].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[6] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
CdbSearchGui.settings.buttons[6]:SetPoint("TOP", 0, -6*21+11)
CdbSearchGui.settings.buttons[6]:SetWidth(450)
CdbSearchGui.settings.buttons[6]:SetHeight(20)
CdbSearchGui.settings.buttons[6]:SetFont("Fonts\\FRIZQT__.TTF", 10)
CdbSearchGui.settings.buttons[6]:SetTextColor(1,1,1,1)
CdbSearchGui.settings.buttons[6]:SetNormalTexture(nil)
CdbSearchGui.settings.buttons[6]:SetPushedTexture(nil)
CdbSearchGui.settings.buttons[6]:SetHighlightTexture(nil)
CdbSearchGui.settings.buttons[6]:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings.buttons[6]:SetBackdropColor(1,1,1,.10)
CdbSearchGui.settings.buttons[6]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText(CdbGetSetting("reqLevel")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows the required level in the quest start tooltips.|r");
    CdbTooltip:Show();
end)
CdbSearchGui.settings.buttons[6]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.10)
    CdbTooltip:Hide()
end)
CdbSearchGui.settings.buttons[6].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[6],"UICheckButtonTemplate")
CdbSearchGui.settings.buttons[6].enabled:SetPoint("RIGHT", -25, 0)
CdbSearchGui.settings.buttons[6].enabled:SetWidth(20)
CdbSearchGui.settings.buttons[6].enabled:SetHeight(20)
CdbSearchGui.settings.buttons[6].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.reqLevel ~= true) then
        CdbSearchGui.settings.buttons[6].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[6].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[6].enabled:SetScript("OnClick", function(self)
    CdbSwitchSetting("reqLevel");
    if (CdbSettings.reqLevel ~= true) then
        CdbSearchGui.settings.buttons[6].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[6].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[7] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
CdbSearchGui.settings.buttons[7]:SetPoint("TOP", 0, -7*21+11)
CdbSearchGui.settings.buttons[7]:SetWidth(450)
CdbSearchGui.settings.buttons[7]:SetHeight(20)
CdbSearchGui.settings.buttons[7]:SetFont("Fonts\\FRIZQT__.TTF", 10)
CdbSearchGui.settings.buttons[7]:SetTextColor(1,1,1,1)
CdbSearchGui.settings.buttons[7]:SetNormalTexture(nil)
CdbSearchGui.settings.buttons[7]:SetPushedTexture(nil)
CdbSearchGui.settings.buttons[7]:SetHighlightTexture(nil)
CdbSearchGui.settings.buttons[7]:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings.buttons[7]:SetBackdropColor(1,1,1,.05)
CdbSearchGui.settings.buttons[7]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText(CdbGetSetting("item_item")..
                            "\n\n|cffffffff"..
                            "When enabled, this option enables showing item drops from other items.|r\n"..
                            "|cFFFF1A1A!WARNING! This option might be unstable!\n"..
                            "It is recommended to leave it turned of if not needed.|r");
    CdbTooltip:Show();
end)
CdbSearchGui.settings.buttons[7]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    CdbTooltip:Hide()
end)
CdbSearchGui.settings.buttons[7].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[7],"UICheckButtonTemplate")
CdbSearchGui.settings.buttons[7].enabled:SetPoint("RIGHT", -25, 0)
CdbSearchGui.settings.buttons[7].enabled:SetWidth(20)
CdbSearchGui.settings.buttons[7].enabled:SetHeight(20)
CdbSearchGui.settings.buttons[7].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.item_item ~= true) then
        CdbSearchGui.settings.buttons[7].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[7].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[7].enabled:SetScript("OnClick", function(self)
    CdbSwitchSetting("item_item");
    if (CdbSettings.item_item ~= true) then
        CdbSearchGui.settings.buttons[7].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[7].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[8] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
CdbSearchGui.settings.buttons[8]:SetPoint("TOP", 0, -8*21+11)
CdbSearchGui.settings.buttons[8]:SetWidth(450)
CdbSearchGui.settings.buttons[8]:SetHeight(20)
CdbSearchGui.settings.buttons[8]:SetFont("Fonts\\FRIZQT__.TTF", 10)
CdbSearchGui.settings.buttons[8]:SetTextColor(1,1,1,1)
CdbSearchGui.settings.buttons[8]:SetNormalTexture(nil)
CdbSearchGui.settings.buttons[8]:SetPushedTexture(nil)
CdbSearchGui.settings.buttons[8]:SetHighlightTexture(nil)
CdbSearchGui.settings.buttons[8]:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings.buttons[8]:SetBackdropColor(1,1,1,.10)
CdbSearchGui.settings.buttons[8]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText(CdbGetSetting("waypoints")..
                            "\n\n|cffffffff"..
                            "When enabled, mob waypoints are shown on the map.\n"..
                            "Due to script spawns not yet being included in the DB\n"..
                            "this can be helpful in finding some special mobs.|r");
    CdbTooltip:Show();
end)
CdbSearchGui.settings.buttons[8]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.10)
    CdbTooltip:Hide()
end)
CdbSearchGui.settings.buttons[8].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[8],"UICheckButtonTemplate")
CdbSearchGui.settings.buttons[8].enabled:SetPoint("RIGHT", -25, 0)
CdbSearchGui.settings.buttons[8].enabled:SetWidth(20)
CdbSearchGui.settings.buttons[8].enabled:SetHeight(20)
CdbSearchGui.settings.buttons[8].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.waypoints ~= true) then
        CdbSearchGui.settings.buttons[8].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[8].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[8].enabled:SetScript("OnClick", function(self)
    CdbSwitchSetting("waypoints");
    if (CdbSettings.waypoints ~= true) then
        CdbSearchGui.settings.buttons[8].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[8].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[9] = CreateFrame("Button","mybutton",CdbSearchGui.settings,"UIPanelButtonTemplate")
CdbSearchGui.settings.buttons[9]:SetPoint("TOP", 0, -9*21+11)
CdbSearchGui.settings.buttons[9]:SetWidth(450)
CdbSearchGui.settings.buttons[9]:SetHeight(20)
CdbSearchGui.settings.buttons[9]:SetFont("Fonts\\FRIZQT__.TTF", 10)
CdbSearchGui.settings.buttons[9]:SetTextColor(1,1,1,1)
CdbSearchGui.settings.buttons[9]:SetNormalTexture(nil)
CdbSearchGui.settings.buttons[9]:SetPushedTexture(nil)
CdbSearchGui.settings.buttons[9]:SetHighlightTexture(nil)
CdbSearchGui.settings.buttons[9]:SetBackdrop(backdrop_noborder)
CdbSearchGui.settings.buttons[9]:SetBackdropColor(1,1,1,.05)
CdbSearchGui.settings.buttons[9]:SetScript("OnEnter", function(self)
    this:SetBackdropColor(1,1,1,.25)
    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
    CdbTooltip:ClearLines();
    CdbTooltip:SetText(CdbGetSetting("auto_plot")..
                            "\n\n|cffffffff"..
                            "When enabled, this option shows notes for all quests in the log.\n"..
                            "It will update automatically every time there is a quest\n"..
                            "event, like looting. If you experience lags when finishing\n"..
                            "a quest objective, disable and use the 'Show all notes'\n"..
                            "button as long as the quest drawing too many notes is in\n"..
                            "in your quest log.|r");
    CdbTooltip:Show();
end)
CdbSearchGui.settings.buttons[9]:SetScript("OnLeave", function(self)
    this:SetBackdropColor(1,1,1,.05)
    CdbTooltip:Hide()
end)
CdbSearchGui.settings.buttons[9].enabled = CreateFrame("CheckButton","mycheckbutton",CdbSearchGui.settings.buttons[9],"UICheckButtonTemplate")
CdbSearchGui.settings.buttons[9].enabled:SetPoint("RIGHT", -25, 0)
CdbSearchGui.settings.buttons[9].enabled:SetWidth(20)
CdbSearchGui.settings.buttons[9].enabled:SetHeight(20)
CdbSearchGui.settings.buttons[9].enabled:SetScript("OnShow", function(self)
    if (CdbSettings.auto_plot ~= true) then
        CdbSearchGui.settings.buttons[9].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[9].enabled:SetChecked(true);
    end
end)
CdbSearchGui.settings.buttons[9].enabled:SetScript("OnClick", function(self)
    CdbSwitchSetting("auto_plot");
    if (CdbSettings.auto_plot ~= true) then
        CdbSearchGui.settings.buttons[9].enabled:SetChecked(false);
    else
        CdbSearchGui.settings.buttons[9].enabled:SetChecked(true);
    end
end)
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
                    CdbSearchGui.quest.buttons[questCount].questObjectives = "";
                    local rest = q[DB_OBJECTIVES];
                    while string.len(rest) > 100 do
                        CdbSearchGui.quest.buttons[questCount].questObjectives = CdbSearchGui.quest.buttons[questCount].questObjectives..string.sub(rest, 1, 99).."-\n";
                        rest = string.sub(rest, 100)
                    end
                    CdbSearchGui.quest.buttons[questCount].questObjectives = CdbSearchGui.quest.buttons[questCount].questObjectives..rest;
                end
                CdbSearchGui.quest.buttons[questCount]:SetText("|cffffcc00["..q[DB_LEVEL].."] |Hquest:0:0:0:0|h["..name.."]|h|r|r (ID:"..id..")")
                CdbSearchGui.quest.buttons[questCount]:SetScript("OnEnter", function(self)
                    this:SetBackdropColor(1,1,1,.25)
                    if this.questObjectives then
                        CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                        CdbTooltip:ClearLines();
                        CdbTooltip:SetText(this:GetText().."\n|cFFffffffObjectives:|r\n|cFFa6a6a6"..this.questObjectives.."|r");
                        CdbTooltip:Show();
                    end
                end)
                CdbSearchGui.quest.buttons[questCount]:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                    if this.questObjectives then CdbTooltip:Hide(); end
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
                    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                    CdbTooltip:ClearLines();
                    CdbTooltip:SetText("Mark as Favourite\n\n|cffffffffFavourites are shown when the search bar is empty.|r");
                    CdbTooltip:Show();
                end)
                CdbSearchGui.quest.buttons[questCount].fav:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                    CdbTooltip:Hide();
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
                    CdbTooltip:SetOwner(this, "ANCHOR_TOPLEFT");
                    CdbTooltip:ClearLines();
                    CdbTooltip:SetText("Mark as finished\n\n|cffffffffQuests that are marked as finished do not appear when Quest Starts are plotted.\nTo refresh your Quest Start display, clean the map and then reenable Quest Starts.|r");
                    CdbTooltip:Show();
                end)
                CdbSearchGui.quest.buttons[questCount].finished:SetScript("OnLeave", function(self)
                    if this.even == true then
                        this:SetBackdropColor(1,1,1,.05)
                    else
                        this:SetBackdropColor(1,1,1,.10)
                    end
                    CdbTooltip:Hide();
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
