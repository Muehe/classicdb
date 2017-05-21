## ClassicDB 1.0-beta.2 (2017-05-21)
- When there are more than 14 search results, display actual number of results instead of (\*). ([de944e0](https://github.com/Muehe/classicdb/commit/de944e0b503fd69ee27ea4d39c67b66b1e750e1f))
- Search result list can be scrolled now. Use with care (do not scroll long lists rapidly, like ones with 1k+ results). ([ded34e5](https://github.com/Muehe/classicdb/commit/b5e82f517ce8024d3641cf2a8676af82a186e030))
- Fix settings tab disappearing when searching. ([b5e82f5](https://github.com/Muehe/classicdb/commit/b5e82f517ce8024d3641cf2a8676af82a186e030))
- Show minimap button position while dragging. ([f25c327](https://github.com/Muehe/classicdb/commit/f25c32757537ff804ed6bebe5fc3a7bca307eec9))
- Fix bug with quest log selection. Under certain conditions it could happen that the "actually" selected quest from the UIs point of view would differ from the visibly selected quest. ([a2591d8](https://github.com/Muehe/classicdb/commit/a2591d8e66ec5200f6e0e4518b64ff815c4be67e) and [722b298](https://github.com/Muehe/classicdb/commit/722b2981b77857a324ba6df5c46f5c74628dc02c))
- Replaced the old WHDB control frame and completely removed the legacy XML code. ([dd421cf](https://github.com/Muehe/classicdb/commit/dd421cf0b913bd38a96c865591c097afe0f34a0b), [dac477c](https://github.com/Muehe/classicdb/commit/dac477c2e85387a443e0e0899bf4979e07bb4ab6) and [dd8ae7a](https://github.com/Muehe/classicdb/commit/dd8ae7ad256cbbce83c92029f575d3cdbfed34f9))
- The "Cycle marked zones" button now cycles backwards when right clicked instead of left clicked. ([4cbe5cc](https://github.com/Muehe/classicdb/commit/4cbe5cca769da2de2784cfc7cb4e52bfad2995e3))
- Raised the frame level of the map (fixes action bars showing above map). Frame level of ClassicDB GUI has been raised accordingly, so it even shows when in the menu. The minimap button is always visible as well and can be used to close/show the other frames. ([34e6bba](https://github.com/Muehe/classicdb/commit/34e6bbaffccb5b844aab77da712d82dfd2ba39a0))
- When the map scale is scrolled up or down, the map is repositioned to match the previous cursor position. Also note and arrow size are set to 1/mapScale, so they get bigger when map gets smaller and vice versa. If you want to set note size independently from map scale, scale the map first, then resize the notes. ([ea6460a](https://github.com/Muehe/classicdb/commit/ea6460ac6f5f391a99260a86c62ce31711ddfb68) and [114dbf0](https://github.com/Muehe/classicdb/commit/114dbf07453db9726842b2cb72fad1b18aac3100))
- Fix tracking of active and finished quests. If you have issues with quest item loot not registering see the commit message or the [known issues section](https://github.com/Muehe/classicdb/wiki#known-issues) of the new wiki page for an explanation (there is a fix server providers can implement). Workaround is to update notes using the "Show all current quest notes" button in the control GUI. ([f1745a0](https://github.com/Muehe/classicdb/commit/f1745a05bf885620b328694389a019c85af136d7))

## ClassicDB Version 1.0-beta.1 (2017-03-02)

- At the request of Shagu, renamed the addon. It is now called ClassicDB.
- Fixed objects not showing finished quests. ([ecdb734](https://github.com/Muehe/classicdb/commit/ecdb734431aac3ec3fa60027e44fd183e97df564))
- Fixed a conflict with Cartographer_ExtraIcons addon (same icon name). ([2f2db6d](https://github.com/Muehe/classicdb/commit/2f2db6d41d1d864f0595409d20a1e31b365d21e1))
- Fixed a conflict with Questie (same function name for hooking a button). ([07a1220](https://github.com/Muehe/classicdb/commit/07a1220725018ebba84e8c95f18a36d17befff19))
- Added search by ID. ([1c66281](https://github.com/Muehe/classicdb/commit/1c662811ce7ecfdabeecf5fd78b77d7f8cb678c5))
- Fix resetting map and note size. ([d74e3ed](https://github.com/Muehe/classicdb/commit/d74e3ed4a8ddedae9b2a6b371df1c208cd61d83b))

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

## ShaguQuest Version 5.0 (2015-10-03)
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
