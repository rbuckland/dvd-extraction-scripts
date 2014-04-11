#!/bin/sh

#
# ramon@thebuckland.com
#
# This script estimates the extraction size of a directory 
#
# estimate.sh <src> <dest>
#
# eg   estimate.sh /dev/scd0 /some/path/to/where/the/dvd/is/being/EXTRACTED
#

dvdDevice=$1
destDir=$2

actual=`df -B 1 $dvdDevice | tail -1 | awk '{print $2;}'`

while [ 1 ]
do
  current=`du -B 1 -s "$destDir"  | cut -f 1`
  echo 1  | awk " { print  ( $current / $actual * 100) \"%\"; } "
  sleep 5
done


