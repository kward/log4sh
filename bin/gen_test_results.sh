#! /bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the Apache 2.0 license.
#
# Author: kate.ward@forestent.com (Kate Ward)
# Repository: https://github.com/kward/log4sh
#
# This script runs the provided unit tests and sends the output to the
# appropriate file.

# Treat unset variables as an error.
set -u

die()
{
  [ $# -gt 0 ] && echo "error: $@" >&2
  exit 1
}

BASE_DIR="`dirname $0`/.."
LIB_DIR="${BASE_DIR}/lib"

# Load libraries.
. ${LIB_DIR}/shflags || die 'unable to load shflags library'
. ${LIB_DIR}/shlib_relToAbsPath || die 'unable to load shlib library'
. ${LIB_DIR}/versions || die 'unable to load versions library'

BASE_DIR=`shlib_relToAbsPath "${BASE_DIR}"`
SRC_DIR="${BASE_DIR}/src/shell"

os_name=`versions_osName |sed 's/ /_/g'`
os_version=`versions_osVersion`

DEFINE_boolean force false 'force overwrite' f
DEFINE_string output_dir "`pwd`" 'output dir' d
DEFINE_string output_file "${os_name}-${os_version}.txt" 'output file' o
DEFINE_string suite 'shunit2_test.sh' 'unit test suite' s
FLAGS "$@" || exit $?; shift ${FLAGS_ARGC}

# Determine output filename.
output="${FLAGS_output_dir:+${FLAGS_output_dir}/}${FLAGS_output_file}"
output=`shlib_relToAbsPath "${output}"`

# Checks.
if [ -f "${output}" ]; then
  if [ ${FLAGS_force} -eq ${FLAGS_TRUE} ]; then
    rm -f "${output}"
  else
    echo "not overwriting '${output}'" >&2
    exit ${FLAGS_ERROR}
  fi
fi
touch "${output}" 2>/dev/null || die "unable to write to '${output}'"

# Run tests.
( cd "${SRC_DIR}"; ./${FLAGS_suite} |tee "${output}" )

echo >&2
echo "output written to '${output}'" >&2
