#!/bin/bash

DVD_INFO=$(isoinfo -d -i /dev/cdrom)

echo ${DVD_INFO}

echo "This is 02G05 a test string 20-Jul-2012" | egrep -o '[0-9]+G[0-9]+' 


#dd if=/dev/cdrom bs=2048 count=1621535 of=filename.iso
