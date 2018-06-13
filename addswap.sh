#!/bin/bash

SWAPFILENAME=swapfile1
SWAPPATH="/$SWAPFILENAME" 

if [ ! -f "$SWAPPATH" ]; then
  dd if=/dev/zero of="$SWAPPATH" bs=1024 count=1048576
  chown root:root "$SWAPPATH"
  chmod 0600 "$SWAPPATH"
  mkswap "$SWAPPATH"
fi
swapon "$SWAPPATH"
