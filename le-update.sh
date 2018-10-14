#!/usr/bin/env bash
#zjisteni vychozi cesty projektu
if [ -f .le/.config ]; then
  cesta_proj=`cat .le/.config | grep '^projdir' | cut -f2 -d' '`
else
    exit 1
fi

#ziskani nazvu souboru ve slozce projektu, pripadne zpracovani argumentu 
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
    if [ -f "$cesta_proj/$soubor" ]; then
      if [ ! -f "$soubor" ]; then
        cp $cesta_proj/$soubor . 2>/dev/null
        cp $cesta_proj/$soubor ./.le 2>/dev/null
        echo C: $soubor
      fi
    elif [ -f .le/"$soubor" ]; then
      if [ ! -f "$cesta_proj/$soubor" ]; then
        rm -f $soubor 
        rm -f .le/$soubor
        echo D: $soubor
      fi
    fi     
    
    cmp $cesta_proj/$soubor ./$soubor >/dev/null 2>/dev/null
    proj_exp=$?
    cmp $cesta_proj/$soubor ./.le/$soubor >/dev/null 2>/dev/null
    proj_ref=$?
    cmp ./.le/$soubor ./$soubor >/dev/null 2>/dev/null
    ref_exp=$?
      
    if [ \( "$proj_exp" -eq 0 \) -a \( "$proj_ref" -eq 0 \) ]; then
      echo .: $soubor
    elif [ \( "$proj_ref" -eq 0 \) -a \( "$proj_exp" -gt 0 \) ]; then
      echo M: $soubor
    elif [ \( "$proj_exp" -eq 0 \) -a \( "$proj_ref" -gt 0 \) ]; then
      echo UM: $soubor
      cp $cesta_proj/$soubor ./.le/$soubor
    elif [ \( "$ref_exp" -eq 0 \) -a \( "$proj_exp" -gt 0 \) ]; then
      cp $cesta_proj/$soubor . 2>/dev/null
      cp $cesta_proj/$soubor ./.le 2>/dev/null
      echo U: $soubor
    elif [ \( "$proj_exp" -gt 0 \) -a \( "$proj_ref" -gt 0 \) -a \( "$ref_exp" -gt 0 \) ]; then
      diff -u ./.le/$soubor $cesta_proj/$soubor >$soubor.patch
      patch -u $soubor $soubor.patch >/dev/null
      if [ "$?" -eq 0 ]; then
        echo M+: $soubor
          rm -f $soubor.*
        cp $cesta_proj/$soubor ./.le 2>/dev/null
      else
        echo M!: $soubor conflict!
        mv $soubor.orig $soubor
        rm -rf $soubor.*
      fi
    fi  
done  
