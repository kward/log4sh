# $Id$
#
# makefile to setup the the docbook support directory
#

CWD=`pwd`
DIST=$(CWD)/../dist
XML=docbook-xml-4.3.zip
XSLT=docbook-xsl-1.67.2.tar.bz2

all: xml xslt

xml:
	if test ! -d xml/4.3; then \
	  mkdir -p xml/4.3; \
	  unzip -qq $(DIST)/$(XML) -d xml/4.3; \
	fi

xslt:
	if test ! -d docbook-xsl/1.67.2; then \
	  mkdir -p docbook-xsl; \
	  bzip2 -dc $(DIST)/$(XSLT) |tar xf -; \
	  mv docbook-xsl-1.67.2 docbook-xsl/1.67.2; \
	fi

clean:
	rm -fr xml docbook-xsl*
