# $Id$
#
# makefile to setup the the docbook support directory
#

CWD=`pwd`
DIST=$(CWD)/../dist
XML=docbook-xml-4.4.zip
XSLT=docbook-xsl-1.68.1.tar.bz2

all: xml xslt

xml:
	if test ! -d xml/4.4; then \
	  mkdir -p xml/4.4; \
	  unzip -qq $(DIST)/$(XML) -d xml/4.4; \
	fi

xslt:
	if test ! -d docbook-xsl/1.68.1; then \
	  mkdir -p docbook-xsl; \
	  bzip2 -dc $(DIST)/$(XSLT) |tar xf -; \
	  mv docbook-xsl-1.68.1 docbook-xsl/1.68.1; \
	fi

clean:
	rm -fr xml docbook-xsl*
