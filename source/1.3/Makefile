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
	@mkdir -p $(DOCBOOK_BUILD_DIR)
	@echo "Preparing documentation for parsing"
	@isoDate=`date "+%Y-%m-%d"`; \
	find $(DOCBOOK_SRC_DIR) -name "*.xml" |\
	while read f; do \
	  bn=`basename $$f`; \
	  sed -e "s/@@ISO_DATE@@/$$isoDate/g" $$f >$(DOCBOOK_BUILD_DIR)/$$bn; \
	done

docs-extract-shelldoc: docs-prep
	@echo "Extracting the ShellDoc"
	@$(BIN_DIR)/extractDocs.pl $(SHELL_SRC_DIR)/log4sh >$(BUILD_DIR)/log4sh_shelldoc.xml

docs-transform-shelldoc: docs-prep docs-extract-shelldoc
	@echo "Parsing the extracted ShellDoc"
	@xsltproc $(PWD)/src/resources/shelldoc.xslt $(BUILD_DIR)/log4sh_shelldoc.xml >$(DOCBOOK_BUILD_DIR)/functions.xml

docs-transform-docbook: docs-prep
	@echo "Parsing the documentation with DocBook"
	@xsltproc $(HTML_XSL) $(DOCBOOK_BUILD_DIR)/log4sh.xml >$(BUILD_DIR)/log4sh.html

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
