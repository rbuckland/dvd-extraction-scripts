#!/bin/bash

#
# Usage: makemkv-extractor.sh /dev/sr0 path/to/dump NAME_OF_DVD
# 
# Use this in conjunction with handbrake-server.pl making the savePath the same as the handbrake-server.pl -s savePath
#

dvdDevice=$1
savePath=$2
titleName=$3
MAKEMKVCON="/Applications/MakeMKV.app/Contents/MacOS/makemkvcon"

echo ":: Locating the longest title"
# this line runs makemkv on info which identifies all the titles (stripping our Copy Protected ones etc)
# perl then gets the times from the makemkvcon output of each identified title and then calculates the time
# it them prints out the title with the longest time
titleId=`$MAKEMKVCON info -r disc:$dvdDevice \
| perl -e '$g=0;while (<>) { if (/TINFO:(.*?),9,.*,\"(\d\d?):(\d\d?):(\d\d?)\"/) {$x=($2*3600)+($3*60)+$4;if($x>$g){$g=$x;$t=$1} } } print "$t"'`

echo ":: Title $titleId will be extracted"
echo ":: Making directory ($savePath/$titleName)"
mkdir -p "$savePath/$titleName"
echo ":: Running - makemkvcon mkv dev:$dvdDevice $titleId \"$savePath/$titleName\""
$MAKEMKVCON --progress=-stdout mkv disc:$dvdDevice $titleId "$savePath/$titleName"
diskutil eject /dev/disk1
