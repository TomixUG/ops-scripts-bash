#!/bin/bash

# funkce na vypis informaci, barvy jsou podle ANSI predpisu
display_success() {
	echo -e "\033[0;32mSuccess:\033[0m $1"
	echo "$1" >>log.txt
}
display_error() {
	echo -e "\033[0;31mError:\033[0m $1"
	echo "ERRROR: $1" >>log.txt
}
display_usage() {
	echo -e "\033[0;31mUsage:\033[0m $1"
}
display_info() {
	echo -e "\033[0;33mInfo:\033[0m $1"
	echo "$1" >>log.txt
}

# zkontroluj jestli byly dodany vsechny parametry
if [ "$#" -ne 1 ] || ([ "$1" != "create" ] && [ "$1" != "remove" ]); then
	display_usage "$0 <create | remove>"
	exit 1
fi

# kontrola jestli jsme root
if [[ $EUID -gt 0 ]]; then
	display_error "Please run as root user"
	exit 1
fi

echo "----- User creation script ($(date)) -----" >log.txt

# zkontroluj jestli soubor studenti.xlsx existuje
if ! [[ -f "studenti.xlsx" ]]; then
	display_error "The input file 'studenti.xlsx' doens't exist"
	echo "ERROR: The input file sudenti.xlsx doesn't exist" >>log.txt
	exit 1
fi
# konvertovani .xlsx do jednoduse citelneho .csv
./gocsv xlsx --sheet 1 studenti.xlsx | grep -v '^$' >studenti.csv

# podle toho jaky uzivatel zadal argument bud spust vytvareni nebo mazani
if [ "$1" = "create" ]; then
	echo "### Mode: creating users ###" >>log.txt
	echo "" >>log.txt

	# vytvoreni vsech groups
	display_info "Creating groups..."
	groups=("T1A" "T2A" "T3A" "T4A" "E1A" "E2A" "E3A" "E4A" "E1B" "E2B" "E3B" "E4B" "STUDENTI" "ICT" "ELEKTRO" "MUZI" "ZENY")
	for group_name in "${groups[@]}"; do
		groupadd "$group_name" 2>/dev/null
		if [ $? -eq 0 ]; then
			display_info "Group '$group_name' created"
		else
			display_info "Group '$group_name' was already created"
		fi
	done

	echo "" >>log.txt

	# loopni kazdeho zaka
	while IFS=',' read -r last_name first_name class_name grade gender; do
		# echo "$last_name" "$first_name" "$class_name" "$grade" "$gender"

		username=$(echo "$last_name" | tr -d ' ' | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]').$(echo "$first_name" | tr -d ' ' | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]')
		password=$(echo "$last_name" | tr -d ' ' | iconv -f utf-8 -t ascii//TRANSLIT)Q12020\!

		# predpokladame, ze script se pousti prvniho zari
		current_year=$(date +%Y)
		if [[ $grade = "První ročník" ]]; then
			expire_date="31-08-$((current_year + 4))"
		elif [[ $grade = "Druhý ročník" ]]; then
			expire_date="31-08-$((current_year + 3))"
		elif [[ $grade = "Třetí ročník" ]]; then
			expire_date="31-08-$((current_year + 2))"
		elif [[ $grade = "Čtvrtý ročník" ]]; then
			expire_date="31-08-$((current_year + 1))"
		else
			display_error "Invalid grade received!, exitting..."
			exit 1
		fi

		# -m vytvori home slozku, -s specifikuje shell
		display_info "---- Creating a user $username ..."
		if ! useradd -m -s /bin/bash "$username" -e "$expire_date" >/dev/null 2>&1; then
			display_error "Error while creating $username, skipping..."
			continue
		fi

		# nastaveni hesla pomoci chpasswd
		display_info "Setting a password..."
		echo "$username:$password" | chpasswd

		# tento prikaz expiruje heslo uzivatele, takze si musi vytvorit nove heslo
		passwd --expire "$username" >/dev/null 2>&1

		# pridej to skupiny Studenti
		display_info "Adding STUDENTI group..."
		if ! usermod -a -G "STUDENTI" "$username" >/dev/null 2>&1; then
			display_error "Failed to add user to STUDENTI group"
		fi

		# pridej do skupiny s nazvem tridy, slo by pres if pro lepsi bezpecnost
		display_info "Adding $class_name group..."
		if ! usermod -a -G "$class_name" "$username"; then
			display_error "Failed to add user to $class_name group"
		fi

		# pridej do skupiny pohlavi
		if [[ $gender = "Muž" ]]; then
			display_info "Adding MUZI group..."
			usermod -a -G "MUZI" "$username" >/dev/null 2>&1
		elif [[ $gender = "Žena" ]]; then
			display_info "Adding ZENY group..."
			usermod -a -G "ZENY" "$username" >/dev/null 2>&1
		else
			display_error "Invalid gender received!, exitting..."
			exit 1
		fi
		if ! [ $? -eq 0 ]; then
			display_error "Failed adding user to group"
		fi

		# pridej do oboru
		if [[ ${class_name:0:1} == "T" ]]; then
			display_info "Adding ICT group..."
			usermod -a -G "ICT" "$username" >/dev/null 2>&1
		elif [[ ${class_name:0:1} == "E" ]]; then
			display_info "Adding ELEKTRO group..."
			usermod -a -G "ELEKTRO" "$username" >/dev/null 2>&1
		else
			display_error "Invalid class name received!, exitting..."
			exit 1
		fi
		if ! [ $? -eq 0 ]; then
			display_error "Failed adding user to class group"
		fi

		display_success "User $username successfully created"

		echo "" >>log.txt

	done <studenti.csv
elif [ "$1" = "remove" ]; then
	echo "### Mode: removing users ###" >>log.txt
	echo "" >>log.txt

	# loopni kazdeho zaka
	while IFS=',' read -r last_name first_name class_name grade gender; do
		username=$(echo "$last_name" | tr -d ' ' | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]').$(echo "$first_name" | tr -d ' ' | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]')

		# vymaz uzivatele
		display_info "Removing user $username"
		if ! userdel -r "$username" >/dev/null 2>&1; then
			display_error "There was an error removing $username (does it exist?)"
		else
			display_success "$username removed"
		fi

		echo "" >>log.txt

	done <studenti.csv
fi
