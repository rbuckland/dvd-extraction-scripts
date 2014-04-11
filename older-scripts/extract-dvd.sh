#!/bin/sh


start=`date`
rawDir=$1
name=$2
touch ${rawDir}/"${name}".extracting
dvdbackup -v -M -o ${rawDir} --name="${name}" 2>&1 /var/log/extract-dvd-${name}.log
rm ${rawDir}/"${name}".extracting
finish=`date`

echo $start
echo $finish

eject /dev/cdrom
