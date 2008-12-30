#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for custom MDC patterns.

APP_NAME='stdout'

# load test helpers
. ./log4sh_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testCustomDateMDC()
{
  mdcDateFmt='+%Y.%m.%d'
  pattern='%X{mdcDate}'
  regex='^[0-9]\{4\}\.[0-9]\{2\}\.[0-9]\{2\}'

  # define custom logger_info function
  my_logger_info()
  {
    mdcDate=`date ${mdcDateFmt}`
    log INFO "$@"
  }

  # set the custom pattern
  appender_setPattern ${APP_NAME} ${pattern}
  appender_activateOptions ${APP_NAME}

  ${DEBUG} 'sending message using custom MDC pattern'
  result=`my_logger_info 'dummy'`
  matched=`echo ${result} |sed "s/${regex}//"`
  ${DEBUG} "dateFormat='${mdcDateFmt}' pattern='${pattern}' result='${result}' matched='${matched}'"

  assertNotNull \
    "custom pattern '${pattern}' failed with empty result" \
    "${result}" || return
  assertNull \
    "custom pattern '${pattern}' output of '${matched}' did not match the regex '${regex}'" \
    "${matched}" || return
}

testCustomTimeMDC()
{
  mdcTimeFmt='+%H:%M:%S'
  pattern='%X{mdcTime}'
  regex='^[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}'

  # define custom logger_info function
  my_logger_info()
  {
    mdcTime=`date ${mdcTimeFmt}`
    log INFO "$@"
  }

  # set the custom pattern
  appender_setPattern ${APP_NAME} ${pattern}
  appender_activateOptions ${APP_NAME}

  ${DEBUG} 'sending message using custom MDC pattern'
  result=`my_logger_info 'dummy'`
  matched=`echo ${result} |sed "s/${regex}//"`
  ${DEBUG} "timeFormat='${mdcTimeFmt}' pattern='${pattern}' result='${result}' matched='${matched}'"

  assertNotNull \
    "custom pattern '${pattern}' failed with empty result" \
    "${result}" || return
  assertNull \
    "custom pattern '${pattern}' output of '${matched}' did not match the regex '${regex}'" \
    "${matched}" || return
}

testCustomUserHostMDC()
{
  pattern='%X{USER}@%X{HOSTNAME}'
  regex='[A-Za-z0-9]*@[-.A-Za-z0-9]*'

  # set variables (if needed)
  if [ -z "${HOSTNAME:-}" ]; then
    HOSTNAME=`hostname`
    export HOSTNAME
  fi

  # set the custom pattern
  appender_setPattern ${APP_NAME} ${pattern}
  appender_activateOptions ${APP_NAME}

  ${DEBUG} 'sending message using custom MDC pattern'
  result=`logger_info 'dummy'`
  matched=`echo ${result} |sed "s/${regex}//"`
  ${DEBUG} "pattern='${pattern}' result='${result}' matched='${matched}'"

  assertNotNull \
    "custom pattern '${pattern}' failed with empty result" \
    "${result}" || return
  assertNull \
    "custom pattern '${pattern}' output of '${matched}' did not match the regex '${regex}'" \
    "${matched}" || return
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  LOG4SH_CONFIGURATION='none'
  th_oneTimeSetUp

  resultF="${TH_TMPDIR}/result"
}

setUp()
{
  # reset log4sh
  log4sh_resetConfiguration

  # configure log4sh
  logger_setLevel INFO
  logger_addAppender ${APP_NAME}
  appender_setLayout ${APP_NAME} PatternLayout
}

tearDown()
{
  rm -f "${resultF}"
}

#------------------------------------------------------------------------------
# main
#

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
