## ClassicDB un-versioned changes
- When there are more than 14 search results, display actual number of results instead of (\*) (de944e0)
- Fix settings tab disappearing when searching (b5e82f5)
- Show minimap button position while dragging (f25c327)
- Fix bug with quest log selection. Under certain conditions it could happen that the "actually" selected quest from the UIs point of view would differ from the visibly selected quest (a2591d8 and 722b298)
- Replaced the old WHDB control frame and completely removed the legacy XML code (dd421cf, dac477c and dd8ae7a)
- General UI polishing and code refactoring

## ClassicDB Version 1.0-beta.1 (2017-03-02)

- At the request of Shagu, renamed the addon. It is now called ClassicDB
- Fixed objects not showing finished quests (ecdb734)
- Fixed a conflict with Cartographer_ExtraIcons addon (same icon name, 2f2db6d)
- Fixed a conflict with Questie (same function name for hooking a button, 07a1220)
- Added search by ID (1c66281)
- Fix resetting map and note size (d74e3ed)

## ShaguQuest Version 8.0 beta
- Merged code from a separately developed version of WHDB (https://github.com/Muehe/WHDB). Most changes are related to this
- New database, more recent data and also more information retrieved from server DB
- Moved objects to a new tab
- Added new tab for settings
- Removed EQL3 clone (ShaguQuest). Quests display is now controlled over a small extra UI
- Note display for quests changed significantly. E.g. quest finishing notes are displayed as question marks, new icons, etc.
- Changes to Cartographer. Map size, note size and map position can be changed by key and mouse combinations (see the top left corner of Cartographer ingame for a list)

## ShaguQuest Version 6.7 (2015-12-28)
- Eliminated Freeze on Loadscreen
- A Message appears if using EQL3 and ShaguQuest at the same time.
- The Minimap Icon now has a valid Name instead of "nil"

## ShaguQuest Version 6.6 (2015-12-07)
- Fixed some Game-freeze Issues
- Moved the minimap icon to a lower framestrata

## ShaguQuest Version 6.5 (2015-12-01)
- New Slashcommands
- Added the ability to hide the Minimap Button

## ShaguQuest Version 6.4 (2015-11-19)
- Fixed Eastern Plaguelands spawns

## ShaguQuest Version 6.3 (2015-11-16)
- Disable Autotracking per default
- Don't save the Autotracking state because of loadscreen freezes

## ShaguQuest Version 6.2 (2015-11-06)
- Separated ShaguDB and ShaguQuest. You can now use ShaguDB without any Quest features
- Added automatic quest tracking to ShaguQuest

## ShaguQuest Version 6.1 (2015-10-31)
- Fixed appearance of Buttons in ShaguDatabase GUI

## ShaguQuest Version 6.0 (2015-10-30)
- Added a Graphical User Interface for Database
- Added experimental Dungeon and Battleground Maps

## ShaguQuest Version 5.0 (03.10.2015)
- Fixed Thunderbluff spawn points
- Implemented a vendor search which allows you to search for items being sold.
- Quests are now filtered by the own faction (e.g /shagu quests)

## ShaguQuest Version 4.2 (2015-05-18)
- Fixed the Button overlapping bug
- Only show required Questobjectives

## ShaguQuest Version 4.1 (2015-03-28)
- Changed the appearance of the cartographer symbols. Looks now much clearer.

## ShaguQuest Version 4.0 (2015-03-25)
- The map will now open on the correct zone everytime (99.99%). The issue where a nearby map is opened instead, is now fixed.
- Overlapping spawnpoints are removed. Only the spawns that are really on the map will now be shown.
- The size of the addon and thus the RAM usage has been reduced.
- Quests without questobjectives now have a "Show" button too.
- Slashcommand /shagu item  does now reliable opens the map with the most spots.
- Slashcommand /shagu item  has been cleaned up. Alot of wrong zones has been removed.
- Some other minor fixes and code cleanups.

## ShaguQuest Version 3.1.1 (2015-03-22)
- Killquests on enGB Clients should now work correctly. Might impact some deDE Quests as well.

## ShaguQuest Version 3.1 (2015-03-06)
- Introducing: Slashcommand "shagu quest  <questname>" will search for a questgiver of the desired quest.
- Slashcommand "shagu quests" will now print all quests of the current map, if no parameters are given.
- Slashcommand "shagu item" now opens the map on the best dropchance.
- Slashcommand "shagu item" will now print all zones instead of one broken zone.
- Re-designed the formatting on the ShaguQuest slashcommands.

## ShaguQuest Version 3.0 (2015-03-05)
- Alot(!) of Quests will now work better, as there was a bug in the object-database.
- Removed many of Lua Errors.
- Intruducing: Slashcommand "shagu quests <map>" will print every Questgiver of the desired  <map>.
- Dropchances are now sortedy by percentage. The highest droprates will now be shown, instead of 5 randoms.
- Rewritten the algorithms to match the best map for a spot. Because of this, the map will be auto-opened again.
- Many parts of the Code where rewritten. Merged alot of redundant code to functions.
- Fixed parse errors in spawnData.lua for enGB clients

## ShaguQuest Version 2.1 (2015-01-18)
- Fixed NullPointer Error for enGB (issue in spawnData.lua)
- Rewritten the code of the database export scripts.
- Changed Addon Description (Ingame), to avoid confusion with EQL3 <=> Extended Quest Log3.

## ShaguQuest Version 2.0 (2014-08-20)
- The Map won't open automatically anymore. Instead, all spawns on every Map will now be shown.
- Questgivers and everything related to a Quest will be shown on the Map as a "Questionmark".
- Changed the structure of questData.lua to make all this possible.

## ShaguQuest Version 1.0 (2014-08-07)
- Initial Release. Alot of confusing Errors and Issues.
