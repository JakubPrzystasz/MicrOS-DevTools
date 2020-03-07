#!/bin/bash

help() {
	echo "configure.sh - configure the MicrOS development envirionment"
	echo " "
	echo "$ configure.sh [options]"
	echo "-h, --help             show this help"
	echo "-w, --workspace-dir    specify workspace directory"
	echo "-t, --threads-count    threads count to use when compiling MicrOS"
	echo "-q, --qemu-path        specify qemu path, needed for wsl environment"
	echo "--wsl                  indicate wsl configuration on Windows 10"
	echo "-s, --skip-compiler    omit the cross compiler installation"
	exit 0
}

if test $# -eq 0; then
	help
	exit 1
fi

while test $# -gt 0; do
	case "$1" in
		-h|--help)
			help
			exit 1
			;;
		-w|--workspace-dir)
			shift
			if test $# -gt 0; then
				WORK_DIR="$(readlink -f "$1")"
				if [ ! -d "$WORK_DIR" ]; then
					echo "Error: $WORK_DIR does not exist."
					exit 1
				fi
			else
				echo "Error: Please specify a workspace directory"
				exit 1
			fi
			shift
			;;
		-t|--threads-count)
			shift
			if test $# -gt 0; then
				# check if value is an integer
				if printf %d "$1" >/dev/null 2>&1; then
					THREADS_COUNT=$1
				else
					echo "Error: Please specify integer threads count"
					exit 1
				fi
			fi
			shift
			;;
		-q|--qemu-path)
			shift
			if test $# -gt 0; then
				# Replace backslash with 4 backslashes
				QEMU_PATH="${1//\\/\\\\\\\\}"
			else
				echo "Error: Please specify qemu path, use windows style formatting"
				exit 1
			fi
			shift
			;;
		--wsl)
			if test -n "$QEMU_PATH"; then
				WSL=1
				shift
			else
				echo "Error: Please specify qemu path first"
				exit 1
			fi
			;;
		-s|--skip-compiler)
			SKIP_CC=1
			shift
			;;
		*)
			break
			;;
	esac
done

if test -z "$WORK_DIR"; then
	echo "Error: Please specify workspace directory."
	exit 1
fi

# Set default values if not defined
THREADS_COUNT=${THREADS_COUNT:-1}
QEMU_PATH=${QEMU_PATH:-"qemu-system-i386"}
WSL=${WSL:-0}
SKIP_CC=${SKIP_CC:-0}

# Check for dependencies
DEPS="nasm curl mcopy make"
for i in $DEPS; do
	if test -z "$(command -v $i)"; then
		echo "Error: dependecies not met, $i is not installed."
		exit 1
	fi
done

# Download files
TEMP="/tmp/MicrOS_DevTools_temp"
SRC="$TEMP/MicrOS-DevTools-2.0"
mkdir -p "$TEMP"
curl -Lks https://github.com/jaenek/MicrOS-DevTools/archive/v2.0.tar.gz | tar xzC "$TEMP"
if test $SKIP_CC -eq 0;then
	curl -Lks https://github.com/jaenek/MicrOS-DevTools/releases/download/v1.0/cross.tar.gz | sudo tar xzC "/opt"
	if test $? -eq 1; then
		echo "Error: wrong sudo password."
		exit 1
	fi
fi

# Replace strings
sed -i "s!\[THREADS_COUNT\]!$THREADS_COUNT!g" "$SRC/build.sh"
if test $WSL -eq 1; then
	sed -i "s!\[QEMU_PATH\]!cmd.exe /c \\\"$QEMU_PATH\\\"!g" "$SRC/tasks.json"
else
	sed -i "s!\[QEMU_PATH\]!$QEMU_PATH!g" "$SRC/tasks.json"
fi

# Prepare workspace directory
mkdir -p "$WORK_DIR/build/"
mkdir -p "$WORK_DIR/scripts/"
mv "$SRC/build.sh" "$WORK_DIR/scripts/"
mkdir -p "$WORK_DIR/.vscode/"
mv "$SRC/launch.json" "$WORK_DIR/.vscode/"
mv "$SRC/tasks.json" "$WORK_DIR/.vscode/"

# Create symlink to nasm
mkdir -p "$WORK_DIR/tools/"
ln -sf "$(command -v nasm)" "$WORK_DIR/tools/nasm"

# Remove temporary directory
rm -r "$TEMP"
