#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for reading of configuration from property files.

# load test helpers
. ./log4sh_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testAppenders()
{
  #
  # invalid appender
  #
  cat <<EOF >${propF}
log4sh.rootLogger = INFO, A
log4sh.appender.A = InvalidAppender
EOF
  echo '- expecting one error'
  log4sh_doConfigure ${propF}
  rtrn=$?
  assertFalse 'the InvalidAppender was not caught' ${rtrn}
}

testLayouts()
{
  #
  # invalid layout
  #
  cat <<EOF >${propF}
log4sh.rootLogger = INFO, A
log4sh.appender.A = ConsoleAppender
log4sh.appender.A.layout = InvalidLayout
EOF
  echo '- expecting one error'
  log4sh_doConfigure ${propF}
  rtrn=$?
  assertFalse 'the InvalidLayout was not caught' ${rtrn}
}

testLayoutTypes()
{
  #
  # invalid layout type
  #
  cat <<EOF >${propF}
log4sh.rootLogger = INFO, A
log4sh.appender.A = ConsoleAppender
log4sh.appender.A.layout = SimpleLayout
log4sh.appender.A.layout.InvalidType = blah
EOF
  echo '- expecting one error'
  log4sh_doConfigure ${propF}
  rtrn=$?
  assertFalse 'the invalid layout type was not caught' ${rtrn}
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  LOG4SH_CONFIGURATION='none'
  th_oneTimeSetUp

  # this file will be cleaned up automatically by shunit2
  propF="${TH_TMPDIR}/properties.log4sh"
}

setUp()
{
  # reset log4sh
  log4sh_resetConfiguration
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
