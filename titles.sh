#!/bin/bash
# 
# Copyright (c) 2017 Marc Young
#
# encode for playback on Roku or Chromcast

echo "What is the name of the show?"
read show_name

if [ ! -d "$show_name" ]; then
	mkdir $show_name
fi

echo "What season is it?"
read season

echo "What episode is it?"
read episode

echo "What quality level (14-20)?"
read quality

read -r -p "Load movie from DVD? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        echo "Loads from dvd"
    	$SOURCE=/dev/dvd
    *)
        echo "Loads from other"
	echo "From which source would you like to load from?"
	array=($(ls -d */))
	for i in "${array[@]}"
	do
		echo $i
	done
	sleep 300
	lsdvd /media/${USER}/${MOUNTED_OPTION} > dvdinfo
	;;
esac

lsdvd ${SOURCE} > dvdinfo

sed -i '/Disc Title:/d' dvdinfo
sed -i '/Longest track:/d' dvdinfo

sequence=$(wc -l < dvdinfo) 
echo $sequence
sleep 4

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

#echo $line | awk '{print $2}' | sed 's/^0*//' | tr -dc '[:alnum:]\n\r'
#HandBrakeCLI --input /dev/dvd --title $i --preset Normal --output $show_name/$show_name"_s"$season"_e"$i.mp4 -s 1; 
  
 # counter=$((counter+1))

done

eject
#while read line; do

		#HandBrakeCLI --input /dev/dvd --title $title --preset Normal --output $show_name/$show_name"_s"$season"_e"$episode.mp4
		#episode=$((episode+1))
		#echo $title
#		HandBrakeCLI --input /dev/dvd --title $i --preset Normal --output $show_name/$show_name"_s"$season"_e"$i.mp4 -s 1
#done < dvdinfo.txt


#cat dvdinfo.txt | while read line
#do
#		title=$(echo $line | awk '{print $2}' | sed 's/^0*//' | tr -dc '[:alnum:]\n\r')
#	    HandBrakeCLI --input /dev/dvd --title $title --preset Normal --output $show_name/$show_name"_s"$season"_e"$title.mp4 -s 1

#done


#for i in `seq `$sequence; do HandBrakeCLI --input /dev/dvd --title $i --preset Normal --output $show_name/$show_name"_s"$season"_e"$i.mp4 -s 1; done
