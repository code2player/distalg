#!/bin/bash

mix new $1

cp *.ex $1/lib/
cp Makefile $1/


rm $1/lib/_*
rm $1/lib/$1.ex

