#!/bin/bash

search_dir=history_tmp
output_dir="history"
source_dir="shm"
filename=

db_schema="idxstock"
db_table="history"

abort() {
	echo "$@"
	exit 1
}

copy_file() {
	cp ./$source_dir/*.csv ./$search_dir/
}

read_all_file() {
	for file in "$search_dir"/*.csv; do
		filename=$(echo "$file" | sed "s/\.\///g")
		old_filename=$(echo "$filename" | sed "s/$search_dir\///g")
		# shellcheck disable=SC2001
		new_filename=$(echo "$old_filename" | sed "s/\.csv//g")
		echo "Formating, $old_filename to $new_filename.sql"
		# Replace blank with NULL
		sed -i='' -e 's/,,/,NULL,/g' "$filename"
		# Remove T00:00:00 if exist
		sed -i='' -e "s/T00:00:00//g" "$filename"
		# add quote 'YYYY-MM-DD'
		sed -i='' -e 's/\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)/'\''\1'\''/' "$filename"
		# add (
		sed -i='' -e "1!s/^/('$new_filename',/" "$filename"
		# add ),
		sed -i='' -e '1!s/$/),/' "$filename"
		# Remove coma symbol on last line
		sed -i='' -e '$s/,$//' "$filename"
		# add INSERT (column... in first Line
		sed -i='' -e "1s/^/INSERT INTO $db_schema.$db_table (code,/" "$filename"
		# add ) VALUES in first Line
		sed -i='' -e '1s/$/) VALUES/' "$filename"

		mv $search_dir/"$old_filename" ./$output_dir/"$new_filename".sql
	done
}

main() {
	clear
	pwd

	mkdir -p "$search_dir"
	rm -rf "$output_dir"
	mkdir -p "$output_dir"

	copy_file
	read_all_file

	rm -rf "$search_dir"
}

main || abort "Compose Error!"
