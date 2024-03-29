#!/bin/bash

ask_to_delete() {
	echo "Delete file(y/n/o)?"
	echo "$1"
}

need_to_delete() {

	ask_to_delete "$1"

	read -p "Input (y/n/o):" answer < /dev/tty

	if echo "$answer" | grep "^y"; then
		return 0
	elif echo "$answer" | grep "^o"; then
		return 1
	elif echo "$answer" | grep "^n"; then
		return 2
	else 
		return 3
	fi
}

is_empty() {
	if [ -s "$1" ]; then
		return 1
	else
		return 0
	fi
}

delete() {
	rm -vr "$1"
}

related_files="related_files.txt"
mdfind -name "$1" > "$related_files"

if is_empty "$related_files"; then
	echo "No '$1' application files on your computer" 
	delete "$related_files"
    exit 0
fi

cat "$related_files" | while read filename; do
	echo "-------------------------"
	need_to_delete "$filename"
	response=$?
	if [ $response -eq 0 ]; then
		echo "  Deleting $filename"
		delete "$filename"
	elif [ $response -eq 1 ]; then
		echo "  Opening"
		parent_dir=$(dirname "$filename")
		open $parent_dir
	elif [ $response -eq 2 ]; then
		echo "  Keeping $filename"
	else
		echo "  Invalid input. File skipped"
	fi
done

delete "$related_files"
exit 0
