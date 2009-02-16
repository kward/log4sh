#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for common appender functionality.

# load test helpers
. ./log4sh_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testNothing()
{
  :
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  LOG4SH_CONFIGURATION='none'
  th_oneTimeSetUp
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
