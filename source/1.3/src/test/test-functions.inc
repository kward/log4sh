# $Id$

# configure debugging. set the DEBUG environment variable to any
# non-empty value to enable debug output, or TRACE to enable trace
# output.
_TRACE=${TRACE:+'_trace '}
_TRACE=${_TRACE:-':'}
[ -n "${TRACE:-}" ] && DEBUG=1
_DEBUG=${DEBUG:+'_debug '}
_DEBUG=${_DEBUG:-':'}

tf_RANDOM=0

_trace()
{
  echo "TRACE $@" >&2
}

_debug()
{
  echo "DEBUG $@" >&2
}

# generate a random number
tf_generateRandom()
{
  tfgr_random=${tf_RANDOM}

  while [ "${tfgr_random}" = "${tf_RANDOM}" ]; do
    if [ -n "${RANDOM:-}" ]; then
      # $RANDOM works
      tfgr_random=${RANDOM}${RANDOM}${RANDOM}$$
    else
      # $RANDOM doesn't work
      #sleep 1  # enough time must pass to guarantee different randomness
      tfgr_date=`date '+%H%M%S'`
      tfgr_random=`expr ${tfgr_date} \* $$`
      unset tfgr_date
    fi
    [ "${tfgr_random}" = "${tf_RANDOM}" ] && sleep 1
  done

  tf_RANDOM=${tfgr_random}
  unset tfgr_random
}

# this section returns the data section from the specified section of a file. a
# datasection is defined by a [header], one or more lines of data, and then a
# blank line.
tf_getDataSect()
{
  tf_sgrep "[$1]" "$2" |sed '1d'
}

# this function greps a section from a file. a section is defined as a group of
# lines preceeded and followed by blank lines.
tf_sgrep()
{
  tf_pattern=$1
  shift

  sed -e '/./{H;$!d;}' -e "x;/${tf_pattern}/"'!d;' $@ |sed '1d'

  unset tf_pattern
}
