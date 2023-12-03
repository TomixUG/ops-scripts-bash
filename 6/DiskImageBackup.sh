#!/bin/bash
# funkce na vypis informaci, barvy jsou podle ANSI predpisu
display_success() {
	echo -e "\033[0;32mSuccess:\033[0m $1"
}
display_error() {
	echo -e "\033[0;31mError:\033[0m $1"
}
display_usage() {
	echo -e "\033[0;31mUsage:\033[0m $1"
}
display_info() {
	echo -e "\033[0;33mInfo:\033[0m $1"
}

# zkontroluj jestli uzivatel zadal vsechny argumenty (alespon 2)
if [ "$#" -ne 2 ]; then
	display_usage "$0 SOURCE_DISK DESTINATION_PATH"
	exit 1
fi

SOURCE_DISK=$1
DESTINATION_PATH=$2

# zkontrolovat jestli cesta existuje
if [ ! -b "$SOURCE_DISK" ]; then
	display_error "Source disk doesn't exist"
	exit 1
fi

# zkontrolovat jestli cílová složka existuje
if [ ! -d "$DESTINATION_PATH" ]; then
	display_error "Destination path is invalid"
	exit 1
fi

# nazev souboru vygenerujeme s pomoci aktualniho data a casu
filename="$DESTINATION_PATH/$(date +"%Y%m%d_%H%M%S")_disk_image.img"

# pomoci programu dd naclonujeme image disku
display_info "Creating the image..."
if ! dd if="$SOURCE_DISK" of="$filename" bs=4M conv=sync,noerror status=progress; then
	display_error "There was an error while creating the image"
	exit 1
fi

# zkompresujeme image pomoci gzip
display_info "Compressing the image..."
if ! gzip "$filename"; then
	display_error "There was an error while compressing the image (no permission?)"
	exit 1
fi

display_success "Backup completed successfully!"
display_success "Image path: $filename.gz"
