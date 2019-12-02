#!/bin/bash

# Take version from the command-line if provided, otherwise prompt for it
if [ -z "$1" ]
then
  read -p "Version: " version
else
  version="$1"
fi


appdata_fixed=$(echo $APPDATA | tr '\\' '/')

mod_name="LogiNetChannels"
factorio_mods="${appdata_fixed}/Factorio/mods"

set -x
rm -r ${factorio_mods}/${mod_name}_*
cp -r src ${factorio_mods}/${mod_name}_${version}