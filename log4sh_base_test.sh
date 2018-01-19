#!/bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008-2018 Kate Ward. All Rights Reserved.
# Released under the Apache License 2.0 license.
#
# log4sh unit test for base functionality.
#
# Author: kate.ward@forestent.com (Kate Ward)
# https://github.com/kward/log4sh

# Load test helpers.
. ./log4sh_test_helpers

test__log4sh_getsetValue() {
  # Test getValue.
  _log4sh_getValue >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'invalid argument count'

  value=`_log4sh_getValue 'missing_key' 2>"${stderrF}"`
  assertFalse 'a missing key should be missed' $?

  # Test setValue.
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

test_log4sh_addLogger() {
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

test__logger_isValid() {
  _logger_isValid ''
  assertFalse 'empty logger should fail' $?

  _logger_isValid 'root'
  assertTrue 'root logger should exist' $?

  _logger_isValid 'invalid'
  assertFalse 'invalid logger should not exist' $?
}

test_logger_addAppender() {
  logger_addAppender >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'invalid argument count'

  logger_addAppender 'newRootAppender' >"${stdoutF}" 2>"${stderrF}"
  assertSuccess $?
  _appender_isValid 'newRootAppender'
  assertTrue 'newRootAppender should exist' $?

  log4sh_addLogger 'newLogger'
  logger_addAppender 'newLoggerAppender' 'newLogger' \
      >"${stdoutF}" 2>"${stderrF}"
  assertSuccess $?
  _appender_isValid 'newLogger.newLoggerAppender'
  assertTrue 'newLogger.newLoggerAppender should exist' $?
}

test_logger_getAppenders() {
  # Root logger.
  appenders=`logger_getAppenders 2>"${stderrF}"`
  assertTrue 'default mode to retrieve root logger should succeed' $?
  assertNull "${appenders}"

  appenders=`logger_getAppenders root 2>"${stderrF}"`
  assertTrue 'getting appenders for root logger should succeed' $?
  assertNull "${appenders}"

  logger_addAppender 'newRootAppender'
  appenders=`logger_getAppenders 2>"${stderrF}"`
  assertTrue 'just added the newRootAppender. where is it?' $?
  assertEquals 'newRootAppender' "${appenders}"

  # Invalid logger.
  appenders=`logger_getAppenders invalidLogger 2>"${stderrF}"`
  assertFalse 'getting appenders for an invalid logger should not succeed' $?
  assertNull "${appenders}"

  # Custom logger.
  log4sh_addLogger custom
  appenders=`logger_getAppenders custom 2>"${stderrF}"`
  assertTrue 'getting appenders for custom logger should succeed' $?
  assertNull "${appenders}"

  logger_addAppender newCustomAppender custom
  appenders=`logger_getAppenders custom 2>"${stderrF}"`
  assertTrue 'just added the newCustomAppender. where is it?' $?
  assertEquals 'newCustomAppender' "${appenders}"
}

test__appender_isValid() {
  _appender_isValid ''
  assertFalse 'empty appender should fail' $?
}

test__appender_isValidType() {
  _appender_isValidType ''
  assertFalse 'empty type should fail' $?

  _appender_isValidType 'DummyAppender'
  assertFalse 'unregistered Dummy appender type should fail' $?

  _log4sh_register_appender 'DummyAppender'
  _appender_isValidType 'DummyAppender'
  assertTrue 'registered Dummy appender type should succeed' $?
}

test_appender_getsetType() {
  # Test getType.
  appType=`appender_getType 2>"${stderrF}"`
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'getType' 'invalid argument count'

  appType=`appender_getType 'invalidAppender' 2>"${stderrF}"`
  assertFalse $?
  assertError 'getType' 'invalid appender'

  # Test setType.
  appender_setType >"${stdoutF}" 2>"${stderrF}"
  assertEquals ${LOG4SH_ERROR} $?
  assertError 'setType' 'invalid argument count'

  appender_setType 'invalidAppender' 'DummyAppender' \
      >"${stdoutF}" 2>"${stderrF}"
  assertFalse $?
  assertError 'setType' 'invalid appender'

  # Default appender type is a ConsoleAppender.
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

testSplitLoggerAppenderMacro() {
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

_appender_register_ConsoleAppender() { :; }
_appender_new_ConsoleAppender() { return ${LOG4SH_TRUE}; }

_appender_register_DummyAppender() { :; }
_appender_new_DummyAppender() { return ${LOG4SH_TRUE}; }

oneTimeSetUp() {
  th_oneTimeSetUp

  _log4sh_register_appender ConsoleAppender
}

setUp() {
  log4sh_resetConfiguration
}

# Load and run shUnit2.
# shellcheck disable=SC2034
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. "${TH_SHUNIT}"
