#!/bin/bash

# usage:
# $ ispring2mp4.sh https://medichi.blackboard.com/class/index.html
#
# expected output:
# class.mp4

url=$(echo $1 | sed -e 's:/index.html::')
class_name=$(awk -F/ '{ print $NF}' <<<"$url")
username="17645592-6"
password="17645592-6"
number=$(find $PWD -name '*.png' -type f | wc -l)
dir=$(find $PWD -maxdepth 0 -printf "%f\n")

mkdir $class_name
curl --anyauth --user $username:$password --cookie-jar cookies.txt $url.pdf -o $class_name/$class_name.pdf

for (( h = 1; h <= $number; h++ ))
do
	aria2c https://medichi.blackboard.com/bbcswebdav/pid-75552-dt-content-rid-4652566_1/courses/C_GERIATRIA_V2/modulo_3_geriatria/lesiones_presion_cortez/data/sound$h.ogg --load-cookies=cookies.txt
done

rm vlist.txt
for (( i = 1; i <= $number; i++ ))
do
	echo "file '$i.png'" >> vlist.txt
	echo "duration $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 sound$i.ogg)" >> vlist.txt
done

rm alist.txt
for (( j = 1; j <= $number; j++ ))
do
	echo "file 'sound$j.ogg'" >> alist.txt
	echo "duration $(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 sound$j.ogg)" >> alist.txt
done

ffmpeg -f concat -safe 0 -i vlist.txt -vcodec libx264 -crf 25 -preset medium -tune stillimage -profile:v baseline -level 3.0 -vf "fps=30000/1001,format=yuv420p" out.mp4

ffmpeg -f concat -safe 0 -i alist.txt -acodec aac -ab 192k -ac 2 -ar 44100 -absf aac_adtstoasc -async 1 out.aac

ffmpeg -i out.mp4 -i out.aac -map 0:0 -map 1:0 -c:v copy -c:a copy $dir.mp4

mpv $dir.mp4
