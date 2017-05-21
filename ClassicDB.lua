-- Global Variables
cMark = "CdbIcon1";
--[[
0 = off
1 = standard debug notes
2 = most function calls
4 = event debug
8 = advanced
16 = other event debug attempt
Example: "CdbDebug = 6" shows 2 "most function calls" and 4 "event debug"
--]]
CdbDebug = 16;
-- This table is used to prepare new notes.
-- It holds npcs, objects, items and marked area triggers.
CdbPrepare = {{},{},{},{}};
-- This table holds a copy of the above table, in case it gets updated. Maybe redundant at the moment.
CdbCurrentNotes = {{},{},{},{}};
-- List of marked zones (Format: ["zoneName"] = true/false)
CdbMarkedZones = {};
-- Currently used zone for CycleMarkedZones().
CdbCycleZone = "";
-- Which zones have quest starts marked.
CdbQuestStartZones = {};
-- Used to prepare notes for being sent to Cartographer.
CdbMapNotes = {};
-- Number of current notes gets saved here (not counting quest starts).
CdbLastNoteCount = 0;
-- This variable is used to achieve different behaviour for quest start notes.
CdbInEvent = false;
-- These variables are used to determine types of Quest Log events (accept/abandon/finish/progress).
CdbQuestLogFootprint = {'',{}}; -- Holds a string representing the quest log state and a table of active quests, where the key is the quest id and the value just true
CdbQuestAbandon = ''; -- In the CdbInit function we hook two buttons to fill this string when a quest is really abandoned, so we know it wasn't finished during the next quest log check

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
DB_PRE_QUEST_GROUP = 12;
DB_PRE_QUEST_SINGLE = 13;
DB_SUB_QUESTS = 14;
DB_QUEST_GROUP = 15;
DB_EXCLUSIVE_QUEST_GROUP = 16;

-- function for event handeling
function CdbOnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    CdbDebugPrint(20, "Event() called", event, arg1, arg2, arg3);
    if (event == "PLAYER_LOGIN") then
        if (Cartographer_Notes ~= nil) then
            ClassicDBDB = {}; ClassicDBDBH = {};
            Cartographer_Notes:RegisterNotesDatabase("ClassicDB",ClassicDBDB,ClassicDBDBH);
            CdbDebugPrint(1, "ClassicDB: Cartographer Database Registered.");
        end

        -- load symbols
        Cartographer_Notes:RegisterIcon("CdbCreature", {
            text = "CdbCreature",
            path = "Interface\\WorldMap\\WorldMapPartyIcon",
            width = 12,
            height = 12,
        })
        Cartographer_Notes:RegisterIcon("CdbWaypoint", {
            text = "CdbWaypoint",
            path = "Interface\\WorldMap\\WorldMapPlayerIcon",
            width = 12,
            height = 12,
        })
        Cartographer_Notes:RegisterIcon("CdbQuestionMark", {
            text = "CdbQuestionMark",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\complete",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbExclamationMark", {
            text = "CdbExclamationMark",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\available",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbAreaTrigger", {
            text = "CdbAreaTrigger",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\event",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbVendor", {
            text = "CdbVendor",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\vendor",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbObject", {
            text = "CdbObject",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\icon_object",
            width = 16,
            height = 16,
        })

        -- Switched 3 and 7 for better contrast of colors follwing each other
        Cartographer_Notes:RegisterIcon("CdbIcon1", {
            text = "Mark 1",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\mk1",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbIcon2", {
            text = "Mark 2",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\mk2",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbIcon3", {
            text = "Mark 3",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\mk7",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbIcon4", {
            text = "Mark 4",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\mk4",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbIcon5", {
            text = "Mark 5",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\mk5",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbIcon6", {
            text = "Mark 6",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\mk6",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbIcon7", {
            text = "Mark 7",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\mk3",
            width = 16,
            height = 16,
        })
        Cartographer_Notes:RegisterIcon("CdbIcon8", {
            text = "Mark 8",
            path = "Interface\\AddOns\\ClassicDB\\symbols\\mk8",
            width = 16,
            height = 16,
        })

        if CdbMinimapEnabled == nil then
          CdbMinimapEnabled = true
        elseif CdbMinimapEnabled == false then
          CdbSearchGui.minimapButton:Hide()
        end

        if (CdbFinishedQuests == nil) then
            CdbFinishedQuests = {};
        end
        if (CdbSettings == nil) then
            CdbSettings = {};
        end
        CdbSettings["auto_plot"] = false;
        CdbSettings["item_item"] = false;
        if (CdbSettings["minDropChance"] == nil) then
            CdbSettings["minDropChance"] = 0;
        end
        if (CdbSettings["dbMode"] == nil) then
            CdbSettings["dbMode"] = false;
        end
        if (CdbSettings["waypoints"] == nil) then
            CdbSettings["waypoints"] = false;
        end
        if (CdbSettings["questStarts"] == nil) then
            CdbSettings["questStarts"] = false;
        end
        if (CdbSettings["filterReqLevel"] == nil) then
            CdbSettings["filterReqLevel"] = true;
        end
        if (CdbSettings["filterPreQuest"] == nil) then
            CdbSettings["filterPreQuest"] = true;
        end
        if (CdbSettings["questIds"] == nil) then
            CdbSettings["questIds"] = true;
        end
        if (CdbSettings["reqLevel"] == nil) then
            CdbSettings["reqLevel"] = true;
        end
        if (CdbSettings["player"] == nil) then
            CdbSettings["player"] = UnitName("player");
        end
        if (CdbSettings["race"] == nil) then
            CdbSettings["race"] = UnitRace("player");
        end
        if (CdbSettings["sex"] == nil) then
            local temp = UnitSex("player");
            if (temp == 3) then
                CdbSettings["sex"] = "Female";
            elseif (temp == 2) then
                CdbSettings["sex"] = "Male";
            else
                CdbSettings["sex"] = nil;
            end
        end
        if (CdbSettings["class"] == nil) then
            CdbSettings["class"] = UnitClass("player");
        end
        if (CdbSettings["faction"] == nil) then
            local temp = UnitFactionGroup("player");
            if (temp) then
                CdbSettings["faction"] = temp;
            end
        end
        if (CdbSettings.faction == "Alliance" and not CdbSettings.dbMode) then
            deleteFaction("H");
            CdbPrint("Horde data cleared.");
        elseif (CdbSettings.faction == "Horde" and not CdbSettings.dbMode) then
            deleteFaction("A");
            CdbPrint("Alliance data cleared.");
        else
            CdbPrint("DB Mode active, no quest data cleared.");
        end
        if not CdbSettings.dbMode then
            deleteClasses();
        end
        fillQuestLookup();
        CdbControlGui:Show();
        CdbPrint("ClassicDB Loaded.");
    elseif (event == "PLAYER_ENTERING_WORLD") then
        CdbSearchGui.minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52-(80*cos(CdbMinimapPosition)),(80*sin(CdbMinimapPosition))-52)
        for _, button in pairs(CdbControlGui.checkButtons) do
            CdbCheckSetting(button.settingName)
        end
        if CdbSettings.x ~= nil then
            CdbControlGui:SetPoint("TOPLEFT", CdbSettings.x, CdbSettings.y)
        else
            CdbControlGui:SetPoint("CENTER", 0, 0)
        end
        CdbSearchGui.inputField.updateSearch();
        CdbInit();
    elseif (event == "WORLD_MAP_UPDATE") and (WorldMapFrame:IsVisible()) and (CdbSettings.questStarts) then
        CdbDebugPrint(4, "    ", zone);
        CdbInEvent = true;
        CdbGetQuestStartNotes();
        CdbInEvent = false;
    elseif (event == "QUEST_LOG_UPDATE") then
        CdbAuxiliaryFrame:UnregisterEvent("QUEST_LOG_UPDATE");
        CdbHandleUpdateEvent();
    elseif (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player") then
        CdbAuxiliaryFrame:RegisterEvent("QUEST_LOG_UPDATE");
    end
end -- Event(event, arg1)

-- Create a "footprint" of the quest log.
-- Returns a table with two elements:
--     1. A string consisting of the names, ids, and some other characters
--        depending on its current state, for all quest in the quest log.
--     2. A sub-table of all those quests IDs. e.g. {[123] = true, [456] = true}
-- If there is more than one ID returned for a single quest, the string part for
-- that quest will say "MULTI_OR_NONE" and the ID table will contain all the
-- possible quest IDs.
function CdbGetQuestLogFootprint()
    CdbDebugPrint(4, "GetQuestLogFootprint() called");
    local oldQuestLogId = GetQuestLogSelection();
    local questLogID=1;
    local footprint = '';
    local ids = {};
    local registerNextEvent = false;
    while (GetQuestLogTitle(questLogID) ~= nil) do
        questLogID = questLogID + 1;
        local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(questLogID);
        if (isHeader == nil) and (questTitle) then
            CdbDebugPrint(4, "    logID, title, level, tag, isHeader, isComplete =", questLogID, questTitle, level, questTag, isHeader, isComplete);
            SelectQuestLogEntry(questLogID);
            local questDescription, questObjectives = GetQuestLogQuestText();
            local skip = false;
            if (isComplete == nil) then
                isComplete = '';
                CdbDebugPrint(4, "    title", questTitle);
                local numObjectives = GetNumQuestLeaderBoards(questLogID);
                if (numObjectives ~= nil) then
                    for i=1, numObjectives, 1 do
                        local text, objectiveType, finished = GetQuestLogLeaderBoard(i, arg1);
                        if not finished then
                            local i, j, itemName, numItems, numNeeded = strfind(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
                            if (itemName ~= nil) and ((strlen(itemName) == 1) or ((strlen(itemName) == 7 and strfind(itemName, "slain")) or (strlen(itemName) == 9 and strfind(itemName, "getötet")))) then
                                skip = true;
                            end
                            CdbDebugPrint(4, "    objective, have, need =", itemName, numItems, numNeeded);
                            if numItems and numNeeded then
                                isComplete = isComplete..numItems.."/"..numNeeded..";"
                            elseif itemName == nil then -- escorts, etc.
                                isComplete = isComplete..objectiveType..";";
                            end
                        else
                            isComplete = isComplete..objectiveType..";";
                        end
                    end
                end
            end
            --[[
            Safeguard against incorrect data during UNIT_QUEST_LOG_CHANGED? Not
            sure which event this was. UQLC event is currently not calling this
            function anymore, but leaving this here because it does no harm and
            the function might be called from elsewhere in the future.
            --]]
            if isComplete == '' then
                isComplete = "1";
            end
            local qIds = CdbGetQuestIds(questTitle, questObjectives, level);
            if not skip then
                local uId;
                if (type(qIds) == "number") then
                    uId = qIds;
                    ids[qIds] = true;
                else
                    if type(qIds) == "table" then
                        for k, qId in pairs(qIds) do
                            ids[qId] = true;
                        end
                    end
                    uId = "MULTI_OR_NONE"
                end
                footprint = footprint.."'"..questTitle.."'"..level..";"..uId..";"..isComplete;
            else
                CdbDebugPrint(16, "Missing WDB data, register next update event. Quest ID:", qIds);
                registerNextEvent = true;
            end
        end
    end
    if registerNextEvent then
        CdbAuxiliaryFrame:RegisterEvent("QUEST_LOG_UPDATE");
    end
    SelectQuestLogEntry(oldQuestLogId);
    return {strlower(footprint), ids}
end

-- Track accepting/finishing/abandoning quests, do automatic update if necessary.
-- For knowing which quest is abandoned two buttons are hooked in the CdbInit function.
function CdbHandleUpdateEvent()
    local footprint = CdbGetQuestLogFootprint(); -- {footprintString, questIdTable}
    CdbDebugPrint(16, "    footprint", footprint[1]);
    if (CdbQuestLogFootprint[1] ~= footprint[1]) then
        for questId, _ in pairs(footprint[2]) do
            if CdbQuestLogFootprint[2][questId] == nil then
                CdbDebugPrint(16, "    Quest accepted", questId);
                CdbFinishedQuests[questId] = false;
            end
        end
        local abandoned = false;
        for questId, _ in pairs(CdbQuestLogFootprint[2]) do
            if footprint[2][questId] == nil then
                if CdbFinishedQuests[questId] == false then
                    if qData[questId][DB_NAME] == CdbQuestAbandon then
                        CdbDebugPrint(16, "    Quest abandoned", questId);
                        CdbFinishedQuests[questId] = nil;
                        abandoned = true;
                    else
                        CdbDebugPrint(16, "    Quest finished", questId);
                        CdbFinishedQuests[questId] = true;
                    end
                end
            end
        end
        if abandoned then
            CdbQuestAbandon = '';
        end
        if (CdbSettings.questStarts == true) then
            CdbCleanMap();
            CdbReopenMapIfVisible();
        end
        if (CdbSettings.auto_plot == true) then
            CdbInEvent = true;
            CdbGetAllQuestNotes();
            CdbInEvent = false;
        end
    else
        CdbDebugPrint(16, "No change in quest log, register next update event.")
        CdbAuxiliaryFrame:RegisterEvent("QUEST_LOG_UPDATE");
    end
    CdbQuestLogFootprint = footprint;
end

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

function CdbInit()
    -- Hook buttons for abandoning quests.
    -- Credit for this approach goes to Questie: https://github.com/AeroScripts/QuestieDev
    CdbQuestAbandonOnAccept = StaticPopupDialogs["ABANDON_QUEST"].OnAccept;
    StaticPopupDialogs["ABANDON_QUEST"].OnAccept = function()
        CdbQuestAbandon = GetAbandonQuestName();
        CdbDebugPrint(16, "Abandon", CdbQuestAbandon);
        CdbQuestAbandonOnAccept();
    end
    CdbQuestAbandonWithItemsOnAccept = StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept;
    StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept = function()
        CdbQuestAbandon = GetAbandonQuestName();
        CdbDebugPrint(16, "Abandon", CdbQuestAbandon);
        CdbQuestAbandonWithItemsOnAccept();
    end

    -- Create the /classicdb SlashCommand
    SLASH_CLASSICDB1 = "/classicdb";
    SLASH_CLASSICDB2 = "/cdb";
    SlashCmdList["CLASSICDB"] = function(input, editbox)
        local params = {};
        if (input == "" or input == "help" or input == nil) then
            CdbPrint("|cff33ff88ClassicDB|cffffffff oooVersionooo |cff00ccff[" .. UnitFactionGroup("player") .. "]|cffaaaaaa [oooLocaleooo]");
            CdbPrint("Available Commands:");
            CdbPrint("/cdb |cffaaaaaa Alternative slash command for |r /classicdb");
            CdbPrint("/classicdb help |cffaaaaaa This help.");
            CdbPrint("/classicdb spawn <npc name> |cffaaaaaa Show NPC location on map.");
            CdbPrint("/classicdb obj <object name> |cffaaaaaa Show object location on map.");
            CdbPrint("/classicdb item <item name> |cffaaaaaa Show item drop info on map (includes vendors).");
            CdbPrint("/classicdb min [0, 101] |cffaaaaaa Minimum drop chance for items. 0 shows all, 101 none.");
            CdbPrint("/classicdb starts |cffaaaaaa Toggle: Automatically show quest starts on changing map.");
            CdbPrint("/classicdb quests <zone name> |cffaaaaaa - Show quest starts for a zone (the current one if no zone name is given).");
            CdbPrint("/classicdb hide <quest ID> |cffaaaaaa Prevent the given quest ID from being plotted to quest starts.");
            CdbPrint("/classicdb quest <quest name | quest ID> |cffaaaaaa - Show all points for quest, by either name or ID (name is case-sensitiv).");
            CdbPrint("/classicdb clean |cffaaaaaa - Clean the map. Disable automatic quest start and objective plotting.");
            CdbPrint("/classicdb minimap |cffaaaaaa - Toggle: Minimap icon.");
            CdbPrint("/classicdb auto |cffaaaaaa Toggle: Automatically plot uncompleted objectives on map.");
            CdbPrint("/classicdb waypoint |cffaaaaaa Toggle: Plot waypoints on map.");
            CdbPrint("/classicdb db |cffaaaaaa - Show database interface.");
            CdbPrint("/classicdb reset |cffaaaaaa Reset positon of the Interface.");
            CdbPrint("/classicdb clear |cffaaaaaa !THIS RELOADS THE UI! Delete ClassicDB Settings.");
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
            CdbPrint("Drops for: "..itemName);
            if (itemName and itemName ~= "") then
                if ((itemLookup[itemName]) and (itemData[itemLookup[itemName]])) then
                    CdbPrepareForDrawing(DB_ITM, itemName, itemName, "", 0);
                    CdbDrawNotesAndShowMap();
                end
            end
        elseif (arg1 == "vendor") then
            local itemName = arg2;
            CdbMapNotes = {};
            CdbPrepareItemNotes(itemName, "Vendors for: "..itemName, "Sells: "..itemName, "CdbVendor", {DB_VENDOR});
            CdbDrawNotesAndShowMap();
        elseif (arg1 == "spawn") then
            local monsterName = arg2;
            if (monsterName and monsterName ~= "") then
                CdbPrint("Location for: "..monsterName);
                if (monsterName ~= nil) then
                    npcID = CdbGetNpcId(monsterName)
                    if (npcData[npcID] ~= nil) then
                        zoneName = zoneData[npcData[npcID][DB_ZONE]];
                        if (zoneName == nil) then zoneName = npcData[npcID][DB_ZONE]; end
                        CdbPrint("    Zone: " .. zoneName);
                        if (CdbPrepareForDrawing(DB_NPC, monsterName, monsterName, CdbGetNpcStatsComment(monsterName, true), 0)) then
                            CdbDrawNotesAndShowMap();
                        end
                    else
                        CdbPrint("No location found.");
                    end
                end
            end
        elseif (arg1 == "quests") then
            local zoneName = arg2;
            if(zoneName == "")then
                zoneName = GetZoneText();
            end
            CdbMapNotes = {};
            CdbGetQuestStartNotes(zoneName);
            CdbDrawNotesAndShowMap();
        elseif (arg1 == "quest") then
            local questTitle = arg2;
            CdbMapNotes = {};
            local qIDs;
            if type(tonumber(questTitle)) == "number" then
                qIDs = tonumber(questTitle);
            elseif type(questTitle) == "string" then
                qIDs = CdbGetQuestIds(questTitle);
            end
            if type(qIDs) == "number" then
                CdbGetQuestNotesById(qIDs);
                CdbNextMark();
            elseif type(qIDs) == "table" then
                for _, qID in pairs(qIDs) do
                    CdbGetQuestNotesById(qID);
                    CdbNextMark();
                end
            end
            CdbDrawNotesAndShowMap();
        elseif (arg1 == "minimap") then
            if (CdbSearchGui.minimapButton:IsShown()) then
                CdbSearchGui.minimapButton:Hide()
                CdbMinimapEnabled = false
            else
                CdbSearchGui.minimapButton:Show()
                CdbMinimapEnabled = true
            end
        elseif (arg1 == "db") then
            if (CdbSearchGui:IsShown()) then
                CdbSearchGui:Hide()
            else
                CdbSearchGui:Show()
            end
        elseif (arg1 == "min") then
            local number = tonumber(arg2);
            if number then
                local value = abs(number);
                if value > 101 then
                    value = 101;
                end
                CdbSettings.minDropChance = value;
                CdbPrint("Minimum Drop Chance set to: "..value.."%");
            else
                CdbPrint("Minimum Drop Chance is: "..CdbSettings.minDropChance.."%");
            end
        elseif (arg1 == "obj") then
            local objName = string.sub(input, 5);
            if (objName ~= "") then
                CdbPrint("Locations for: "..objName);
                if (objName ~= nil) then
                    if (CdbPrepareForDrawing(DB_OBJ, objName, objName, "This object can be found here", 0)) then
                        CdbDrawNotesAndShowMap();
                    else
                        CdbPrint("No locations found.");
                    end
                end
            end
        elseif (arg1 == "clean") then
            CdbCleanMapAndPreventRedraw();
        elseif (arg1 == "auto") then
            CdbSwitchSetting("auto_plot");
        elseif (arg1 == "waypoint") then
            CdbSwitchSetting("waypoints");
        elseif (arg1 == "starts") then
            CdbSwitchSetting("questStarts");
        elseif (arg1 == "hide") then
            local questId = tonumber(string.sub(input, 6));
            if qData[questId] then
                CdbFinishedQuests[questId] = true;
            end
        elseif (arg1 == "reset") then
            CdbResetGui();
        elseif (arg1 == "clear") then
            CdbSettings = nil;
            ReloadUI();
        end
    end;
end -- Init()

function CdbPrint(string)
  DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. string);
end -- Print(string)

function CdbNextMark()
  if (cMark == "CdbIcon1") then
    cMark = "CdbIcon2";
  elseif (cMark == "CdbIcon2") then
    cMark = "CdbIcon3";
  elseif (cMark == "CdbIcon3") then
    cMark = "CdbIcon4";
  elseif (cMark == "CdbIcon4") then
    cMark = "CdbIcon5";
  elseif (cMark == "CdbIcon5") then
    cMark = "CdbIcon6";
  elseif (cMark == "CdbIcon6") then
    cMark = "CdbIcon7";
  elseif (cMark == "CdbIcon7") then
    cMark = "CdbIcon8";
  elseif (cMark == "CdbIcon8") then
    cMark = "CdbIcon1";
  else
    cMark = "CdbIcon1";
  end
end -- NextCMark()

function CdbCleanMap()
    CdbDebugPrint(2, "CleanMap() called");
    if (Cartographer_Notes ~= nil) then
        Cartographer_Notes:UnregisterNotesDatabase("ClassicDB");
        ClassicDBDB = {}; ClassicDBDBH = {};
        Cartographer_Notes:RegisterNotesDatabase("ClassicDB",ClassicDBDB,ClassicDBDBH);
    end
    CdbMarkedZones = {};
    CdbCycleZone = "";
    CdbQuestStartZones = {};
    CdbCurrentNotes = {{},{},{},{}};
    CdbMapNotes = {};
end -- CleanMap()

function CdbDrawNotesAndShowMap()
    CdbDebugPrint(2, "ShowMap() called");
    local ShowMapZone, ShowMapTitle, ShowMapID = CdbDrawNotesOnMap();
    if (Cartographer) then
        if WorldMapFrame:IsVisible() then
            CdbReopenMapIfVisible();
        elseif (ShowMapZone ~= nil) then
            WorldMapFrame:Show();
            SetMapZoom(CdbGetZoneIdFromZoneName(ShowMapZone));
        end
    end
end -- ShowMap()

function CdbCheckIcons(a, b)
    if a ~= -1 then
        if a ~= b then
            if (a == 2 or b == 2 or a == "CdbQuestionMark" or b == "CdbQuestionMark") then
                a = 2;
            elseif (a == 5 or b == 5 or a == "CdbExclamationMark" or b == "CdbExclamationMark") then
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

function CdbDrawNotesOnMap()
    CdbDebugPrint(2, "PlotNotesOnMap() called");

    if CdbPrepare[DB_NPC] then
        for k, npcMarks in CdbPrepare[DB_NPC] do
            local noteTitle, comment, icon = '', '', -1;
            if CdbGetTableLength(npcMarks) > 1 then
                noteTitle = npcData[k][DB_NAME];
                for key, note in pairs(npcMarks) do
                    comment = comment.."\n"..note[NOTE_TITLE].."\n"..note[NOTE_COMMENT].."\n";
                    icon = CdbCheckIcons(icon, note[NOTE_ICON])
                end
                if (icon ~= 2) and (icon ~= 5) and (icon ~= 6) then
                    comment = CdbGetNpcStatsComment(k, true)..comment;
                    local st, en = string.find(comment, "|c.-|r");
                    noteTitle = string.sub(comment, st, en);
                    comment = string.sub(comment, en+2);
                end
                CdbGetNpcNotes(k, noteTitle, comment, icon);
            else
                for key, v in pairs(npcMarks) do
                    if (v[NOTE_ICON] ~= 2) and (v[NOTE_ICON] ~= 5) and (v[NOTE_ICON] ~= 6) then
                        comment = CdbGetNpcStatsComment(k, true)..comment;
                    end
                    CdbGetNpcNotes(k, v[NOTE_TITLE], comment..v[NOTE_COMMENT], v[NOTE_ICON]);
                end
            end
        end
    end
    if CdbPrepare[DB_OBJ] then
        for k, objMarks in CdbPrepare[DB_OBJ] do
            local noteTitle, comment, icon = '', '', -1;
            if CdbGetTableLength(objMarks) > 1 then
                noteTitle = objData[k][DB_NAME];
                for key, note in pairs(objMarks) do
                    comment = comment.."\n"..note[NOTE_TITLE].."\n"..note[NOTE_COMMENT].."\n";
                    icon = CdbCheckIcons(icon, note[NOTE_ICON])
                end
                CdbGetObjNotes(k, noteTitle, comment, icon);
            else
                for key, v in pairs(objMarks) do
                    CdbGetObjNotes(k, v[NOTE_TITLE], v[NOTE_COMMENT], v[NOTE_ICON]);
                end
            end
        end
    end
    if CdbPrepare[DB_TRIGGER_MARKED] then
        for questId, _ in CdbPrepare[DB_TRIGGER_MARKED] do
            local color = CdbGetQuestDifficultyColor(qData[questId][DB_LEVEL]);
            local level = qData[questId][DB_LEVEL];
            if level == -1 then level = UnitLevel("player"); end
            local title = color.."Location for: ".."["..level.."] "..qData[questId][DB_NAME].."|r";
            for zoneId, coords in pairs(qData[questId][DB_TRIGGER][2]) do
                for _, coord in pairs(coords) do
                    table.insert(CdbMapNotes,{zoneData[zoneId], coord[1], coord[2], title, "|cFF00FF00"..qData[questId][DB_TRIGGER][1].."|r", 7});
                end
            end
        end
    end
    CdbCurrentNotes = CdbPrepare;
    CdbPrepare = {{},{},{},{}};

    if CdbMapNotes == {} then
        return false, false, false;
    end
    local firstNote = 1;

    local zone = nil;
    local title = nil;
    local noteID = nil;

    for nKey, nData in ipairs(CdbMapNotes) do
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
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "CdbCreature", "ClassicDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 1) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "Diamond", "ClassicDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 2) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "CdbQuestionMark", "ClassicDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 3) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "CdbWaypoint", "ClassicDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 4) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "Cross", "ClassicDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 5) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "CdbExclamationMark", "ClassicDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 6) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "CdbVendor", "ClassicDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] == 7) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, "CdbAreaTrigger", "ClassicDB", 'title', nData[4], 'info', nData[5]);
            elseif (nData[6] ~= nil) then
                Cartographer_Notes:SetNote(nData[1], nData[2]/100, nData[3]/100, nData[6], "ClassicDB", 'title', nData[4], 'info', nData[5]);
            end
        end
        if (nData[1] ~= nil) and (not instance) then
            zone = nData[1];
            if nData[6] ~= 5 then
                CdbMarkedZones[zone] = true;
            end
            title = nData[4];
        end
    end
    if (table.getn(CdbMapNotes) ~= nil) and (not CdbInEvent) then
        local notes = table.getn(CdbMapNotes);
        if (notes ~= CdbLastNoteCount) then
            CdbPrint(notes.." notes plotted.");
            CdbLastNoteCount = notes;
        end
        CdbPrint(CdbGetTableLength(CdbMarkedZones).." zones marked.");
    end
    CdbMapNotes = {}
    return zone, title, noteID;
end -- PlotNotesOnMap()

function CdbGetZoneIdFromZoneName(zoneText)
    CdbDebugPrint(2, "GetMapIDFromZone(", zoneText, ") called");
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
  local oldQuestLogId = GetQuestLogSelection();

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
  SelectQuestLogEntry(oldQuestLogId);
end -- SetItemRef (link, text, button)

----------------------------------------------------
--Merge
----------------------------------------------------

--------------------------------------------------------
-- Wowhead DB By: UniRing
--------------------------------------------------------
-- Wowhead DB Continued By: Muehe
--------------------------------------------------------

function CdbCycleMarkedZones(reversed)
    local currentlyShown = zoneData[CdbGetCurrentZoneId()];
    if CdbCycleZone == "" and currentlyShown then CdbCycleZone = currentlyShown; end
    local lastZone = nil;
    if CdbCycleZone ~= "" then
        local found = false;
        for k, v in pairs(CdbMarkedZones) do
            if found then -- last loop was match, cycle forward to current entry
                CdbCycleZone = k;
                SetMapZoom(CdbGetZoneIdFromZoneName(k));
                return;
            end
            if k == CdbCycleZone then
                if reversed and lastZone ~= nil then -- cycle backwards
                    CdbCycleZone = lastZone;
                    SetMapZoom(CdbGetZoneIdFromZoneName(lastZone));
                    return;
                elseif reversed then -- first entry is match, cycle backwards to last
                    for k, v in pairs(CdbMarkedZones) do
                        lastZone = k;
                    end
                    CdbCycleZone = lastZone;
                    SetMapZoom(CdbGetZoneIdFromZoneName(lastZone));
                    return;
                else -- cycle forward in the next loop or after leaving the loop
                    found = true;
                end
            else
                lastZone = k;
            end
        end
        -- last entry is match or no match, cycle forward to first
        for k, v in pairs(CdbMarkedZones) do
            CdbCycleZone = k;
            SetMapZoom(CdbGetZoneIdFromZoneName(k));
            return;
        end
    else -- no last cycled-to zone is set
        for k, v in pairs(CdbMarkedZones) do
            CdbCycleZone = k;
            SetMapZoom(CdbGetZoneIdFromZoneName(k));
            return;
        end
    end
end -- CycleMarkedZones()

-- Debug print function. Credits to Questie.
function CdbDebugPrint(...)
    local debugWin = 0;
    local name, shown;
    for i=1, NUM_CHAT_WINDOWS do
        name,_,_,_,_,_,shown = GetChatWindowInfo(i);
        if (string.lower(name) == "shagudebug") then debugWin = i; break; end
    end
    if (debugWin == 0) or (CdbDebug == 0) or (bit.band(arg[1], CdbDebug) == 0) then return end
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
            CdbPrintTable(arg[i]);
        else
            out = out .. t;
        end
    end
    getglobal("ChatFrame"..debugWin):AddMessage(out, 1.0, 1.0, 0.3);
end -- Debug_Print(...)

-- TODO debug
function CdbResetGui()
    CdbSearchGui:ClearAllPoints();
    CdbSearchGui:SetPoint("CENTER", 0, 0);
    CdbControlGui:ClearAllPoints();
    CdbControlGui:SetPoint("BOTTOMLEFT", "CdbSearchGui", "BOTTOMRIGHT", 0, 0);
    CdbSearchGui:Show();
    CdbControlGui:Show();
end -- ResetGui()

function CdbGetAllQuestNotes()
    CdbDebugPrint(2, "PlotAllQuests() called");
    local oldQuestLogId = GetQuestLogSelection();
    local questLogID=1;
    CdbMapNotes = {};
    while (GetQuestLogTitle(questLogID) ~= nil) do
        questLogID = questLogID + 1;
        CdbGetQuestNotes(questLogID)
    end
    CdbQuestStartZones = {};
    CdbCleanMap();
    if CdbInEvent == true then
        CdbDrawNotesOnMap();
        CdbReopenMapIfVisible();
    else
        CdbDrawNotesAndShowMap();
    end
    SelectQuestLogEntry(oldQuestLogId);
end -- PlotAllQuests()

-- called from xml
function CdbCleanMapAndPreventRedraw()
    CdbDebugPrint(2, "DoCleanMap() called");
    if (CdbSettings.auto_plot) then
        CdbSettings.auto_plot = false;
        CdbCheckSetting("auto_plot")
        CdbPrint("Auto plotting disabled.");
    end
    if (CdbSettings.questStarts) then
        CdbSettings.questStarts = false;
        CdbCheckSetting("questStarts")
        CdbPrint("Quest start plotting disabled.");
    end
    CdbCleanMap();
end -- DoCleanMap()

function CdbSearchEndNpc(questID)
    CdbDebugPrint(2, "SearchEndNPC(", questID, ") called");
    for npc, data in pairs(npcData) do
        if (data[DB_NPC_ENDS] ~= nil) then
            for line, entry in pairs(data[DB_NPC_ENDS]) do
                if (entry == questID) then return npc; end
            end
        end
    end
    return nil;
end -- SearchEndNPC(questID)

function CdbSearchEndObj(questID)
    CdbDebugPrint(2, "SearchEndObj(", questID, ") called");
    for obj, data in pairs(objData) do
        if (data[DB_ENDS] ~= nil) then
            for line, entry in pairs(data[DB_ENDS]) do
                if (entry == questID) then return obj; end
            end
        end
    end
    return nil;
end -- SearchEndObj(questID)

function CdbGetQuestEndNotes(questLogID)
    CdbDebugPrint(2, "GetQuestEndNotes(", questLogID, ") called");
    local questTitle, level = GetQuestLogTitle(questLogID);
    local oldQuestLogId = GetQuestLogSelection();
    SelectQuestLogEntry(questLogID);
    local questDescription, questObjectives = GetQuestLogQuestText();
    if (questObjectives == nil) then questObjectives = ''; end
    local qIDs = CdbGetQuestIds(questTitle, questObjectives, level);
    if qIDs ~= false then
        CdbDebugPrint(8, "    ", type(qIDs));
    end
    if (qIDs ~= false) then
        if (type(qIDs) == "table") then
            local multi = 0;
            local npcIDs = {}
            for _, qID in pairs(qIDs) do
                multi = multi + 1;
                local npcID = CdbSearchEndNpc(qID);
                if (npcID) then
                    local done = false;
                    for _, IDInside in pairs(npcIDs) do
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
                        CdbPrepareForDrawing(DB_NPC, npcID, commentTitle, "Finished by: |cFFa6a6a6"..comment.."|r", 2);
                    end
                else
                    local npcID = npcIDs[1]
                    local comment = npcData[npcID][DB_NAME].."\n(Ends "..multi.." quests with this name)"
                    return CdbPrepareForDrawing(DB_NPC, npcID, "|cFF33FF00"..questTitle.." (Complete)|r", "Finished by: |cFFa6a6a6"..comment.."|r", 2);
                end
            else
                local objIDs = {}
                for _, qID in pairs(qIDs) do
                    local objID = CdbSearchEndObj(qID);
                    if (objID) then
                        local done = false;
                        for _, IDInside in pairs(objIDs) do
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
                            CdbPrepareForDrawing(DB_OBJ, objID, commentTitle, "Finished by: |cFFa6a6a6"..comment.."|r", 2);
                        end
                    else
                        local objID = objIDs[1]
                        local comment = objData[objID][DB_NAME].."\n(Ends "..multi.." quests with this name)"
                        return CdbPrepareForDrawing(DB_OBJ, objID, "|cFF33FF00"..questTitle.." (Complete)|r", "Finished by: |cFFa6a6a6"..comment.."|r", 2);
                    end
                else
                    return false;
                end
            end
            return true;
        elseif (type(qIDs) == "number") then
            local npcID = CdbSearchEndNpc(qIDs);
            if npcID and npcData[npcID] then
                local name = npcData[npcID][DB_NAME];
                return CdbPrepareForDrawing(DB_NPC, npcID, "|cFF33FF00"..questTitle.." (Complete)|r", "Finished by: |cFFa6a6a6"..name.."|r", 2);
            else
                local objID = CdbSearchEndObj(qIDs);
                if objID and objData[objID] then
                    local name = objData[objID][DB_NAME];
                    return CdbPrepareForDrawing(DB_OBJ, objID, "|cFF33FF00"..questTitle.." (Complete)|r", "Finished by: |cFFa6a6a6"..name.."|r", 2);
                else
                    return false;
                end
            end
        end
    else
        return false;
    end
    SelectQuestLogEntry(oldQuestLogId);
end -- GetQuestEndNotes(questLogID)

function CdbGetQuestIds(questName, objectives, ...)
    if not qLookup[questName] then
        return false;
    end
    local qIDs = {};
    if (objectives == nil) then objectives = ''; end
    CdbDebugPrint(2, "GetQuestIDs('", questName, "', '", objectives, "')", arg[1]);
    if (CdbGetTableLength(qLookup[questName]) == 1) then
        for k, v in pairs(qLookup[questName]) do
            CdbDebugPrint(8, "    Possible questIDs: 1");
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
        if (CdbGetTableLength(qIDs) > 1) then
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
    local length = CdbGetTableLength(qIDs);
    CdbDebugPrint(8, "    Possible questIDs: ", length);
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
function CdbGetNpcId(npcName)
    CdbDebugPrint(2, "GetNPCID(", npcName, ") called");
    for npcid, data in pairs(npcData) do
        if (data[DB_NAME] == npcName) then return npcid; end
    end
    return false;
end -- GetNPCID(npcName)

function CdbGetObjIds(objName)
    CdbDebugPrint(2, "GetObjID(", objName, ") called");
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

CdbSettingsText = {
        ["waypoints"] = "Show waypoints",
        ["auto_plot"] = "Automatic quest note update",
        ["questStarts"] = "Show quest starts",
        ["reqLevel"] = "Show required level in quest start tooltips",
        ["filterPreQuest"] = "Filter quest starts based on finished quests",
        ["filterReqLevel"] = "Filter quest starts based on required level",
        ["questIds"] = "Show quest IDs in tooltips (currently unused)",
        ["dbMode"] = "DB Mode",
        ["item_item"] = "Show items dropped by items",
};

function CdbSwitchSetting(setting, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    if (CdbSettings[setting] == false) then
        CdbSettings[setting] = true;
        CdbPrint(CdbSettingsText[setting].." enabled.");
    elseif (setting == "minDropChance") then
        local number = tonumber(arg1);
        if (number) and (number >= 0 and number <= 101) then
            CdbSettings[setting] = number;
            CdbPrint(CdbSettingsText[setting].." set to: "..number);
        else
            CdbPrint(CdbSettingsText[setting].." is: "..CdbSettings[setting]);
        end
    else
        CdbSettings[setting] = false;
        CdbPrint(CdbSettingsText[setting].." disabled.");
    end
    CdbCheckSetting(setting);
    if (setting == "auto_plot") and (CdbSettings[setting]) then
        CdbGetAllQuestNotes();
    elseif (setting == "auto_plot") and (not CdbSettings[setting]) then
        CdbCleanMap();
        CdbReopenMapIfVisible();
    elseif (setting == "questStarts") and (CdbSettings[setting]) then
        CdbReopenMapIfVisible();
    elseif (setting == "questStarts") and (not CdbSettings[setting]) then
        CdbCleanMap();
        if CdbSettings.auto_plot then
            CdbGetAllQuestNotes();
        end
    end
end -- SwitchSetting(setting)

function CdbGetSetting(setting, ...)
    if (CdbSettingsText[setting]) and (CdbSettings[setting]) then
        return CdbSettingsText[setting].." is|cFF40C040 enabled|r";
    elseif (CdbSettingsText[setting]) then
        return CdbSettingsText[setting].." is|cFFFF1A1A disabled|r";
    end
end -- GetSetting(setting, ...)

function CdbCheckSetting(setting)
    if (setting ~= "waypoints") and (setting ~= "auto_plot") and (setting ~= "questStarts") then
        return;
    end
    if (CdbSettings[setting] == true) then
        CdbControlGui.checkButtons[CdbControlGui.checkButtonValues[setting].position]:SetChecked(true);
    else
        CdbControlGui.checkButtons[CdbControlGui.checkButtonValues[setting].position]:SetChecked(false);
    end
end -- CheckSetting(setting)

-- tries to get locations for an NPC and inserts them in CdbMapNotes if found
function CdbGetNpcNotes(npcNameOrID, commentTitle, comment, icon)
    if (npcNameOrID ~= nil) then
        CdbDebugPrint(2, "GetNPCNotes(", npcNameOrID, ") called");
        local npcID;
        if (type(npcNameOrID) == "string") then
            npcID = CdbGetNpcId(npcNameOrID);
        else
            npcID = npcNameOrID;
        end
        if (npcData[npcID] ~= nil) then
            local showMap = false;
            if (npcData[npcID][DB_NPC_WAYPOINTS] and CdbSettings.waypoints == true) then
                for zoneID, coordsdata in pairs(npcData[npcID][DB_NPC_WAYPOINTS]) do
                    zoneName = zoneData[zoneID];
                    for cID, coords in pairs(coordsdata) do
                        if (coords[1] == -1) then
                            for id, data in pairs(instanceData[zoneID]) do
                                noteZone = zoneData[data[1] ];
                                coordx = data[2];
                                coordy = data[3];
                                table.insert(CdbMapNotes,{noteZone, coordx, coordy, commentTitle, "|cFF00FF00Instance Entry to "..zoneName.."|r\n"..comment, icon});
                            end
                            break;
                        end
                        coordx = coords[1];
                        coordy = coords[2];
                        table.insert(CdbMapNotes,{zoneName, coordx, coordy, commentTitle, comment, 3});
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
                                    table.insert(CdbMapNotes,{noteZone, coordx, coordy, commentTitle, "|cFF00FF00Instance Entry to "..zoneName.."|r\n"..comment, icon});
                                end
                            end
                            coordx = coords[1];
                            coordy = coords[2];
                            table.insert(CdbMapNotes,{zoneName, coordx, coordy, commentTitle, comment, icon});
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

-- tries to get locations for an (ingame) object and inserts them in CdbMapNotes if found
function CdbGetObjNotes(objNameOrID, commentTitle, comment, icon)
    CdbDebugPrint(2, "GetObjNotes(objNameOrID, commentTitle, comment, icon) called");
    if (objNameOrID ~= nil) then
        local objIDs;
        if (type(objNameOrID) == "string") then
            objIDs = CdbGetObjIds(objNameOrID);
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
                                table.insert(CdbMapNotes,{zoneName, coordx, coordy, commentTitle, comment, icon});
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

function CdbPrepareItemNotes(itemNameOrID, commentTitle, comment, icon, types)
    CdbDebugPrint(2, "PrepareItemNotes(", itemNameOrID, ") called");
    local itemID = 0;
    if (type(itemNameOrID) == "number") then
        itemID = itemNameOrID;
    elseif (type(itemNameOrID) == "string") then
        itemID = itemLookup[itemNameOrID];
    end
    if itemID ~= 0 then
        CdbPrepare[DB_ITM][itemID] = true;
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
        CdbDebugPrint(8, "    ", types);
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
                    if (CdbSettings.minDropChance > 0) and (value[2] < CdbSettings.minDropChance) then
                        show = false;
                    end
                    if show then
                        local dropComment = " ("..value[2].."%)";
                        showMap = CdbPrepareForDrawing(DB_NPC, value[1], commentTitle, comment..dropComment, icon) or showMap;
                    end
                end
            end
        end
        if (itemData[itemID][DB_OBJ]) and ((showType == nil) or (showType[DB_OBJ])) then
            for key, value in pairs(itemData[itemID][DB_OBJ]) do
                if objData[value[1]] then
                    local show = true;
                    if (CdbSettings.minDropChance > 0) and (value[2] < CdbSettings.minDropChance) then
                        show = false;
                    end
                    if show then
                        local dropComment = objData[value[1]][DB_NAME].."\n"..comment.." ("..value[2].."%)";
                        showMap = CdbPrepareForDrawing(DB_OBJ, objData[value[1]][DB_NAME], commentTitle, dropComment, icon) or showMap;
                    end
                end
            end
        end
        if (itemData[itemID][DB_ITM]) and (CdbSettings.item_item) and ((showType == nil) or (showType[DB_ITM])) then
            for key, value in pairs(itemData[itemID][DB_ITM]) do
                local show = true;
                if (CdbSettings.minDropChance > 0) and (value[2] < CdbSettings.minDropChance) then
                    show = false;
                end
                if show then
                    local dropComment = "|cFF00FF00"..value[2].."% chance of containing "..commentTitle.."|r\n"
                    showMap = CdbPrepareItemNotes(value[1], commentTitle, dropComment..comment, icon, true) or showMap;
                end
            end
        end
        if (itemData[itemID][DB_VENDOR]) and ((showType == nil) or (showType[DB_VENDOR])) then
            for key, value in pairs(itemData[itemID][DB_VENDOR]) do
                local npc, maxcount, increaseTime = value[1], value[2], value[3];
                if npcData[npc] then
                    local sellComment = '';
                    if maxcount then
                        sellComment = "Sold by: "..npcData[npc][DB_NAME].."\nMax available: "..maxcount.."\nRestock time: "..CdbGetTimeString(increaseTime).."\n"..comment;
                    else
                        sellComment = "Sold by: "..npcData[npc][DB_NAME].."\n"..comment;
                    end
                    showMap = CdbPrepareForDrawing(DB_NPC, npc, commentTitle, sellComment, 6) or showMap;
                else
                    CdbDebugPrint(1, "Spawn Error for NPC", npc);
                end
            end
        end
        return showMap;
    else
        return false;
    end
end -- PrepareItemNotes(itemNameOrID, commentTitle, comment, icon, types)

function CdbGetTimeString(seconds)
    local hour, minute, second;
    hour = math.floor(seconds/(60*60));
    minute = math.floor(mod(seconds/60, 60));
    second = mod(seconds, 60);
    return string.format("%.2d:%.2d:%.2d", hour, minute, second);
end -- GetTimeString(seconds)

function CdbGetSpecialNpcNotes(qId, objectiveText, numItems, numNeeded, title)
    local showMap = false;
    for _, v in pairs(qData[qId][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_NPC]) do
        if v[2] ~= nil and v[2] == objectiveText then
            local comment = "|cFF00FF00"..objectiveText..":  "..numItems.."/"..numNeeded.."|r";
            showMap = CdbPrepareForDrawing(DB_NPC, v[1], title, comment, cMark) or showMap;
        end
    end
    return showMap;
end -- GetSpecialNpcNotes(qId, objectiveText, numItems, numNeeded, title)

function CdbGetQuestNotes(questLogID)
    CdbDebugPrint(18, "GetQuestNotes(questLogID) called", questLogID);
    local oldQuestLogId = GetQuestLogSelection();
    local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(questLogID);
    local showMap = false;
    if (not isHeader and questTitle ~= nil) then
        CdbDebugPrint(24, "    questTitle = ", questTitle);
        CdbDebugPrint(8, "    level = ", level);
        CdbDebugPrint(24, "    isComplete = ", isComplete);
        local numObjectives = GetNumQuestLeaderBoards(questLogID);
        if (numObjectives ~= nil) then
            CdbDebugPrint(24, "    numObjectives = ", numObjectives);
        end
        SelectQuestLogEntry(questLogID);
        local questDescription, questObjectives = GetQuestLogQuestText();
        local qIDs = CdbGetQuestIds(questTitle, questObjectives, level);
        local title = "";
        if (type(qIDs) == "number") then
            CdbDebugPrint(8, "    qID = ", qIDs);
            local level = qData[qIDs][DB_LEVEL];
            if level == -1 then level = UnitLevel("player"); end
            title = CdbGetQuestDifficultyColor(qData[qIDs][DB_LEVEL]).."["..level.."] "..questTitle.."|r";
        elseif (type(qIDs) == "table") then
            numQuests = 0;
            for k, qID in pairs(qIDs) do
                CdbDebugPrint(8, "    qID[", k, "] = ", qID);
                numQuests = numQuests + 1;
            end
            title = questTitle.."|cFFa6a6a6 (there are "..numQuests.." Quests with this name)|r";
        else
            CdbDebugPrint(1, "Failed to find Quest ID for: ", questTitle)
            title = questTitle
        end
        local itemList = {};
        if (numObjectives ~= nil) and (numObjectives ~= 0) then
            -- Add objective notes by quest log state
            for i=1, numObjectives, 1 do
                local text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogID);
                local i, j, itemName, numItems, numNeeded = strfind(text, "(.*):%s*([%d]+)%s*/%s*([%d]+)");
                if itemName then
                    CdbDebugPrint(24, "    i, j, itemName, numItems, numNeeded = ", i, j, itemName, numItems, numNeeded);
                end
                if (not finished) then
                    if (objectiveType == "monster") then
                        CdbDebugPrint(8, "    type = monster");
                        local i, j, monsterName = strfind(itemName, "(.*) slain");
                        if i == nil then
                            i, j, monsterName = strfind(itemName, "(.*) getötet");
                        end
                        CdbDebugPrint(16, "    monsterName = ", monsterName);
                        if monsterName then
                            local npcID = CdbGetNpcId(monsterName);
                            if npcID then
                                local comment = "|cFF00FF00"..itemName..":  "..numItems.."/"..numNeeded.."|r";
                                showMap = CdbPrepareForDrawing(DB_NPC, npcID, title, comment, cMark) or showMap;
                            end
                        else
                            if (type(qIDs) == "number") then
                                showMap = CdbGetSpecialNpcNotes(qIDs, itemName, numItems, numNeeded, title) or showMap;
                            elseif (type(qIDs) == "table") then
                                for _, qId in pairs(qIDs) do
                                    showMap = CdbGetSpecialNpcNotes(qId, itemName, numItems, numNeeded, title) or showMap;
                                end
                            end
                        end
                    elseif (objectiveType == "item") then
                        CdbDebugPrint(8, "    type = item");
                        local itemID = itemLookup[itemName];
                        if (itemID and (itemData[itemID])) then
                            itemList[itemID] = true;
                            local comment = "|cFF00FF00"..itemName..": "..numItems.."/"..numNeeded.."|r"
                            showMap = CdbPrepareItemNotes(itemID, title, comment, cMark, true) or showMap;
                        end
                    elseif (objectiveType == "object") then
                        CdbDebugPrint(8, "    type = object");
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
                                        CdbPrepareForDrawing(DB_OBJ, objectId, title, comment, "CdbObject");
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
                                            CdbPrepareForDrawing(DB_OBJ, objectId, title, comment, "CdbObject");
                                        end
                                    end
                                end
                            end
                        end
                    elseif (objectiveType == "event") then
                        if (type(qIDs) == "number") then
                            if qData[qIDs][DB_TRIGGER] then
                                CdbPrepare[DB_TRIGGER_MARKED][qIDs] = true;
                            end
                        elseif (type(qIDs) == "table") then
                            for k, qID in pairs(qIDs) do
                                if qData[qIDs][DB_TRIGGER] then
                                    CdbPrepare[DB_TRIGGER_MARKED][qID] = true;
                                end
                            end
                        end
                    -- checks for objective type other than item/monster/object, e.g. reputation, event
                    elseif (objectiveType ~= "item" and objectiveType ~= "monster" and objectiveType ~= "object" and objectiveType ~= "event") then
                        CdbDebugPrint(1, "    ", objectiveType, " quest objective-type not supported yet");
                    end
                elseif (objectiveType == "item") then
                    CdbDebugPrint(8, "    type = item");
                    local itemID = itemLookup[itemName];
                    if (itemID and (itemData[itemID])) then
                        itemList[itemID] = true;
                    end
                end
            end
            -- Add additional items not show in the quest log
            if (not isComplete) then
                if (type(qIDs) == "number") then
                    CdbDebugPrint(8, "    Quest related drop for: ", qIDs)
                    if qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_ITM] then
                        for k, item in pairs(qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_ITM]) do
                            if (itemData[item[1]] and itemList[item[1]] == nil) then
                                local comment = "Drop for quest related item:\n"..itemData[item[1]][DB_ITM_NAME];
                                showMap = CdbPrepareItemNotes(item[1], title, comment, cMark, true) or showMap;
                            end
                        end
                    end
                end
                if (type(qIDs) == "table") then
                    for k, qID in pairs(qIDs) do
                        CdbDebugPrint(8, "    Quest related drop for: ", qID)
                        if qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_ITM] then
                            for k, item in pairs(qData[qIDs][DB_REQ_NPC_OR_OBJ_OR_ITM][DB_ITM]) do
                                if itemData[item[1]] then
                                    local comment = "Drop for quest related item:\n"..itemData[item[1]][DB_ITM_NAME];
                                    showMap = CdbPrepareItemNotes(item[1], title, comment, cMark, true) or showMap;
                                end
                            end
                        end
                    end
                end
            end
        end
        -- added numObjectives condition due to some quests not showing "isComplete" though having nothing to do but turn it in
        if (isComplete or numObjectives == 0) then
            CdbGetQuestEndNotes(questLogID);
        end
    end
    if (showMap) and (not isComplete) then
        CdbNextMark();
    end
    SelectQuestLogEntry(oldQuestLogId);
    return showMap;
end -- GetQuestNotes(questLogID)

-- returns level and hp values with prefix for provided NPC name as string
function CdbGetNpcStatsComment(npcNameOrID, ...)
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
    CdbDebugPrint(2, "GetNPCStatsComment(", npcNameOrID, ") called");
    local npcID = 0;
    if (type(npcNameOrID) == "string") then
        npcID = CdbGetNpcId(npcNameOrID);
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
            local colorStringMax = CdbGetQuestDifficultyColor(maxLevel);
            local colorStringMin = CdbGetQuestDifficultyColor(minLevel);
            return colorStringMax..npcData[npcID][DB_NAME].."|r\nLevel: "..colorStringMin..minLevel.."|r - "..colorStringMax..maxLevel.." "..rank.."|r\n".."Health: "..colorStringMin..npcData[npcID][DB_MIN_LEVEL_HEALTH].."|r - "..colorStringMax..npcData[npcID][DB_MAX_LEVEL_HEALTH].."|r\n";
        else
            local colorString = CdbGetQuestDifficultyColor(npcData[npcID][DB_LEVEL]);
            return colorString..npcData[npcID][DB_NAME].."|r\nLevel: "..colorString..npcData[npcID][DB_MIN_LEVEL].." "..rank.."|r\n".."Health: "..colorString..npcData[npcID][DB_MIN_LEVEL_HEALTH].."|r\n";
        end
    else
        CdbDebugPrint(1, "    NPC not found: ", npcNameOrID);
        return "NPC not found: "..npcNameOrID;
    end
end -- GetNPCStatsComment(npcNameOrID)

-- returns dropRate value with prefix for provided NPC name as string
-- TODO: fix for new item data
-- unused ?
function CdbGetNpcDropComment(itemName, npcName)
    CdbDebugPrint(2, "GetNPCDropComment(", itemName, ", ", npcName, ") called");
    local dropRate = itemData[itemName][npcName];
    if (dropRate == "" or dropRate == nil) then
        dropRate = "Unknown";
    end
    return "Drop chance: "..dropRate.."%";
end -- GetNPCDropComment(itemName, npcName)

function CdbGetQuestStartNotes(zoneName)
    local zoneID = 0;
    if zoneName == nil then
        zoneID = CdbGetCurrentZoneId();
    end
    if (zoneID == 0) and (zoneName) then
        for k,v in pairs(zoneData) do
            if v == zoneName then
                zoneID = k;
            end
        end
    end
    if zoneID ~= 0 then
        if CdbQuestStartZones[zoneID] == true then
            return;
        else
            CdbQuestStartZones[zoneID] = true;
        end
        CdbPrepare = CdbCurrentNotes;
        for id, data in pairs(npcData) do
            if (data[DB_NPC_SPAWNS][zoneID] ~= nil) and (data[DB_NPC_STARTS] ~= nil) then
                local comment = CdbGetQuestStartComment(data[DB_NPC_STARTS]);
                if (comment ~= "") then -- (comment == "") => other faction quest, or quest is filtered
                    CdbPrepareForDrawing(DB_NPC, id, data[DB_NAME], "Starts quests:\n"..comment, 5);
                end
            end
        end
        for id, data in pairs(objData) do
            if (data[DB_OBJ_SPAWNS][zoneID] ~= nil) and (data[DB_STARTS] ~= nil) then
                local comment = CdbGetQuestStartComment(data[DB_STARTS]);
                if (comment ~= "") then
                    CdbPrepareForDrawing(DB_OBJ, id, data[DB_NAME], "Starts quests:\n"..comment, 5);
                end
            end
        end
        local _,_,_ = CdbDrawNotesOnMap();
    end
end -- GetQuestStartNotes(zoneName)

function CdbGetQuestStartComment(npcOrGoStarts)
    local tooltipText = "";
    for key, questID in npcOrGoStarts do
        if (qData[questID]) and (CdbFinishedQuests[questID] == nil) and (CdbFinishedQuests[questID] ~= true) then
            local skip = false;
            if (CdbSettings.filterReqLevel == true) and (qData[questID][DB_MIN_LEVEL] > UnitLevel("player")) then
                skip = true;
            end
            if (CdbSettings.filterPreQuest == true) then
                if (qData[questID][DB_PRE_QUEST_GROUP] ~= nil) then
                    for key2, questID2 in pairs(qData[questID][DB_PRE_QUEST_GROUP]) do
                        if (CdbFinishedQuests[questID2] ~= true) then
                            skip = true;
                        end
                    end
                end
                if (qData[questID][DB_PRE_QUEST_SINGLE] ~= nil) then
                    local skip2 = true;
                    for key2, questID2 in pairs(qData[questID][DB_PRE_QUEST_SINGLE]) do
                        if (CdbFinishedQuests[questID2] == true) then
                            skip2 = false;
                        end
                    end
                    if (skip2 == true) then
                        skip = true;
                    end
                end
            end
            local colorString = CdbGetQuestDifficultyColor(qData[questID][DB_LEVEL]);
            local level = qData[questID][DB_LEVEL];
            if level == -1 then level = UnitLevel("player"); end
            if not skip then
                tooltipText = tooltipText..colorString.."["..level.."] "..qData[questID][DB_NAME].."|r\n";
                if CdbSettings.reqLevel then
                    tooltipText = tooltipText.."|cFFa6a6a6(ID: "..questID..") | |r";
                else
                    tooltipText = tooltipText.."|cFFa6a6a6(ID: "..questID..")|r\n";
                end
                if CdbSettings.reqLevel then
                    local comment = "";
                    if CdbGetQuestGreyLevel(UnitLevel("player")) >= qData[questID][DB_MIN_LEVEL] then
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

function CdbGetCurrentZoneId()
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
function CdbGetSelectionQuestNotes()
    CdbPrepare = CdbCurrentNotes;
    CdbGetQuestNotes(GetQuestLogSelection())
    CdbDrawNotesAndShowMap();
end -- GetSelectionQuestNotes()

function CdbGetTableLength(tab)
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

function CdbGetQuestDifficultyColor(level1, ...)
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
    elseif (level1 > CdbGetQuestGreyLevel(level2)) then
        return "|cFF40C040"; -- Green
    else
        return "|cFFC0C0C0"; -- Grey
    end
    return "|cFFffffff"; --white
end -- GetDifficultyColor(level1, ...)

function CdbGetQuestGreyLevel(level)
    if (level <= 5) then
        return 0;
    elseif (level <= 39) then
        return (level - math.floor(level/10) - 5);
    else
        return (level - math.floor(level/5) - 1);
    end
end -- GetGreyLevel(level)

function CdbPrepareForDrawing(kind, nameOrId, title, comment, icon, ...)
    CdbDebugPrint(2, "MarkForPlotting(", kind, ", ", nameOrId, ") called");
    if kind == DB_NPC then
        local npcID = 0;
        if type(nameOrId) == "number" then
            npcID = nameOrId;
        else
            npcID = CdbGetNpcId(nameOrId);
        end
        if npcID and npcID ~=0 then
            if not CdbPrepare[DB_NPC][npcID] then CdbPrepare[DB_NPC][npcID] = {}; end
            CdbInsertInPrepareTable(CdbPrepare[DB_NPC][npcID], title, comment, icon);
            return true;
        end
    elseif kind == DB_OBJ then
        local objIDs = 0;
        if type(nameOrId) == "number" then
            objIDs = {nameOrId};
        else
            objIDs = CdbGetObjIds(nameOrId);
        end
        if objIDs and objIDs ~= 0 then
            for k, objID in pairs(objIDs) do
                if not CdbPrepare[DB_OBJ][objID] then CdbPrepare[DB_OBJ][objID] = {}; end
                CdbInsertInPrepareTable(CdbPrepare[DB_OBJ][objID], title, comment, icon);
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
            CdbPrepareItemNotes(itmID, title, comment, icon, true);
            return true;
        end
    end
    return false;
end -- MarkForPlotting(kind, nameOrId, title, comment, icon, ...)

function CdbInsertInPrepareTable(tab, title, comment, icon)
    CdbDebugPrint(2, "FillPrepare(", title, ", ", comment, ", ", icon, tostring(tab), ")")
    if tab then
        local added = false;
        for k, v in tab do
            if (v[NOTE_TITLE] == title) and (not strfind(strlower(v[NOTE_COMMENT]), strlower(comment))) and (comment ~= v[NOTE_COMMENT]) then
                v[NOTE_ICON] = CdbCheckIcons(v[NOTE_ICON], icon);
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

function CdbGetQuestNotesById(questId)
    if qData[questId] then
        local quest = qData[questId];
        local title = CdbGetQuestDifficultyColor(quest[DB_LEVEL]).."["..quest[DB_LEVEL].."] "..quest[DB_NAME].." (ID: "..questId..")|r";
        for k, v in pairs(quest[DB_STARTS]) do
            if v then
                for _, id in pairs(v) do
                    CdbDebugPrint(8, "    starts ", id)
                    local comment = "-";
                    local icon = "CdbExclamationMark";
                    if k == DB_NPC then comment = "|cFFa6a6a6Creature|r "..npcData[id][DB_NAME].." |cFFa6a6a6starts the quest|r";
                    elseif k == DB_OBJ then comment = "|cFFa6a6a6Object|r "..objData[id][DB_NAME].." |cFFa6a6a6starts the quest|r";
                    elseif k == DB_ITM then comment = "|cFFa6a6a6Aquire item|r "..itemData[id][DB_ITM_NAME].." |cFFa6a6a6 to start the quest|r";
                    end
                    CdbPrepareForDrawing(k, id, title, comment, icon);
                end
            end
        end
        for k, v in pairs(quest[DB_ENDS]) do
            if v then
                for _, id in pairs(v) do
                    CdbDebugPrint(8, "    ends", id)
                    local comment = "+";
                    local icon = "CdbQuestionMark";
                    if k == DB_NPC then
                        if not npcData[id] then
                            CdbDebugPrint(16, "Missing creature "..id);
                        else
                            comment = "|cFFa6a6a6Creature|r "..npcData[id][DB_NAME].." |cFFa6a6a6ends the quest|r";
                        end
                    elseif k == DB_OBJ then
                        if not objData[id] then
                            CdbDebugPrint(16, "Missing object "..id);
                        else
                            comment = "|cFFa6a6a6Object|r "..objData[id][DB_NAME].." |cFFa6a6a6ends the quest|r";
                        end
                    end
                    CdbPrepareForDrawing(k, id, title, comment, icon);
                end
            end
        end
        for k, v in pairs(quest[DB_REQ_NPC_OR_OBJ_OR_ITM]) do
            if v then
                for _, list in pairs(v) do
                    if type(list) == "table" then
                        CdbDebugPrint(8, "    tables2 ", list[1], list[2], " - type ", k)
                        local id = list[1];
                        local text = nil;
                        if list[2] then
                            text = list[2]
                        end
                        local comment, icon = ".", 4;
                        if k == DB_NPC and text == nil and npcData[id] then comment = "|cFFa6a6a6'Creature'-type objective:|r "..npcData[id][DB_NAME]; icon = cMark;
                        elseif k == DB_NPC and text then comment = "|cFFa6a6a6'Creature'-type objective:|r "..text; icon = cMark;
                        elseif k == DB_OBJ and text == nil and objData[id] then comment = "|cFFa6a6a6'Object'-type objective:|r "..objData[id][DB_NAME]; icon = "CdbObject";
                        elseif k == DB_OBJ and text then comment = "|cFFa6a6a6'Object'-type objective:|r "..text; icon = "CdbObject";
                        elseif k == DB_ITM and text == nil and id ~= quest[DB_SRC_ITM] and itemData[id] then comment = "|cFFa6a6a6'Item'-type objective:|r "..itemData[id][DB_ITM_NAME]; icon = "CdbVendor";
                        elseif k == DB_ITM and text then comment = "|cFFa6a6a6Item type objective:|r "..text; icon = "CdbVendor";
                        end
                        if comment ~= "." and icon ~= 4 then CdbPrepareForDrawing(k, id, title, comment, icon); end
                    end
                end
            end
        end
        if quest[DB_SRC_ITM] then
            if not (CdbPrepare[DB_ITM][quest[DB_SRC_ITM]] == true) and itemData[quest[DB_SRC_ITM]] then
                CdbPrepareForDrawing(DB_ITM, quest[DB_SRC_ITM], title, "|cFFa6a6a6Item related to quest:|r "..quest[DB_NAME], "CdbVendor");
            end
        end
    end
end -- GetQuestNotesById(questId)

-- Unused dev helper functions

function CdbCompareTables(tab1, tab2)
    for k, v in pairs(tab1) do
        if (type(v) == "table") then
            if not CdbCompareTables(v, tab2[k]) then
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

function CdbPrintTable(tab, indent)
    if indent == nil then indent = 0; end
    local debugWin = 0;
    local name, shown;
    for i=1, NUM_CHAT_WINDOWS do
        name,_,_,_,_,_,shown = GetChatWindowInfo(i);
        if (string.lower(name) == "shagudebug") then debugWin = i; break; end
    end
    if (debugWin == 0) or (CdbDebug == 0) then return end
    local iString = "";
    local ind = indent;
    while (ind > 0) do
        iString = iString.."-";
        ind = ind -1;
    end
    for k, v in pairs(tab) do
        if (type(v) == "table") then
            getglobal("ChatFrame"..debugWin):AddMessage(iString.."["..k.."] = ", 1.0, 1.0, 0.3);
            CdbPrintTable(v, indent+1);
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

function CdbMarkQuestAsFinished(questId)
    if qData[questId] then
        CdbFinishedQuests[questId] = true;
    end
    WorldMapFrame:Hide();
    CdbCleanMap();
    if (CdbSettings.auto_plot) then
        CdbGetAllQuestNotes();
    else
        WorldMapFrame:Show();
    end
end

function CdbResetMapAndIconSize()
    Cartographer_Notes:SetIconSize(1);
    Cartographer_LookNFeel:SetScale(1);
    local size = 1;
    if Cartographer_LookNFeel.db.profile.largePlayer then
        size = size*1.5;
    end
    Cartographer_LookNFeel.playerModel:SetModelScale(size);
    WorldMapFrame:StartMoving();
    WorldMapFrame:ClearAllPoints();
    WorldMapFrame:SetPoint("CENTER", 0, 0);
    WorldMapFrame:StopMovingOrSizing();
end

function CdbReopenMapIfVisible()
    if WorldMapFrame:IsVisible() then
        local continent = GetCurrentMapContinent();
        local zone = GetCurrentMapZone();
        WorldMapFrame:Hide();
        WorldMapFrame:Show();
        SetMapZoom(continent, zone);
    end
end

function CdbClearTable(table)
    for k, v in pairs(table) do
        v = nil;
    end
end

-- https://www.lua.org/pil/19.3.html
-- used to display search results in order
function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end
