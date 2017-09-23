# log4sh 1.5 changes

## 1.5.1

Replaced `lib/shlib` with `shlib_relToAbsPath` from
[shlib](https://github.com/kward/shlib).

Upgraded [shUnit2](https://github.com/kward/shunit2) to 2.1.7pre.

Upgraded versions [shlib](https://github.com/kward/shlib) library.

Moving to use Markdown for documentation as this is the standard for GitHub.

Moved repository from [SourceForge](https://sourceforge.net/p/log4sh/) to
[GitHub](https://github.com/kward/log4sh).

Fixed brown-bag error which prevented the default stdout appender from printing
anything.

Unset additional variables that were missed.

Fixed off-by-one in exit value for scripts exits caught with trap.

Major directory restructuring. Simplifying to match that of shUnit2 and shFlags.

The code base is split from one large script into smaller more manageable pieces
that also allow for easier testing and for future expansion (say a
DatabaseAppender perhaps).

## 1.5.0 (since 1.4.0)

Removed all deprecated functions.

Remove old non-unit-test tests.

Removed extra parameters that were being wrongly passed to the
`appender_setType()` and `appender_setLayout()` functions.

Removed the `appender_activateOptions()` call when caching the appender.

Made the `/dev/urandom` random number generator the default when the
`mktemp()` function is present.

Consolidated appender data get/set requests with new `_appender_getData()`
and `_appender_setData()` functions.

Added return values to all functions [where it makes sense].

Added return value checking in *many* locations.

Updated shUnit to 2.1.0pre.

Made the `Makefile` much more generic so it can be used with other projects.

Replaced the DocBook archive extraction functionality with script that will
properly download and extract the DocBook sources so building the DocBook
documentation will be easier.

Moving to use [reStructured Text](http://docutils.sourceforge.net/rst.html)
for documentation.

Fixed the `Makefile` so that calling `make docs` will properly download the
appropriate DocBook XML and XSLT files before attempting to build the docs.

Renamed the `__LOG4SH_TRUE`, `__LOG4SH_FALSE`, and `__LOG4SH_ERROR` variables
to the same without the leading underscores (e.g. `LOG4SH_TRUE`). Scripts using
log4sh should have access to these.

Fixed bug when attempting to log a message at an invalid logging level with the
`log()` function. It should have returned an error, but it didn't.

Fixed bug where the 'B' unit was not recognized for the MaxFileSize of a
RollingFileAppender.
