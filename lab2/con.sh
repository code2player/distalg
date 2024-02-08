#!/bin/bash

mix new $1

cp peer.ex $1/lib/
cp flooding.ex $1/lib/
cp helper.ex $1/lib/
cp Makefile $1/

rm $1/lib/$1.ex

