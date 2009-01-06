#! /bin/sh
# $Id: log4sh_test_file_appender.sh 589 2008-12-30 14:50:53Z sfsetse $
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

testSplitLoggerAppenderMacro()
{
  set -- 'appender'
  ${_LOG4SH_SPLIT_LOGGER_APPENDER_}
  assertEquals 'root' "${log4sh_logger_}"
  assertEquals 'appender' "${log4sh_appender_}"

  set -- 'logger.appender'
  ${_LOG4SH_SPLIT_LOGGER_APPENDER_}
  assertEquals 'logger' "${log4sh_logger_}"
  assertEquals 'appender' "${log4sh_appender_}"
}

test_log4sh_addLogger()
{
  log4sh_addLogger >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'invalid argument count'

  log4sh_addLogger 'root' >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_FALSE} $?
  assertError 'logger already exists'

  log4sh_addLogger 'newLogger' >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_TRUE} $?
  _logger_isValid 'newLogger'
  assertTrue 'new logger should exist' $?
}

test__logger_isValid()
{
  _logger_isValid ''
  assertFalse 'empty logger should fail' $?

  _logger_isValid 'root'
  assertTrue 'root logger should exist' $?

  _logger_isValid 'invalid'
  assertFalse 'invalid logger should not exist' $?
}

test_logger_addAppender()
{
  logger_addAppender >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'invalid argument count'

  logger_addAppender 'newRootAppender' >"${stdoutF}" 2>"${stderrF}"
  assertSuccess $?
  _appender_isValid 'newRootAppender'
  assertTrue 'newRootAppender should exist' $?

  log4sh_addLogger 'newLogger'
  logger_addAppender 'newLogger' 'newLoggerAppender' \
      >"${stdoutF}" 2>"${stderrF}"
  assertSuccess $?
  _appender_isValid 'newLogger.newLoggerAppender'
  assertTrue 'newLogger.newLoggerAppender should exist' $?
}

test_appender_getsetType()
{
  appender_setType 'someAppender' >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'invalid argument count'

  appender_setType 'invalidAppender' 'ConsoleAppender' \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse $?
  assertError 'invalid appender'

  logger_addAppender 'myAppender'
  appender_setType 'myAppender' 'ConsoleAppender' >"${stdoutF}" 2>"${stderrF}"
  assertSuccess $?
  appType=`appender_getType 'myAppender'`
  assertTrue $?
  assertEquals 'ConsoleAppender' "${appType}"
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  th_oneTimeSetUp

  # load libraries
  . ./log4sh_base
}

setUp()
{
  log4sh_resetConfiguration
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
