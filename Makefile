YEAR ?= "2019"
SEMESTER ?= "w2"

.PHONY: all sync

%.html: %.scrbl
	scribble --html $<

all: *.scrbl
	scribble --htmls compiler-theory.scrbl
	rsync -avz share compiler-theory/

sync:
	rsync -avz --exclude "*.js" compiler-theory/ http@wjb:www/teaching/$(YEAR)/$(SEMESTER)/cpsc539b/

serve: all
	racket -t serve.rkt
