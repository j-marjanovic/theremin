
nr_lines=0

files=$(ls -1)
for filename in $files
do
	ext=$(echo $filename | awk -F. '{print $2;}')
	if [ ${#ext} -gt 0 ] && [ $ext == "sv" ]
	then
		nr_lines=$((nr_lines+$(wc -l $filename | awk {'print $1;'})))
	fi
done

echo "Number of .sv lines: " $nr_lines
