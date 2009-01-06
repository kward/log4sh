#! /bin/sh
# $Id$
# vim:et:ft=sh:sts=2:sw=2
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
# Build script for log4sh.
#
# This script takes the various individual code pieces and brings them
# together.

outF='log4sh.new'

echo "appending code from log4sh_base"
cat 'log4sh_base' >${outF}

for appender in log4sh_*Appender; do
  echo "appending code from ${appender}"
  echo >>${outF}
  echo '#==============================================================================' >>${outF}
  # strip top of header and append the rest
  sed '1,7d' ${appender} >>${outF}
done

echo ${outF} generated.
