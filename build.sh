#!/bin/bash
# Set threads count used during GCC compilation
THREADS_COUNT=4
TEMP="/tmp/temp_disk_A"

mkdir -p build/floppy/ENV

# Delete old ELF and BIN files
find build -iname "*.elf" -type f -delete
find build -iname "*.bin" -type f -delete

find environment -iname "*.elf" -type f -delete
find library -iname "*.elf" -type f -delete
find os -iname "*.elf" -type f -delete

# Delete broken directory
rm -rf $TEMP

export MODE=release

# Build bootloader
cd os/bootloader
    make $1 -j $THREADS_COUNT

    if [ "$?" != "0" ]; then
        exit 1
    fi
cd ../..

# Build C Library
cd library
    make $1 -j $THREADS_COUNT

    if [ "$?" != "0" ]; then
        exit 1
    fi
cd ..

# Build applications
cd environment
    for i in *;
    do
        cd $i
        make $1 -j $THREADS_COUNT

        if [ "$?" != "0" ]; then
            exit 1
        fi

        if [ "$1" != "clean" ]; then
            cp bin/$i.elf ../../build/floppy/ENV/`echo $i | tr a-z A-Z`.ELF
        fi

        cd ..
    done
cd ..

# Build kernel
cd os/kernel
    make $1 -j $THREADS_COUNT

    if [ "$?" != "0" ]; then
        exit 1
    fi

    if [ "$1" != "clean" ]; then
        cp bin/kernel.bin ../../build/floppy/KERNEL.BIN
        cp bin/kernel.elf ../../build/kernel.elf
    fi
cd ../..

if [ "$1" != "clean" ]; then
	# Remove old floppy img
	rm build/floppy.img

	# Make and format the floppy disk
	mkfs.msdos -C build/floppy.img 1440

    # Upload bootloader to the floppy
    dd if=os/bootloader/bin/bootloader.bin of=build/floppy.img bs=512 conv=notrunc

    # Copy kernel to the floppy
	cd build
	mkdir -p $TEMP
	sudo mount -o loop,uid=$UID floppy.img $TEMP
	cd floppy
	cp -r . $TEMP
	cd ../..
	cd resources
	cp -r . $TEMP
    cd ..

	# Unmount floppy
	sudo umount $TEMP
fi
