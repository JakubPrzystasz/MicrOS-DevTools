#!/bin/bash
# Set threads count used during GCC compilation
THREADS_COUNT=[THREAD_COUNT]
WORKSPACE_DIR="$PWD"

# Delete old ELF and BIN files
find build -iname "*.elf" -type f -delete
find build -iname "*.bin" -type f -delete

find environment -iname "*.elf" -type f -delete
find library -iname "*.elf" -type f -delete
find os -iname "*.elf" -type f -delete

export MODE=release

# Build bootloader
cd os/bootloader
	make $1 -j "$THREADS_COUNT"

	if [ "$?" != "0" ]; then
		exit 1
	fi
cd ../..

# Build C Library
cd library
	make $1 -j "$THREADS_COUNT"

	if [ "$?" != "0" ]; then
		exit 1
	fi
cd ..

# Build applications
cd environment
	for i in *;
	do
		cd "$i"
		make $1 -j "$THREADS_COUNT"

		if [ "$?" != "0" ]; then
			exit 1
		fi

		if [ "$1" != "clean" ]; then
			mkdir -p ../build/floppy/ENV
			cp bin/"$i".elf ../../build/floppy/ENV/`echo "$i" | tr a-z A-Z`.ELF
		fi

		cd ..
	done
cd ..

# Build kernel
cd os/kernel
	make $1 -j "$THREADS_COUNT"

	if [ "$?" != "0" ]; then
		exit 1
	fi

	if [ "$1" != "clean" ]; then
		cp bin/kernel.bin ../../build/floppy/KERNEL.BIN
		cp bin/kernel.elf ../../build/kernel.elf
	fi
cd ../..

copy() {
	cd "$1"
	for i in *;
	do
		mcopy -bvi "$FLOPPY_IMG" $i ::$i
	done
	cd "$WORKSPACE_DIR"
}

# Create floppy
if [ "$1" != "clean" ]; then
	FLOPPY_IMG="$WORKSPACE_DIR/build/floppy.img"
	# Remove old floppy img
	rm "$FLOPPY_IMG"

	# Make and format the floppy
	mkfs.msdos -C "$FLOPPY_IMG" 1440

	# Upload bootloader to the floppy
	dd if=os/bootloader/bin/bootloader.bin of="$FLOPPY_IMG" bs=512 conv=notrunc

	# Copy kernel to the floppy
	copy build/floppy
	copy resources
fi
