#!/bin/zsh

skladnia="Prawidlowe wywolanie skryptu: ./lab7.sh [-a] plik [kolumna1 kolumna2 ...]"
plik=""
flag=0

#Sprawdzenie liczby argumentow
if [ $# -lt 1 ]
then
	echo "Za malo argumentow"
	echo $skladnia
	exit 0
fi

#Sprawdzenie opcji -a
if [ "$1" = "-a" ]
then
	flag=1
	shift
	plik=$1
	shift
else
	plik=$1
	shift
fi

#Sprawdzenie czy plik istnieje
if [ ! -f $plik ]
then
	echo "Plik nie istnieje"
	exit 1
fi

#Sprawdzenie praw dostepu do pliku
if [ ! -r $plik ]
then
	echo "Brak praw odczytu do pliku"
	exit 2 
fi

#Sprawdzenie czy numery kolumn sa liczbami naturalnymi
nat='^[0-9]+$'
for i in "$@"
do
	if ! [[ $i =~ $nat ]] || [[ $i -eq 0 ]]
	then
		echo "Numer kolumny musi byc liczba naturalna oraz wieksza od 0"
		echo $skladnia
		exit 3
	fi
done

args="$@"

#Przypadek gdy nie mamy numeru kolumny tylko sama nazwe pliku
if [ -z $1 ]
then
awk -F " |\t" -v a="$flag" \
'BEGIN {
sumaa=0
}
{
	suma=0
for(i=1;i<=NF;i++){
	if($i~/^[+-]?[0-9]+$/){
	suma+=$i
}
else if($i=='\t' || $zm=='\n' || $zm=='\40'){
	suma+=0
}
else{
	print "W pliku znajduje sie znak niebedacy liczba calkowita", $i
	exit
}
}
sumaa+=suma
print suma
}
END{
if(a==1){
print "Suma kolumny wynikowej:", sumaa
}
}' "$plik"
#Przypadek gdy numery kolumn zostaly podane
else
awk -F " |\t" -v a="$flag" -v arg="$args" \
'BEGIN {
split(arg, tab, " ")
sumaa=0
}
{
        suma=0
	for(i=1;i<=NF;i++){
	if($i~/^[+-]?[0-9]+$/){
	for(j=1;j<=length(tab);j++){
		if(i==tab[j]){
        suma+=$i
}
}
}
else if(!i || $i=='\t' || $i=='\n' || $i=='\40'){
suma+=0
}
else{
	print "W kolumnie znajduje sie znak niebedacy liczba calkowita"
	exit
}
}
sumaa+=suma
print suma
}
END{
if(a==1){
print "Suma kolumny wynikowej:", sumaa
}
}' "$plik"

fi
