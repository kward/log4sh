#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for log4j compatibility support.

# load test helpers
. ./log4sh_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testAppenders()
{
  for appender in \
    ConsoleAppender \
    FileAppender \
    RollingFileAppender \
    DailyRollingFileAppender \
    SMTPAppender \
    SyslogAppender
  do
    cat <<EOF >${propertiesF}
log4j.rootLogger = INFO, A
log4j.appender.A = org.apache.log4j.${appender}
EOF
    log4sh_doConfigure ${propertiesF}
    rtrn=$?
    assertTrue \
        "compatibility problems with the log4j ${appender}" \
        "[ ${rtrn} -eq ${LOG4SH_TRUE} ]"
  done
}

testLayouts()
{
  for layout in \
    SimpleLayout \
    PatternLayout \
    HTMLLayout
  do
    cat <<EOF >${propertiesF}
log4j.rootLogger = INFO, A
log4j.appender.A = org.apache.log4j.ConsoleAppender
log4j.appender.A.layout = org.apache.log4j.${layout}
EOF
    log4sh_doConfigure ${propertiesF}
    rtrn=$?
    assertTrue \
        "compatibility problems with the log4j ${layout}" \
        "[ ${rtrn} -eq ${LOG4SH_TRUE} ]"
  done
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  LOG4SH_CONFIGURATION='none'
  LOG4SH_CONFIG_PREFIX='log4j'
  th_oneTimeSetUp

  # declare the properties file
  propertiesF="${TH_TMPDIR}/properties.log4sh"
}

setUp()
{
  # reset log4sh
  log4sh_resetConfiguration
}

tearDown()
{
  # remove the properties file
  rm -f "${propertiesF}"
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
