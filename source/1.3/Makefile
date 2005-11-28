# $Id$

BIN_DIR=$(PWD)/bin

DOCBOOK_SRC_DIR=$(PWD)/src/docbook
SHELL_SRC_DIR=$(PWD)/src/shell
TEST_SRC_DIR=$(PWD)/src/test

BUILD_DIR=$(PWD)/build
DOCBOOK_BUILD_DIR=$(BUILD_DIR)/docbook

DIST_DIR=$(PWD)/dist

HTML_XSL=$(PWD)/share/docbook/tldp-xsl/21MAR2004/html/tldp-one-page.xsl

all: build docs

build:
	mkdir $(BUILD_DIR)

docs: docs-transform-shelldoc docs-transform-docbook

docs-prep:
	mkdir -p $(DOCBOOK_BUILD_DIR)
	cp $(DOCBOOK_SRC_DIR)/*.xml $(DOCBOOK_BUILD_DIR)

docs-extract-shelldoc: docs-prep
	$(BIN_DIR)/extractDocs.pl $(SHELL_SRC_DIR)/log4sh >$(BUILD_DIR)/log4sh_shelldoc.xml

docs-transform-shelldoc: docs-prep docs-extract-shelldoc
	xsltproc $(PWD)/src/resources/shelldoc.xslt $(BUILD_DIR)/log4sh_shelldoc.xml >$(DOCBOOK_BUILD_DIR)/functions.xml

docs-transform-docbook: docs-prep
	xsltproc $(HTML_XSL) $(DOCBOOK_BUILD_DIR)/log4sh.xml >$(BUILD_DIR)/log4sh.html

test: build
	( cd $(BUILD_DIR); $(TEST_SRC_DIR)/test-log4sh )

dist: build docs
	mkdir $(DIST_DIR)
	cp -p src/shell/log4sh $(DIST_DIR)
	cp -p $(BUILD_DIR)/log4sh.html $(DIST_DIR)

clean:
	rm -fr $(BUILD_DIR)

distclean: clean
	rm -fr $(DIST_DIR)
