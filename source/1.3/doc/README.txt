#------------------------------------------------------------------------------
# SourceForge
#

This project is stored on SourceForge as http://sf.net/projects/log4sh. The
source code can be accessed using the following information.

* Subversion
$ svn co https://svn.sourceforge.net/svnroot/log4sh/trunk log4sh

Subversion may also be browsed via a web browser at
http://svn.sourceforge.net/log4sh

#------------------------------------------------------------------------------
# Making a release
#

For these steps, it is assumed we are working with release 1.3.6.

Steps:
* write release notes
* update version
* finish changelog
* check all the code in
* tag the release
* export the release
* create tarball
* md5sum the tarball
* update website
* post to SourceForge and Freshmeat

WRITE RELEASE NOTES

Pretty self explainatory.

To get the versions of the various shells, do the following:
Cygwin
  bash - bash --version
  pdksh - look in the downloaded Cygwin directory
Linux
  bash - bash --version
  ksh - ksh --version
Solaris 10
  sh - not possible
  bash - bash --version
  ksh - strings /usr/bin/ksh |grep Version

UPDATE VERSION

Edit the log4sh source code, and change the version number in the comment, as
well as in the __LOG4SH_VERSION variable. Next, edit the src/docbook/log4sh.xml
file, edit the version in the <title> element, and make sure there is a
revision section for this release.

FINISH DOCUMENTATION

Make sure that any remaning changes get put into the CHANGES.txt file.

Finish writing the RELEASE_NOTES.txt. Once it is finished, run it through the
'fmt' command to make it pretty.

$ fmt -w 80 RELEASE_NOTES-1.3.6.txt >RELEASE_NOTES-1.3.6.txt.new
$ mv RELEASE_NOTES-1.3.6.txt.new RELEASE_NOTES-1.3.6.txt

We want to have an up-to-date version of the documentation in the release, so
we'd better build it.

$ pwd
.../log4sh/source/1.3
$ make docs
...
$ cp -p build/log4sh.html doc
$ svn ci -m "" doc/log4sh.html

CHECK IN ALL THE CODE

This step is pretty self-explainatory

TAG THE RELEASE

$ pwd
.../log4sh/source
$ ls
1.2  1.3
$ svn cp -m "Release 1.3.6" \
1.3 https://svn.sourceforge.net/svnroot/log4sh/tags/source/1.3.6

EXPORT THE RELEASE

$ pwd
.../log4sh/builds
$ svn export \
https://svn.sourceforge.net/svnroot/log4sh/tags/source/1.3.6 log4sh-1.3.6

CREATE TARBALL

$ tar cfz ../releases/log4sh-1.3.6.tgz log4sh-1.3.6

MD5SUM THE TARBALL

$ cd ../releases
$ md5sum log4sh-1.3.6.tgz >log4sh-1.3.6.tgz.md5

UPDATE WEBSITE

Again, pretty self-explainatory.

Once that is done, make sure to tag the website so we can go back in time if
needed.

$ pwd
.../log4sh
$ ls
source  website
$ svn cp -m "Release 1.3.6" \
website https://svn.sourceforge.net/svnroot/log4sh/tags/website/20060916

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
