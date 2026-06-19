#! /bin/bash -e

for tool in "$FILEDIR"/local-bin/*
do
	cp $tool /usr/local/bin/
	chmod a+rx /usr/local/bin/"$(basename $tool)"
done
