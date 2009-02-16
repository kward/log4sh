#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for the ConsoleAppender.

# load test helpers
. ./log4sh_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testNothing()
{
  logger_addAppender app
  appender_setType app ConsoleAppender
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  th_oneTimeSetUp

  # load libraries
  . ./log4sh_base
  . ./log4sh_ConsoleAppender
}

setUp()
{
  # reset log4sh
  #log4sh_resetConfiguration
  :
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
