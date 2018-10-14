#!/usr/bin/env bash
if [ -f .le/.config ]; then
  cesta_proj=`cat .le/.config | grep '^projdir' | cut -f2 -d' '`
else
  exit 1
fi

if [ "$#" -eq 0 ]; then
  find $cesta_proj/ -name "*" | sed 's|.*/||g' | sed -e '/^ *$/d' >argumenty.txt
else 
  while [ "$#" -ne 0 ]
    do
      echo "$1" >>argumenty.txt
      shift
    done
fi

if [ -f .le/.config ]; then
  cat .le/.config | grep '^ignore' | sed 's|^ignore | -e |g' >ignore.txt
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
    if [ \( -f $cesta_proj/$soubor \) -a \( ! -f $soubor \) ]; then
      echo C: $soubor
    elif [ \( -f $soubor \) -a \( ! -f $cesta_proj/$soubor \) ]; then
      echo D: $soubor
    elif [ \( -f $cesta_proj/$soubor \) -a \( -f $soubor \) ]; then
      diff -u $cesta_proj/$soubor $soubor 2>/dev/null
      if [ "$?" -eq 0 ]; then
        echo .: $soubor
      fi
    fi
done   
