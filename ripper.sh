#!/bin/bash
# 
# Copyright (c) 2017 Marc Young
#
# encode for playback on Roku or Chromcast

MOUNT_PATH=/media/${USER}
E="_e"
S="_s"

is_tv () {
  read -p "Is this tv [yn]" answer
}

mount_isos () {
  for f in *.iso
  do
    FILENAME=${f%%.*}
    sudo mkdir -p i"${MOUNT_PATH}/${FILENAME}"
    sudo mount -o loop "${f}" "${MOUNT_PATH}/${FILENAME}"
  done
}

is_tv

case "${answer}" in
   [yY][eE][sS]|[yY])
	echo "What is the name of the show?"
	read -r show_name

	echo "What season is it?"
	read -r season

	echo _"What episode is it?"
	read -r episode

	echo "What quality level (14-20)?"
	read -r quality

        echo "Loads from dvd"
    	SOURCE=/dev/cdrom;;
    *)
        echo "Loads from other"
	echo "From which source would you like to load from?"
	echo "Select a number."
	mount_isos
	cd "${MOUNT_PATH}" || exit
	array=($(ls -d */))
	INDEX=0
	for i in "${array[@]}"
	do
	  echo "${INDEX}" ":" "$i"
	  let INDEX=${INDEX}+1
	done	
	read -r INDEX_NUM
	MOUNTED_SOURCE=${array[${INDEX_NUM}]}
	SOURCE=${MOUNT_DIR}/${MOUNTED_SOURCE}
	;;
esac

if [ ! -d "${show_name}" ]; then
        mkdir "${show_name}"
fi

cd "${show_name}" || exit

lsdvd "${SOURCE}" > dvdinfo
sed -i '/Disc Title:/d' dvdinfo
sed -i '/Longest track:/d' dvdinfo

sequence=$(wc -l < dvdinfo) 

for i in `seq $sequence`; do 
line=$(awk 'NR=='"$i" dvdinfo)
	if echo "${line}" | grep -Eq 'Length: 00:0'
		then 
		echo "Crap"
	else
		echo "great"
		title=$(echo "${line}" | awk '{print $2}' | sed 's/^0*//' | tr -dc '[:alnum:]\n\r')
		HandBrakeCLI -E copy:aac --input "${SOURCE}" --title "${title}" --output "${show_name}${S}${season}${E}${episode}".mp4 -e x264 -q "${quality}" -B 320;
		episode=$((episode+1))
	fi

done

eject

exit


