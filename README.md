# NOT IN DEVELOPMENT ANYMORE

**This project is not developed anymore and just left here for archival purposes.**

**If you need a quest addon for 1.12 take a look at [pfQuest](https://gitlab.com/shagu/pfQuest).**

# ClassicDB
ClassicDB is an addon for World of Warcraft (1.12.1), which helps you to find ingame stuff and getting your quests done. It draws spawn information of gameobjects and NPCs on your map. Also it allows you to search for quests, items and much more. Cartographer is required and an enhanced version is included in the download.

**Note:** ClassicDB is not meant to be a QuestHelper clone, although it offers quest tracking features via a simple GUI. ClassicDB is mainly a database addon (basically an updated ShaguQuest), and therefore has a higher memory use *(due to the way item data is stored and accessed, it takes ~150 MB in memory instead of the ~20 MB it has in the file, but that should not be a problem for a modern PC)*. If you are searching for just a QuestHelper addon, which is easier on your memory, you might want to check out a project called [Questie](https://github.com/AeroScripts/QuestieDev) instead of ClassicDB (of course you can use both together).

# Credits
Initially developed as ShaguQuest 8, ClassicDB is a fork of [WowHead DataBase (WHDB)](https://wow.curseforge.com/projects/whdb) for TBC by UniRing, which was ported to classic WoW by Bërsërk in the RQP (Rapid Quest Pack) addon collection. It was merged together from two independently developed forks, [ShaguQuest](https://github.com/shagu/shaguquest) and [Continued WHDB](https://github.com/Muehe/WHDB). ClassicDB is based on data from [cmangos/classic-db](https://github.com/cmangos/classic-db), as well as [MangosExtras/MangosZero_Localised](https://github.com/MangosExtras/MangosZero_Localised/tree/master/Translations) for translations used in the deDE version.

# Feedback
You are welcome to provide bug reports and suggestions on the [Issue Tracker](https://github.com/Muehe/classicdb/issues). Please make sure you checked the open issues and the [Wiki](https://github.com/Muehe/classicdb/wiki#known-issues) before you submit a new report.

# Download
If you want to test it, you can download it on the [Releases](https://github.com/Muehe/classicdb/releases) page.

# Installation
1. Download the zip file corresponding with your clients language from the release page (see above) and extract it.
2. Copy the two directories `Cartographer` and `ClassicDB` to `<WOW_PATH>\Interface\AddOns\`.
3. Start World of Warcraft and log in.
4. Click on **AddOns** in the bottom left corner of the character selection screen.
5. In the top right corner of the window that opens, set **Script Memory** to **0** (this will remove the memory limit, if you want to limit it set to at least 384 MB).

![memory](https://cloud.githubusercontent.com/assets/8838573/23493066/632ab67a-ff09-11e6-939e-8b453cddb211.png)
