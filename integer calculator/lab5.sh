#!/bin/zsh

#Informacje o skrypcie mozna wyswietlic za pomoca ./lab5.sh --about


if [[ $1 = "--about" ]]
then
	echo "Skrypt dziala jak prosty kalkulator liczb calkowitych
	Dozwolone dzialania: +-*/
	Poprawne wywolanie skryptu: ./lab5.sh arg op ( arg op arg )...
	Skrypt sprawdza poprawnosc skladni i jesli wszystko jest dobrze oblicza podane wyrazenie uzywajac polecenia expr. Uzytkownik informowany jest o popelnionym bledzie
	Znaki *() musza byc poprzedzone znakiem \ "
	exit 0
fi


#Funkcja sprawdzajaca czy argument jest liczba calkowita
isInt() {
if [[ "$1" =~ ^[+-]?[0-9]+$ ]]
then
	return 0
else
	return 1
fi
}


#Funkcja sprawdzajaca czy argument jest operatorem
isOperator(){
	if [[ ${#1} -ne 1 ]] 
	then
		return 1
	elif [ "$1" = "+" ] || [ "$1" = "-" ] || [ "$1" = "/" ] || [ "$1" = '*' ]
       	then
                return 0
	else
		return 1
	fi
}



#Sprawdzenie liczby arugmentow
if [ $# -lt 3 ]
then
        echo "Za malo argumentow"
        echo "Poprawne wywolanie skryptu: ./lab5.sh arg op ( arg op arg )..."
        exit 1
fi

#Sprawdzenie czy 1 argument jest liczba lub nawiasem otwierajacym
if ! isInt $1 && [[ $1 != '(' ]]
then
	echo "Pierwszy argument musi byc liczba calkowita lub nawiasem otwierajacym"
	exit 2
fi

cur=2	#Numer aktualnego argumentu
prev=1	#Numer poprzedniego argumentu
next=3	#Numer kolejnego argumentu

flag=0	#Flaga okreslajaca czy nawias zostal zamkniety
chck=0	#Zmienna pomocnicza do sprawdzenia poprawnosci nawiasow
chck2=0	#Zmienna pomocnicza do sprawdzenia poprawnosci argumentow

flag2=0	#Flaga pomocnicza do sprawdzania czy nie wystepuje dzielenie przez nawias ktory jest rowny 0
partRes=0 #Czastkowy wynik nawiasu do sprawdzania czy nie wystepuje dzielenie przez 0
p=0	  #Zmienna pomocnicza
d=0	  #Zmienna pomocnicza

args=("$@")	#Tablica wszystkich argumentow
result=0	#Wynik koncowy



#Sprawdzenie czy nawias zostal zamkniety, czy nie wystepuja nawiasy zagniezdzone i czy nawias zamykajacy nie poprzedza otwierajacego       
        for (( j=1; j<=$#; j++ ))
        do
                chck=${args[$j]}
                if [[ $chck = '(' ]]
                then
                        flag=$((flag+1))
			if [[ $flag -eq 2 ]]
			then
				echo "Kalkulator nie obsluguje nawiasow zagniezdzonych"
				echo "Poprawne wywolanie skryptu: ./lab5.sh arg op ( arg op arg )..."
				exit 3
			fi
                elif [[ $chck = ')' ]]
                then
                        flag=$((flag-1))
			if [[ $flag -lt 0 ]]
			then
				echo "Zostal uzyty nawias zamykajacy bez poprzedzenia nawiasem otwierajacym"
				echo "Poprawne wywolanie skryptu: ./lab5.sh arg op ( arg op arg )..."
				exit 3
			fi
                else
                        continue
                fi
        done
        if [[ $flag != 0 ]]
        then
                echo "Nawias nie zostal zamkniety"
                echo "Poprawne wywolanie skryptu: ./lab5.sh arg op ( arg op arg )..."
                exit 4
        fi

#Sprawdzenie czy nie wystepuja niedozwolone argumenty
        for (( k=1; k<=$#; k++ ))
        do
        chck2=${args[$k]}
        if ! isInt $chck2 && ! isOperator $chck2 && [[ $chck2 != '(' ]] && [[ $chck2 != ')' ]]
        then
                echo "Niedozwolony argument '$chck2'. Sprobuj jeszcze raz"
                echo "Dozwolone znaki: liczby calkowite +-*/ ()"
                exit 5
        fi
        done




for (( i=1; i<=$#; i++ ))
do
	p=0
	d=0
	flag2=0
	partRes=0
	cur=${args[$i]}
        prev=${args[$i-1]}
	next=${args[$i+1]}


#Sprawdzenie czy nie wystepuje dzielenie przez 0
	if [[ $cur = '/' ]] && [[ $next = 0 ]]
	then
		echo "Nie mozna dzielic przez 0"
		exit 6
	fi

#Sprawdzenie czy nie wystepuje dzielenie przez nawias, ktorego wynik daje 0

	if [[ $cur = '/' ]] && [[ $next = '(' ]]
	then
		p=i+1
		while [[ $flag2 != 1 ]]
		do

			p=$((p+1))
			if [[ ${args[$p]} = ')' ]]
			then
				flag2=1
			fi
		done
		d=$((p-i))
		partRes=`expr ${args[@]:$i:$d}`
		if [[ $partRes = 0 ]]
		then
			echo "Wystepuje dzielenie przez 0 ktore jest wynikiem nawiasu "${args[@]:$i:$d}""
			exit 10
		fi
	fi



#Sprawdzenie czy miedzy liczbami jest operator

	if isInt $cur || [[ $cur = '(' ]]
	then
	if isInt $prev
	then
		echo "Brak operatora miedzy $prev a $cur"
		exit 7
	fi
	fi

#Sprawdzenie czy operator znajduje sie miedzy liczbami lub miedzy liczba a nawiasem otwierajacym 
	if isOperator $cur
	then
		if isInt $prev || [[ $prev = ')' ]] && isInt $next || [[ $next = '(' ]]
	then
	else
		echo "Operator musi znajdowac sie po liczbie lub nawiasie zamykajacym i przed liczba lub nawiasem otwierajacym"
		echo "Poprawne wywolanie skryptu: ./lab5.sh arg op ( arg op arg )..."
        	exit 8
	fi
	fi

#Sprawdzenie czy po nawiasie zamykajacym wystepuje liczba lub nawias otwierajacy
	if [[ $cur = ')' ]]
	then
		if isInt $next || [[ $next = '(' ]]
		then
			echo "Po nawiasie musi znajdowac sie operator lub nic"
			echo "Poprawne wywolanie skryptu: ./lab5.sh arg op ( arg op arg )..."
			exit 9
		fi
	fi
done

result=`expr $args`
echo "Wynik operacji $args = $result"


