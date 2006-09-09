#------------------------------------------------------------------------------
# SourceForge
#

This project is stored on SourceForge as http://sf.net/projects/log4sh.  CVS
can be accessed using the following information.

* Anonymous CVS access
$ cvs -d :pserver:anonymous@log4sh.cvs.sourceforge.net:/cvsroot/log4sh login
$ cvs -d :pserver:anonymous@log4sh.cvs.sourceforge.net:/cvsroot/log4sh co -P <modulename>

* Developer CVS access
$ cvs -d :ext:<developer>@log4sh.cvs.sourceforge.net:/cvsroot/log4sh co -P <modulename>

CVS may also be browsed via a web browser at
http://cvs.sourceforge.net/viewcvs.py/log4sh/.


CVS is organized as follows

/cvsroot/log4sh
 + CVSROOT
 + source
   + 1.2
   + 1.3


Other related documentation and links:

Basic Introduction to CS and SourceForge.net Project CVS Services
  http://sourceforge.net/docman/display_doc.php?docid=14033&group_id=1

#------------------------------------------------------------------------------
# Making a release
#

For these steps, it is assumed we are working with release 1.3.0.

Steps:
* update version
* finish changelog
* check all the code in
* tag the release
* export the release
* create tarball
* md5sum the tarball
* update website
* post to SourceForge and Freshmeat

UPDATE VERSION

Edit the log4sh source code, and change the version number in the comment, as
well as in the __LOG4SH_VERSION variable. Next, edit the src/docbook/log4sh.xml
file, edit the version in the <title> element, and make sure there is a
revision section for this release.

FINISH THE CHANGELOG

Make sure that any remaning changes get put into the CHANGES file.

CHECK IN ALL THE CODE

This step is pretty self-explainatory

TAG THE RELEASE

$ pwd
.../log4sh/1.3
$ cvs tag rel-1-3-0

EXPORT THE RELEASE

$ pwd
.../log4sh/builds
$ cvs -d :ext:sfsetse@log4sh.cvs.sourceforge.net:/cvsroot/log4sh export -r rel-1-3-0 -d log4sh-1.3.0 1.3

CREATE TARBALL

$ tar cfz ../releases/log4sh-1.3.0.tgz log4sh-1.3.0

MD5SUM THE TARBALL

$ cd ../releases
$ md5sum log4sh-1.3.0.tgz >log4sh-1.3.0.tgz.md5

UPDATE WEBSITE

Again, pretty self-explainatory.

POST TO SOURCEFORGE AND FRESHMEAT

http://sourceforge.net/projects/log4sh/
http://freshmeat.net/

#------------------------------------------------------------------------------
# Testing a release
#

To test a release, shUnit unit tests are included. Prepare the test
environment, and then you can run the tests. Hopefully all of the tests will
pass with a 100% success rate.

$ make test-prep
$ cd test
$ ./run-test-suite


$Revision$
