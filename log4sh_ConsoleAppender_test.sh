#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008-2018 Kate Ward. All Rights Reserved.
# Released under the Apache License 2.0 license.
#
# log4sh unit test for the ConsoleAppender.
#
# Author: kate.ward@forestent.com (Kate Ward)
# https://github.com/kward/log4sh

# Load test helpers.
. ./log4sh_test_helpers

testNothing() {
  logger_addAppender app
  appender_setType app ConsoleAppender
}

oneTimeSetUp() {
  th_oneTimeSetUp
}

setUp() {
  # Reset log4sh.
  #log4sh_resetConfiguration
  :
}

# Load and run shUnit2.
# shellcheck disable=SC2034
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. "${TH_SHUNIT}"
