# Copyright (C) 2023 Ethan Uppal. All rights reserved.
all:
	make extract
	make analyze

extract:
	swift programs/cleaner.swift

analyze: data/morris-with-catherine.txt data/morris-with-sloper.txt
	swift programs/analyzer.swift > output/results.txt
