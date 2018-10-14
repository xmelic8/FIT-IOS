#!/usr/bin/env bash
if [ -d .le ]
  then
    rm -rf .le/*
else
    mkdir .le 
fi

if [ -f .le/.config ]
  then
    cat .le/.config | grep '^ignore ' | sed 's/ignore / -e /g' >ignore.txt
    cislo=`wc -l <ignore.txt` 
    if [ $cislo -gt 0 ]
      then
        ignore_config=`cat ignore.txt | tr -d '\n'`  
        find $1 -name "*" | grep -v -E $ignore_config | xargs -I{} cp "{}" . 2>/dev/null
        find $1 -name "*" | grep -v -E $ignore_config | xargs -I{} cp "{}" ./.le 2>/dev/null
        sed "s|^projdir.*|projdir $1|g" .le/.config | tee .le/.config2 >/dev/null
        rm -f .le/.config
        mv .le/.config2 .le/.config 
      else
        cp $1/* . 2>/dev/null
        cp $1/* ./.le 2>/dev/null
        echo projdir $1 >.le/.config
    fi
    rm -f ignore.txt
  else
    cp $1/* . 2>/dev/null
    cp $1/* ./.le 2>/dev/null
    echo projdir $1 >.le/.config
fi
