DEVICE      ?= $(or $(CIQ_DEVICE),fenix7)
KEY         ?= $(HOME)/.ciq/developer_key.der
JUNGLE      ?= monkey.jungle
JUNGLE_TEST ?= monkey-test.jungle
OUT         ?= bin
APP         ?= SimpTemp

.PHONY: help devices dev-device all-devices sdk sdk-link build release run sim package test clean

help:
	@grep -E '^[a-z-]+:' Makefile | cut -d: -f1 | tail -n +2

devices:            ## list every device in manifest.xml
	connect-iq-sdk-manager device list --manifest=manifest.xml

dev-device:         ## download just $(DEVICE) — manifest.xml has ~90 products,
                    ## downloading all of them is many GB
	connect-iq-sdk-manager device download -d $(DEVICE) --include-fonts

all-devices:        ## download every device in the manifest (needed for make package)
	connect-iq-sdk-manager device download --manifest=manifest.xml

sdk:                ## show active SDK
	connect-iq-sdk-manager sdk current-path

sdk-link:           ## repoint ~/.local/ciq-sdk after `sdk set`
	ln -sfn "$$(connect-iq-sdk-manager sdk current-path)" $(HOME)/.local/ciq-sdk

build:              ## debug build for $(DEVICE)
	@mkdir -p $(OUT)
	monkeyc -d $(DEVICE) -f $(JUNGLE) -o $(OUT)/$(APP).prg -y $(KEY)

release:            ## optimized build (-r) for $(DEVICE)
	@mkdir -p $(OUT)
	monkeyc -r -d $(DEVICE) -f $(JUNGLE) -o $(OUT)/$(APP).prg -y $(KEY)

sim:                ## start the simulator (needs DISPLAY)
	connectiq &

run: build          ## build, then push to a running simulator
	monkeydo $(OUT)/$(APP).prg $(DEVICE)

test:               ## build with unit tests and run them
	@mkdir -p $(OUT)
	monkeyc -d $(DEVICE) -f $(JUNGLE_TEST) -o $(OUT)/$(APP)-test.prg -y $(KEY) --unit-test
	monkeydo $(OUT)/$(APP)-test.prg $(DEVICE) -t

package:            ## build the .iq store package (all devices in manifest)
	@mkdir -p $(OUT)
	monkeyc -e -w -f $(JUNGLE) -o $(OUT)/$(APP).iq -y $(KEY)

clean:
	rm -rf $(OUT)
