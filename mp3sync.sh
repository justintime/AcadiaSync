#!/bin/bash
VOLUME="ACADIA"
USER=justintime

# Copy com.techadvise.mp3sync.plist to /System/Library/LaunchDaemons/
# Run sudo launchctl load /System/Library/LaunchDaemons/com.techadvise.mp3sync.plist

# Redirect everything to a file
exec &> /tmp/mp3sync.log

PATH=/bin:/usr/bin:/usr/local/bin
MOUNTPOINT="/Volumes/${VOLUME}"

if [ ! -d ${MOUNTPOINT} ]; then
  echo "${VOLUME} not mounted at ${MOUNTPOINT}"
  exit
fi

# --size-only saves a lot of time on slow usb without timestamp support
rsync -ruv --delete --size-only /Users/${USER}/Music/iTunes/iTunes\ Media/Music/* ${MOUNTPOINT}/

java -jar $(dirname $0)/itunesexport/itunesexport.jar -library=/Users/${USER}/Music/iTunes/iTunes\ Music\ Library.xml -outputDir=${MOUNTPOINT} -musicPath="/"

cd ${MOUNTPOINT} && rm -rf .Spotlight-V100 .Trashes ._.Trashes .fseventsd &&  echo "Removed hidden dirs"
cd /

if [ -x "/usr/local/bin/fatsort" ]; then
  DEVICE=$(/sbin/mount | grep ${MOUNTPOINT} | cut -d' ' -f1)
  /usr/sbin/diskutil unmount /Volumes/${VOLUME}
  /usr/local/bin/fatsort -I -c ${DEVICE} && echo "Completed FAT sort."
fi

