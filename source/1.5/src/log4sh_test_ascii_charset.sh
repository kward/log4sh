#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# log4sh unit test for standard ASCII character set support.

# load test helpers
. ./log4sh_test_helpers

#------------------------------------------------------------------------------
# suite tests
#

testAsciiCharset()
{
  # save stdin and redirect it from an in-line file
  exec 9<&0 <<EOF
# 20-2F (escaping the leading space)
\ !"#$%&'()*+,-./
# 30-3F
0123456789:;<=>?
# 40-4F
@ABCDEFGHIJKLMNO
# 50-5F (escaping the backslash)
PQRSTUVWXYZ[\\]^_
# 60-6F
\`abcdefghijklmno
# 70-7E (7F is the unprintable DEL char)
pqrstuvwxzy{|}~
EOF
  while read expected; do
    # ignore comment lines or blank lines
    echo "${expected}" |egrep -v '^(#|$)' >/dev/null || continue

    # test the function
    actual="`logger_info \"${expected}\"`"
    ${DEBUG} "expected='${expected}' actual='${actual}'"
    assertEquals "'${expected}' != '${actual}'" "${expected}" "${actual}"
  done
  # restore stdin
  exec 0<&9 9<&-
}

#------------------------------------------------------------------------------
# suite functions
#

oneTimeSetUp()
{
  LOG4SH_CONFIGURATION="${TH_TESTDATA_DIR}/ascii_charset.log4sh"
  th_oneTimeSetUp
}

# load and run shUnit2
[ -n "${ZSH_VERSION:-}" ] && SHUNIT_PARENT=$0
. ${TH_SHUNIT}
