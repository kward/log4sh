#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for the SMTPAppender.

# load test helpers
. ./log4sh_test_helpers

APP_NAME='mySMTP'
APP_CONFIG="${TH_TESTDATA_DIR}/smtp_appender.log4sh"

TEST_SUBJECT='This is a Subject worth testing'
TEST_TO='some.user@some.host'

#------------------------------------------------------------------------------
# suite tests
#

testSubjectGetterSetter()
{
  # configure log4sh
  logger_addAppender ${APP_NAME}
  appender_setType ${APP_NAME} SMTPAppender
  appender_activateOptions ${APP_NAME}

  ${DEBUG} 'testing that the default Subject is empty'
  currSubject=`appender_smtp_getSubject ${APP_NAME}`
  ${TRACE} "currSubject='${currSubject}'"
  assertNull \
      'the default SMTP Subject was not empty' \
      "${currSubject}"

  ${DEBUG} 'testing that it is possible to set and get the SMTP Subject'
  # TODO: test for the log4sh:ERROR message
  appender_smtp_setSubject ${APP_NAME} "${TEST_SUBJECT}"
  appender_activateOptions ${APP_NAME}
  currSubject=`appender_smtp_getSubject ${APP_NAME}`
  ${TRACE} "currSubject='${currSubject}'"
  assertEquals \
      'the returned SMTP Subject does not match the one that was set' \
      "${currSubject}" "${TEST_SUBJECT}"

  # TODO: test the passing of invalid params

  unset currSubject
}

testToGetterSetter()
{
  # configure log4sh
  logger_addAppender ${APP_NAME}
  appender_setType ${APP_NAME} SMTPAppender
  appender_activateOptions ${APP_NAME}

  ${DEBUG} 'testing that the default To is empty'
  currTo=`appender_smtp_getTo ${APP_NAME}`
  ${TRACE} "currTo='${currTo}'"
  assertNull \
      'the default SMTP To was not empty' \
      "${currTo}"

  ${DEBUG} 'testing that it is possible to set and get the SMTP To'
  # TODO: test for the log4sh:ERROR message
  appender_smtp_setTo ${APP_NAME} "${TEST_TO}"
  appender_activateOptions ${APP_NAME}
  currTo=`appender_smtp_getTo ${APP_NAME}`
  ${TRACE} "currTo='${currTo}'"
  assertEquals \
      'the returned SMTP To does not match the one that was set' \
      "${currTo}" "${TEST_TO}"

  # TODO: test the passing of invalid params

  unset currTo
}

testAppenderSetupFromConfig()
{
  # configure log4sh
  log4sh_doConfigure "${APP_CONFIG}"

  ${DEBUG} 'verifying that the appender Type was properly set'
  currType=`appender_getType ${APP_NAME}`
  ${TRACE} "currType='${currType}'"
  assertEquals \
      'the returned appender type was not SMTPAppender' \
      "${currType}" 'SMTPAppender'

  ${DEBUG} 'verifying that the appender Subject was properly set'
  currSubject=`appender_smtp_getSubject ${APP_NAME}`
  ${TRACE} "currSubject='${currSubject}'"
  assertEquals \
      'the returned SMTP Subject does not match what was expected' \
      "${currSubject}" "${TEST_SUBJECT}"

  ${DEBUG} 'verifying that the appender To was properly set'
  currTo=`appender_smtp_getTo ${APP_NAME}`
  ${TRACE} "currTo='${currTo}'"
  assertEquals \
      'the returned SMTP To does not match what was expected' \
      "${currTo}" "${TEST_TO}"

  unset currType currSubject currTo
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
  log4sh_resetConfiguration
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
