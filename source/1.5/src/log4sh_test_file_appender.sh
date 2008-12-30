#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for the FileAppender.

# load test helpers
. ./log4sh_test_helpers

APP_ACCESSORS='accessors'
APP_ACCESSORS_FILE=''
APP_ACCESSORS_LOG4SH="${TH_TESTDATA_DIR}/file_appender_accessors.log4sh"

APP_SIMPLE='mySimple'
APP_SIMPLE_FILE=''
APP_SIMPLE_LOG4SH="${TH_TESTDATA_DIR}/file_appender_simple.log4sh"

APP_STDERR='mySTDERR'
APP_STDERR_LOG4SH="${TH_TESTDATA_DIR}/file_appender_stderr.log4sh"

#------------------------------------------------------------------------------
# suite tests
#

commonSTDERR()
{
  assert=$1
  msg=$2
  cmd=$3

  ${DEBUG} "sending a message to ${APP_STDERR}"
  result=`eval ${cmd}`
  ${DEBUG} "assert='${assert}' cmd='${cmd}' result='${result}'"
  eval ${assert} \"${msg}\" \"${result}\"
}

testSTDERR_runtime()
{
  # runtime configure a STDERR FileAppender
  logger_setLevel INFO
  logger_addAppender ${APP_STDERR}
  appender_setType ${APP_STDERR} FileAppender
  appender_file_setFile ${APP_STDERR} STDERR
  appender_activateOptions ${APP_STDERR}

  commonSTDERR \
    'assertNotNull' \
    "${APP_STDERR} runtime FileAppender didn't go to STDERR" \
    "logger_info \'dummy\' 2>&1 >/dev/null" \
  || return

  commonSTDERR \
    'assertNull' \
    "${APP_STDERR} runtime FileAppender went to STDOUT" \
    "logger_info \'dummy\' 2>/dev/null" \
  || return
}

testSTDERR_config()
{
  # configure a STDERR FileAppender via config
  log4sh_doConfigure "${APP_STDERR_LOG4SH}"

  commonSTDERR \
    'assertNotNull' \
    "${APP_STDERR} config FileAppender didn't go to STDERR" \
    "logger_info \'dummy\' 2>&1 1>/dev/null" \
  || return

  commonSTDERR \
    'assertNull' \
    "${APP_STDERR} config FileAppender went to STDOUT" \
    "logger_info \'dummy\' 2>/dev/null" \
  || return
}

commonSimple()
{
  assert=$1
  msg=$2
  cmd=$3

  ${DEBUG} "sending a message to ${APP_SIMPLE}"
  result=`eval ${cmd}`
  ${DEBUG} "assert='${assert}' cmd='${cmd}' result='${result}'"
  eval ${assert} \"${msg}\" \"${result}\"
}

testSimple_runtime()
{
  # runtime configure a simple ConsoleAppender
  logger_setLevel INFO
  logger_addAppender ${APP_SIMPLE}
  appender_setLevel ${APP_SIMPLE} DEBUG
  appender_setType ${APP_SIMPLE} FileAppender
  appender_file_setFile ${APP_SIMPLE} "${APP_SIMPLE_FILE}"
  appender_activateOptions ${APP_SIMPLE}

  commonSimple \
    'assertNull' \
    "${APP_SIMPLE} config FileAppender went to STDOUT or STDERR" \
    "logger_info \'dummy\' 2>&1" \
  || return

  commonSimple \
    'assertNotNull' \
    "${APP_SIMPLE} config FileAppender didn't go to file" \
    "logger_info \'dummy\' 2>&1; cat \"${APP_SIMPLE_FILE}\"" \
  || return
}

testSimple_config()
{
  # configure a simple ConsoleAppender via config
  log4sh_doConfigure "${APP_SIMPLE_LOG4SH}"

  commonSimple \
    'assertNull' \
    "${APP_SIMPLE} runtime FileAppender went to STDOUT or STDERR" \
    "logger_info \'dummy\' 2>&1" \
  || return

  commonSimple \
    'assertNotNull' \
    "${APP_SIMPLE} runtime FileAppender didn't go to file" \
    "logger_info \'dummy\'; cat ${APP_SIMPLE_FILE}" \
  || return
}

# test that the filename set in the configuration file is readable
# programatically
testAccessors_getFilename()
{
  # configure log4sh via config
  log4sh_doConfigure "${APP_ACCESSORS_LOG4SH}"

  fileName=`appender_file_getFile ${APP_ACCESSORS}`
  assertEquals \
    "${APP_ACCESSORS} file '${fileName}' was not '${APP_ACCESSORS_FILE}'" \
    "${fileName}" "${APP_ACCESSORS_FILE}"
}

# test that setting the filename of an appender actually changes it
testAccessors_setgetFilename()
{
  # configure log4sh via config
  log4sh_doConfigure "${APP_ACCESSORS_LOG4SH}"

  newFileName='/var/tmp/accessors.log'

  # the current filename should be what is stored in ${APP_ACCESSORS_FILE}.
  # changing it to /var/tmp/accessors.log
  appender_file_setFile ${APP_ACCESSORS} "${newFileName}"

  # now, re-reading the file name to verify
  fileName=`appender_file_getFile ${APP_ACCESSORS}`
  assertEquals \
    "${APP_ACCESSORS} file was not ${newFileName}" \
    "${fileName}" "${newFileName}"
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  LOG4SH_CONFIGURATION='none'
  th_oneTimeSetUp

  APP_ACCESSORS_FILE="${TH_TMPDIR}/myAccessors.out"
  APP_SIMPLE_FILE="${TH_TMPDIR}/mySimple.out"
}

setUp()
{
  # reset log4sh
  log4sh_resetConfiguration
}

tearDown()
{
  rm -f "${APP_ACCESSORS_FILE}" "${APP_SIMPLE_FILE}"
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
