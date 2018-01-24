.PHONY: test

test:
	./test/run.rb

install:
	ln -s $(PWD)/bin/vrsn /usr/local/bin