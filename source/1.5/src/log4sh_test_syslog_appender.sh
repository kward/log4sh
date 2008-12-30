#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for the SyslogAppender.
#
# This unit test tests the general logging functionality of Syslog. It sends
# all logging to only a single facility to prevent spamming of system logs
# (something that happens to be a side effect of running this test). This test
# expects that syslog has been configured to write its output to the
# /var/log/log4sh.log logfile so that this file can be parsed.
#
# Sample syslog.conf entries. Note, one should *not* add a '-' char before the
# filename to enable buffering (available only with certain Syslog variants).
#
### Linux (sysklogd)
# local4.*		/var/log/log4sh.log
#
### Solaris (syslogd; use tabs for whitespace!)
# local4.debug		/var/log/log4sh.log
#
# Possible issues:
# * race conditions waiting for logs to be output via syslog. our backoff might
#   be too short for the syslog message to arrive
# * different Syslog variants produce different output. we try to get around
#   this by outputing a unique random number to each logging message so each
#   message can be tracked individually.
#

# load test helpers
. ./log4sh_test_helpers

APP_NAME='mySyslog'
APP_SYSLOG_FACILITY='local4'

BACKOFF_TIMES='0 1 2 4'
TAIL_SAMPLE_SIZE=25
TEST_PRIORITY_DATA="${TH_TESTDATA_DIR}/priority_matrix.dat"
TEST_SYSLOG_DATA="${TH_TESTDATA_DIR}/syslog_appender.dat"
TEST_LOGFILE='/var/log/log4sh.log'

#------------------------------------------------------------------------------
# suite tests
#

testFacilityGetterSetter()
{
  # configure log4sh
  logger_addAppender ${APP_NAME}
  appender_setType ${APP_NAME} SyslogAppender
  appender_activateOptions ${APP_NAME}

  ${DEBUG} 'testing the setting and getting of the valid syslog facilities'
  for facility in `th_getDataSect facilities "${TEST_SYSLOG_DATA}"`; do
    appender_syslog_setFacility ${APP_NAME} "${facility}"
    appender_activateOptions ${APP_NAME}
    currFacility=`appender_syslog_getFacility ${APP_NAME}`
    assertEquals \
        "the syslog facility (${currFacility}) does not match the one set (${facility})" \
        "${facility}" "${currFacility}"
  done

  ${DEBUG} 'testing an invalid syslog facility'
  testFacility='invalid'
  appender_syslog_setFacility ${APP_NAME} "${testFacility}"
  appender_activateOptions ${APP_NAME}
  currFacility=`appender_syslog_getFacility ${APP_NAME}`
  failSame \
      "the returned syslog facility (${currFacility}) matches the invalid one set (${testFacility})" \
      "${testFacility}" "${currFacility}"

  # TODO: test the passing of invalid params

  unset facility currFacility testFacility
}

testHostGetterSetter()
{
  # configure log4sh
  logger_addAppender ${APP_NAME}
  appender_setType ${APP_NAME} SyslogAppender
  appender_activateOptions ${APP_NAME}

  ${DEBUG} 'testing that the default syslog host is empty'
  currHost=`appender_syslog_getHost ${APP_NAME}`
  assertNull \
      'the default syslog host was not empty' \
      "${currHost}"

  ${DEBUG} 'testing that it is possible to set and get the syslog host'
  testHost='localhost'
  # TODO: test for the log4sh:ERROR message
  appender_syslog_setHost ${APP_NAME} "${testHost}"
  appender_activateOptions ${APP_NAME}
  currHost=`appender_syslog_getHost ${APP_NAME}`
  assertEquals \
      'the syslog host does not match the one that was set' \
      "${testHost}" "${currHost}"

  # TODO: test the passing of invalid params

  unset currHost testHost
}

testSyslogLogfilePresent()
{
  # check for logfile presence
  assertTrue \
      "unable to read from the test syslog output file (${TEST_LOGFILE})." \
      "[ -r \"${TEST_LOGFILE}\" ]"
}

testPriorityMatrix()
{
  PRIORITY_NAMES='TRACE DEBUG INFO WARN ERROR FATAL'
  PRIORITY_POS='1 2 3 4 5 6'

  # configure log4sh (appender_activateOptions called later)
  logger_addAppender ${APP_NAME}
  appender_setType ${APP_NAME} SyslogAppender
  appender_syslog_setFacility ${APP_NAME} ${APP_SYSLOG_FACILITY}

  # if the test logfile doesn't exist, we want to skip the tests
  [ ! -r "${TEST_LOGFILE}" ] && startSkipping

  # save stdin, and redirect it from a file
  exec 9<&0 <"${TEST_PRIORITY_DATA}"
  while read priority outputs; do
    # ignore comment lines or blank lines
    echo "${priority}" |egrep -v '^(#|$)' >/dev/null || continue

    echo "  testing appender priority '${priority}'"
    appender_setLevel ${APP_NAME} ${priority}
    appender_activateOptions ${APP_NAME}

    # the number of outputs must match the number of priority names and
    # positions for this to work
    for pos in ${PRIORITY_POS}; do
      testPriority=`echo ${PRIORITY_NAMES} |cut -d' ' -f${pos}`
      shouldOutput=`echo ${outputs} |cut -d' ' -f${pos}`
      result=''

      ${DEBUG} "generating '${testPriority}' message"
      th_generateRandom
      random=${th_RANDOM}
      log ${testPriority} "${TH_ARGV0} test message - ${random}"

      # do a timed backoff to wait for the result -- syslog might take a bit
      if ! isSkipping; then
        for backoff in ${BACKOFF_TIMES}; do
          [ ${backoff} -eq 2 ] \
              && echo "    waiting for possible '${testPriority}' message..."
          sleep ${backoff}
          result=`tail ${tailNumOpt}${TAIL_SAMPLE_SIZE} "${TEST_LOGFILE}" |\
              grep "${random}"`
          [ -n "${result}" ] && break
        done
        ${DEBUG} "result=${result}"
      fi

      if [ ${shouldOutput} -eq 1 ]; then
        assertNotNull \
            "'${priority}' priority appender did not emit a '${testPriority}' message" \
            "${result}"
      else
        assertNull \
            "'${priority}' priority appender emitted a '${testPriority}' message" \
            "${result}"
      fi
    done
  done

  # restore stdin
  exec 0<&9 9<&-

  unset backoff outputs priority random result shouldOutput testPriority
}

#
# this test attempts to send a message to a remote syslog host. in this case,
# it is actually the localhost, but when a syslog host is defined, a completely
# different set of logging code is exercised. using the same local4 facility
# like in the priority matrix test, we should still be able to test for the
# presence of a logging message.
#
testRemoteLogging()
{
  # define the netcat alternative command (required!)
  log4sh_setAlternative 'nc' "${LOG4SH_ALTERNATIVE_NC:-/bin/nc}"

  # configure log4sh
  ${DEBUG} 'configuring log4sh'
  logger_addAppender ${APP_NAME}
  appender_setType ${APP_NAME} SyslogAppender
  appender_syslog_setFacility ${APP_NAME} 'local4'
  appender_syslog_setHost ${APP_NAME} 'localhost'
  appender_activateOptions ${APP_NAME}

  # send a logging message
  ${DEBUG} 'generating message'
  th_generateRandom
  random=${th_RANDOM}
  logger_error "${TH_ARGV0} test message - ${random}"

  # skip the actual test if there is no logfile to tail at
  if [ ! -r "${TEST_LOGFILE}" ]; then
    fail
  else
    # do a timed backoff to wait for the result -- syslog might take a bit
    for backoff in ${BACKOFF_TIMES}; do
      [ ${backoff} -eq 2 ] \
          && echo "    waiting longer for message..."
      sleep ${backoff}
      result=`tail ${tailNumOpt}${TAIL_SAMPLE_SIZE} "${TEST_LOGFILE}" |\
          grep "${random}"`
      [ -n "${result}" ] && break
    done
    ${DEBUG} "result=${result}"

    assertNotNull \
        'did not receive the remotely logged syslog message' \
        "${result}"
  fi

  unset backoff random result
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
  log4sh_resetConfiguration
}

# check options on tail command
result=`echo '' |tail -n 1 >/dev/null 2>&1`
if [ $? -eq 0 ]; then
  # newer tail command
  tailNumOpt='-n '
else
  tailNumOpt='-'
fi

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
