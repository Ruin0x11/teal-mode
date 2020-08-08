# Makefile for teal-mode

VERSION="$(shell sed -nre '/^;; Version:/ { s/^;; Version:[ \t]+//; p }' teal-mode.el)"
DISTFILE = teal-mode-$(VERSION).zip

# EMACS value may be overridden
EMACS?=emacs
EMACS_MAJOR_VERSION=$(shell $(EMACS) -batch -eval '(princ emacs-major-version)')
TEAL_MODE_ELC=teal-mode.$(EMACS_MAJOR_VERSION).elc

EMACS_BATCH=$(EMACS) --batch -Q

default:
	@echo version is $(VERSION)

%.$(EMACS_MAJOR_VERSION).elc: %.elc
	mv $< $@

%.elc: %.el
	$(EMACS_BATCH) -f batch-byte-compile $<

compile: $(TEAL_MODE_ELC)

dist:
	rm -f $(DISTFILE) && \
	git archive --format=zip -o $(DISTFILE) --prefix=teal-mode/ HEAD

.PHONY: test-compiled-nocask test-uncompiled-nocask test-compiled test-uncompiled
# check both regular and compiled versions
test-nocask: test-compiled-nocask test-uncompiled-nocask

test: test-compiled test-uncompiled

test-compiled-nocask: $(TEAL_MODE_ELC)
	$(EMACS) -batch -l $(TEAL_MODE_ELC) -l buttercup -f buttercup-run-discover

test-uncompiled-nocask:
	$(EMACS) -batch -l teal-mode.el -l buttercup -f buttercup-run-discover

test-compiled: $(TEAL_MODE_ELC)
	EMACS=$(EMACS) cask exec buttercup -l $(TEAL_MODE_ELC)

test-uncompiled:
	EMACS=$(EMACS) cask exec buttercup -l teal-mode.el

tryout:
	cask exec $(EMACS) -Q -l init-tryout.el test.teal

tryout-nocask:
	$(EMACS) -Q -l init-tryout.el test.teal

release:
	git fetch && \
	git diff remotes/origin/master --exit-code && \
	git tag -a -m "Release tag" rel-$(VERSION) && \
	woger teal-l teal-mode teal-mode "release $(VERSION)" "Emacs major mode for editing Teal files" release-notes-$(VERSION) http://github.com/Ruin0x11/teal-mode/ && \
	git push origin master
	@echo 'Send update to ELPA!'
