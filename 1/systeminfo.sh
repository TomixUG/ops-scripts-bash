#!/bin/bash

# funkce na hezky vypis
display_success() {
	echo -e "\033[0;32mSuccess:\033[0m $1"
	echo "$1" >>log.txt
}

display_info() {
	echo -e "\033[0;33mInfo:\033[0m $1"
	echo "$1" >>log.txt
}

newLine() {
	echo "" >>systeminfo.txt
}

display_info "Processing date..."
echo "Aktualni datum a cas: " >systeminfo.txt
date >>systeminfo.txt
newLine

display_info "Processing current user info..."
echo "Aktualne prihlaseny uzivatel: " >>systeminfo.txt
whoami >>systeminfo.txt

newLine

display_info "Processing system info..."
echo "Systemove informace:" >>systeminfo.txt
echo "- kernel info: " >>systeminfo.txt
uname -a >>systeminfo.txt
newLine

echo "- info o pameti: " >>systeminfo.txt
free -h >>systeminfo.txt
newLine

echo "- vas procesor: " >>systeminfo.txt
cat /proc/cpuinfo | grep 'model name' | uniq | awk -F': ' '/model name/ {print $2}' >>systeminfo.txt

newLine

echo "" >>systeminfo.txt
echo "" >>systeminfo.txt
display_info "Processing paths..."
echo "Seznam vyhledavacich cest:" >>systeminfo.txt
echo $PATH >>systeminfo.txt

newLine

display_info "Processing env variables..."
echo "Seznam a hodnoty systemovych promennych:" >>systeminfo.txt
printenv >>systeminfo.txt

display_success "Output is in systeminfo.txt"
