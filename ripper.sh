#!/bin/bash
# 
# Copyright (c) 2017 Marc Young
#
# encode for playback on Roku or Chromcast

MOUNT_PATH=/media/${USER}

echo "What is the name of the show?"
read -r show_name

echo "What season is it?"
read -r season

echo _"What episode is it?"
read -r episode

echo "What quality level (14-20)?"
read -r quality

mount_isos () {
  for f in *.iso
  do
    FILENAME=${f%%.*}
    sudo mkdir -p ${MOUNT_PATH}/${FILENAME}
    sudo mount -o loop ${f} ${MOUNT_PATH}/${FILENAME}
  done
}


read -r -p "Load movie from DVD? [y/N] " response
case "${response}" in
    [yY][eE][sS]|[yY])
        echo "Loads from dvd"
    	SOURCE=/dev/dvd;;
    *)
        echo "Loads from other"
	echo "From which source would you like to load from?"
	echo "Select a number."
	mount_isos
	cd ${MOUNT_PATH} 
	array=($(ls -d */))
	INDEX=0
	for i in "${array[@]}"
	do
	  echo ${INDEX} ":" $i
	  let INDEX=${INDEX}+1
	done	
	read -r INDEX_NUM
	MOUNTED_SOURCE=${array[${INDEX_NUM}]}
	SOURCE=${MOUNT_DIR}/${MOUNTED_SOURCE}
	;;
esac
echo ${SOURCE}
exit
if [ ! -d "${show_name}" ]; then
        mkdir ${show_name}
fi

lsdvd ${SOURCE} > dvdinfo
exit
sed -i '/Disc Title:/d' dvdinfo
sed -i '/Longest track:/d' dvdinfo

sequence=$(wc -l < dvdinfo) 

if [ ! -d "$show_name" ]; then
        mkdir $show_name
fi

for i in `seq $sequence`; do 
line=$(awk 'NR=='$i dvdinfo)
	if echo $line | grep -Eq 'Length: 00:0'
		then 
		echo 'Crap'
	else
		echo "great"
		title=$(echo $line | awk '{print $2}' | sed 's/^0*//' | tr -dc '[:alnum:]\n\r')
		HandBrakeCLI -E copy:aac --input "${SOURCE}" --title $title --preset Normal --output $show_name/$show_name"_s"$season"_e"$episode.mp4 -e x264 -q $quality -B 320;
		episode=$((episode+1))
	fi

done

eject

exit


