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

test__log4sh_getsetValue()
{
  # getValue
  _log4sh_getValue >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'invalid argument count'

  value=`_log4sh_getValue 'missing_key' 2>"${stderrF}"`
  assertFalse 'a missing key should be missed' $?

  # setValue
  _log4sh_setValue >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'invalid argument count'

  _log4sh_setValue 'abc' 123 >"${stdoutF}" 2>"${stderrF}"
  assertSuccess $?
  diff "${__log4sh_dictFile}" - >/dev/null <<EOF
abc 123
EOF
  assertTrue 'invalid data written to dictionary' $? || cat "${__log4sh_dictFile}"

  value=`_log4sh_getValue 'abc' 2>"${stderrF}"`
  assertSuccess $?
  assertEquals 'unable to get key value' 123 "${value}"
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

test__appender_isValid()
{
  _appender_isValid ''
  assertFalse 'empty appender should fail' $?
}

test__appender_isValidType()
{
  _appender_isValidType ''
  assertFalse 'empty type should fail' $?

  _appender_isValidType 'DummyAppender'
  assertFalse 'unregistered Dummy appender type should fail' $?

  _log4sh_register_appender 'DummyAppender'
  _appender_isValidType 'DummyAppender'
  assertTrue 'registered Dummy appender type should succeed' $?
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
  # getType
  appender_getType >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'invalid argument count'

  appender_getType 'invalidAppender' >"${stdoutF}" 2>"${stderrF}"
  assertFalse $?
  assertError 'invalid appender'

  # setType
  appender_setType 'someAppender' >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'invalid argument count'

  appender_setType 'invalidAppender' 'DummyAppender' \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse $?
  assertError 'invalid appender'

  # default appender type is a ConsoleAppender
  logger_addAppender 'myConsoleAppender'
  appType=`appender_getType 'myConsoleAppender' 2>"${stderrF}"`
  assertSuccess 'failed to get myConsoleAppender type' $?
  assertEquals 'ConsoleAppender' "${appType}"

  _log4sh_register_appender 'DummyAppender'
  logger_addAppender 'myDummyAppender'
  appender_setType 'myDummyAppender' 'DummyAppender' >"${stdoutF}" 2>"${stderrF}"
  assertSuccess 'failed to set myDummyAppender type' $?
  appType=`appender_getType 'myDummyAppender' 2>"${stderrF}"`
  assertSuccess 'failed to get myDummyAppender type' $?
  assertEquals 'DummyAppender' "${appType}"
}

testSplitLoggerAppenderMacro()
{
  set -- 'appender'
  ${_LOG4SH_SPLIT_LOGGER_APPENDER_}
  assertEquals 'root' "${log4sh_logger_}"
  assertEquals 'appender' "${log4sh_appender_}"
  assertEquals 'root.appender' "${log4sh_fqAppender_}"

  set -- 'logger.appender'
  ${_LOG4SH_SPLIT_LOGGER_APPENDER_}
  assertEquals 'logger' "${log4sh_logger_}"
  assertEquals 'appender' "${log4sh_appender_}"
  assertEquals 'logger.appender' "${log4sh_fqAppender_}"
}

#
# stub functions
#
_appender_register_ConsoleAppender() { :; }
_appender_new_ConsoleAppender() { return ${LOG4SH_TRUE}; }

_appender_register_DummyAppender() { :; }
_appender_new_DummyAppender() { return ${LOG4SH_TRUE}; }

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  th_oneTimeSetUp

  # load libraries
  . ./log4sh_base

  _log4sh_register_appender ConsoleAppender
}

setUp()
{
  log4sh_resetConfiguration
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
