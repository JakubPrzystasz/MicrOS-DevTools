#!/bin/bash
# Set threads count used during GCC compilation
THREADS_COUNT=4

mkdir -p build/floppy/ENV

# Delete old ELF and BIN files
find build -iname "*.elf" -type f -delete
find build -iname "*.bin" -type f -delete

find environment -iname "*.elf" -type f -delete
find library -iname "*.elf" -type f -delete
find os -iname "*.elf" -type f -delete

# Delete broken directory
if [ -d "build/floppy/$FLOPPY_LETTER" ]; then
	rm -Rf "build/floppy/$FLOPPY_LETTER";
fi

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
    # Upload bootloader to the floppy
    dd if=os/bootloader/bin/bootloader.bin bs=512 of=build/floppy.img
fi

# Build floppy
if [ "$1" != "clean" ]; then
	# mount floppy image and
	cd build/floppy/
	mkdir -p $FLOPPY_LETTER/
	sudo mount -o loop,uid=$UID ../floppy.img $FLOPPY_LETTER/

    # Copy kernel to the floppy directory
    sudo cp -r . $FLOPPY_LETTER/
	cd ../..
	cd resources
	sudo cp -r . $FLOPPY_LETTER/
    cd ../..

    # Unmount floppy remove mount directory
   	sudo umount $FLOPPY_LETTER/
fi
