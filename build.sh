#!/bin/bash
# Set threads count used during GCC compilation
THREADS_COUNT=[THREADS_COUNT]

# Delete old ELF and BIN files
find Build -iname "*.elf" -type f -delete
find Build -iname "*.bin" -type f -delete

find Environment -iname "*.elf" -type f -delete
find Library -iname "*.elf" -type f -delete
find OS -iname "*.elf" -type f -delete

# Delete broken directory
if [ -d "Build/Floppy/$FLOPPY_LETTER" ]; then
	rm -Rf "Build/Floppy/$FLOPPY_LETTER";
fi

export MODE=release

# Build bootloader
cd OS/Bootloader
    make $1 -j $THREADS_COUNT

    if [ "$?" != "0" ]; then
        exit 1
    fi
cd ../..

# Build C Library
cd Library
    make $1 -j $THREADS_COUNT

    if [ "$?" != "0" ]; then
        exit 1
    fi
cd ..

# Build applications
cd Environment
    for i in *;
    do
        cd $i
        make $1 -j $THREADS_COUNT

        if [ "$?" != "0" ]; then
            exit 1
        fi

        if [ "$1" != "clean" ]; then
            cp bin/$i.elf ../../Build/Floppy/ENV/`echo $i | tr a-z A-Z`.ELF
        fi

        cd ..
    done
cd ..

# Build kernel
cd OS/Kernel
    make $1 -j $THREADS_COUNT

    if [ "$?" != "0" ]; then
        exit 1
    fi

    if [ "$1" != "clean" ]; then
        cp bin/kernel.bin ../../Build/Floppy/KERNEL.BIN
        cp bin/kernel.elf ../../Build/kernel.elf
    fi
cd ../..

# Build floppy
if [ "$1" != "clean" ]; then
    # Copy bootloader and kernel to the floppy directory
	cp /OS/Bootloader/bin/bootloader.bin $FLOPPY_LETTER
    cd Floppy
    cp -r . $FLOPPY_LETTER/
	cd ../..
	cd resources
    cp -r . $FLOPPY_LETTER/
    cd ../..

	# Make floppy image, mount it and copy files from floppy directory
	cd Build/Floppy
	mkfs.vfat -C  1440 floppy.img
	mkdir -p $FLOPPY_LETTER
	mount -o loop,uid=$UID -t vfat floppy.img $FLOPPY_LETTER

    # Unmount floppy
    umount $FLOPPY_LETTER
fi
