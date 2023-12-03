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

# kontrola jestli existuje vstupni soubor
input_file="priklady.txt"
if [ ! -f "$input_file" ]; then
	display_error "Input file '$input_file' not found."
	exit 1
fi

display_info "Processing expressions. Please wait..."

result_content="" # zde se ukladaji vysledky prikladu

i=0
# loopni kazdy radek vstupniho souboru
while IFS= read -r line || [[ -n "$line" ]]; do
	i=$((i + 1))

	# ignoruj prazdne radky
	if [ -z "$line" ]; then
		continue
	fi

	# pomoci programu bc vypocte vylsedek, pokud je chyba vrati prazdnou promennou
	result=$(echo "scale=2; $line" | bc -l 2>/dev/null)

	# pokud nastala chyba napis chyba a ukonci program
	if [ -z "$result" ]; then
		display_error "(line $i) Invalid expression: $line"
		display_error "Exiting..."
		exit 1
	else
		display_success "$line = $result"
		result_content+="\n$line = $result" # uloz vylsedek do temp promenne
	fi
done <"$input_file"

# zkopiruj vystup z temp promenne do vstupniho souboru
echo -e "$result_content" >>"$input_file"

display_info "Results appended into '$input_file'"
