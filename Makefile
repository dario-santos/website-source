SOURCE_PAGES:=$(wildcard *.md)
HTML_PAGES:=$(patsubst %.md,site/%.html,$(SOURCE_PAGES))
TEMPLATE:=bootstrap-template

all: site

site: site/doc site/img site/style.css $(HTML_PAGES)

clean:
	rm -fR site

site/style.css: style.css
	cp $< $@

site/doc: doc doc/*
	cp -r doc site
	touch site/doc

site/img: img img/*
	cp -r img site
	touch site/img

site/%.html: %.md $(TEMPLATE).html Makefile
	pandoc \
	  --title-prefix "OCaml Software Foundation" \
	  --template $(TEMPLATE) \
	  --variable active-$(<:.md=) \
	  $< -o $@
