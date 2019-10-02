SOURCE_PAGES:=$(wildcard *.md)
HTML_PAGES:=$(patsubst %.md,site/%.html,$(SOURCE_PAGES))
TEMPLATE:=bootstrap-template
STYLE_PAGES:=site/style.css site/local-style.css

COMPLETE_SITE=site/doc site/img $(STYLE_PAGES) $(HTML_PAGES)

all: $(COMPLETE_SITE)

clean:
	rm -fR site

site:
	mkdir -p site

site/%.css: %.css
	cp $< $@

site/doc: site doc doc/*
	mkdir -p site
	cp -r doc site/
	touch site/doc

site/img: site img img/*
	cp -r img site/
	touch site/img

site/%.html: %.md $(TEMPLATE).html Makefile site
	pandoc \
	  --title-prefix "OCSF" \
	  --template $(TEMPLATE) \
	  --variable active-$(<:.md=) \
	  $< -o $@

DEPLOY_REPO = ../ocaml-sf.github.io
deploy: all
	@cd $(DEPLOY_REPO) && git rm -r *
	@cp -r $(COMPLETE_SITE) $(DEPLOY_REPO)/
	@cd $(DEPLOY_REPO) && git add *
	cd $(DEPLOY_REPO) && git status
	@cd $(DEPLOY_REPO) && \
	   (git commit -a -m "update website from build" \
	    && echo "now push from $(DEPLOY_REPO): \
	             (cd $(DEPLOY_REPO) && git push)" \
	    || echo "deploy failed: maybe there were no changes at all?")
