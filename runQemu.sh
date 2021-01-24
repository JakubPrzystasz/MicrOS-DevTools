#!/bin/bash

if test $# -eq 0; then
	echo "Mode not specified"
	exit 1
fi

while test $# -gt 0; do
	case "$1" in
		-debug)
			DEBUG=1
            shift
			;;
		-run)
			RUN=1
            shift
            ;;
	esac
done

if [ $DEBUG -eq 1 ]; then
[QEMU_PATH] -m 640M\
 -monitor stdio \
 -drive file=build/floppy.img,format=raw,if=floppy\
 -drive file=build/hdd.img,format=raw -boot a -S -s\
 -netdev user,id=u1,hostfwd=tcp::5555-:22\
 -device rtl8139,netdev=u1\
 -object filter-dump,id=f1,netdev=u1,file=dump.dat
fi


if [ $RUN -eq 1 ]; then
[QEMU_PATH] -m 640M\
 -drive file=build/floppy.img,format=raw,if=floppy\
 -drive file=build/hdd.img,format=raw -boot a -soundhw pcspk\
 -netdev user,id=u1,hostfwd=tcp::5555-:22\
 -device rtl8139,netdev=u1
fi