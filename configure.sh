#!/bin/sh

THREADS_COUNT=${THREADS_COUNT:-1}

help() {
	echo "You must specify workspace directory like so:"
	echo -e "\t./configure.sh <workspace directory>\n"
	echo "You can also specify the thread count to use when compiling MicrOS:"
	echo -e "\t./configure.sh <workspace directory> THREADS_COUNT=<number of threads>\n"
}

if [ "$1" = "help" ];
then
	help
	exit 1
fi

if [ ! "$1" ];
then
	echo "Error: Please specify workspace directory"
	help
	exit 1
else
	WORKSPACE_DIR="$(readlink -f "$1")"
	if [ ! -d "$WORKSPACE_DIR" ];
	then
		echo "Error: $WORKSPACE_DIR does not exist."
	fi
fi

# Check for dependencies
NASM="$(command -v nasm)"
MCOPY="$(command -v mcopy)"

if [ ! "$NASM" ];
then
	echo "Error: dependecies not met, nasm is not installed."
	exit 1
fi

if [ ! "$MCOPY" ];
then
	echo "Error: dependecies not met, mcopy is not installed."
	exit 1
fi

# Download files
TEMP="/tmp/MicrOS_DevTools_temp"
SRC="$TEMP/MicrOS-DevTools-1.0"
mkdir "$TEMP"
curl -Lk https://github.com/jaenek/MicrOS-DevTools/archive/v1.0.tar.gz | tar xzC "$TEMP"
# curl -Lk https://github.com/jaenek/MicrOS-DevTools/releases/download/v1.0/cross.tar.gz | sudo tar xzC "/opt"

# Replace strings
sed -i "s/\[THREADS_COUNT\]/$THREADS_COUNT/g" "$SRC/build.sh"

# Prepare workspace directory
mkdir -p "$WORKSPACE_DIR/build/"
mkdir -p "$WORKSPACE_DIR/scripts/"
mv "$SRC/build.sh" "$WORKSPACE_DIR/scripts/"
mkdir -p "$WORKSPACE_DIR/.vscode/"
mv "$SRC/launch.json" "$WORKSPACE_DIR/.vscode/"
mv "$SRC/tasks.json" "$WORKSPACE_DIR/.vscode/"

# Create symlink to nasm
mkdir -p "$WORKSPACE_DIR/tools/"
ln -sf "$NASM" "$WORKSPACE_DIR/tools/nasm"

# Remove temporary directory
rm -r "$TEMP"
