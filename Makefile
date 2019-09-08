SOURCE_PAGES:=$(wildcard *.md)
HTML_PAGES:=$(patsubst %.md,site/%.html,$(SOURCE_PAGES))

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

site/%.html: %.md template.html
	pandoc \
	  --title-prefix "OCaml Software Foundation" \
	  --template template \
	  $< -o $@
