#!/bin/bash
cd /get5src && git submodule update --init --recursive
cp -rf /get5src/get5_eventula_apistats/* /get5/
mkdir -p /get5/scripting/get5
mkdir -p /get5/scripting/include
mkdir -p /get5/translations

cp -rf /get5src/get5/scripting/get5/* /get5/scripting/get5/
cp -rf /get5src/get5/scripting/include/* /get5/scripting/include/
cp -rf /get5src/get5/translations/* /get5/translations/
cp /get5src/LICENSE /get5/
cp /get5src/README.md /get5/

cp -r /get5src/get5/dependencies/sm-json/addons/sourcemod/scripting/include/* /get5/addons/sourcemod/scripting/include

cd /get5
smbuilder --flags='-E'

cd /get5/builds/get5_eventula_apistats

zip -r ../get5_eventula_apistats.zip *
