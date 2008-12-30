#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for simultaneous appender definitions.

# load test helpers
. ./log4sh_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testTwoSimilarFileAppenders()
{
  # configure log4sh
  logger_setLevel INFO

  # setup first appender
  logger_addAppender ${APP_ONE_NAME}
  appender_setType ${APP_ONE_NAME} FileAppender
  appender_file_setFile ${APP_ONE_NAME} "${APP_ONE_FILE}"
  appender_activateOptions ${APP_ONE_NAME}

  # setup second appender
  logger_addAppender ${APP_TWO_NAME}
  appender_setType ${APP_TWO_NAME} FileAppender
  appender_file_setFile ${APP_TWO_NAME} "${APP_TWO_FILE}"
  appender_activateOptions ${APP_TWO_NAME}

  # log a message
  th_generateRandom
  random=${th_RANDOM}
  logger_info "dummy message ${random}"

  # verify first appender
  matched=`tail "${APP_ONE_FILE}" |grep "${random}"`
  assertNotNull \
    'first appender did not properly receive message' \
    "${matched}"

  # verify second appender
  matched=`tail "${APP_TWO_FILE}" |grep "${random}"`
  assertNotNull \
    'second appender did not properly receive message' \
    "${matched}"
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  LOG4SH_CONFIGURATION='none'
  th_oneTimeSetUp

  # the logfiles will be cleaned up automatically by shunit2
  APP_ONE_NAME='appenderOne'
  APP_ONE_FILE="${TH_TMPDIR}/appender_one.log"
  APP_TWO_NAME='appenderTwo'
  APP_TWO_FILE="${TH_TMPDIR}/appender_two.log"
}

setUp()
{
  log4sh_resetConfiguration
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
