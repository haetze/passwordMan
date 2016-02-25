#Makefile for MyCalendar
#

INPUTS := $(wildcard src/Modules/*.hs)
OUTPUTS := $(patsubst src/Modules/%.hs,src/Modules/%.o, $(INPUTS))

all: src/Main/passwordMan.hs $(OUTPUTS)
	ghc -isrc/Modules src/Main/passwordMan.hs
	cp src/Main/passwordMan bin/passwordMan
	sudo cp bin/passwordMan /usr/local/bin/passwordMan

src/Modules/%.o: src/Modules/%.hs 
	ghc -isrc/Modules $< 


