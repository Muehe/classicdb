-- clear variables
ShaguDB_QuestZoneInfo = {}; -- unused?
cMark = "mk1";
--[[
0 = off
1 = standard debug notes
2 = most function calls
4 = event debug
8 = advanced
--]]
ShaguDB_Debug = 7;
-- This table is used to prepare new notes.
-- It holds npcs, objects, items and marked area triggers.
ShaguDB_PREPARE = {{},{},{},{}};
-- This table holds a copy of the above table, in case it gets updated. Maybe redundant at the moment.
ShaguDB_MARKED = {{},{},{},{}};
-- List of marked zones (Format: ["zoneName"] = true/false)
ShaguDB_MARKED_ZONES = {};
-- Currently used zone for CycleMarkedZones().
ShaguDB_MARKED_ZONE = "";
-- Which zones have quest starts marked.
ShaguDB_QUEST_START_ZONES = {};
-- Used to prepare notes for being sent to Cartographer.
ShaguDB_MAP_NOTES = {};
-- Number of current notes gets saved here (not counting quest starts).
ShaguDB_Notes = 0;
-- This variable is used to achieve different behaviour for quest start notes.
ShaguDB_InEvent = false;
-- These variables are used to determine types of Quest Log events (accept/abandon/finish).
ShaguDB_QuestLogFootprint = {{},{}};
ShaguDB_QuestAbandon = '';

-- DB keys
DB_NAME, DB_NPC, NOTE_TITLE = 1, 1, 1;
DB_STARTS, DB_OBJ, NOTE_COMMENT, DB_MIN_LEVEL_HEALTH = 2, 2, 2, 2;
DB_ENDS, DB_ITM, NOTE_ICON, DB_MAX_LEVEL_HEALTH = 3, 3, 3, 3;
DB_MIN_LEVEL, DB_ZONES, DB_VENDOR, DB_OBJ_SPAWNS, DB_TRIGGER_MARKED = 4, 4, 4, 4, 4;
DB_LEVEL, DB_ITM_QUEST_REW = 5, 5;
DB_REQ_RACE, DB_RANK, DB_ITM_NAME = 6, 6, 6;
DB_REQ_CLASS, DB_NPC_SPAWNS = 7, 7;
DB_OBJECTIVES, DB_NPC_WAYPOINTS = 8, 8;
DB_TRIGGER, DB_ZONE = 9, 9;
DB_REQ_NPC_OR_OBJ_OR_ITM, DB_NPC_STARTS = 10, 10;
DB_SRC_ITM, DB_NPC_ENDS = 11, 11;

-- functions for the event handeling and control frame

function ShaguDB_OnMouseDown(arg1)
    if (arg1 == "LeftButton") then
        ShaguDB_Frame:StartMoving();
    end
end -- OnMouseDown(arg1)

function ShaguDB_OnMouseUp(arg1)
    if (arg1 == "LeftButton") then
        ShaguDB_Frame:StopMovingOrSizing();
    end
end -- OnMouseUp(arg1)

function ShaguDB_OnFrameShow()
    --
end -- OnFrameShow()

function ShaguDB_Event(event, ...)
    ShaguDB_Debug_Print(4, "Event() called", event, arg1, arg2, arg3);
    if (event == "PLAYER_LOGIN") then
        if (Cartographer_Notes ~= nil) then
            ShaguDBDB = {}; ShaguDBDBH = {};
            Cartographer_Notes:RegisterNotesDatabase("ShaguDB",ShaguDBDB,ShaguDBDBH);
            ShaguDB_Debug_Print(1, "ShaguDB: Cartographer Database Registered.");
        end

        -- load symbols
        Cartographer_Notes:RegisterIcon("NPC", {
            text = "NPC",
            path = "Interface\\WorldMap\\WorldMapPartyIcon",
            width = 12,
            height = 12,
        })
        Cartographer_Notes:RegisterIcon("Waypoint", {
            text = "Waypoint",
            path = "Interface\\WorldMap\\WorldMapPlayerIcon",
            width = 12,
            height = 12,
        })
        Cartographer_Notes:RegisterIcon("QuestionMark", {
            text = "QuestionMark",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\complete",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("ExclamationMark", {
            text = "ExclamationMark",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\available",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("AreaTrigger", {
            text = "AreaTrigger",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\event",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("Vendor", {
            text = "Vendor",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\vendor",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("Object", {
            text = "Vendor",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\icon_object",
            width = 16,
            height = 16,
        })

        -- Switched 3 and 7 for better contrast of colors follwing each other
        Cartographer_Notes:RegisterIcon("mk1", {
            text = "Mark 1",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\mk1",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("mk2", {
            text = "Mark 2",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\mk2",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("mk3", {
            text = "Mark 3",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\mk7",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("mk4", {
            text = "Mark 4",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\mk4",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("mk5", {
            text = "Mark 5",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\mk5",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("mk6", {
            text = "Mark 6",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\mk6",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("mk7", {
            text = "Mark 7",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\mk3",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("mk8", {
            text = "Mark 8",
            path = "Interface\\AddOns\\ShaguDB\\symbols\\mk8",
            width = 16,
            height = 16,
        })

        if ShaguMinimapEnabled == nil then
          ShaguMinimapEnabled = true
        elseif ShaguMinimapEnabled == false then
          SDBG.minimapButton:Hide()
        end

        if (ShaguDB_FinishedQuests == nil) then
            ShaguDB_FinishedQuests = {};
        end
        if (ShaguDB_Settings == nil) then
            ShaguDB_Settings = {};
        end
        ShaguDB_Settings["auto_plot"] = false;
        ShaguDB_Settings["item_item"] = false;
        if (ShaguDB_Settings["minDropChance"] == nil) then
            ShaguDB_Settings["minDropChance"] = 0;
        end
        if (ShaguDB_Settings["dbMode"] == nil) then
            ShaguDB_Settings["dbMode"] = false;
        end
        if (ShaguDB_Settings["waypoints"] == nil) then
            ShaguDB_Settings["waypoints"] = false;
        end
        if (ShaguDB_Settings["questStarts"] == nil) then
            ShaguDB_Settings["questStarts"] = false;
        end
        if (ShaguDB_Settings["filterReqLevel"] == nil) then
            ShaguDB_Settings["filterReqLevel"] = true;
        end
        if (ShaguDB_Settings["questIds"] == nil) then
            ShaguDB_Settings["questIds"] = true;
        end
        if (ShaguDB_Settings["reqLevel"] == nil) then
            ShaguDB_Settings["reqLevel"] = true;
        end
        if (ShaguDB_Settings["player"] == nil) then
            ShaguDB_Settings["player"] = UnitName("player");
        end
        if (ShaguDB_Settings["race"] == nil) then
            ShaguDB_Settings["race"] = UnitRace("player");
        end
        if (ShaguDB_Settings["sex"] == nil) then
            local temp = UnitSex("player");
            if (temp == 3) then
                ShaguDB_Settings["sex"] = "Female";
            elseif (temp == 2) then
                ShaguDB_Settings["sex"] = "Male";
            else
                ShaguDB_Settings["sex"] = nil;
            end
        end
        if (ShaguDB_Settings["class"] == nil) then
            ShaguDB_Settings["class"] = UnitClass("player");
        end
        if (ShaguDB_Settings["faction"] == nil) then
            local temp = UnitFactionGroup("player");
            if (temp) then
                ShaguDB_Settings["faction"] = temp;
            end
        end
        if (ShaguDB_Settings.faction == "Alliance" and not ShaguDB_Settings.dbMode) then
            deleteFaction("H");
            ShaguDB_Print("Horde data cleared.");
        elseif (ShaguDB_Settings.faction == "Horde" and not ShaguDB_Settings.dbMode) then
            deleteFaction("A");
            ShaguDB_Print("Alliance data cleared.");
        else
            ShaguDB_Print("DB Mode active, no quest data cleared.");
        end
        if not ShaguDB_Settings.dbMode then
            deleteClasses();
        end
        fillQuestLookup();
        ShaguDB_Frame:Show();
        ShaguDB_Print("ShaguDB Loaded.");
    elseif (event == "WORLD_MAP_UPDATE") and (WorldMapFrame:IsVisible()) and (ShaguDB_Settings.questStarts) then
        ShaguDB_Debug_Print(4, "    ", zone);
        ShaguDB_InEvent = true;
        ShaguDB_GetQuestStartNotes();
        ShaguDB_InEvent = false;
    elseif (event == "QUEST_LOG_UPDATE") then
        local footprint = ShaguDB_GetQuestLogFootprint(); -- {footprintString, questIdTable}
        local count = GetNumQuestLogEntries();
        -- NOTE: maybe ShaguDB_CompareTables(ShaguDB_QuestLogFootprint[2], footprint[2]) would catch more edge cases, making footprintString obsolete
        if (ShaguDB_QuestLogFootprint[1] ~= footprint[1]) then
            local added = 0;
            for k, v in pairs(footprint[2]) do
                if ShaguDB_QuestLogFootprint[2][k] == nil then
                    added = k;
                end
            end
            if added ~= 0 then
                ShaguDB_Debug_Print(4, "    Quest accepted", added);
                ShaguDB_FinishedQuests[added] = false;
            end
            local removed = 0;
            for k, v in pairs(ShaguDB_QuestLogFootprint[2]) do
                if footprint[2][k] == nil then
                    removed = k;
                end
            end
            if removed ~= 0 then
                if ShaguDB_FinishedQuests[removed] == false then
                    ShaguDB_Debug_Print(4, "    Quest finished", removed);
                    ShaguDB_FinishedQuests[removed] = true;
                else
                    ShaguDB_Debug_Print(4, "    Quest abandoned", removed);
                    ShaguDB_FinishedQuests[removed] = nil;
                end
            end
            if (ShaguDB_Settings.auto_plot) then
                ShaguDB_InEvent = true;
                ShaguDB_PlotAllQuests();
                ShaguDB_InEvent = false;
            end
        end
        ShaguDB_Debug_Print(4, "    footprint", {footprint, count, change});
    elseif (event == "QUEST_PROGRESS") then
        local footprint = ShaguDB_GetQuestLogFootprint();
        local count = GetNumQuestLogEntries();
        ShaguDB_Debug_Print(4, "    footprint", {footprint, count});
        ShaguDB_QuestLogFootprint = footprint;
    elseif (event == "UNIT_QUEST_LOG_CHANGED") then
        local footprint = ShaguDB_GetQuestLogFootprint();
        local count = GetNumQuestLogEntries();
        ShaguDB_Debug_Print(4, "    footprint", {ShaguDB_QuestLogFootprint, count});
        if ((ShaguDB_Settings.auto_plot) and (ShaguDB_QuestLogFootprint[1] ~= footprint[1])) then
            ShaguDB_InEvent = true;
            ShaguDB_PlotAllQuests();
            ShaguDB_InEvent = false;
        end
        ShaguDB_QuestLogFootprint = footprint;
    elseif (event == "QUEST_FINISHED") then
        local footprint = ShaguDB_GetQuestLogFootprint();
        local count = GetNumQuestLogEntries();
        ShaguDB_Debug_Print(4, "    footprint", {footprint, count});
        local count = GetNumQuestLogEntries();
        local questLogId = 1;
        local finishingTitle = GetTitleText()
        for i in range(1, count) do
            local questLogTitle, _ = GetQuestLogTitle(i)
            if questLogTitle == finishingTitle then
                questLogId = i;
                break;
            end
        end
        ShaguDB_Debug_Print(4, "    ", questLogId);
    end
end -- Event(event, arg1)

function range(from, to, step)
  step = step or 1
  return function(_, lastvalue)
    local nextvalue = lastvalue + step
    if step > 0 and nextvalue <= to or step < 0 and nextvalue >= to or
       step == 0
    then
      return nextvalue
    end
  end, nil, from - step
end

 -- Called from xml
function ShaguDB_Init()
    -- Register Events (some unused)
    this:RegisterEvent("PLAYER_LOGIN");
    this:RegisterEvent("QUEST_WATCH_UPDATE");
    this:RegisterEvent("QUEST_LOG_UPDATE");
    this:RegisterEvent("QUEST_PROGRESS");
    this:RegisterEvent("QUEST_FINISHED");
    this:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
    this:RegisterEvent("WORLD_MAP_UPDATE");

    -- Hook buttons for abandoning quests.
    -- Credit for this approach goes to Questie: https://github.com/AeroScripts/QuestieDev
    QuestAbandonOnAccept = StaticPopupDialogs["ABANDON_QUEST"].OnAccept;
    StaticPopupDialogs["ABANDON_QUEST"].OnAccept = function()
        ShaguDB_QuestAbandon = GetAbandonQuestName();
        ShaguDB_Debug_Print(4, "Abandon", ShaguDB_QuestAbandon);
        QuestAbandonOnAccept();
    end
    QuestAbandonWithItemsOnAccept = StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept;
    StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept = function()
        ShaguDB_QuestAbandon = GetAbandonQuestName();
        ShaguDB_Debug_Print(4, "Abandon", ShaguDB_QuestAbandon);
        QuestAbandonOnAccept();
    end

    -- Create the /shagu SlashCommand
    SLASH_SHAGU1 = "/shagu";
    SlashCmdList["SHAGU"] = function(input, editbox)
        local params = {};
        if (input == "" or input == "help" or input == nil) then
            ShaguDB_Print("|cff33ff88ShaguDB|cffffffff oooVersionooo |cff00ccff[" .. UnitFactionGroup("player") .. "]|cffaaaaaa [oooLocaleooo]");
            ShaguDB_Print("Available Commands:");
            ShaguDB_Print("/shagu help |cffaaaaaa This help.");
            ShaguDB_Print("/shagu spawn <npc name> |cffaaaaaa Show NPC location on map.");
            ShaguDB_Print("/shagu obj <object name> |cffaaaaaa Show object location on map.");
            ShaguDB_Print("/shagu item <item name> |cffaaaaaa Show item drop info on map (includes vendors).");
            ShaguDB_Print("/shagu min [0, 101] |cffaaaaaa Minimum drop chance for items. 0 shows all, 101 none.");
            ShaguDB_Print("/shagu starts |cffaaaaaa Toggle: Automatically show quest starts on changing map.");
            ShaguDB_Print("/shagu quests <zone name> |cffaaaaaa - Show quest starts for a zone (the current one if no zone name is given).");
            ShaguDB_Print("/shagu hide <quest ID> |cffaaaaaa Prevent the given quest ID from being plotted to quest starts.");
            ShaguDB_Print("/shagu quest <quest name | quest ID> |cffaaaaaa - Show all points for quest, by either name or ID (name is case-sensitiv).");
            ShaguDB_Print("/shagu clean |cffaaaaaa - Clean the map. Disable automatic quest start and objective plotting.");
            ShaguDB_Print("/shagu minimap |cffaaaaaa - Toggle: Minimap icon.");
            ShaguDB_Print("/shagu auto |cffaaaaaa Toggle: Automatically plot uncompleted objectives on map.");
            ShaguDB_Print("/shagu waypoint |cffaaaaaa Toggle: Plot waypoints on map.");
            ShaguDB_Print("/shagu db |cffaaaaaa - Show database interface.");
            ShaguDB_Print("/shagu reset |cffaaaaaa Reset positon of the Interface.");
            ShaguDB_Print("/shagu clear |cffaaaaaa !THIS RELOADS THE UI! Delete ShaguDB Settings.");
            DEFAULT_CHAT_FRAME:AddMessage("\n");
        end

        local commandlist = {};
        local command;

        for command in string.gfind(input, "[^ ]+") do
            table.insert(commandlist, command);
        end

        arg1 = commandlist[1];
        arg2 = "";

        -- handle whitespace mob- and item names correctly
        for i in commandlist do
            if (i ~= 1) then
                arg2 = arg2 .. commandlist[i];
                if (commandlist[i+1] ~= nil) then
                    arg2 = arg2 .. " ";
                end
            end
        end

        -- argument: item
        if (arg1 == "item") then
            local itemName = arg2;
            if (string.sub(itemName,1,1) == "|") then
                _, _, _, itemName = string.find(itemName, "^|c%x+|H(.+)|h%[(.+)%]");
            end
            ShaguDB_Print("Drops for: "..itemName);
            if (itemName and itemName ~= "") then
                if ((itemLookup[itemName]) and (itemData[itemLookup[itemName]])) then
                    ShaguDB_MarkForPlotting(DB_ITM, itemName, itemName, "", 0);
                    ShaguDB_ShowMap();
                end
            end
        elseif (arg1 == "vendor") then
            local itemName = arg2;
            ShaguDB_MAP_NOTES = {};
            ShaguDB_PrepareItemNotes(itemName, "Vendors for: "..itemName, "Sells: "..itemName, "Vendor", {DB_VENDOR});
            ShaguDB_ShowMap();
        elseif (arg1 == "spawn") then
            local monsterName = arg2;
            if (monsterName and monsterName ~= "") then
                ShaguDB_Print("Location for: "..monsterName);
                if (monsterName ~= nil) then
                    npcID = ShaguDB_GetNPCID(monsterName)
                    if (npcData[npcID] ~= nil) then
                        zoneName = zoneData[npcData[npcID][DB_ZONE]];
                        if (zoneName == nil) then zoneName = npcData[npcID][DB_ZONE]; end
                        ShaguDB_Print("    Zone: " .. zoneName);
                        if (ShaguDB_MarkForPlotting(DB_NPC, monsterName, monsterName, ShaguDB_GetNPCStatsComment(monsterName, true), 0)) then
                            ShaguDB_ShowMap();
                        end
                    else
                        ShaguDB_Print("No location found.");
                    end
                end
            end
        elseif (arg1 == "quests") then
            local zoneName = arg2;
            if(zoneName == "")then
                zoneName = GetZoneText();
            end
            ShaguDB_MAP_NOTES = {};
            ShaguDB_GetQuestStartNotes(zoneName);
            ShaguDB_ShowMap();
        elseif (arg1 == "quest") then
            local questTitle = arg2;
            ShaguDB_MAP_NOTES = {};
            local qIDs;
            if type(tonumber(questTitle)) == "number" then
                qIDs = tonumber(questTitle);
            elseif type(questTitle) == "string" then
                qIDs = ShaguDB_GetQuestIDs(questTitle);
            end
            if type(qIDs) == "number" then
                ShaguDB_GetQuestNotesById(qIDs);
                ShaguDB_NextCMark();
            elseif type(qIDs) == "table" then
                for _, qID in pairs(qIDs) do
                    ShaguDB_GetQuestNotesById(qID);
                    ShaguDB_NextCMark();
                end
            end
            ShaguDB_ShowMap();
        elseif (arg1 == "minimap") then
            if (SDBG.minimapButton:IsShown()) then
                SDBG.minimapButton:Hide()
                ShaguMinimapEnabled = false
            else
                SDBG.minimapButton:Show()
                ShaguMinimapEnabled = true
            end
        elseif (arg1 == "db") then
            if (SDBG:IsShown()) then
                SDBG:Hide()
            else
                SDBG:Show()
            end
        elseif (arg1 == "min") then
            local number = tonumber(arg2);
            if number then
                local value = abs(number);
                if value > 101 then
                    value = 101;
                end
                ShaguDB_Settings.minDropChance = value;
                ShaguDB_Print("Minimum Drop Chance set to: "..value.."%");
            else
                ShaguDB_Print("Minimum Drop Chance is: "..ShaguDB_Settings.minDropChance.."%");
            end
        elseif (arg1 == "obj") then
            local objName = string.sub(input, 5);
            if (objName ~= "") then
                ShaguDB_Print("Locations for: "..objName);
                if (objName ~= nil) then
                    if (ShaguDB_MarkForPlotting(DB_OBJ, objName, objName, "This object can be found here", 0)) then
                        ShaguDB_ShowMap();
                    else
                        ShaguDB_Print("No locations found.");
                    end
                end
            end
        elseif (arg1 == "clean") then
            ShaguDB_DoCleanMap();
        elseif (arg1 == "auto") then
            ShaguDB_SwitchSetting("auto_plot");
        elseif (arg1 == "waypoint") then
            ShaguDB_SwitchSetting("waypoints");
        elseif (arg1 == "starts") then
            ShaguDB_SwitchSetting("questStarts");
        elseif (arg1 == "hide") then
            local questId = tonumber(string.sub(input, 6));
            if qData[questId] then
                ShaguDB_FinishedQuests[questId] = true;
            end
        elseif (arg1 == "reset") then
            ShaguDB_ResetGui();
        elseif (arg1 == "clear") then
            ShaguDB_Settings = nil;
            ReloadUI();
        end
    end;
end -- Init()

function ShaguDB_Print(string)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. string);
end -- Print(string)

function ShaguDB_NextCMark()
  if (cMark == "mk1") then
    cMark = "mk2";
  elseif (cMark == "mk2") then
    cMark = "mk3";
  elseif (cMark == "mk3") then
    cMark = "mk4";
  elseif (cMark == "mk4") then
    cMark = "mk5";
  elseif (cMark == "mk5") then
    cMark = "mk6";
  elseif (cMark == "mk6") then
    cMark = "mk7";
  elseif (cMark == "mk7") then
    cMark = "mk8";
  elseif (cMark == "mk8") then
    cMark = "mk1";
  end
end -- NextCMark()

function ShaguDB_CleanMap()
    ShaguDB_Debug_Print(2, "CleanMap() called");
    if (Cartographer_Notes ~= nil) then
        Cartographer_Notes:UnregisterNotesDatabase("ShaguDB");
        ShaguDBDB = {}; ShaguDBDBH = {};
        Cartographer_Notes:RegisterNotesDatabase("ShaguDB",ShaguDBDB,ShaguDBDBH);
    end
    ShaguDB_MARKED_ZONES = {};
    ShaguDB_MARKED_ZONE = "";
    ShaguDB_QUEST_START_ZONES = {};
    ShaguDB_MARKED = {{},{},{},{}};
    ShaguDB_MAP_NOTES = {};
end -- CleanMap()

function ShaguDB_ShowMap()
    ShaguDB_Debug_Print(2, "ShowMap() called");
    local ShowMapZone, ShowMapTitle, ShowMapID = ShaguDB_PlotNotesOnMap();
    if (Cartographer) then
        if (ShowMapZone ~= nil) then
            WorldMapFrame:Show();
            if (ShowMapZone) then
                SetMapZoom(ShaguDB_GetMapIDFromZone(ShowMapZone));
            end
        end
    end
end -- ShowMap()

function ShaguDB_CheckIcons(a, b)
    if a ~= -1 then
        if a ~= b then
            if (a == 2 or b == 2 or a == "QuestionMark" or b == "QuestionMark") then
                a = 2;
            elseif (a == 5 or b == 5 or a == "ExclamationMark" or b == "ExclamationMark") then
                a = 5;
            else
                a = 0;
            end
            return a;
        end
    else
        a = b;
    end
    return a;
end -- CheckIcons(a, b)

function ShaguDB_PlotNotesOnMap()
    ShaguDB_Debug_Print(2, "PlotNotesOnMap() called");

    if ShaguDB_PREPARE[DB_NPC] then
        for k, npcMarks in ShaguDB_PREPARE[DB_NPC] do
            local noteTitle, comment, icon = '', '', -1;
            if ShaguDB_GetTableLength(npcMarks) > 1 then
                noteTitle = npcData[k][DB_NAME];
                for key, note in pairs(npcMarks) do
                    comment = comment.."\n"..note[NOTE_TITLE].."\n"..note[NOTE_COMMENT].."\n";
                    icon = ShaguDB_CheckIcons(icon, note[NOTE_ICON])
                end
                if (icon ~= 2) and (icon ~= 5) and (icon ~= 6) then
                    comment = ShaguDB_GetNPCStatsComment(k, true)..comment;
                    local st, en = string.find(comment, "|c.-|r");
                    noteTitle = string.sub(comment, st, en);
                    comment = string.sub(comment, en+2);
                end
                ShaguDB_GetNPCNotes(k, noteTitle, comment, icon);
            else
                for key, v in pairs(npcMarks) do
                    if (v[NOTE_ICON] ~= 2) and (v[NOTE_ICON] ~= 5) and (v[NOTE_ICON] ~= 6) then
                        comment = ShaguDB_GetNPCStatsComment(k, true)..comment;
                    end
                    ShaguDB_GetNPCNotes(k, v[NOTE_TITLE], comment..v[NOTE_COMMENT], v[NOTE_ICON]);
                end
            end
        end
    end
    if ShaguDB_PREPARE[DB_OBJ] then
        for k, objMarks in ShaguDB_PREPARE[DB_OBJ] do
            local noteTitle, comment, icon = '', '', -1;
            if ShaguDB_GetTableLength(objMarks) > 1 then
                noteTitle = objData[k][DB_NAME];
                for key, note in pairs(objMarks) do
                    comment = comment.."\n"..note[NOTE_TITLE].."\n"..note[NOTE_COMMENT].."\n";
                    icon = ShaguDB_CheckIcons(icon, note[NOTE_ICON])
                end
                ShaguDB_GetObjNotes(k, noteTitle, comment, icon);
            else
                for key, v in pairs(objMarks) do
                    ShaguDB_GetObjNotes(k, v[NOTE_TITLE], v[NOTE_COMMENT], v[NOTE_ICON]);
                end
            end
        end
    end
    if ShaguDB_PREPARE[DB_TRIGGER_MARKED] then
        for questId, _ in ShaguDB_PREPARE[DB_TRIGGER_MARKED] do
            local color = ShaguDB_GetDifficultyColor(qData[questId][DB_LEVEL]);
            local level = qData[questId][DB_LEVEL];
            if level == -1 then level = UnitLevel("player"); end
            local title = color.."Location for: ".."["..level.."] "..qData[questId][DB_NAME].."|r";
            for zoneId, coords in pairs(qData[questId][DB_TRIGGER][2]) do
                for _, coord in pairs(coords) do
                    table.insert(ShaguDB_MAP_NOTES,{zoneData[zoneId], coord[1], coord[2], title, "|cFF00FF00"..qData[questId][DB_TRIGGER][1].."|r", 7});
                end
            end
        end
    end
    ShaguDB_MARKED = ShaguDB_PREPARE;
    ShaguDB_PREPARE = {{},{},{},{}};

    if ShaguDB_MAP_NOTES == {} then
        return false, false, false;
    end
    local firstNote = 1;

    local zone = nil;
    local title = nil;
    local noteID = nil;

    for nKey, nData in ipairs(ShaguDB_MAP_NOTES) do
        -- C nData[1] is zone name/number
        -- C nData[2] is x coordinate
        -- C nData[3] is y coordinate
        -- C nData[4] is comment title
        -- C nData[5] is comment body
        -- C nData[6] is icon number/string
        local instance = nil;
        if nData[2] == -1 then
            instance = true;
        end
        if (Cartographer_Notes ~= nil) and (not instance) then
            if (nData[6] == 0) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "NPC", "ShaguDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 1) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "Diamond", "ShaguDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 2) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "QuestionMark", "ShaguDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 3) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "Waypoint", "ShaguDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 4) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "Cross", "ShaguDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 5) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "ExclamationMark", "ShaguDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 6) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "Vendor", "ShaguDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 7) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "AreaTrigger", "ShaguDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] ~= nil) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, nData[6], "ShaguDB", 'title', nData[4], 'info', nData[5]);
            end
        end
        if (nData[1] ~= nil) and (not instance) then
            zone = nData[1];
            if nData[6] ~= 5 then
                ShaguDB_MARKED_ZONES[zone] = true;
            end
            title = nData[4];
        end
    end
    if (table.getn(ShaguDB_MAP_NOTES) ~= nil) and (not ShaguDB_InEvent) then
        local notes = table.getn(ShaguDB_MAP_NOTES);
        if (notes ~= ShaguDB_Notes) then
            ShaguDB_Print(notes.." notes plotted.");
            ShaguDB_Notes = notes;
        end
        ShaguDB_Print(ShaguDB_GetTableLength(ShaguDB_MARKED_ZONES).." zones marked.");
    end
    ShaguDB_MAP_NOTES = {}
    return zone, title, noteID;
end -- PlotNotesOnMap()

function ShaguDB_GetMapIDFromZone(zoneText)
    ShaguDB_Debug_Print(2, "GetMapIDFromZone(", zoneText, ") called");
    for cKey, cName in ipairs{GetMapContinents()} do
        for zKey,zName in ipairs{GetMapZones(cKey)} do
            if(zoneText == zName) then
                return cKey, zKey;
            end
        end
    end
    return -1, zoneText;
end -- GetMapIDFromZone(zoneText)

local HookSetItemRef = SetItemRef
SetItemRef = function (link, text, button)
  isQuest, _, questID = string.find(link, "quest:(%d+):.*");
  isQuest2, _, _ = string.find(link, "quest2:.*");

  _, _, questLevel = string.find(link, "quest:%d+:(%d+)");
  local playerHasQuest = false

  if isQuest then
    -- A usual Quest Link introduced in 2.0x
    ShowUIPanel(ItemRefTooltip);
    ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");

    hasTitle, _, questTitle = string.find(text, ".*|h%[(.*)%]|h.*");
    if hasTitle then
      ItemRefTooltip:AddLine(questTitle, 1,1,0)
    end

    for i=1, GetNumQuestLogEntries() do
      local questlogTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i);
      if questTitle == questlogTitle then
        playerHasQuest = true
        SelectQuestLogEntry(i)
        local _, text = GetQuestLogQuestText()
        ItemRefTooltip:AddLine(text,1,1,1,true)

        for j=1, GetNumQuestLeaderBoards() do
          if j == 1 and GetNumQuestLeaderBoards() > 0 then ItemRefTooltip:AddLine("|cffffffff ") end
          local desc, type, done = GetQuestLogLeaderBoard(j)
          if done then ItemRefTooltip:AddLine("|cffaaffaa"..desc.."|r")
          else ItemRefTooltip:AddLine("|cffffffff"..desc.."|r") end
        end
      end
    end

    if playerHasQuest == false then
      ItemRefTooltip:AddLine("You don't have this quest.", 1, .8, .8)
    end

    if questLevel ~= 0 and questLevel ~= "0" then
      local color = GetDifficultyColor(questLevel)
      ItemRefTooltip:AddLine("Quest Level " .. questLevel, color.r, color.g, color.b)
    end

    ItemRefTooltip:Show()

  elseif isQuest2 then
    -- QuestLink Compatibility
      ShowUIPanel(ItemRefTooltip);
      ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE");
      hasTitle, _, questTitle = string.find(text, ".*|h%[(.*)%]|h.*");
      if hasTitle then
        ItemRefTooltip:AddLine(questTitle, 1,1,0)
      end
      ItemRefTooltip:AddLine("(Unknown QuestLink).", 1, .3, .3)

      for i=1, GetNumQuestLogEntries() do
        local questlogTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(i);
        if questTitle == questlogTitle then
          playerHasQuest = true
          SelectQuestLogEntry(i)
          local _, text = GetQuestLogQuestText()
          ItemRefTooltip:AddLine(text,1,1,1,true)

          for j=1, GetNumQuestLeaderBoards() do
            if j == 1 and GetNumQuestLeaderBoards() > 0 then ItemRefTooltip:AddLine("|cffffffff ") end
            local desc, type, done = GetQuestLogLeaderBoard(j)
            if done then ItemRefTooltip:AddLine("|cffaaffaa"..desc.."|r")
            else ItemRefTooltip:AddLine("|cffffffff"..desc.."|r") end
          end
        end
      end

      if playerHasQuest == false then
        ItemRefTooltip:AddLine("You don't have this quest.", 1, .8, .8)
      end
      ItemRefTooltip:Show()
  else
    HookSetItemRef(link, text, button)
  end
end -- SetItemRef (link, text, button)

----------------------------------------------------
--Merge
----------------------------------------------------

--------------------------------------------------------
-- Wowhead DB By: UniRing
--------------------------------------------------------
-- Wowhead DB Continued By: Muehe
--------------------------------------------------------

function ShaguDB_CycleMarkedZones()
    local currentlyShown = zoneData[ShaguDB_GetCurrentZoneID()];
    if ShaguDB_MARKED_ZONE == "" and currentlyShown then ShaguDB_MARKED_ZONE = currentlyShown; end
    if ShaguDB_MARKED_ZONE ~= "" then
        local found = false;
        for k, v in pairs(ShaguDB_MARKED_ZONES) do
            if found then
                ShaguDB_MARKED_ZONE = k;
                SetMapZoom(ShaguDB_GetMapIDFromZone(k));
                return;
            end
            if k == ShaguDB_MARKED_ZONE then
                found = true;
            end
        end
        if found then
            for k, v in pairs(ShaguDB_MARKED_ZONES) do
                ShaguDB_MARKED_ZONE = k;
                SetMapZoom(ShaguDB_GetMapIDFromZone(k));
                return;
            end
        end
    else
        for k, v in pairs(ShaguDB_MARKED_ZONES) do
            ShaguDB_MARKED_ZONE = k;
            SetMapZoom(ShaguDB_GetMapIDFromZone(k));
            return;
        end
    end
end -- CycleMarkedZones()

-- Debug print function. Credits to Questie.
function ShaguDB_Debug_Print(...)
    local debugWin = 0;
    local name, shown;
    for i=1, NUM_CHAT_WINDOWS do
        name,_,_,_,_,_,shown = GetChatWindowInfo(i);
        if (string.lower(name) == "shagudebug") then debugWin = i; break; end
    end
    if (debugWin == 0) or (ShaguDB_Debug == 0) or (bit.band(arg[1], ShaguDB_Debug) == 0) then return end
    local out = "";
    for i = 2, arg.n, 1 do
        if (i > 2) then out = out .. ", "; end
        local t = type(arg[i]);
        if (t == "string") then
            out = out..arg[i];
        elseif (t == "number") then
            out = out .. arg[i];
        elseif (t == "boolean") then
            if t == true then
                out = out .. "true";
            else
                out = out .. "false";
            end
        elseif (t == "nil") then
            out = out .. "nil";
        elseif (t == "table") then
            out = out .. "table (see above)";
            ShaguDB_PrintTable(arg[i]);
        else
            out = out .. t;
        end
    end
    getglobal("ChatFrame"..debugWin):AddMessage(out, 1.0, 1.0, 0.3);
end -- Debug_Print(...)

function ShaguDB_ResetGui()
    SDBG:ClearAllPoints();
    SDBG:SetPoint("CENTER", 0, 0);
    ShaguDB_Frame:ClearAllPoints();
    ShaguDB_Frame:SetPoint("BOTTOMLEFT", "SDBG", "BOTTOMRIGHT", 0, 0);
    SDBG:Show();
    ShaguDB_Frame:Show();
end -- ResetGui()

function ShaguDB_PlotAllQuests()
    ShaguDB_Debug_Print(2, "PlotAllQuests() called");
    local questLogID=1;
    ShaguDB_MAP_NOTES = {};
    while (GetQuestLogTitle(questLogID) ~= nil) do
        questLogID = questLogID + 1;
        ShaguDB_GetQuestNotes(questLogID)
    end
    ShaguDB_QUEST_START_ZONES = {};
    ShaguDB_CleanMap();
    if ShaguDB_InEvent == true then
        ShaguDB_PlotNotesOnMap();
    else
        ShaguDB_ShowMap();
    end
end -- PlotAllQuests()

-- called from xml
function ShaguDB_DoCleanMap()
    ShaguDB_Debug_Print(2, "DoCleanMap() called");
    if (ShaguDB_Settings.auto_plot) then
        ShaguDB_Settings.auto_plot = false;
        ShaguDB_CheckSetting("auto_plot")
        ShaguDB_Print("Auto plotting disabled.");
    end
    if (ShaguDB_Settings.questStarts) then
        ShaguDB_Settings.questStarts = false;
        ShaguDB_CheckSetting("questStarts")
        ShaguDB_Print("Quest start plotting disabled.");
    end
    ShaguDB_CleanMap();
end -- DoCleanMap()

function ShaguDB_SearchEndNPC(questID)
    ShaguDB_Debug_Print(2, "SearchEndNPC(", questID, ") called");
    for npc, data in pairs(npcData) do
        if (data[DB_NPC_ENDS] ~= nil) then
            for line, entry in pairs(data[DB_NPC_ENDS]) do
                if (entry == questID) then return npc; end
            end
        end
    end
    return nil;
end -- SearchEndNPC(questID)

function ShaguDB_SearchEndObj(questID)
    ShaguDB_Debug_Print(2, "SearchEndObj(", questID, ") called");
    for obj, data in pairs(objData) do
        if (data["ends"] ~= nil) then
            for line, entry in pairs(data["ends"]) do
                if (entry == questID) then return obj; end
            end
        end
    end
    return nil;
end -- SearchEndObj(questID)

function ShaguDB_GetQuestEndNotes(questLogID)
    ShaguDB_Debug_Print(2, "GetQuestEndNotes(", questLogID, ") called");
    local questTitle, level = GetQuestLogTitle(questLogID);
    SelectQuestLogEntry(questLogID);
    local questDescription, questObjectives = GetQuestLogQuestText();
    if (questObjectives == nil) then questObjectives = ''; end
    local qIDs = ShaguDB_GetQuestIDs(questTitle, questObjectives, level);
    if qIDs ~= false then
        ShaguDB_Debug_Print(8, "    ", type(qIDs));
    end
    if (qIDs ~= false) then
        if (type(qIDs) == "table") then
            local multi = 0;
            local npcIDs = {}
            for n, qID in pairs(qIDs) do
                multi = multi + 1;
                local npcID = ShaguDB_SearchEndNPC(qID);
                if (npcID) then
                    local done = false;
                    for n, IDInside in pairs(npcIDs) do
                        if (npcID == IDInside) then
                            done = true;
                        end
                    end
                    if not (done) then
                        table.insert(npcIDs, npcID);
                    end
                end
            end
            if (table.getn(npcIDs) > 0) then
                if (table.getn(npcIDs) > 1) then
                    for n, npcID in pairs(npcIDs) do
                        local commentTitle = "|cFF33FF00"..questTitle.." (Complete)|r".." - "..n.."/"..table.getn(npcIDs).." NPCs";
                        local comment = npcData[npcID][DB_NAME].."\n("..multi.." quests with this name)"
                        ShaguDB_MarkForPlotting(DB_NPC, npcID, commentTitle, "Finished by: |cFFa6a6a6"..comment.."|r", 2);
                    end
                else
                    local npcID = npcIDs[1]
                    local comment = npcData[npcID][DB_NAME].."\n(Ends "..multi.." quests with this name)"
                    return ShaguDB_MarkForPlotting(DB_NPC, npcID, "|cFF33FF00"..questTitle.." (Complete)|r", "Finished by: |cFFa6a6a6"..comment.."|r", 2);
                end
            else
                local objIDs = {}
                    for n, qID in pairs(qIDs) do
                    local objID = ShaguDB_SearchEndObj(qID);
                    if (objID) then
                        local done = false;
                        for n, IDInside in pairs(objIDs) do
                            if (objID == IDInside) then
                                done = true;
                            end
                        end
                        if not (done) then
                            table.insert(objIDs, objID);
                        end
                    end
                end
                if (table.getn(objIDs) > 0) then
                    if (table.getn(objIDs) > 1) then
                        for n, objID in pairs(objIDs) do
                            local commentTitle = "|cFF33FF00"..questTitle.." (Complete)|r".." - "..n.."/"..table.getn(objIDs).." NPCs";
                            local comment = objData[objID][DB_NAME].."\n("..multi.." quests with this name)"
                            ShaguDB_MarkForPlotting(DB_OBJ, objID, commentTitle, "Finished by: |cFFa6a6a6"..comment.."|r", 2);
                        end
                    else
                        local objID = objIDs[1]
                        local comment = objData[objID][DB_NAME].."\n(Ends "..multi.." quests with this name)"
                        return ShaguDB_MarkForPlotting(DB_OBJ, objID, "|cFF33FF00"..questTitle.." (Complete)|r", "Finished by: |cFFa6a6a6"..comment.."|r", 2);
                    end
                else
                    return false;
                end
            end
            return true;
        elseif (type(qIDs) == "number") then
            local npcID = ShaguDB_SearchEndNPC(qIDs);
            if npcID and npcData[npcID] then
                local name = npcData[npcID][DB_NAME];
                return ShaguDB_MarkForPlotting(DB_NPC, npcID, "|cFF33FF00"..questTitle.." (Complete)|r", "Finished by: |cFFa6a6a6"..name.."|r", 2);
            else
                local objID = ShaguDB_SearchEndObj(qIDs);
                if objID and objData[objID] then
                    local name = objData[objID][DB_NAME];
                    return ShaguDB_MarkForPlotting(DB_OBJ, objID, "|cFF33FF00"..questTitle.." (Complete)|r", "Finished by: |cFFa6a6a6"..name.."|r", 2);
                else
                    return false;
                end
            end
        end
    else
        return false;
    end
end -- GetQuestEndNotes(questLogID)

function ShaguDB_GetQuestIDs(questName, objectives, ...)
    if not qLookup[questName] then
        return false;
    end
    local qIDs = {};
    if (objectives == nil) then objectives = ''; end
    ShaguDB_Debug_Print(2, "GetQuestIDs('", questName, "', '", objectives, "')", arg[1]);
    if (ShaguDB_GetTableLength(qLookup[questName]) == 1) then
        for k, v in pairs(qLookup[questName]) do
            ShaguDB_Debug_Print(8, "    Possible questIDs: 1");
            return k;
        end
    else
        if (objectives ~= '') then
            for k, v in pairs(qLookup[questName]) do
                if v == objectives then -- implicit nil ~= string
                    table.insert(qIDs, k);
                end
            end
        end
        if (table.getn(qIDs) == 0) then
            for k, v in pairs(qLookup[questName]) do
                table.insert(qIDs, k);
            end
        end
        if (ShaguDB_GetTableLength(qIDs) > 1) then
            local level = arg[1];
            if level then
                for k, v in pairs(qIDs) do
                    if qData[v][DB_LEVEL] ~= level and level ~= UnitLevel("player") then
                        qIDs[k] = nil;
                    end
                end
            end
        end
    end
    local length = ShaguDB_GetTableLength(qIDs);
    ShaguDB_Debug_Print(8, "    Possible questIDs: ", length);
    if (length == nil) then
        return false;
    elseif (length == 1) then
        for k, v in pairs(qIDs) do
            return v;
        end
    else
        return qIDs;
    end
end -- GetQuestIDs(questName, objectives)

-- TODO 19 npc names are used twice. first found is chosen atm
function ShaguDB_GetNPCID(npcName)
    ShaguDB_Debug_Print(2, "GetNPCID(", npcName, ") called");
    for npcid, data in pairs(npcData) do
        if (data[DB_NAME] == npcName) then return npcid; end
    end
    return false;
end -- GetNPCID(npcName)

function ShaguDB_GetObjID(objName)
    ShaguDB_Debug_Print(2, "GetObjID(", objName, ") called");
    local objIDs = {};
    for objID, data in pairs(objData) do
        if (data[DB_NAME] == objName) then
            table.insert(objIDs, objID);
        end
    end
    if objIDs == {} then return false;
    else return objIDs;
    end
end -- GetObjID(objName)

function ShaguDB_SwitchSetting(setting, ...)
    text = {
        ["waypoints"] = "Showing waypoints",
        ["auto_plot"] = "Automatically tracking quests",
        ["questStarts"] = "Showing quest starts",
        ["reqLevel"] = "Showing required level in quest start tooltips",
        ["filterReqLevel"] = "Filtering quest starts by required level",
        ["questIds"] = "Showing quest IDs in tooltips",
        ["dbMode"] = "DB Mode",
        ["item_item"] = "Showing items dropped by items",
        ["minDropChance"] = "Minimum drop chance for items to be shown",
    };
    if (ShaguDB_Settings[setting] == false) then
        ShaguDB_Settings[setting] = true;
        ShaguDB_Print(text[setting].." enabled.");
    elseif (setting == "minDropChance") then
        local number = tonumber(arg1);
        if (number) and (number >= 0 and number <= 101) then
            ShaguDB_Settings[setting] = number;
            ShaguDB_Print(text[setting].." set to: "..number);
        else
            ShaguDB_Print(text[setting].." is: "..ShaguDB_Settings[setting]);
        end
    else
        ShaguDB_Settings[setting] = false;
        ShaguDB_Print(text[setting].." disabled.");
    end
    ShaguDB_CheckSetting(setting);
    if (setting == "auto_plot") and (ShaguDB_Settings[setting]) then
        ShaguDB_PlotAllQuests();
    elseif (setting == "auto_plot") and (not ShaguDB_Settings[setting]) then
        ShaguDB_CleanMap();
    end
end -- SwitchSetting(setting)

function ShaguDB_GetSetting(setting, ...)
    text = {
        ["waypoints"] = "Showing waypoints",
        ["auto_plot"] = "Automatically tracking quests",
        ["questStarts"] = "Showing quest starts",
        ["reqLevel"] = "Showing required level in quest start tooltips",
        ["filterReqLevel"] = "Filtering quest starts by required level",
        ["questIds"] = "Showing quest IDs in tooltips",
        ["dbMode"] = "DB Mode",
        ["item_item"] = "Showing items dropped by items",
    };
    if (text[setting]) and (ShaguDB_Settings[setting]) then
        return text[setting].."|cFF40C040 is enabled|r";
    elseif (text[setting]) then
        return text[setting].."|cFFFF1A1A is disabled|r";
    end
end -- GetSetting(setting, ...)

function ShaguDB_CheckSetting(setting)
    if (setting ~= "waypoints") and (setting ~= "auto_plot") and (setting ~= "questStarts") then
        return;
    end
    if (ShaguDB_Settings[setting] == true) then
        getglobal(setting):SetChecked(true);
    else
        getglobal(setting):SetChecked(false);
    end
end -- CheckSetting(setting)

-- tries to get locations for an NPC and inserts them in ShaguDB_MAP_NOTES if found
function ShaguDB_GetNPCNotes(npcNameOrID, commentTitle, comment, icon)
    if (npcNameOrID ~= nil) then
        ShaguDB_Debug_Print(2, "GetNPCNotes(", npcNameOrID, ") called");
        local npcID;
        if (type(npcNameOrID) == "string") then
            npcID = ShaguDB_GetNPCID(npcNameOrID);
        else
            npcID = npcNameOrID;
        end
        if (npcData[npcID] ~= nil) then
            local showMap = false;
            if (npcData[npcID][DB_NPC_WAYPOINTS] and ShaguDB_Settings.waypoints == true) then
                for zoneID, coordsdata in pairs(npcData[npcID][DB_NPC_WAYPOINTS]) do
                    zoneName = zoneData[zoneID];
                    for cID, coords in pairs(coordsdata) do
                        if (coords[1] == -1) then
                            for id, data in pairs(instanceData[zoneID]) do
                                noteZone = zoneData[data[1] ];
                                coordx = data[2];
                                coordy = data[3];
                                table.insert(ShaguDB_MAP_NOTES,{noteZone, coordx, coordy, commentTitle, "|cFF00FF00Instance Entry to "..zoneName.."|r\n"..comment, icon});
                            end
                            break;
                        end
                        coordx = coords[1];
                        coordy = coords[2];
                        table.insert(ShaguDB_MAP_NOTES,{zoneName, coordx, coordy, commentTitle, comment, 3});
                        showMap = true;
                    end
                end
            end
            if (npcData[npcID][DB_NPC_SPAWNS]) then
                for zoneID, coordsdata in pairs(npcData[npcID][DB_NPC_SPAWNS]) do
                    if (zoneID ~= 5 and zoneID ~= 6) then
                        zoneName = zoneData[zoneID];
                        for cID, coords in pairs(coordsdata) do
                            if (coords[1] == -1) and (instanceData[zoneID]) then
                                for id, data in pairs(instanceData[zoneID]) do
                                    noteZone = zoneData[data[1] ];
                                    coordx = data[2];
                                    coordy = data[3];
                                    table.insert(ShaguDB_MAP_NOTES,{noteZone, coordx, coordy, commentTitle, "|cFF00FF00Instance Entry to "..zoneName.."|r\n"..comment, icon});
                                end
                            end
                            coordx = coords[1];
                            coordy = coords[2];
                            table.insert(ShaguDB_MAP_NOTES,{zoneName, coordx, coordy, commentTitle, comment, icon});
                            showMap = true;
                        end
                    end
                end
            end
            return showMap;
        end
    end
    return false;
end -- GetNPCNotes(npcNameOrID, commentTitle, comment, icon)

-- tries to get locations for an (ingame) object and inserts them in ShaguDB_MAP_NOTES if found
function ShaguDB_GetObjNotes(objNameOrID, commentTitle, comment, icon)
    ShaguDB_Debug_Print(2, "GetObjNotes(objNameOrID, commentTitle, comment, icon) called");
    if (objNameOrID ~= nil) then
        local objIDs;
        if (type(objNameOrID) == "string") then
            objIDs = ShaguDB_GetObjID(objNameOrID);
        else
            objIDs = {objNameOrID};
        end
        local showMap = false;
        local count = 0;
        for n, objID in pairs(objIDs) do
            if (objData[objID] ~= nil) then
                if (objData[objID][DB_OBJ_SPAWNS]) then
                    for zoneID, coordsdata in pairs(objData[objID][DB_OBJ_SPAWNS]) do
                        if (zoneID ~= 5 and zoneID ~= 6) then -- C legacy, unused, kept for future (world map coords)
                            zoneName = zoneData[zoneID]
                            for cID, coords in pairs(coordsdata) do
                                coordx = coords[1]
                                coordy = coords[2]
                                table.insert(ShaguDB_MAP_NOTES,{zoneName, coordx, coordy, commentTitle, comment, icon});
                                showMap = true;
                            end
                        end
                    end
                end
            end
        end
        return showMap;
    end
    return false;
end -- GetObjNotes(objNameOrID, commentTitle, comment, icon)

function ShaguDB_PrepareItemNotes(itemNameOrID, commentTitle, comment, icon, types)
    ShaguDB_Debug_Print(2, "PrepareItemNotes(", itemNameOrID, ") called");
    local itemID = 0;
    if (type(itemNameOrID) == "number") then
        itemID = itemNameOrID;
    elseif (type(itemNameOrID) == "string") then
        itemID = itemLookup[itemNameOrID];
    end
    if itemID ~= 0 then
        ShaguDB_PREPARE[DB_ITM][itemID] = true;
    end
    -- if recursively called
    if (type(commentTitle) == "number") then
        for name, id in pairs(itemLookup) do
            if (id == commentTitle) then
                commentTitle = name;
                break;
            end
        end
    end
    local showType = {};
    if type(types) == "table" then
        ShaguDB_Debug_Print(8, "    ", types);
        for _, type in pairs(types) do
            showType[type] = true;
        end
    elseif types == true then
        showType[DB_NPC] = true;
        showType[DB_OBJ] = true;
        showType[DB_ITM] = true;
        showType[DB_VENDOR] = true;
    end
    if (itemData[itemID]) then
        local showMap = false;
        if (itemData[itemID][DB_NPC]) and ((showType == nil) or (showType[DB_NPC])) then
            for key, value in pairs(itemData[itemID][DB_NPC]) do
                if npcData[value[1]] then
                    local show = true;
                    if (ShaguDB_Settings.minDropChance > 0) and (value[2] < ShaguDB_Settings.minDropChance) then
                        show = false;
                    end
                    if show then
                        local dropComment = " ("..value[2].."%)";
                        showMap = ShaguDB_MarkForPlotting(DB_NPC, value[1], commentTitle, comment..dropComment, icon) or showMap;
                    end
                end
            end
        end
        if (itemData[itemID][DB_OBJ]) and ((showType == nil) or (showType[DB_OBJ])) then
            for key, value in pairs(itemData[itemID][DB_OBJ]) do
                if objData[value[1]] then
                    local show = true;
                    if (ShaguDB_Settings.minDropChance > 0) and (value[2] < ShaguDB_Settings.minDropChance) then
                        show = false;
                    end
                    if show then
                        local dropComment = objData[value[1]][DB_NAME].."\n"..comment.." ("..value[2].."%)";
                        showMap = ShaguDB_MarkForPlotting(DB_OBJ, objData[value[1]][DB_NAME], commentTitle, dropComment, icon) or showMap;
                    end
                end
            end
        end
        if (itemData[itemID][DB_ITM]) and (ShaguDB_Settings.item_item) and ((showType == nil) or (showType[DB_ITM])) then
            for key, value in pairs(itemData[itemID][DB_ITM]) do
                local show = true;
                if (ShaguDB_Settings.minDropChance > 0) and (value[2] < ShaguDB_Settings.minDropChance) then
                    show = false;
                end
                if show then
                    local dropComment = "|cFF00FF00"..value[2].."% chance of containing "..commentTitle.."|r\n"
                    showMap = ShaguDB_PrepareItemNotes(value[1], commentTitle, dropComment..comment, icon, true) or showMap;
                end
            end
        end
        if (itemData[itemID][DB_VENDOR]) and ((showType == nil) or (showType[DB_VENDOR])) then
            for key, value in pairs(itemData[itemID][DB_VENDOR]) do
                local npc, maxcount, increaseTime = value[1], value[2], value[3];
                if npcData[npc] then
                    local sellComment = '';
                    if maxcount then
                        sellComment = "Sold by: "..npcData[npc][DB_NAME].."\nMax available: "..maxcount.."\nRestock time: "..ShaguDB_GetTimeString(increaseTime).."\n"..comment;
                    else
                        sellComment = "Sold by: "..npcData[npc][DB_NAME].."\n"..comment;
                    end
                    showMap = ShaguDB_MarkForPlotting(DB_NPC, npc, commentTitle, sellComment, 6) or showMap;
                else
                    ShaguDB_Debug_Print(1, "Spawn Error for NPC", npc);
                end
            end
        end
        return showMap;
    else
        return false;
    end
end -- PrepareItemNotes(itemNameOrID, commentTitle, comment, icon, types)

function ShaguDB_GetTimeString(seconds)
    local hour, minute, second;
    hour = math.floor(seconds/(60*60));
    minute = math.floor(mod(seconds/60, 60));
    second = mod(seconds, 60);
    return string.format("%.2d:%.2d:%.2d", hour, minute, second);
end -- GetTimeString(seconds)

function ShaguDB_GetSpecialNpcNotes(qId, objectiveText, numItems, numNeeded, title)
    local showMap = false;
    for _, v in pairs(qData[qId][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_NPC]) do
        if v[2] ~= nil and v[2] == objectiveText then
            local comment = "|cFF00FF00"..objectiveText..":  "..numItems.."/"..numNeeded.."|r";
            showMap = ShaguDB_MarkForPlotting(DB_NPC, v[1], title, comment, cMark) or showMap;
        end
    end
    return showMap;
end -- GetSpecialNpcNotes(qId, objectiveText, numItems, numNeeded, title)

function ShaguDB_GetQuestNotes(questLogID)
    ShaguDB_Debug_Print(2, "GetQuestNotes(", questLogID, ") called");
    local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(questLogID);
    local showMap = false;
    if (not isHeader and questTitle ~= nil) then
        ShaguDB_Debug_Print(8, "    questTitle = ", questTitle);
        ShaguDB_Debug_Print(8, "    level = ", level);
        ShaguDB_Debug_Print(8, "    isComplete = ", isComplete);
        local numObjectives = GetNumQuestLeaderBoards(questLogID);
        if (numObjectives ~= nil) then
            ShaguDB_Debug_Print(8, "    numObjectives = ", numObjectives);
        end
        SelectQuestLogEntry(questLogID);
        local questDescription, questObjectives = GetQuestLogQuestText();
        local qIDs = ShaguDB_GetQuestIDs(questTitle, questObjectives, level);
        local title = "";
        if (type(qIDs) == "number") then
            ShaguDB_Debug_Print(8, "    qID = ", qIDs);
            local level = qData[qIDs][DB_LEVEL];
            if level == -1 then level = UnitLevel("player"); end
            title = ShaguDB_GetDifficultyColor(qData[qIDs][DB_LEVEL]).."["..level.."] "..questTitle.."|r";
        elseif (type(qIDs) == "table") then
            numQuests = 0;
            for k, qID in pairs(qIDs) do
                ShaguDB_Debug_Print(8, "    qID[", k, "] = ", qID);
                numQuests = numQuests + 1;
            end
            title = questTitle.."|cFFa6a6a6 (there are "..numQuests.." Quests with this name)|r";
        else
            ShaguDB_Debug_Print(1, "Failed to find Quest ID for: ", questTitle)
            title = questTitle
        end
        local itemList = {};
        if (numObjectives ~= nil) then
            for i=1, numObjectives, 1 do
                local text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogID);
                local i, j, itemName, numItems, numNeeded = strfind(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
                if itemName then
                    ShaguDB_Debug_Print(8, "    objectiveText = ", itemName);
                end
                if (not finished) then
                    if (objectiveType == "monster") then
                        ShaguDB_Debug_Print(8, "    type = monster");
                        local i, j, monsterName = strfind(itemName, "(.*) slain");
                        if i == nil then
                            i, j, monsterName = strfind(itemName, "(.*) getötet");
                        end
                        if monsterName then
                            local npcID = ShaguDB_GetNPCID(monsterName);
                            if npcID then
                                local comment = "|cFF00FF00"..itemName..":  "..numItems.."/"..numNeeded.."|r";
                                showMap = ShaguDB_MarkForPlotting(DB_NPC, npcID, title, comment, cMark) or showMap;
                            end
                        else
                            if (type(qIDs) == "number") then
                                showMap = ShaguDB_GetSpecialNpcNotes(qIDs, itemName, numItems, numNeeded, title) or showMap;
                            elseif (type(qIDs) == "table") then
                                for _, qId in pairs(qIDs) do
                                    showMap = ShaguDB_GetSpecialNpcNotes(qId, itemName, numItems, numNeeded, title) or showMap;
                                end
                            end
                        end
                    elseif (objectiveType == "item") then
                        ShaguDB_Debug_Print(8, "    type = item");
                        local itemID = itemLookup[itemName];
                        if (itemID and (itemData[itemID])) then
                            itemList[itemID] = true;
                            local comment = "|cFF00FF00"..itemName..": "..numItems.."/"..numNeeded.."|r"
                            showMap = ShaguDB_PrepareItemNotes(itemID, title, comment, cMark, true) or showMap;
                        end
                    elseif (objectiveType == "object") then
                        ShaguDB_Debug_Print(8, "    type = object");
                        if (type(qIDs) == "number") then
                            if qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_OBJ] then
                                for key, data in pairs(qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_OBJ]) do
                                    local objectId, objectiveText = data[1], data[2];
                                    if (objData[objectId] and objectiveText == itemName) then
                                        local comment = "|cFF00FF00";
                                        if (numNeeded == "1") then
                                            comment = comment..objectiveText.."|r\n";
                                        else
                                            comment = comment..objectiveText..": "..numItems.."/"..numNeeded.."|r\n";
                                        end
                                        ShaguDB_MarkForPlotting(DB_OBJ, objectId, title, comment, "Object");
                                    end
                                end
                            end
                        elseif (type(qIDs) == "table") then
                            for k, qID in pairs(qIDs) do
                                if qData[qID][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_OBJ] then
                                    for key, data in pairs(qData[qID][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_OBJ]) do
                                        local objectId, objectiveText = data[1], data[2];
                                        if (objData[objectId] and objectiveText == itemName) then
                                            local comment = "|cFF00FF00";
                                            if (numItems == "1") then
                                                comment = comment..objectiveText.."|r\n";
                                            else
                                                comment = comment..objectiveText..": "..numItems.."/"..numNeeded.."|r\n";
                                            end
                                            ShaguDB_MarkForPlotting(DB_OBJ, objectId, title, comment, "Object");
                                        end
                                    end
                                end
                            end
                        end
                    elseif (objectiveType == "event") then
                        if (type(qIDs) == "number") then
                            if qData[qIDs][DB_TRIGGER] then
                                ShaguDB_PREPARE[DB_TRIGGER_MARKED][qIDs] = true;
                            end
                        elseif (type(qIDs) == "table") then
                            for k, qID in pairs(qIDs) do
                                if qData[qIDs][DB_TRIGGER] then
                                    ShaguDB_PREPARE[DB_TRIGGER_MARKED][qID] = true;
                                end
                            end
                        end
                    -- checks for objective type other than item/monster/object, e.g. reputation, event
                    elseif (objectiveType ~= "item" and objectiveType ~= "monster" and objectiveType ~= "object" and objectiveType ~= "event") then
                        ShaguDB_Debug_Print(1, "    ", objectiveType, " quest objective-type not supported yet");
                    end
                end
            end
            if ((not isComplete) and (numObjectives ~= 0)) then
                if (type(qIDs) == "number") then
                    ShaguDB_Debug_Print(8, "    Quest related drop for: ", qIDs)
                    if qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_ITM] then
                        for k, item in pairs(qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_ITM]) do
                            if (itemData[item[1]] and itemList[item[1]] == nil) then
                                local comment = "Drop for quest related item:\n"..itemData[item[1]][DB_ITM_NAME];
                                showMap = ShaguDB_PrepareItemNotes(item[1], title, comment, cMark, true) or showMap;
                            end
                        end
                    end
                end
                if (type(qIDs) == "table") then
                    for k, qID in pairs(qIDs) do
                        ShaguDB_Debug_Print(8, "    Quest related drop for: ", qID)
                        if qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_ITM] then
                            for k, item in pairs(qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_ITM]) do
                                if itemData[item[1]] then
                                    local comment = "Drop for quest related item:\n"..itemData[item[1]][DB_ITM_NAME];
                                    showMap = ShaguDB_PrepareItemNotes(item[1], title, comment, cMark, true) or showMap;
                                end
                            end
                        end
                    end
                end
            end
        end
        -- added numObjectives condition due to some quests not showing "isComplete" though having nothing to do but turn it in
        if (isComplete or numObjectives == 0) then
            ShaguDB_GetQuestEndNotes(questLogID);
        end
    end
    if showMap then
        ShaguDB_NextCMark();
    end
    return showMap;
end -- GetQuestNotes(questLogID)

-- returns level and hp values with prefix for provided NPC name as string
function ShaguDB_GetNPCStatsComment(npcNameOrID, ...)
    local color = arg[1];
    local colorStringMin = "|cFFFFFFFF";
    local colorStringMax = "|cFFFFFFFF";
    if (color) and (type(color) ~= "boolean") and (type(color)  ~= "string") then
        if (bit.band(36, bit.lshift(1, color))) ~= 0 then
            color = false;
        end
    elseif (type(color) == "string") then
        color = true;
    else
        color = true;
    end
    ShaguDB_Debug_Print(2, "GetNPCStatsComment(", npcNameOrID, ") called");
    local npcID = 0;
    if (type(npcNameOrID) == "string") then
        npcID = ShaguDB_GetNPCID(npcNameOrID);
    else
        npcID = npcNameOrID;
    end
    if (npcID ~= 0) and (npcData[npcID] ~= nil) then
        local rank = "";
        if npcData[npcID][DB_RANK] ~= 0 then
            if npcData[npcID][DB_RANK] == 1 then rank = "Elite";
            elseif npcData[npcID][DB_RANK] == 2 then rank = "Rare Elite";
            elseif npcData[npcID][DB_RANK] == 3 then rank = "World Boss";
            elseif npcData[npcID][DB_RANK] == 4 then rank = "Rare";
            end
        end
        if npcData[npcID][DB_LEVEL] ~= npcData[npcID][DB_MIN_LEVEL] then
            local maxLevel = npcData[npcID][DB_LEVEL];
            local minLevel = npcData[npcID][DB_MIN_LEVEL];
            local colorStringMax = ShaguDB_GetDifficultyColor(maxLevel);
            local colorStringMin = ShaguDB_GetDifficultyColor(minLevel);
            return colorStringMax..npcData[npcID][DB_NAME].."|r\nLevel: "..colorStringMin..minLevel.."|r - "..colorStringMax..maxLevel.." "..rank.."|r\n".."Health: "..colorStringMin..npcData[npcID][DB_MIN_LEVEL_HEALTH].."|r - "..colorStringMax..npcData[npcID][DB_MAX_LEVEL_HEALTH].."|r\n";
        else
            local colorString = ShaguDB_GetDifficultyColor(npcData[npcID][DB_LEVEL]);
            return colorString..npcData[npcID][DB_NAME].."|r\nLevel: "..colorString..npcData[npcID][DB_MIN_LEVEL].." "..rank.."|r\n".."Health: "..colorString..npcData[npcID][DB_MIN_LEVEL_HEALTH].."|r\n";
        end
    else
        ShaguDB_Debug_Print(1, "    NPC not found: ", npcNameOrID);
        return "NPC not found: "..npcNameOrID;
    end
end -- GetNPCStatsComment(npcNameOrID)

-- returns dropRate value with prefix for provided NPC name as string
-- TODO: fix for new item data
function ShaguDB_GetNPCDropComment(itemName, npcName)
    ShaguDB_Debug_Print(2, "GetNPCDropComment(", itemName, ", ", npcName, ") called");
    local dropRate = itemData[itemName][npcName];
    if (dropRate == "" or dropRate == nil) then
        dropRate = "Unknown";
    end
    return "Drop chance: "..dropRate.."%";
end -- GetNPCDropComment(itemName, npcName)

function ShaguDB_GetQuestStartNotes(zoneName)
    local zoneID = 0;
    if zoneName == nil then
        zoneID = ShaguDB_GetCurrentZoneID();
    end
    if (zoneID == 0) and (zoneName) then
        for k,v in pairs(zoneData) do
            if v == zoneName then
                zoneID = k;
            end
        end
    end
    if zoneID ~= 0 then
        if ShaguDB_QUEST_START_ZONES[zoneID] == true then
            return;
        else
            ShaguDB_QUEST_START_ZONES[zoneID] = true;
        end
        ShaguDB_PREPARE = ShaguDB_MARKED;
        -- TODO: add hide option to right click menu
        for id, data in pairs(npcData) do
            if (data[DB_NPC_SPAWNS][zoneID] ~= nil) and (data[DB_NPC_STARTS] ~= nil) then
                local comment = ShaguDB_GetQuestStartComment(data[DB_NPC_STARTS]);
                if (comment ~= "") then -- (comment == "") => other faction quest
                    ShaguDB_MarkForPlotting(DB_NPC, id, data[DB_NAME], "Starts quests:\n"..comment, 5);
                end
            end
        end
        for id, data in pairs(objData) do
            if (data[DB_OBJ_SPAWNS][zoneID] ~= nil) and (data[DB_STARTS] ~= nil) then
                local comment = ShaguDB_GetQuestStartComment(data[DB_STARTS]);
                if (comment ~= "") then
                    ShaguDB_MarkForPlotting(DB_OBJ, id, data[DB_NAME], "Starts quests:\n"..comment, 5);
                end
            end
        end
        local _,_,_ = ShaguDB_PlotNotesOnMap();
    end
end -- GetQuestStartNotes(zoneName)

function ShaguDB_GetQuestStartComment(npcOrGoStarts)
    local tooltipText = "";
    for key, questID in npcOrGoStarts do
        if (qData[questID]) and (ShaguDB_FinishedQuests[questID] == nil) and (ShaguDB_FinishedQuests[questID] ~= true) then
            local tooHigh = false;
            if (ShaguDB_Settings.filterReqLevel == true) and (qData[questID][DB_MIN_LEVEL] > UnitLevel("player")) then
                tooHigh = true;
            end
            local colorString = ShaguDB_GetDifficultyColor(qData[questID][DB_LEVEL]);
            local level = qData[questID][DB_LEVEL];
            if level == -1 then level = UnitLevel("player"); end
            if not tooHigh then
                tooltipText = tooltipText..colorString.."["..level.."] "..qData[questID][DB_NAME].."|r\n";
                if ShaguDB_Settings.questIds and ShaguDB_Settings.reqLevel then
                    tooltipText = tooltipText.."|cFFa6a6a6(ID: "..questID..") | |r";
                elseif ShaguDB_Settings.questIds then
                    tooltipText = tooltipText.."|cFFa6a6a6(ID: "..questID..")|r\n";
                end
                if ShaguDB_Settings.reqLevel then
                    local comment = "";
                    if ShaguDB_GetGreyLevel(UnitLevel("player")) >= qData[questID][DB_MIN_LEVEL] then
                        comment = qData[questID][DB_MIN_LEVEL];
                    elseif qData[questID][DB_MIN_LEVEL] > UnitLevel("player") then
                        comment = "|r|cFFFF1A1A"..qData[questID][DB_MIN_LEVEL]; -- red
                    else
                        comment = "|r|cFFFFFF00"..qData[questID][DB_MIN_LEVEL]; -- yellow
                    end
                    tooltipText = tooltipText.."|cFFa6a6a6Requires level: "..comment.."|r\n"; -- grey
                end
            end
        end
    end
    return tooltipText;
end -- GetQuestStartComment(npcOrGoStarts)

function ShaguDB_GetCurrentZoneID()
    local zoneXY = {GetMapZones(GetCurrentMapContinent())};
    local zoneName = zoneXY[GetCurrentMapZone()];
    for k,v in pairs(zoneData) do
        if v == zoneName then
            return k;
        end
    end
    return false;
end -- GetCurrentZoneID()

-- called from xml
function ShaguDB_GetSelectionQuestNotes()
    ShaguDB_PREPARE = ShaguDB_MARKED;
    ShaguDB_GetQuestNotes(GetQuestLogSelection())
    ShaguDB_ShowMap();
end -- GetSelectionQuestNotes()

function ShaguDB_GetTableLength(tab)
    if tab then
        local count = 0;
        for k, v in pairs(tab) do
            count = count + 1;
        end
        return count;
    else
        return 0;
    end
end -- GetTableLength()

function ShaguDB_GetDifficultyColor(level1, ...)
    if level1 == -1 then
        level1 = UnitLevel("player");
    end
    local level2 = 0;
    if type(arg[1]) ~= "number" then
        level2 = UnitLevel("player");
    end
    if (level1 > (level2 + 4)) then
        return "|cFFFF1A1A"; -- Red
    elseif (level1 > (level2 + 2)) then
        return "|cFFFF8040"; -- Orange
    elseif (level1 <= (level2 + 2)) and (level1 >= (level2 - 2)) then
        return "|cFFFFFF00"; -- Yellow
    elseif (level1 > ShaguDB_GetGreyLevel(level2)) then
        return "|cFF40C040"; -- Green
    else
        return "|cFFC0C0C0"; -- Grey
    end
    return "|cFFffffff"; --white
end -- GetDifficultyColor(level1, ...)

function ShaguDB_GetGreyLevel(level)
    if (level <= 5) then
        return 0;
    elseif (level <= 39) then
        return (level - math.floor(level/10) - 5);
    else
        return (level - math.floor(level/5) - 1);
    end
end -- GetGreyLevel(level)

function ShaguDB_MarkForPlotting(kind, nameOrId, title, comment, icon, ...)
    ShaguDB_Debug_Print(2, "MarkForPlotting(", kind, ", ", nameOrId, ") called");
    if kind == DB_NPC then
        local npcID = 0;
        if type(nameOrId) == "number" then
            npcID = nameOrId;
        else
            npcID = ShaguDB_GetNPCID(nameOrId);
        end
        if npcID and npcID ~=0 then
            if not ShaguDB_PREPARE[DB_NPC][npcID] then ShaguDB_PREPARE[DB_NPC][npcID] = {}; end
            ShaguDB_FillPrepare(ShaguDB_PREPARE[DB_NPC][npcID], title, comment, icon);
            return true;
        end
    elseif kind == DB_OBJ then
        local objIDs = 0;
        if type(nameOrId) == "number" then
            objIDs = {nameOrId};
        else
            objIDs = ShaguDB_GetObjID(nameOrId);
        end
        if objIDs and objIDs ~= 0 then
            for k, objID in pairs(objIDs) do
                if not ShaguDB_PREPARE[DB_OBJ][objID] then ShaguDB_PREPARE[DB_OBJ][objID] = {}; end
                ShaguDB_FillPrepare(ShaguDB_PREPARE[DB_OBJ][objID], title, comment, icon);
            end
            return true;
        end
    elseif kind == DB_ITM then
        local itmID = 0;
        if type(nameOrId) == "number" then
            itmID = nameOrId;
        else
            itmID = itemLookup[nameOrId];
        end
        if itmID and itmID ~=0 then
            ShaguDB_PrepareItemNotes(itmID, title, comment, icon, true);
            return true;
        end
    end
    return false;
end -- MarkForPlotting(kind, nameOrId, title, comment, icon, ...)

function ShaguDB_FillPrepare(tab, title, comment, icon)
    ShaguDB_Debug_Print(2, "FillPrepare(", title, ", ", comment, ", ", icon, tostring(tab), ")")
    if tab then
        local added = false;
        for k, v in tab do
            if (v[NOTE_TITLE] == title) and (not strfind(strlower(v[NOTE_COMMENT]), strlower(comment))) and (comment ~= v[NOTE_COMMENT]) then
                v[NOTE_ICON] = ShaguDB_CheckIcons(v[NOTE_ICON], icon);
                v[NOTE_COMMENT] = v[NOTE_COMMENT].."\n"..comment;
                added = true;
            elseif (strfind(strlower(v[NOTE_COMMENT]), strlower(comment))) or (comment == v[NOTE_COMMENT]) then
                added = true;
            end
        end
        if not added then
            table.insert(tab, {title, comment, icon})
        end
    else
        tab = {{title, comment, icon}};
    end
    return true;
end -- FillPrepare(tab, title, comment, icon)

function ShaguDB_GetQuestNotesById(questId)
    if qData[questId] then
        local quest = qData[questId];
        local title = ShaguDB_GetDifficultyColor(quest[DB_LEVEL]).."["..quest[DB_LEVEL].."] "..quest[DB_NAME].." (ID: "..questId..")|r";
        for k, v in pairs(quest[DB_STARTS]) do
            if v then
                for _, id in pairs(v) do
                    ShaguDB_Debug_Print(8, "    starts ", id)
                    local comment = "-";
                    local icon = "ExclamationMark";
                    if k == DB_NPC then comment = "|cFFa6a6a6Creature|r "..npcData[id][DB_NAME].." |cFFa6a6a6starts the quest|r";
                    elseif k == DB_OBJ then comment = "|cFFa6a6a6Object|r "..objData[id][DB_NAME].." |cFFa6a6a6starts the quest|r";
                    elseif k == DB_ITM then comment = "|cFFa6a6a6Aquire item|r "..itemData[id][DB_ITM_NAME].." |cFFa6a6a6 to start the quest|r";
                    end
                    ShaguDB_MarkForPlotting(k, id, title, comment, icon);
                end
            end
        end
        for k, v in pairs(quest[DB_ENDS]) do
            if v then
                for _, id in pairs(v) do
                    ShaguDB_Debug_Print(8, "    ends", id)
                    local comment = "+";
                    local icon = "QuestionMark";
                    if k == DB_NPC then comment = "|cFFa6a6a6Creature|r "..npcData[id][DB_NAME].." |cFFa6a6a6ends the quest|r";
                    elseif k == DB_OBJ then comment = "|cFFa6a6a6Object|r "..objData[id][DB_NAME].." |cFFa6a6a6ends the quest|r";
                    end
                    ShaguDB_MarkForPlotting(k, id, title, comment, icon);
                end
            end
        end
        for k, v in pairs(quest[DB_REQ_NPC_OR_OBJ_OR_ITM]) do
            if v then
                for _, list in pairs(v) do
                    if type(list) == "table" then
                        ShaguDB_Debug_Print(8, "    tables2 ", list[1], list[2], " - type ", k)
                        local id = list[1];
                        local text = nil;
                        if list[2] then
                            text = list[2]
                        end
                        local comment, icon = ".", 4;
                        if k == DB_NPC and text == nil and npcData[id] then comment = "|cFFa6a6a6'Creature'-type objective:|r "..npcData[id][DB_NAME]; icon = cMark;
                        elseif k == DB_NPC and text then comment = "|cFFa6a6a6'Creature'-type objective:|r "..text; icon = cMark;
                        elseif k == DB_OBJ and text == nil and objData[id] then comment = "|cFFa6a6a6'Object'-type objective:|r "..objData[id][DB_NAME]; icon = "Object";
                        elseif k == DB_OBJ and text then comment = "|cFFa6a6a6'Object'-type objective:|r "..text; icon = "Object";
                        elseif k == DB_ITM and text == nil and id ~= quest[DB_SRC_ITM] and itemData[id] then comment = "|cFFa6a6a6'Item'-type objective:|r "..itemData[id][DB_ITM_NAME]; icon = "Vendor";
                        elseif k == DB_ITM and text then comment = "|cFFa6a6a6Item type objective:|r "..text; icon = "Vendor";
                        end
                        if comment ~= "." and icon ~= 4 then ShaguDB_MarkForPlotting(k, id, title, comment, icon); end
                    end
                end
            end
        end
        if quest[DB_SRC_ITM] then
            if not (ShaguDB_PREPARE[DB_ITM][quest[DB_SRC_ITM]] == true) and itemData[quest[DB_SRC_ITM]] then
                ShaguDB_MarkForPlotting(DB_ITM, quest[DB_SRC_ITM], title, "|cFFa6a6a6Item related to quest:|r "..quest[DB_NAME], "Vendor");
            end
        end
    end
end -- GetQuestNotesById(questId)

-- Unused dev helper functions

function ShaguDB_CompareTables(tab1, tab2)
    for k, v in pairs(tab1) do
        if (type(v) == "table") then
            if not ShaguDB_CompareTables(v, tab2[k]) then
                return false;
            end
        else
            if not (v == tab2[k]) then
                return false;
            end
        end
    end
    return true;
end -- CompareTables(tab1, tab2)

function ShaguDB_PrintTable(tab, indent)
    if indent == nil then indent = 0; end
    local debugWin = 0;
    local name, shown;
    for i=1, NUM_CHAT_WINDOWS do
        name,_,_,_,_,_,shown = GetChatWindowInfo(i);
        if (string.lower(name) == "shagudebug") then debugWin = i; break; end
    end
    if (debugWin == 0) or (ShaguDB_Debug == 0) then return end
    local iString = "";
    local ind = indent;
    while (ind > 0) do
        iString = iString.."-";
        ind = ind -1;
    end
    for k, v in pairs(tab) do
        if (type(v) == "table") then
            getglobal("ChatFrame"..debugWin):AddMessage(iString.."["..k.."] = ", 1.0, 1.0, 0.3);
            ShaguDB_PrintTable(v, indent+1);
        else
            if (v) then
                local out = v;
                if (type(v) == "boolean") then
                    out = "true";
                end
                getglobal("ChatFrame"..debugWin):AddMessage(iString.."["..k.."] = "..out, 1.0, 1.0, 0.3);
            elseif v == false then
                getglobal("ChatFrame"..debugWin):AddMessage(iString.."["..k.."] = ".."false", 1.0, 1.0, 0.3);
            else
                getglobal("ChatFrame"..debugWin):AddMessage(iString.."["..k.."] = ".."nil", 1.0, 1.0, 0.3);
            end
        end
    end
end -- PrintTable(tab, indent)

function ShaguDB_GetQuestLogFootprint()
    ShaguDB_Debug_Print(4, "GetQuestLogFootprint() called");
    local questLogID=1;
    local footprint = "";
    local ids = {};
    while (GetQuestLogTitle(questLogID) ~= nil) do
        questLogID = questLogID + 1;
        local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(questLogID);
        if (isHeader == nil) and (questTitle) then
            ShaguDB_Debug_Print(4, "    logID, title, level, tag, isHeader, isComplete =", questLogID, questTitle, level, questTag, isHeader, isComplete);
            SelectQuestLogEntry(questLogID);
            local questDescription, questObjectives = GetQuestLogQuestText();
            local qIds = ShaguDB_GetQuestIDs(questTitle, questObjectives, level);
            local uId;
            if (type(qIds) == "number") then
                uId = qIds;
                ids[qIds] = true;
                if (ShaguDB_QuestAbandon == questTitle) then
                    ShaguDB_FinishedQuests[qIds] = -1;
                    ShaguDB_QuestAbandon = '';
                end
            else
                if type(qIds) == "table" then
                    for k, qId in pairs(qIds) do
                        ids[qId] = true;
                    end
                end
                uId = "MULTI_OR_NONE"
            end
            if (isComplete == nil) then
                isComplete = 'nil';
            end
            footprint = footprint.."'"..questTitle.."'"..level.."#"..uId.."#"..isComplete;
        end
    end
    return {strlower(footprint), ids}
end

function ShaguDB_FinishQuest(questId)
    if qData[questId] then
        ShaguDB_FinishedQuests[questId] = true;
    end
    WorldMapFrame:Hide();
    ShaguDB_CleanMap();
    if (ShaguDB_Settings.auto_plot) then
        ShaguDB_PlotAllQuests();
    else
        WorldMapFrame:Show();
    end
end
