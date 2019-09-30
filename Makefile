SOURCE_PAGES:=$(wildcard *.md)
HTML_PAGES:=$(patsubst %.md,site/%.html,$(SOURCE_PAGES))
TEMPLATE:=bootstrap-template
STYLE_PAGES:=site/style.css site/local-style.css

all: site

site: site/doc site/img $(STYLE_PAGES) $(HTML_PAGES)

clean:
	rm -fR site

site/%.css: %.css
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
