#!/bin/bash
#
# funkce na vypis informaci, barvy jsou podle ANSI predpisu
display_success() {
	echo -e "\033[0;32mSuccess:\033[0m $1"
}
display_error() {
	echo -e "\033[0;31mError:\033[0m $1"
}
display_info() {
	echo -e "\033[0;33mInfo:\033[0m $1"
}

# kontrola jestli jsme root
if [[ $EUID -gt 0 ]]; then
	display_error "Please run as root user"
	exit 1
fi

# vytvori slozku
# velice spatny napad, ve /home by se nemely vytvaret slozky
# promenna $USER bude vzdy root
display_info "Creating /home/scripts/$USER folder"
mkdir -p /home/scripts/"$USER"

# nastav ji ALL RVX permise
display_info "Setting ALL RVX in that folder"
chmod -R 777 /home/scripts/"$USER"

# vypsani slozky '/' by trvalo nehezky dlouho
display_info "Executing tree on my Downloads folder"
tree /home/tomso/Downloads/ >tree.txt

# vypis skrytych souboru, rekurzivne
display_info "Printing hidden files"
echo "Hidden files:" >hidden.txt
# pomoci find najdeme rekurzivne vsechny soubory, pomoci regexu vyfiltrujeme ty co zacinaji teckou a vystup hodime do ls -la
find /etc -type f -printf "%p\n" | grep '/\.[^/]*$' | xargs ls -la >>hidden.txt
echo >>hidden.txt
echo >>hidden.txt

# vypis hardlinks
echo "Hardlinks: " >>hidden.txt
display_info "Printing hardlinks"
find /etc -type f -links +1 -exec ls -la {} + >>hidden.txt
echo >>hidden.txt
echo >>hidden.txt

# vypis symlinks
display_info "Printing symlinks"
echo >>hidden.txt
echo "Symlinks: " >>hidden.txt
find /etc -type l -ls >>hidden.txt
echo >>hidden.txt
echo >>hidden.txt

display_success "Script finished successfully"
