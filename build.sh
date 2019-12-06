#!/bin/bash

# Check that 7zip is on the path
which 7z &> /dev/null
if [ $? -ne 0 ]
then
  echo "Please add 7-zip (7z) to your shell path"
  exit 1
fi

# Take version from the command-line if provided, otherwise prompt for it
if [ -z "$1" ]
then
  read -p "Version: " version
else
  version="$1"
fi


appdata_fixed=$(echo $APPDATA | tr '\\' '/')

mod_name="LogiNetChannels"
build_dir="zip"

set -x
cp -r src ${build_dir}/${mod_name}_${version}
7z a ${build_dir}/${mod_name}_${version}.zip ./${build_dir}/${mod_name}_${version}
rm -r ${build_dir}/${mod_name}_${version}