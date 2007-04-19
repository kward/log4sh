Release Notes for log4sh 1.5.0
==============================

This release mostly focuses on cleaning up leftover issues from the 1.4.0
release. Deprecated functions have been removed, and the directory structure
has been cleaned up a bit.

See the ``CHANGES-1.5.rst`` file for a full list of changes.


Tested Platforms
----------------

Cygwin

? bash 3.2.9(10)
? pdksh 5.2.14

Linux (Ubuntu Feisty)

? bash 3.1.17(1)
? dash 0.5.3
? ksh 1993-12-28
? pdksh 5.2.14
? zsh 4.3.2 (does not work)

Mac OS X 1.4.8 (Darwin 8.8)

? bash 2.05b.0(1)
? ksh 1993-12-28

Solaris 8 U3 (x86)

? /bin/sh
? bash 2.03.0(1)
? ksh M-11/16/88i

Solaris 9 ?? (x86)

? /bin/sh
? bash 2.03.0(1)
? ksh M-11/16/88i

Solaris 10 U2 (x86)

? /bin/sh
? bash 3.00.16(1)
? ksh M-11/16/88i

Solaris 11 [nv b61] (sparc)

? /bin/sh
? bash 3.00.16(1)
? ksh M-11/16/88i


New Features
------------

None.


Major Changes and Enhancements
------------------------------

All deprecated functions present in the 1.4.x series have been removed.

The process of getting the Docbook documentation built has been greatly
improved. A script is now included to download the appropriate DocBook sources
with which the documentation can be built.

The ``__LOG4SH_TRUE``, ``__LOG4SH_FALSE``, and ``__LOG4SH_ERROR}`` variables
have been renamed to the same without the leading underscores (e.g.
``LOG4SH_TRUE``) as scripts using log4sh should have access to them.


Bug Fixes
---------

Fixed the ``Makefile`` so that the DocBook XML and XSLT files would be
downloaded before documentation parsing will continue.

Logging requests at an invalid level now return an error.


Deprecate Features
-------------------

None.


Known Bugs and Issues
---------------------

Passing of the '\' character in an logging message does not work under the
standard Solaris Bourne shell [``/bin/sh``], under the ``dash`` shell
[``/bin/dash``], or under Cygwin with ``ksh`` [``/bin/ksh``].

The ``DailyRollingFileAppender`` appender do not roll files.

Trap handling is not yet absolutely 100% fool-proof.

Performance is prohibitively slow under Cygwin

More error checking/reporting needs to be added; this includes validating input
to public functions.
