# Copyright (C) 2023 Ethan Uppal. All rights reserved.
all:
	make extract
	make analyze

extract:
	swift programs/cleaner.swift

analyze: data/morris-with-catherine.txt data/morris-with-sloper.txt
	rm -rf tempdir
	mkdir tempdir
	rm -rf data/morris-both.txt
	cp programs/analyzer.swift tempdir/main.swift
	swiftc tempdir/main.swift programs/attribute.swift -o tempdir/main
	tempdir/main > output/results.txt

output/morris-both.txt: data/morris-with-catherine.txt data/morris-with-sloper.txt
	cat data/morris-with-catherine.txt > output/morris-both.txt
	cat data/morris-with-sloper.txt >> output/morris-both.txt

chatbot: output/morris-both.txt
	rm -rf tempdir
	mkdir tempdir
	cp programs/chatbot.swift tempdir/main.swift
	swiftc tempdir/main.swift programs/attribute.swift -o tempdir/main
	tempdir/main

clean:
	rm -rfoutput
	rm -rf tempdir
