# $Id$
#
# makefile to setup the the docbook support directory
#

CWD=`pwd`
DIST=$(CWD)/../dist
XML=docbook-xml-4.4.zip
XSLT=docbook-xsl-1.71.1.tar.bz2

all: extract-xml extract-xslt

extract-xml:
	if test ! -d xml/4.4; then \
	  mkdir -p xml/4.4; \
	  unzip -qq $(DIST)/$(XML) -d xml/4.4; \
	fi

extract-xslt:
	if test ! -d docbook-xsl/1.71.1; then \
	  mkdir -p docbook-xsl; \
	  bzip2 -dc $(DIST)/$(XSLT) |tar xf -; \
	  mv docbook-xsl-1.71.1 docbook-xsl/1.71.1; \
	  ln -s 1.71.1 docbook-xsl/current; \
	fi

clean:
	rm -fr xml docbook-xsl*
