#!/bin/bash
# 
# Copyright (c) 2019 Marc Young
#
# encode for playback on Roku or Chromcast

MOUNT_PATH=/media/${USER}
E="_e"
S="_s"

is_tv () {
  read -p "Is this tv [yn]" answer
}

questions () {
        echo "What is the name of the show?"
        read -r show_name

        echo "What season is it?"
        read -r season

        echo _"What episode is it?"
        read -r episode

        echo "What quality level (14-20)?"
        read -r quality

	if [ ! -d "${show_name}" ]; then
        	mkdir "${show_name}"
	fi

	cd "${show_name}" || exit
}


is_tv

case "${answer}" in
   [yY][eE][sS]|[yY])
	questions

        echo "Loads from dvd"
    	SOURCE=/dev/cdrom


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
	;;
    *)
        echo "Loads from other"
	echo "From which source would you like to load from?"
	echo "Path to ISO file."
	read -r ISO_FILE
	 
	questions
	
	rawout=$(HandBrakeCLI -i "${ISO_FILE}"/video_ts -t 0 2>&1 >/dev/null)
	#read handbrake's stderr into variable

	count=$(echo $rawout | grep -Eao "\\+ title [0-9]+:" | wc -l)
	#parse the variable using grep to get the count

	echo $count 
	sleep 3s
	for i in $(seq $count)
	do
		HandBrakeCLI -E copy:aac --input "${ISO_FILE}" --title "${i}" --output "${show_name}${S}${season}${E}${episode}".mp4 -e x264 -q "${quality}" -B 320;
	sleep 60m
	done
	;;
esac

eject

exit
