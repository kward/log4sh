# vim:et:ft=sh:sts=2:sw=2
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the Apache 2.0 license.
#
# Author: kate.ward@forestent.com (Kate Ward)
# Repository: https://github.com/kward/shlib

SHLIB_PWD='pwd'

# Convert a relative path into it's absolute equivalent.
#
# This function will automatically prepend the current working directory if the
# path is not already absolute. It then removes all parent references (`../`) to
# reconstruct the proper absolute path.
#
# Args:
#   shlib_path_: string: relative path
# Outputs:
#   string: absolute path
shlib_relToAbsPath() {
  shlib_path_=$1

  # Prepend current directory to relative paths.
  echo "${shlib_path_}" |grep '^/' >/dev/null 2>&1 \
      || shlib_path_="`${SHLIB_PWD}`/${shlib_path_}"

  # Clean up the path. If all `sed` commands supported true regular expressions,
  # then this is what they would do.
  shlib_old_=${shlib_path_}
  while true; do
    shlib_new_=`echo "${shlib_old_}" |sed 's/[^/]*\/\.\.\/*//g;s/\/\.\//\//'`
    [ "${shlib_old_}" = "${shlib_new_}" ] && break
    shlib_old_=${shlib_new_}
  done
  echo "${shlib_new_}"

  unset shlib_old_ shlib_new_ shlib_path_
}
