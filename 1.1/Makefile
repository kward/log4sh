# $Id: Makefile,v 1.2 2004/04/13 16:26:18 kward Exp $

SHELL_SRC_DIR=$(PWD)/src/shell
TEST_SRC_DIR=$(PWD)/src/test
BUILD_DIR=$(PWD)/build
DIST_DIR=$(PWD)/dist

all: build

build:
	mkdir $(BUILD_DIR)
	cp -pr $(SHELL_SRC_DIR)/* $(BUILD_DIR)

test: build
	( cd $(BUILD_DIR); $(TEST_SRC_DIR)/test-log4sh )

dist: build
	mkdir $(DIST_DIR)
	cp -p src/shell/log4sh $(DIST_DIR)

clean:
	rmdir $(BUILD_DIR)

distclean: clean
	rmdir $(DIST_DIR)
