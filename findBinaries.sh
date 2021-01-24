#!/bin/bash

env=$(find environment/ -name '*.elf')
os=$(find os/ -name '*.elf')

DEBUG_PATHS=""
COUNT=0

#read os
while IFS= read -r line; do
    if [ -n "$DEBUG_PATHS" ]; then
        DEBUG_PATHS="${DEBUG_PATHS},\"/${line}\""
    else
        DEBUG_PATHS="\"/${line}\""
    fi
	((COUNT=COUNT+1))
done <<< "$os"


#read env
while IFS= read -r line; do
    if [ -n "$DEBUG_PATHS" ]; then
        DEBUG_PATHS="${DEBUG_PATHS},\"/${line}\""
    else
        DEBUG_PATHS="\"/${line}\""
    fi
	((COUNT=COUNT+1))
done <<< "$env"
#[DEBUG_PATHS]

cp "scripts/launch.json" ".vscode/launch.json"
sed -i "s!\[DEBUG_PATHS\]!$DEBUG_PATHS!g" ".vscode/launch.json"

echo "Found: $COUNT files"
