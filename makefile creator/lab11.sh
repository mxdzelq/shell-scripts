#!/bin/sh

if ! [ -d $1 ]
then
	echo "Katalog nie istnieje"
	exit 0
fi

cd "$1"

echo "CC = gcc" > makefile
echo "HEADERS = ./headers" >> makefile
echo "LIBS = " >> makefile
echo 'CFLAGS = -O -I$(HEADERS)' >> makefile

main=""
count=0
flag=0
obj=""
spc=" "
for f in *.c
do
    if  grep -q "main(" $f;
    then
        main="$f"
	flag=1
    fi
    obj=$obj$spc$f
    count=$((count+1))
done

if [ $count -eq 0 ]
then
	echo "Brak plików źródłowych w folderze"
	exit 0
fi

if [ $flag -eq 0 ]
then
	echo "Brak pliku źródłowego z funkcją main"
	exit 0
fi

str=' : $(OBJECTS) '
echo "OBJECTS ="$obj | sed -e "s/".c"/".o"/g""" >> makefile
echo $main | sed -e "s/".c"/$str/g" >> makefile
echo '\t$(CC) -o $@ $^ $(CFLAGS) $(LIBS)' >> makefile

str=""
str2=""
for f in *.c
do
	str="$(grep '#include ".*"' $f | tr -d \" | sed -e 's/#include //')"
	str2=`echo $f | sed -e "s/".c"/".o"/g"`
	echo "$str2: \$(HEADERS)/$str" >> makefile

done

echo "clean:" >> makefile
echo "\t rm -f *.o" >> makefile



