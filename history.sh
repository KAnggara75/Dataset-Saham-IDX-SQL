#!/bin/bash

set -e

search_dir="csv2sql"
output_dir="history"

abort() {
	echo "$@"
	exit 1
}

copy_file() {
	mkdir -p "$search_dir"
	cp ./Saham/*.csv "$search_dir"/
}

read_all_file() {
	mkdir -p "$output_dir"
	for file in "$search_dir"/*.csv; do
		filename="${file#./}"                     # Hilangkan './' di depan
		old_filename="${filename#${search_dir}/}" # Ambil nama file saja
		new_filename="${old_filename%.csv}"       # Hilangkan ekstensi .csv

		echo "Formating $old_filename to $new_filename.sql"

		# Ganti kosong dengan NULL
		sed -i='' -e 's/,,/,NULL,/g' "$filename"

		# Hapus T00:00:00 jika ada
		sed -i='' -e 's/T00:00:00//g' "$filename"

		# Bungkus tanggal YYYY-MM-DD dengan tanda petik satu
		sed -i='' -e "s/\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)/'\1'/" "$filename"

		# Tambahkan ('CODE', di setiap baris kecuali baris pertama (header)
		sed -i='' -e "1!s/^/('$new_filename',/" "$filename"

		# Tambahkan ), di akhir setiap baris kecuali baris pertama
		sed -i='' -e "1!s/\$/),/" "$filename"

		# Hapus koma di akhir baris terakhir
		sed -i='' -e '$s/,$//' "$filename"

		# Tambahkan header INSERT ... pada baris pertama
		sed -i='' -e '1s/^/INSERT INTO history (code, /' "$filename"

		# Tambahkan ) VALUES pada akhir baris pertama
		sed -i='' -e '1s/\$/) VALUES/' "$filename"

		# Ganti kata change dengan `change`
		sed -i='' -e 's/\bchange\b/`change`/g' "$filename"

		mv "$file" "$output_dir/$new_filename.sql"
	done
}

main() {
	clear
	pwd
	rm -rf "$output_dir"
	mkdir -p "$output_dir"
	mkdir -p "$search_dir"

	copy_file
	read_all_file

	rm -rf "$search_dir"
}

main || abort "Compose Error!"
