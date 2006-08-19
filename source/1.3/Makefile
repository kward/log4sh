# $Id$


DOCBOOK_SRC_DIR=$(PWD)/src/docbook
EXAMPLES_SRC_DIR=$(PWD)/src/examples
SHELL_SRC_DIR=$(PWD)/src/shell
TEST_SRC_DIR=$(PWD)/src/test

BIN_DIR=$(PWD)/bin
BUILD_DIR=$(PWD)/build
DIST_DIR=$(PWD)/dist
DOCBOOK_BUILD_DIR=$(BUILD_DIR)/docbook
LIB_DIR=$(PWD)/lib
TEST_DIR=$(PWD)/test

HTML_XSL=$(PWD)/share/docbook/tldp-xsl/21MAR2004/html/tldp-one-page.xsl

all: build docs

build: build-prep
	cp -p $(SHELL_SRC_DIR)/log4sh $(BUILD_DIR)

build-clean:
	rm -fr $(BUILD_DIR)

build-prep:
	@mkdir -p $(BUILD_DIR)

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

test: test-prep
	@echo -------------------------------------------------------------------------------
	@echo "testing log4sh from an initial properties configuration"
	( cd $(TEST_DIR); $(TEST_SRC_DIR)/test-prop-config )
	@echo -------------------------------------------------------------------------------
	@echo "testing log4sh via runtime configuration"
	( cd $(TEST_DIR); $(TEST_SRC_DIR)/test-runtime-config )
	@echo -------------------------------------------------------------------------------
	@echo "executing log4sh unit tests"
	( cd $(TEST_DIR); $(TEST_SRC_DIR)/log4sh-test-suite )

test-clean:
	rm -fr $(TEST_DIR)

test-prep: build test-clean
	@mkdir -p $(TEST_DIR)
	cp -p $(EXAMPLES_SRC_DIR)/hello_world $(TEST_DIR)
	cp -p $(TEST_SRC_DIR)/test* $(TEST_DIR)
	cp -p $(TEST_SRC_DIR)/run-test-suite $(TEST_DIR)
	cp -p $(TEST_SRC_DIR)/*.properties $(TEST_DIR)
	cp -p $(LIB_DIR)/shunit/shunit $(TEST_DIR)
	cp -p $(BUILD_DIR)/log4sh $(TEST_DIR)

dist: build docs
	@mkdir $(DIST_DIR)
	cp -p $(BUILD_DIR)/log4sh $(DIST_DIR)
	cp -p $(BUILD_DIR)/log4sh.html $(DIST_DIR)

clean: build-clean test-clean

distclean: clean
	rm -fr $(DIST_DIR)
