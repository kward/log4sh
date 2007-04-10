Changes in log4sh 1.5.X
=======================

Changes with 1.5.0 (since 1.4.0)
--------------------------------

Removed all deprecated functions

Remove old non-unit-test tests

Removed extra parameters that were being wrongly passed to the
``appender_setType()`` and ``appender_setLayout()`` functions

Removed the ``appender_activateOptions()`` call when caching the appender

Made the ``/dev/urandom`` random number generator the default when the
``mktemp()`` function is present

Consolidated appender data get/set requests with new ``_appender_getData()``
and ``_appender_setData()`` functions

Added return values to all functions [where it makes sense]

Added return value checking in *many* locations

Updated shUnit to 2.0.1

Made the ``Makefile`` much more generic so it can be used with other projects

Replaced the DocBook archive extraction functionality with script that will
properly download and extract the DocBook sources so building the DocBook
documentation will be easier.

Moving to use `reStructured Text <http://docutils.sourceforge.net/rst.html>`_
for documentation.


$Revision$
vim:spell
