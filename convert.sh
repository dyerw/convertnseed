#!/bin/bash

flac_folder=$1
tracker_url=$2

# Make folders for mp3 formats
m320_folder=${flac_folder//"FLAC"/"320"} 
v0_folder=${flac_folder//"FLAC"/"v0"} 
v2_folder=${flac_folder//"FLAC"/"v2"} 

mkdir "${m320_folder}"
mkdir "${v0_folder}"
mkdir "${v2_folder}"

# Convert all FLAC to 320, v0, v2 mp3s 
# IFS is a hack b/c the file names have spaces
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for file in $(ls "${flac_folder}"*.flac)
do
	file_base=$(basename ${file})
	mp3_filename=${file_base//"flac"/"mp3"}
	
	# Convert to 320 and save into 320 folder
	echo ${file}
	sox "${file}" -C 320 "${m320_folder}${mp3_filename}"
	sox "${file}" -C -0.2 "${v0_folder}${mp3_filename}"
	sox "${file}" -C -2.2 "${v2_folder}${mp3_filename}"
done

# Copy album art into the new folders
for file in $(ls "${flac_folder}"*.jpg)
do
	file_base=$(basename ${file})
	for folder in ${m320_folder} ${v0_folder} ${v2_folder}
	do
		echo "Copying ${file} to ${folder}${file_base}"
		cp ${file} ${folder}/${file_base}
	done
done

IFS=$SAVEIFS

# Create all the torrent files
sudo transmission-create -p -t ${tracker_url} -o "$(basename "${flac_folder}").torrent" "${flac_folder}"
sudo transmission-create -p -t ${tracker_url} -o "$(basename "${m320_folder}").torrent" "${m320_folder}"
sudo transmission-create -p -t ${tracker_url} -o "$(basename "${v0_folder}").torrent" "${v0_folder}"
sudo transmission-create -p -t ${tracker_url} -o "$(basename "${v2_folder}").torrent" "${v2_folder}"
