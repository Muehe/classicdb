#!/usr/bin/env python3
import configparser
import os
import shutil
import subprocess
import sys

def copyFile(sourcePath, destinationPath):
    if not os.path.isfile(sourcePath):
        print(sourcePath+' has not been found. Aborting file copy.')
        return
    with open(sourcePath, 'rt') as file:
        content = file.read()

config = configparser.ConfigParser()
config.read('release.ini')

version = config['default']['version']
path = config['default']['release_path']
release_de = config['default']['release_de']

runPath = os.path.dirname(os.path.abspath(__file__))

enPath = path+'ClassicDB-'+version+'-enGB/'
if os.path.exists(enPath[:-1]):
    sys.exit('Path "'+enPath+'" already exists')
else:
    os.makedirs(enPath[:-1])
    os.makedirs(enPath+'ClassicDB')
    os.makedirs(enPath+'ClassicDB/db')

    shutil.copytree('resources/Cartographer', enPath+'Cartographer')
    shutil.copytree('resources/img', enPath+'ClassicDB/img')
    shutil.copytree('resources/symbols', enPath+'ClassicDB/symbols')

    shutil.copy2('ClassicDB_GUI.lua', enPath+'ClassicDB')
    subprocess.run(['sed',  '-i', 's/oooVersionooo/'+version+'/g', enPath+'ClassicDB/ClassicDB_GUI.lua'])
    shutil.copy2('ClassicDB.lua', enPath+'ClassicDB')
    subprocess.run(['sed',  '-i', 's/oooVersionooo/'+version+'/g', enPath+'ClassicDB/ClassicDB.lua'])
    subprocess.run(['sed',  '-i', 's/oooLocaleooo/enGB/g', enPath+'ClassicDB/ClassicDB.lua'])
    shutil.copy2('ClassicDB.toc', enPath+'ClassicDB')
    subprocess.run(['sed',  '-i', 's/oooVersionooo/'+version+'/g', enPath+'ClassicDB/ClassicDB.toc'])
    subprocess.run(['sed',  '-i', 's/oooLocaleooo/enGB/g', enPath+'ClassicDB/ClassicDB.toc'])

    shutil.copy2('resources/itemDB.lua_enGB', enPath+'ClassicDB/db/itemDB.lua')
    shutil.copy2('resources/objectDB.lua_enGB', enPath+'ClassicDB/db/objectDB.lua')
    shutil.copy2('resources/questDB.lua_enGB', enPath+'ClassicDB/db/questDB.lua')
    shutil.copy2('resources/spawnDB.lua_enGB', enPath+'ClassicDB/db/spawnDB.lua')
    shutil.copy2('resources/zoneDB.lua_enGB', enPath+'ClassicDB/db/zoneDB.lua')

    os.chdir(path)
    subprocess.run(['zip', '-r', 'ClassicDB-'+version+'-enGB.zip', 'ClassicDB-'+version+'-enGB/'])
    os.chdir(runPath)

dePath = path+'ClassicDB-'+version+'-deDE/'
if os.path.exists(dePath[:-1]):
    sys.exit('Path "'+dePath+'" already exists')
else:
    os.makedirs(dePath[:-1])
    os.makedirs(dePath+'ClassicDB')
    os.makedirs(dePath+'ClassicDB/db')

    shutil.copytree('resources/Cartographer', dePath+'Cartographer')
    shutil.copytree('resources/img', dePath+'ClassicDB/img')
    shutil.copytree('resources/symbols', dePath+'ClassicDB/symbols')

    shutil.copy2('ClassicDB_GUI.lua', dePath+'ClassicDB')
    subprocess.run(['sed',  '-i', 's/oooVersionooo/'+version+'/g', dePath+'ClassicDB/ClassicDB_GUI.lua'])
    shutil.copy2('ClassicDB.lua', dePath+'ClassicDB')
    subprocess.run(['sed',  '-i', 's/oooVersionooo/'+version+'/g', dePath+'ClassicDB/ClassicDB.lua'])
    subprocess.run(['sed',  '-i', 's/oooLocaleooo/deDE/g', dePath+'ClassicDB/ClassicDB.lua'])
    shutil.copy2('ClassicDB.toc', dePath+'ClassicDB')
    subprocess.run(['sed',  '-i', 's/oooVersionooo/'+version+'/g', dePath+'ClassicDB/ClassicDB.toc'])
    subprocess.run(['sed',  '-i', 's/oooLocaleooo/deDE/g', dePath+'ClassicDB/ClassicDB.toc'])

    shutil.copy2('resources/itemDB.lua_deDE', dePath+'ClassicDB/db/itemDB.lua')
    shutil.copy2('resources/objectDB.lua_deDE', dePath+'ClassicDB/db/objectDB.lua')
    shutil.copy2('resources/questDB.lua_deDE', dePath+'ClassicDB/db/questDB.lua')
    shutil.copy2('resources/spawnDB.lua_deDE', dePath+'ClassicDB/db/spawnDB.lua')
    shutil.copy2('resources/zoneDB.lua_deDE', dePath+'ClassicDB/db/zoneDB.lua')

    os.chdir(path)
    subprocess.run(['zip', '-r', 'ClassicDB-'+version+'-deDE.zip', 'ClassicDB-'+version+'-deDE/'])
