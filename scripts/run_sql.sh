#!/bin/bash

echo
echo "-- SQL"
echo
cat $1
echo

sqlite3 ../relojes.sqlite < $1

if [ $? -eq 0 ]; then
    echo "-- Ok"
else
    echo
    echo "-- Error"
fi
echo
