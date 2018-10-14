#!/usr/bin/env bash
if [ "$#" -eq 0 ]; then
  find ./.le/ -name "*" | sed 's|.*/||g' | sed -e '/^ *$/d' >argumenty.txt
else
  while [ "$#" -ne 0 ]
    do
      echo "$1" >>argumenty.txt
      shift
    done
fi

if [ -f .le/.config ]; then
  cat .le/.config | grep '^ignore' | sed 's/ignore / -e /g'>ignore.txt
  cislo=`wc -l <ignore.txt`
  if [ $cislo -gt 0 ]; then
    ignore_config=`cat ignore.txt`
    cat argumenty.txt | grep -v -E $ignore_config >argumenty2.txt
  else 
    mv argumenty.txt argumenty2.txt
  fi
  rm -f ignore.txt
  rm -f argumenty.txt
fi

seznam_souboru=`cat argumenty2.txt | tr '\n' ' '`
rm -f argumenty2.txt

for soubor in $seznam_souboru
  do
    cp ./.le/$soubor . 2>/dev/null
done
