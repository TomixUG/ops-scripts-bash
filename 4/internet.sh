#!/bin/bash

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

# overeni jestli mame internet
display_info "Checking internet connection..."
ping -c 4 google.com >/dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Internet is OK" >internet.txt
	echo "" >>internet.txt
	display_success "Internet is OK"
else
	display_error "No internet available"
	display_error "Exitting..."
	exit 1
fi

# user ma zadat IP adresu nebo domenu serveru
while true; do
	read -p "Enter an IP address or a domain name: " server
	if [ -n "$server" ]; then
		# zkontroluj jestli je zadany server validni
		display_info "Checking entered server..."
		ping -c 4 $server >/dev/null 2>&1
		if [ $? -eq 0 ]; then
			display_success "Entered server is online"
			break
		else
			display_error "Entered server is invalid or offline"
		fi

	else
		display_error "Invalid input"
	fi
done

# cesta paketu na zadanou adresu serveru
display_info "Scanning traceroute..."
echo "Traceroute:" >>internet.txt
traceroute "$server" >>internet.txt
echo "" >>internet.txt

# whois
echo "Whois:" >>internet.txt
display_info "Scanning Whois..."
whois "$server" >>internet.txt
echo "" >>internet.txt

# DNS zaznamy
echo "DNS:" >>internet.txt
display_info "Scanning DNS..."
dig @8.8.8.8 "$server" all >>internet.txt
echo "" >>internet.txt

display_success "The results have been saved to internet.txt"
