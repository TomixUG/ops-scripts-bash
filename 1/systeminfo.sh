#!/bin/bash

newLine() {
	echo "" >>systeminfo.txt
}

echo "Aktualni datum a cas: " >systeminfo.txt
date >>systeminfo.txt
newLine

echo "Aktualne prihlaseny uzivatel: " >>systeminfo.txt
whoami >>systeminfo.txt

newLine

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

echo "Seznam vyhledavacich cest:" >>systeminfo.txt
echo $PATH >>systeminfo.txt

newLine

echo "Seznam a hodnoty systemovych promennych:" >>systeminfo.txt
printenv >>systeminfo.txt

top >>systeminfo.txt
