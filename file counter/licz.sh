#!/bin/sh

#Sprawdzenie liczby argumentow
if [ $# -lt 1 ] || [ $# -gt 3 ]
then
	echo "Niepoprawna liczba argumentow"
	echo "Poprawne wywolanie: ./licz.sh [-R] katalog [typ]"
	exit 0
fi

#Funkcja do sprawdzania poprawnosci typu poszukiwanego pliku
isType(){
	if [ "$1" = "f" ] || [ "$1" = "d" ] || [ "$1" = "c" ] || [ "$1" = "b" ] || [ "$1" = "s" ] || [ "$1" = "p" ] || [ "$1" = "l" ]
	then 
		return 0
	else
		return 1
	fi
}

flag=0		#Flaga do okreslania czy wystepuje rekurencja
liczba=0	#Koncowy wynik obliczen
katalog=""	#Sciezka do katalogu
typ=""		#Typ pliku


#Sprawdzenie czy wystepuje rekurencja
if [ $1 = "-R" ]
then
	flag=1
        typ="$3"
	katalog="$2"
else
	flag=0
	katalog="$1"
	typ="$2"
fi

#Sprawdzenie czy nie wystepuja niedozwolone typy plikow
if [ $flag = 0 ] && [ ! -z "$2" ]
then
	if ! isType $2 
	then
		echo "Niedozwolony typ plikow "$2""
		exit 1
	fi
elif [ $flag = 1 ] && [ ! -z "$3" ]
then
	if ! isType $3
        then
                echo "Niedozwolony typ plikow "$3""
                exit 1
        fi
fi

#Sprawdzenie czy katalog istnieje
if [ ! -d $katalog ]
then
	echo "Katalog nie istnieje"
	exit 2
fi

#Sprawdzenie praw dostepu do katalogu
if [ ! -r $katalog ]
then
	echo "Brak praw do odczytu katalogu"
	exit 3
fi

#Obliczanie ilosci podanego typu pliku lub wszystkich plikow w katalogu
if [ $flag = 0 ]
then
	if [ -z "$2" ]
	then
		liczba=$( find "$katalog" -maxdepth 1 ! -path '.' ! -path ".." | awk 'END {print NR}')
		echo "Liczba wszystkich plikow: "$liczba""
	else
		liczba=$( find "$katalog" -maxdepth 1 -type "$typ" ! -path '.' ! -path '..' | awk 'END {print NR}')
	echo "Liczba plikow typu "$typ" : "$liczba""
	fi
else
	if [ -z "$3" ]
        then
                liczba=$( find "$katalog" ! -path '.' ! -path ".." | awk 'END {print NR}')
                echo "Liczba wszystkich plikow: "$liczba""
        else
                liczba=$( find "$katalog" -type "$typ" ! -path '.' ! -path '..' | awk 'END {print NR}')
        echo "Liczba plikow typu "$typ" : "$liczba""
                        
        fi

fi


