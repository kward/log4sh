# $Id$
# vim:et:ft=sh:sts=2:sw=2
# vim:foldmethod=marker:foldmarker=/**,*/
#
# Copyright 2008 Kate Ward. All Rights Reserved.
# Released under the LGPL (GNU Lesser General Public License)
# Author: kate.ward@forestent.com (Kate Ward)
#
#/**
# <?xml version="1.0" encoding="UTF-8"?>
# <s:shelldoc xmlns:s="http://www.forestent.com/projects/shelldoc/xsl/2005.0">
# <s:header>
# log4sh 1.5.1
# Logging framework 4 SHell scripts
#
# http://log4sh.sourceforge.net/
#
# written by Kate Ward &lt;kate.ward@forestent.com&gt;
# released under the LGPL
#
# this module implements something like the log4j module from the Apache group
#
# notes:
# *) the default appender is a ConsoleAppender named stdout with a level
#    of ERROR and layout of SimpleLayout
# *) the appender levels are as follows (decreasing order of output):
#    TRACE, DEBUG, INFO, WARN, ERROR, FATAL, OFF
# </s:header>
#*/

# return if log4sh already loaded
[ -z "${LOG4SH_VERSION:-}" ] || return
LOG4SH_VERSION='1.5.1pre'

# shell flags for log4sh:
# u - treat unset variables as an error when performing parameter expansion
__LOG4SH_SHELL_FLAGS='u'

# save the current set of shell flags, and then set some for log4sh
__log4sh_oldShellFlags=$-
for _log4sh_shellFlag in `echo "${__LOG4SH_SHELL_FLAGS}" |sed 's/\(.\)/\1 /g'`
do
  set -${_log4sh_shellFlag}
done
unset _log4sh_shellFlag

#
# constants
#
LOG4SH_TRUE=0
LOG4SH_FALSE=1
LOG4SH_ERROR=2

__LOG4SH_NULL='~'

__LOG4SH_APPENDER_FUNC_PREFIX='_log4sh_app_'
__LOG4SH_APPENDER_INCLUDE_EXT='.inc'

__LOG4SH_TYPE_CONSOLE='ConsoleAppender'
__LOG4SH_TYPE_DAILY_ROLLING_FILE='DailyRollingFileAppender'
__LOG4SH_TYPE_FILE='FileAppender'
__LOG4SH_TYPE_ROLLING_FILE='RollingFileAppender'
__LOG4SH_TYPE_ROLLING_FILE_MAX_BACKUP_INDEX=1
__LOG4SH_TYPE_ROLLING_FILE_MAX_FILE_SIZE=10485760
__LOG4SH_TYPE_SMTP='SMTPAppender'
__LOG4SH_TYPE_SYSLOG='SyslogAppender'
__LOG4SH_TYPE_SYSLOG_FACILITY_NAMES=' kern user mail daemon auth security syslog lpr news uucp cron authpriv ftp local0 local1 local2 local3 local4 local5 local6 local7 '
__LOG4SH_TYPE_SYSLOG_FACILITY='user'

__LOG4SH_LAYOUT_HTML='HTMLLayout'
__LOG4SH_LAYOUT_SIMPLE='SimpleLayout'
__LOG4SH_LAYOUT_PATTERN='PatternLayout'

__LOG4SH_LEVEL_TRACE=0
__LOG4SH_LEVEL_TRACE_STR='TRACE'
__LOG4SH_LEVEL_DEBUG=1
__LOG4SH_LEVEL_DEBUG_STR='DEBUG'
__LOG4SH_LEVEL_INFO=2
__LOG4SH_LEVEL_INFO_STR='INFO'
__LOG4SH_LEVEL_WARN=3
__LOG4SH_LEVEL_WARN_STR='WARN'
__LOG4SH_LEVEL_ERROR=4
__LOG4SH_LEVEL_ERROR_STR='ERROR'
__LOG4SH_LEVEL_FATAL=5
__LOG4SH_LEVEL_FATAL_STR='FATAL'
__LOG4SH_LEVEL_OFF=6
__LOG4SH_LEVEL_OFF_STR='OFF'
__LOG4SH_LEVEL_CLOSED=255
__LOG4SH_LEVEL_CLOSED_STR='CLOSED'

__LOG4SH_PATTERN_DEFAULT='%d %p - %m%n'
__LOG4SH_THREAD_DEFAULT='main'

__LOG4SH_CONFIGURATION="${LOG4SH_CONFIGURATION:-log4sh.properties}"
__LOG4SH_CONFIG_PREFIX="${LOG4SH_CONFIG_PREFIX:-log4sh}"

# the following IFS is *supposed* to be on two lines!!
__LOG4SH_IFS_ARRAY="
"
__LOG4SH_IFS_DEFAULT=' '

__LOG4SH_SECONDS=`eval "expr \`date '+%H \* 3600 + %M \* 60 + %S'\`"`

# configure log4sh debugging. set the LOG4SH_INFO environment variable to any
# non-empty value to enable info output, LOG4SH_DEBUG enable debug output, or
# LOG4SH_TRACE to enable trace output. log4sh ERROR and above messages are
# always printed. to send the debug output to a file, set the LOG4SH_DEBUG_FILE
# with the filename you want debug output to be written to.
__LOG4SH_TRACE=${LOG4SH_TRACE:+'_log4sh_trace '}
__LOG4SH_TRACE_CALL=${LOG4SH_TRACE:+'_log4sh_traceCall '}
__LOG4SH_TRACE=${__LOG4SH_TRACE:-':'}
__LOG4SH_TRACE_CALL=${__LOG4SH_TRACE_CALL:-':'}
[ -n "${LOG4SH_TRACE:-}" ] && LOG4SH_DEBUG=1
__LOG4SH_DEBUG=${LOG4SH_DEBUG:+'_log4sh_debug '}
__LOG4SH_DEBUG=${__LOG4SH_DEBUG:-':'}
[ -n "${LOG4SH_DEBUG:-}" ] && LOG4SH_INFO=1
__LOG4SH_INFO=${LOG4SH_INFO:+'_log4sh_info '}
__LOG4SH_INFO=${__LOG4SH_INFO:-':'}

# set the constants to readonly
for _log4sh_const in `set |grep "^__LOG4SH_" |cut -d= -f1`; do
  readonly ${_log4sh_const}
done
unset _log4sh_const

#
# internal variables
#

__log4sh_filename=`basename $0`
__log4sh_tmpDir=''
__log4sh_trapsFile=''

__log4sh_alternative_mail='mail'

__log4sh_threadName=${__LOG4SH_THREAD_DEFAULT}
__log4sh_threadStack=${__LOG4SH_THREAD_DEFAULT}

__log4sh_seconds=0
__log4sh_secondsLast=0
__log4sh_secondsWrap=0

# workarounds for various commands
__log4sh_wa_strictBehavior=${LOG4SH_FALSE}
(
  # determine if the set builtin needs to be evaluated. if the string is parsed
  # into two separate strings (common in ksh), then set needs to be evaled.
  str='x{1,2}'
  set -- ${str}
  test ! "$1" = 'x1' -a ! "${2:-}" = 'x2'
)
__log4sh_wa_setNeedsEval=$?


#=============================================================================
# Log4sh
#

#-----------------------------------------------------------------------------
# internal debugging
#

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_log</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#       <paramdef>string <parameter>message</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     This is an internal debugging function. It should not be called.
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_log DEBUG "some message"</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_log()
{
  _ll__level=$1

  shift
  if [ -z "${LOG4SH_DEBUG_FILE:-}" ]; then
    echo "log4sh:${_ll__level} $@" >&2
  else
    echo "${_ll__level} $@" >>${LOG4SH_DEBUG_FILE}
  fi

  unset _ll__level
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_trace</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is an internal debugging function. It should not be
#   called.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_trace "some message"</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_trace()
{
  _log4sh_log "${__LOG4SH_LEVEL_TRACE_STR}" \
      "${BASH_LINENO:+(${BASH_LINENO}) }$@"
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_debug</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is an internal debugging function. It should not be
#   called.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_debug "some message"</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_debug()
{
  _log4sh_log "${__LOG4SH_LEVEL_DEBUG_STR}" \
      "${BASH_LINENO:+(${BASH_LINENO}) }$@"
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_info</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is an internal debugging function. It should not be
#   called.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_info "some message"</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_info()
{
  _log4sh_log "${__LOG4SH_LEVEL_INFO_STR}" \
      "${BASH_LINENO:+(${BASH_LINENO}) }$@"
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_warn</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is an internal debugging function. It should not be
#   called.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_warn "some message"</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_warn()
{
  echo "log4sh:${__LOG4SH_LEVEL_WARN_STR} $@" >&2
  [ -n "${LOG4SH_DEBUG_FILE:-}" ] \
      && _log4sh_log "${__LOG4SH_LEVEL_WARN_STR}" "$@"
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_error</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is an internal debugging function. It should not be
#   called.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_error "some message"</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_error()
{
  echo "log4sh:${__LOG4SH_LEVEL_ERROR_STR} $@" >&2
  [ -n "${LOG4SH_DEBUG_FILE:-}" ] \
      && _log4sh_log "${__LOG4SH_LEVEL_ERROR_STR}" "$@"
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_fatal</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is an internal debugging function. It should not be
#   called.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_fatal "some message"</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_fatal()
{
  echo "log4sh:${__LOG4SH_LEVEL_FATAL_STR} $@" >&2
  [ -n "${LOG4SH_DEBUG_FILE:-}" ] \
      && _log4sh_log "${__LOG4SH_LEVEL_FATAL_STR}" "$@"
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_traceCall</function></funcdef>
#       <paramdef>string <parameter>funcName</parameter></paramdef>
#       <paramdef>integer <parameter>lineNo</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     This is an internal debugging function. It should not be called.
#   </para>
#   <para><emphasis role="strong">Since:</emphasis> 1.5.0</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_traceCall</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_traceCall()
{
  _ltc_funcName=$1
  _ltc_numArgs=$2
  _ltc_argsCheck=$3
  _ltc_wantArgs=$4
  _ltc_lineNo=${5:-}

  ${__LOG4SH_TRACE} "${_ltc_funcName}()${_ltc_lineNo:+ (called from ${_ltc_lineNo})}"
  if [ ${_ltc_numArgs} ${_ltc_argsCheck} ${_ltc_wantArgs} ]; then
    _log4sh_error "${_ltc_funcName}(): invalid argument count (${_ltc_numArgs} ${_ltc_argsCheck} ${_ltc_wantArgs})"
    return ${LOG4SH_FALSE}
  fi
  return ${LOG4SH_TRUE}
}

#-----------------------------------------------------------------------------
# miscellaneous
#

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_mktempDir</function></funcdef>
#       <void />
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Creates a secure temporary directory within which temporary files can be
#     created. Honors the <code>TMPDIR</code> environment variable if it is
#     set.
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>tmpDir=`_log4sh_mktempDir`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_mktempDir()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_mktempDir \
      $# -ne 0 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lmd_tmpPrefix='log4sh'

  # try the standard mktemp function
  ( exec mktemp -dqt ${_lmd_tmpPrefix}.XXXXXX 2>/dev/null ) && return

  # the standard mktemp didn't work. doing our own.
  if [ -r '/dev/urandom' ]; then
    _lmd_random=`od -vAn -N4 -tx4 </dev/urandom |sed 's/^[^0-9a-f]*//'`
  elif [ -n "${RANDOM:-}" ]; then
    # $RANDOM works
    _lmd_random=${RANDOM}${RANDOM}${RANDOM}$$
  else
    # could not get a random number; generating one as best we can
    _lmd_date=`date '+%Y%m%d%H%M%S'`
    _lmd_random=`expr ${_lmd_date} / $$`
    unset _lmd_date
  fi

  _lmd_tmpDir="${TMPDIR:-/tmp}/${_lmd_tmpPrefix}.${_lmd_random}"
  ( umask 077 && mkdir "${_lmd_tmpDir}" ) || {
    _log4sh_fatal 'could not create temporary directory! exiting'
    exit 1
  }

  ${__LOG4SH_DEBUG} "created temporary directory (${_lmd_tmpDir})"
  echo "${_lmd_tmpDir}"
  unset _lmd_random _lmd_tmpDir _lmd_tmpPrefix
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>/return
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_updateSeconds</function></funcdef>
#       <void />
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Set the <code>__log4sh_seconds</code> variable to the number of seconds
#     elapsed since the start of the script.
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_updateSeconds`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_updateSeconds()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_updateSeconds \
      $# -ne 0 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  if [ -n "${SECONDS:-}" ]; then
    __log4sh_seconds=${SECONDS}
  else
    _lgs__date=`date '+%H \* 3600 + %M \* 60 + %S'`
    _lgs__seconds=`eval "expr ${_lgs__date} + ${__log4sh_secondsWrap} \* 86400"`
    if [ ${_lgs__seconds} -lt ${__log4sh_secondsLast} ]; then
      __log4sh_secondsWrap=`expr ${__log4sh_secondsWrap} + 1`
      _lgs__seconds=`expr ${_lgs_seconds} + 86400`
    fi
    __log4sh_seconds=`expr ${_lgs__seconds} - ${__LOG4SH_SECONDS}`
    __log4sh_secondsLast=${__log4sh_seconds}
    unset _lgs__date _lgs__seconds
  fi
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Log4sh" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>log4sh_enableStrictBehavior</function></funcdef>
#       <void />
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Enables strict log4j behavior.
#   </para>
#   <para><emphasis role="strong">Since:</emphasis> 1.3.7</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>log4sh_enableStrictBehavior</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
log4sh_enableStrictBehavior()
{
  ${__LOG4SH_TRACE_CALL} log4sh_enableStrictBehavior \
      $# -ne 0 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  __log4sh_wa_strictBehavior=${LOG4SH_TRUE}
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Log4sh" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>log4sh_setAlternative</function></funcdef>
#       <paramdef>string <parameter>command</parameter></paramdef>
#       <paramdef>string <parameter>path</parameter></paramdef>
#       <paramdef>boolean <parameter>useRuntimePath</parameter> (optional)</paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Specifies an alternative path for a command.
#   </para>
#   <para><emphasis role="strong">Since:</emphasis> 1.3.7</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>log4sh_setAlternative nc /bin/nc</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
log4sh_setAlternative()
{
  ${__LOG4SH_TRACE_CALL} log4sh_setAlternative \
      $# -lt 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  lsa_cmdName=$1
  lsa_cmdPath=$2
  lsa_useRuntimePath=${3:-}
  __log4sh_return=${LOG4SH_TRUE}

  # check that the alternative command exists and is executable
  if [ ! -x "${lsa_cmdPath}" \
      -a ${lsa_useRuntimePath:-${LOG4SH_FALSE}} -eq ${LOG4SH_FALSE} ]
  then
    # the alternative command is not executable
    _log4sh_error "unrecognized command alternative '${lsa_cmdName}'"
    __log4sh_return=${LOG4SH_FALSE}
  fi

  # check for valid alternative
  if [ ${__log4sh_return} -eq ${LOG4SH_TRUE} ]; then
    case ${lsa_cmdName} in
      mail) ;;
      nc)
        lsa_cmdVers=`${lsa_cmdPath} --version 2>&1 |head -1`
        if echo "${lsa_cmdVers}" |grep '^netcat' >/dev/null; then
          # GNU Netcat
          __log4sh_alternative_nc_opts='-c'
        else
          # older netcat (v1.10)
          if nc -q 0 2>&1 |grep '^no destination$' >/dev/null 2>&1; then
            # supports -q option
            __log4sh_alternative_nc_opts='-q 0'
          else
            # doesn't support the -q option
            __log4sh_alternative_nc_opts=''
          fi
        fi
        unset lsa_cmdVers
        ;;
      *)
        # the alternative is not valid
        _log4sh_error "unrecognized command alternative '${lsa_cmdName}'"
        __log4sh_return=${LOG4SH_FALSE}
        ;;
    esac
  fi

  # set the alternative
  if [ ${__log4sh_return} -eq ${LOG4SH_TRUE} ]; then
    eval __log4sh_alternative_${lsa_cmdName}="\${lsa_cmdPath}"
    ${__LOG4SH_DEBUG} \
        "alternative '${lsa_cmdName}' command set to '${lsa_cmdPath}'"
  fi

  unset lsa_cmdName lsa_cmdPath
  return ${__log4sh_return}
}

#-----------------------------------------------------------------------------
# array handling
#
# note: arrays are '1' based
#

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <code>integer</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_findArrayElement</function></funcdef>
#       <paramdef>string[] <parameter>array</parameter></paramdef>
#       <paramdef>string <parameter>element</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Find the position of element in an array</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>
#       pos=`_log4sh_findArrayElement "$array" $element`
#     </funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_findArrayElement()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_findArrayElement \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lfae_array=$1
  _lfae_element=$2
  __log4sh_return=${LOG4SH_TRUE}

  _lfae_pos=`echo "${_lfae_array}" |awk '$0==e{print NR}' e="${_lfae_element}"`
  if [ -n "${_lfae_pos}" ]; then
    echo "${_lfae_pos}"
  else
    echo 0
    __log4sh_return=${LOG4SH_FALSE}
  fi

  unset _lfae_array _lfae_element _lfae_pos
  return ${__log4sh_return}
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_getArrayElement</function></funcdef>
#       <paramdef>string[] <parameter>array</parameter></paramdef>
#       <paramdef>integer <parameter>position</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Retrieve the element at the given position from an array</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>element=`_log4sh_getArrayElement "$array" $position`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
#
# XXX This function must not set or change __log4sh_return. Calling functions
# rely on it not being altered.
#
_log4sh_getArrayElement()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_getArrayElement \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lgae_array=$1
  _lgae_index=$2
  ${__LOG4SH_TRACE} "_lgae_array='${_lgae_array}' _lgae_index='${_lgae_index}'"

  _lgae_oldIFS=${IFS}
  if [ ${__log4sh_wa_setNeedsEval} -eq ${LOG4SH_TRUE} ]; then
    ${__LOG4SH_TRACE} '__log4sh_wa_setNeedsEval == LOG4SH_TRUE'
    IFS=${__LOG4SH_IFS_ARRAY}
    set -- junk ${_lgae_array}
    IFS=${_lgae_oldIFS}
${__LOG4SH_TRACE} "1='${1:-}' 2='${2:-}' 3='${3:-}' ..."
  else
    ${__LOG4SH_TRACE} '__log4sh_wa_setNeedsEval != LOG4SH_TRUE'
    IFS=${__LOG4SH_IFS_ARRAY}
    eval "set -- junk \"${_lgae_array}\""
    IFS=${_lgae_oldIFS}
    _lgae_arraySize=$#

    if [ ${_lgae_arraySize} -le ${__log4shAppenderCount} ]; then
      # the evaled set *didn't* work; failing back to original set command and
      # disabling the work around. (pdksh)
      ${__LOG4SH_DEBUG} '__log4sh_wa_setNeedsEval *must* == LOG4SH_TRUE'
      __log4sh_wa_setNeedsEval=${LOG4SH_FALSE}
      IFS=${__LOG4SH_IFS_ARRAY}
      set -- junk ${_lgae_array}
      IFS=${_lgae_oldIFS}
    fi
  fi

  shift ${_lgae_index}
  ${__LOG4SH_TRACE} "1='${1:-}' 2='${2:-}' 3='${3:-}' ..."
  echo "$1"

  unset _lgae_array _lgae_arraySize _lgae_index _lgae_oldIFS
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <code>integer</code>/boolean
# </entry>
# <entry align="left">
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_getArrayLength</function></funcdef>
#       <paramdef>string[] <parameter>array</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Get the length of an array</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>length=`_log4sh_getArrayLength "$array"`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_getArrayLength()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_getArrayLength \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lgal_oldIFS=${IFS} IFS=${__LOG4SH_IFS_ARRAY}
  set -- $1
  echo $#
  IFS=${_lgal_oldIFS}

  unset _lgal_oldIFS
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <code>string[]</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_setArrayElement</function></funcdef>
#       <paramdef>string[] <parameter>array</parameter></paramdef>
#       <paramdef>integer <parameter>position</parameter></paramdef>
#       <paramdef>string <parameter>element</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Place an element at a given location in an array</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>newArray=`_log4sh_setArrayElement "$array" 1 abc`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_setArrayElement()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_setArrayElement \
      $# -ne 3 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  echo "$1" |awk '{if(NR==r){print e}else{print $0}}' r=$2 e="$3"
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <code>string[]</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_join</function></funcdef>
#       <paramdef>string <parameter>separator</parameter></paramdef>
#       <paramdef>string[] <parameter>array</parameter></paramdef>
#       <paramdef>string <parameter>element</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Joins two strings together with a separator string in
#   between.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>newStr=`_log4sh_join ' ' "foo bar" buz`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_join()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_join \
      $# -ne 3 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  echo "${2:+$2$1}$3"
  return ${LOG4SH_TRUE}
}

#=============================================================================
# Appender
#

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_getData</function></funcdef>
#       <paramdef>string[] <parameter>array</parameter></paramdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Retrieve the appender data an appender data array</para>
#   <para><emphasis role="strong">Since:</emphasis> 1.5.0</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>data=`_appender_getData "${array}" myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_appender_getData()
{
  ${__LOG4SH_TRACE_CALL} _appender_getData \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _agd_array=$1
  _agd_appender=$2

  _agd_index=`_log4sh_findArrayElement "${__log4shAppenders}" ${_agd_appender}`
  if [ $? -eq ${LOG4SH_TRUE} ]; then
    _log4sh_getArrayElement "${_agd_array}" ${_agd_index}
    __log4sh_return=$?
  else
    _log4sh_error "invalid appender passed (${_agd_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset _agd_array _agd_appender _agd_index
  return ${__log4sh_return}
}

#/**
# <s:function group="Log4sh" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_setData</function></funcdef>
#       <paramdef>string <parameter>arrayVar</parameter></paramdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>value</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Set the appender value for appender array variable</para>
#   <para><emphasis role="strong">Since:</emphasis> 1.5.0</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_appender_setData arrayVar myAppender data</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_appender_setData()
{
  ${__LOG4SH_TRACE_CALL} _appender_setData \
      $# -ne 3 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _asd_arrayVar=$1
  _asd_appender=$2
  _asd_value=$3
  ${__LOG4SH_TRACE} "_asd_arrayVar='${_asd_arrayVar}' _asd_appender='${_asd_appender}' _asd_value='${_asd_value}'"

  _asd_index=`_log4sh_findArrayElement "${__log4shAppenders}" ${_asd_appender}`
  if [ $? -eq ${LOG4SH_TRUE} ]; then
    ${__LOG4SH_TRACE} "_asd_index='${_asd_index}'"
    _asd_strToEval="_asd_array=\"\${${_asd_arrayVar}}\""
    eval "${_asd_strToEval}"

    _asd_strToEval="${_asd_arrayVar}=\`_log4sh_setArrayElement \
        \"${_asd_array}\" ${_asd_index} \"${_asd_value}\"\`"
    eval "${_asd_strToEval}"
    if [ $? -eq ${LOG4SH_TRUE} ]; then
      _appender_cache ${_asd_appender}
      # inheriting __log4sh_return from _appender_cache
    else
      _log4sh_error "unable to set array element for appender (${_asd_appender})"
      __log4sh_return=${LOG4SH_ERROR}
    fi
  else
    _log4sh_error "invalid appender passed (${_asd_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset _asd_arrayVar _asd_appender _asd_value
  unset _asd_array _asd_index _asd_strToEval
  return ${__log4sh_return}
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_activateOptions</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Activate an appender's configuration. This should be called after
#     reconfiguring an appender via code. It needs only to be called once
#     before any logging statements are called. This calling of this function
#     will be required in log4sh 1.4.x.
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_activateAppender myAppender</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_activateOptions()
{
  ${__LOG4SH_TRACE_CALL} appender_activateOptions \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  ${__LOG4SH_APPENDER_FUNC_PREFIX}${1}_activateOptions
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_close</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Disable any further logging via an appender. Once closed, the
#   appender can be reopened by setting it to any logging Level (e.g.
#   INFO).</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_close myAppender</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_close()
{
  ${__LOG4SH_TRACE_CALL} appender_close \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  appender_setLevel $1 ${__LOG4SH_LEVEL_CLOSED_STR}
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_exists</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Checks for the existance of a named appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>exists=`appender_exists myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_exists()
{
  ${__LOG4SH_TRACE_CALL} appender_exists \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  # the following function executed in subshell so that the __log4sh_return
  # value of calling functions will not be altered
  ( _log4sh_findArrayElement "${__log4shAppenders}" $1 >/dev/null )
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_getLayout</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Gets the Layout of an Appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>type=`appender_getLayout myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_getLayout()
{
  ${__LOG4SH_TRACE_CALL} appender_getLayout \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _appender_getData "${__log4shAppenderLayouts}" $1
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_setLayout</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>layout</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Sets the Layout of an Appender (e.g. PatternLayout)</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_setLayout myAppender PatternLayout</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_setLayout()
{
  ${__LOG4SH_TRACE_CALL} appender_setLayout \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  asl_appender=$1
  asl_layout=$2
  __log4sh_return=${LOG4SH_TRUE}

  case ${asl_layout} in
    "${__LOG4SH_LAYOUT_HTML}"|\
    "${__LOG4SH_LAYOUT_SIMPLE}"|\
    "${__LOG4SH_LAYOUT_PATTERN}") ;;
    *)
      _log4sh_error "unknown layout: ${asl_layout}"
      __log4sh_return=${LOG4SH_FALSE}
      ;;
  esac

  if [ ${__log4sh_return} -eq ${LOG4SH_TRUE} ]; then
    _appender_setData __log4shAppenderLayouts \
        ${asl_appender} "${asl_layout}"
    # inheriting __log4sh_return from _appender_setData
    if [ $? -ne ${LOG4SH_TRUE} ]; then
      _log4sh_error "unable to set the 'layout' for appender (${asl_appender})"
      __log4sh_return=${LOG4SH_ERROR}
    fi
  fi

  unset asl_appender asl_layout
  return ${__log4sh_return}
}

#/**
# <s:function group="Appender" modifier="private">
# <entry align="right">
#   <code>string</code>/return
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_getLayoutByIndex</function></funcdef>
#       <paramdef>integer <parameter>index</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Gets the Layout of an Appender at the given array index</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>type=`_appender_getLayoutByIndex 3`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_appender_getLayoutByIndex()
{
  ${__LOG4SH_TRACE_CALL} _appender_getLayoutByIndex \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _log4sh_getArrayElement "${__log4shAppenderLayouts}" $1
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_getLevel</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Gets the current logging Level of an Appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>type=`appender_getLevel myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_getLevel()
{
  ${__LOG4SH_TRACE_CALL} appender_getLevel \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _appender_getData "${__log4shAppenderLevels}" $1
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_getLevelByIndex</function></funcdef>
#       <paramdef>integer <parameter>index</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Gets the current logging Level of an Appender at the given array
#   index</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>type=`_appender_getLevelByIndex 3`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_appender_getLevelByIndex()
{
  ${__LOG4SH_TRACE_CALL} _appender_getLevelByIndex \
      $# -ne 1 ${BASH_LINENO:-}  || return ${LOG4SH_FALSE}

  _log4sh_getArrayElement "${__log4shAppenderLevels}" $1
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_setLevel</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Sets the Level of an Appender (e.g. INFO)</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_setLevel myAppender INFO</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_setLevel()
{
  ${__LOG4SH_TRACE_CALL} appender_setLevel \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  asl_appender=$1
  asl_level=$2

  _appender_setData __log4shAppenderLevels \
      ${asl_appender} "${asl_level}"
  # inheriting __log4sh_return from _appender_setData
  if [ $? -ne ${LOG4SH_TRUE} ]; then
    _log4sh_error "unable to set the 'level' for appender (${asl_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset asl_appender asl_level
  return ${__log4sh_return}
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_getPattern</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Gets the Pattern of an Appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>pattern=`appender_getPattern myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_getPattern()
{
  ${__LOG4SH_TRACE_CALL} appender_getPattern \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _appender_getData "${__log4shAppenderPatterns}" $1
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_setPattern</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>pattern</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Sets the Pattern of an Appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_setPattern myAppender '%d %p - %m%n'</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_setPattern()
{
  ${__LOG4SH_TRACE_CALL} appender_setPattern \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  asp_appender=$1
  asp_pattern=$2

  _appender_setData __log4shAppenderPatterns \
      ${asp_appender} "${asp_pattern}"
  # inheriting __log4sh_return from _appender_setData
  if [ $? -ne ${LOG4SH_TRUE} ]; then
    _log4sh_error "unable to set the 'pattern' for appender (${asp_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset asp_appender asp_pattern
  return ${__log4sh_return}
}

#/**
# <s:function group="Appender" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_getPatternByIndex</function></funcdef>
#       <paramdef>integer <parameter>index</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Gets the Pattern of an Appender at the specified array index</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>pattern=`_appender_getPatternByIndex 3`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_appender_getPatternByIndex()
{
  ${__LOG4SH_TRACE_CALL} _appender_getPatternByIndex \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _log4sh_getArrayElement "$__log4shAppenderPatterns" $1
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_parsePattern</function></funcdef>
#       <paramdef>string <parameter>pattern</parameter></paramdef>
#       <paramdef>string <parameter>priority</parameter></paramdef>
#       <paramdef>string <parameter>message</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Generate a logging message given a Pattern, priority, and message.
#   All dates will be represented as ISO 8601 dates (YYYY-MM-DD
#   HH:MM:SS).</para>
#   <para>Note: the '<code>%r</code>' character modifier does not work in the
#   Solaris <code>/bin/sh</code> shell</para>
#   <para>Example:
#     <blockquote>
#       <funcsynopsis>
#         <funcsynopsisinfo>_appender_parsePattern '%d %p - %m%n' INFO "message to log"</funcsynopsisinfo>
#       </funcsynopsis>
#     </blockquote>
#   </para>
# </entry>
# </s:function>
#*/
_appender_parsePattern()
{
  ${__LOG4SH_TRACE_CALL} _appender_parsePattern \
      $# -ne 3 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _app_pattern=$1
  _app_priority=$2
  _app_msg=$3

  _app_date=''
  _app_doEval=${LOG4SH_FALSE}
  _app_oldIFS=${IFS}

  # determine if various commands must be run
  IFS='%'; set -- x${_app_pattern}; IFS=${_app_oldIFS}
  if [ $# -gt 1 ]; then
    # run the date command??
    IFS='d'; set -- ${_app_pattern}x; IFS=${_app_oldIFS}
    [ $# -gt 1 ] && _app_date=`date '+%Y-%m-%d %H:%M:%S'`

    # run the eval command?
    IFS='X'; set -- ${_app_pattern}x; IFS=${_app_oldIFS}
    [ $# -gt 1 ] && _app_doEval=${LOG4SH_TRUE}
  fi

  # escape any '\' and '&' chars in the message
  _app_msg=`echo "${_app_msg}" |sed 's/\\\\/\\\\\\\\/g;s/&/\\\\&/g'`

  # deal with any newlines in the message
  _app_msg=`echo "${_app_msg}" |tr '\n' ''`

  # parse the pattern
  _app_pattern=`echo "${_app_pattern}" |sed \
    -e 's/%c/shell/g' \
    -e 's/%d{[^}]*}/%d/g' -e "s/%d/${_app_date}/g" \
    -e "s/%F/${__log4sh_filename}/g" \
    -e 's/%L//g' \
    -e 's/%n//g' \
    -e "s/%-*[0-9]*p/${_app_priority}/g" \
    -e "s/%-*[0-9]*r/${__log4sh_seconds}/g" \
    -e "s/%t/${__log4sh_threadName}/g" \
    -e 's/%x//g' \
    -e 's/%X{/$\{/g' \
    -e 's/%%m/%%%m/g' -e 's/%%/%/g' \
    -e "s%m${_app_msg}" |tr '' '\n'`
  if [ ${_app_doEval} -eq ${LOG4SH_FALSE} ]; then
    echo "${_app_pattern}"
  else
    eval "echo \"${_app_pattern}\""
  fi

  unset _app_date _app_doEval _app_msg _app_oldIFS _app_pattern _app_tag
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_getType</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Gets the Type of an Appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>type=`appender_getType myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_getType()
{
  ${__LOG4SH_TRACE_CALL} appender_getType \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _appender_getData "${__log4shAppenderTypes}" $1
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_setType</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>type</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Sets the Type of an Appender (e.g. FileAppender)</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_setType myAppender FileAppender</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_setType()
{
  ${__LOG4SH_TRACE_CALL} appender_setType \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  ast_appender=$1
  ast_type=$2

  _appender_setData __log4shAppenderTypes \
      ${ast_appender} "${ast_type}"
  # inheriting __log4sh_return from _appender_setData
  if [ $? -ne ${LOG4SH_TRUE} ]; then
    _log4sh_error "unable to set the 'type' for appender (${ast_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset ast_appender ast_type
  return ${__log4sh_return}
}

#/**
# <s:function group="Appender" modifier="private">
# <entry align="right">
#   <code>string</code>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_getTypeByIndex</function></funcdef>
#       <paramdef>integer <parameter>index</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Gets the Type of an Appender at the given array index</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>type=`_appender_getTypeByIndex 3`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_appender_getTypeByIndex()
{
  ${__LOG4SH_TRACE_CALL} _appender_getTypeByIndex \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _log4sh_getArrayElement "${__log4shAppenderTypes}" $1
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_cache</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Dynamically creates an appender function in memory that will fully
#   instantiate itself when it is called.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_appender_cache myAppender</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
#
# XXX This function must not set or change __log4sh_return. Calling functions
# rely on it not being altered.
#
_appender_cache()
{
  ${__LOG4SH_TRACE_CALL} _appender_cache \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _ac_appender=$1

  _ac_inc="${__log4sh_tmpDir}/${_ac_appender}${__LOG4SH_APPENDER_INCLUDE_EXT}"

  cat >"${_ac_inc}" <<EOF
${__LOG4SH_APPENDER_FUNC_PREFIX}${_ac_appender}_activateOptions()
{
  ${__LOG4SH_TRACE_CALL} ${__LOG4SH_APPENDER_FUNC_PREFIX}${_ac_appender}_activateOptions \\
      \$# -ne 0 || return ${LOG4SH_FALSE}

  _appender_activate ${_ac_appender}
}

${__LOG4SH_APPENDER_FUNC_PREFIX}${_ac_appender}_append() { :; }
EOF

  # source the new functions
  . "${_ac_inc}"

  unset _ac_appender _ac_inc
  # return value passed through
}

#/**
# <s:function group="Appender" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_activate</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Dynamically regenerates an appender function in memory that is fully
#     instantiated for a specific logging task.
#     </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_appender_activate myAppender</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_appender_activate()
{
  ${__LOG4SH_TRACE_CALL} _appender_activate \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _aa_appender=$1
  __log4sh_return=${LOG4SH_TRUE}
  ${__LOG4SH_TRACE} "_aa_appender='${_aa_appender}'"

  _aa_index=`_log4sh_findArrayElement "${__log4shAppenders}" ${_aa_appender}`
  if [ $? -ne ${LOG4SH_TRUE} ]; then
    _log4sh_error "unable to activate appender (${_aa_appender})"
    unset _aa_appender _aa_index
    return ${LOG4SH_ERROR}
  fi

  _aa_inc="${__log4sh_tmpDir}/${_aa_appender}${__LOG4SH_APPENDER_INCLUDE_EXT}"

  ### generate function for inclusion
  # TODO can we modularize this in the future?

  # send STDOUT to our include file
  exec 4>&1 >${_aa_inc}

  # header
  cat <<EOF
${__LOG4SH_APPENDER_FUNC_PREFIX}${_aa_appender}_append()
{
  ${__LOG4SH_TRACE_CALL} ${__LOG4SH_APPENDER_FUNC_PREFIX}${_aa_appender}_append \\
      \$# -ne 2 || return ${LOG4SH_FALSE}

  _la_level=\$1
  _la_message=\$2
EOF

  # determine the 'layout'
  _aa_layout=`_appender_getLayoutByIndex ${_aa_index}`
  ${__LOG4SH_TRACE} "_aa_layout='${_aa_layout}'"
  case ${_aa_layout} in
    ${__LOG4SH_LAYOUT_SIMPLE}|\
    ${__LOG4SH_LAYOUT_HTML})
      ${__LOG4SH_DEBUG} 'using simple/html layout'
      echo "  _la_layout=\"\${_la_level} - \${_la_message}\""
      ;;

    ${__LOG4SH_LAYOUT_PATTERN})
      ${__LOG4SH_DEBUG} 'using pattern layout'
      _aa_pattern=`_appender_getPatternByIndex ${_aa_index}`
      echo "  _la_layout=\`_appender_parsePattern '${_aa_pattern}' \${_la_level} \"\${_la_message}\"\`"
      ;;
  esac

  # what appender 'type' do we have? TODO check not missing
  _aa_type=`_appender_getTypeByIndex ${_aa_index}`
  ${__LOG4SH_TRACE} "_aa_type='${_aa_type}'"
  case ${_aa_type} in
    ${__LOG4SH_TYPE_CONSOLE})
      echo "  echo \"\${_la_layout}\""
      ;;

    ${__LOG4SH_TYPE_FILE}|\
    ${__LOG4SH_TYPE_ROLLING_FILE}|\
    ${__LOG4SH_TYPE_DAILY_ROLLING_FILE})
      _aa_file=`_appender_file_getFileByIndex ${_aa_index}`
      ${__LOG4SH_TRACE} "_aa_file='${_aa_file}'"
      if [ "${_aa_file}" = 'STDERR' ]; then
        echo "  echo \"\${_la_layout}\" >&2"
      elif [ "${_aa_file}" != "${__LOG4SH_NULL}" ]; then
        # do rotation
        case ${_aa_type} in
          ${__LOG4SH_TYPE_ROLLING_FILE})
            # check whether the max file size has been exceeded
            _aa_rotIndex=`appender_file_getMaxBackupIndex ${_aa_appender}`
            _aa_rotSize=`appender_file_getMaxFileSize ${_aa_appender}`
            cat <<EOF
  _la_rotSize=${_aa_rotSize}
  _la_size=\`wc -c '${_aa_file}' |awk '{print \$1}'\`
  if [ \${_la_size} -ge \${_la_rotSize} ]; then
    if [ ${_aa_rotIndex} -gt 0 ]; then
      # rotate the appender file(s)
      _la_rotIndex=`expr ${_aa_rotIndex} - 1`
      _la_rotFile="${_aa_file}.\${_la_rotIndex}"
      [ -f "\${_la_rotFile}" ] && rm -f "\${_la_rotFile}"
      while [ \${_la_rotIndex} -gt 0 ]; do
        _la_rotFileLast="\${_la_rotFile}"
        _la_rotIndex=\`expr \${_la_rotIndex} - 1\`
        _la_rotFile="${_aa_file}.\${_la_rotIndex}"
        [ -f "\${_la_rotFile}" ] && mv -f "\${_la_rotFile}" "\${_la_rotFileLast}"
      done
      mv -f '${_aa_file}' "\${_la_rotFile}"
    else
      # keep no backups; truncate the file
      cp /dev/null "${_aa_file}"
    fi
    unset _la_rotFile _la_rotFileLast _la_rotIndex
  fi
  unset _la_rotSize _la_size
EOF
            ;;
          ${__LOG4SH_TYPE_DAILY_ROLLING_FILE})
            ;;
        esac
        echo "  echo \"\${_la_layout}\" >>'${_aa_file}'"
      else
        # the file "${__LOG4SH_NULL}" is closed?? Why did we get here, and why
        # did I care when I wrote this bit of code?
        _log4sh_error "This code should never have been reached"
        __log4sh_return=${LOG4SH_ERROR}
        :
      fi

      unset _aa_file
      ;;

    ${__LOG4SH_TYPE_SMTP})
      _aa_smtpTo=`appender_smtp_getTo ${_aa_appender}`
      _aa_smtpSubject=`appender_smtp_getSubject ${_aa_appender}`

      cat <<EOF
  echo "\${_la_layout}" |\\
      ${__log4sh_alternative_mail} -s "${_aa_smtpSubject}" ${_aa_smtpTo}
EOF
      ;;

    ${__LOG4SH_TYPE_SYSLOG})
      cat <<EOF
  case "\${_la_level}" in
    ${__LOG4SH_LEVEL_TRACE_STR}) _la_tag='debug' ;;  # no 'trace' equivalent
    ${__LOG4SH_LEVEL_DEBUG_STR}) _la_tag='debug' ;;
    ${__LOG4SH_LEVEL_INFO_STR}) _la_tag='info' ;;
    ${__LOG4SH_LEVEL_WARN_STR}) _la_tag='warning' ;;  # 'warn' is deprecated
    ${__LOG4SH_LEVEL_ERROR_STR}) _la_tag='err' ;;     # 'error' is deprecated
    ${__LOG4SH_LEVEL_FATAL_STR}) _la_tag='alert' ;;
  esac
EOF

      _aa_facilityName=`appender_syslog_getFacility ${_aa_appender}`
      _aa_syslogHost=`appender_syslog_getHost ${_aa_appender}`
      _aa_hostname=`hostname |sed 's/^\([^.]*\)\..*/\1/'`

      # are we logging to a remote host?
      if [ -z "${_aa_syslogHost}" ]; then
        # no -- use logger
        cat <<EOF
  ( exec logger -p "${_aa_facilityName}.\${_la_tag}" \
      -t "${__log4sh_filename}[$$]" "\${_la_layout}" 2>/dev/null )
  unset _la_tag
EOF
      else
        # yes -- use netcat
        if [ -n "${__log4sh_alternative_nc:-}" ]; then
          case ${_aa_facilityName} in
            kern) _aa_facilityCode=0 ;;            # 0<<3
            user) _aa_facilityCode=8 ;;            # 1<<3
            mail) _aa_facilityCode=16 ;;           # 2<<3
            daemon) _aa_facilityCode=24 ;;         # 3<<3
            auth|security) _aa_facilityCode=32 ;;  # 4<<3
            syslog) _aa_facilityCode=40 ;;         # 5<<3
            lpr) _aa_facilityCode=48 ;;            # 6<<3
            news) _aa_facilityCode=56 ;;           # 7<<3
            uucp) _aa_facilityCode=64 ;;           # 8<<3
            cron) _aa_facilityCode=72 ;;           # 9<<3
            authpriv) _aa_facilityCode=80 ;;       # 10<<3
            ftp) _aa_facilityCode=88 ;;            # 11<<3
            local0) _aa_facilityCode=128 ;;        # 16<<3
            local1) _aa_facilityCode=136 ;;        # 17<<3
            local2) _aa_facilityCode=144 ;;        # 18<<3
            local3) _aa_facilityCode=152 ;;        # 19<<3
            local4) _aa_facilityCode=160 ;;        # 20<<3
            local5) _aa_facilityCode=168 ;;        # 21<<3
            local6) _aa_facilityCode=176 ;;        # 22<<3
            local7) _aa_facilityCode=184 ;;        # 23<<3
          esac

          cat <<EOF
  case \${_la_tag} in
    alert) _la_priority=1 ;;
    err|error) _la_priority=3 ;;
    warning|warn) _la_priority=4 ;;
    info) _la_priority=6 ;;
    debug) _la_priority=7 ;;
  esac
  _la_priority=\`expr ${_aa_facilityCode} + \${_la_priority}\`
  _la_date=\`date "+%b %d %H:%M:%S"\`
  _la_hostname='${_aa_hostname}'

  _la_syslogMsg="<\${_la_priority}>\${_la_date} \${_la_hostname} \${_la_layout}"

  # do RFC 3164 cleanups
  _la_date=\`echo \"\${_la_date}\" |sed 's/ 0\([0-9]\) /  \1 /'\`
  _la_syslogMsg=\`echo "\${_la_syslogMsg}" |cut -b1-1024\`

  ( echo "\${_la_syslogMsg}" |\
      exec ${__log4sh_alternative_nc} ${__log4sh_alternative_nc_opts} -w 1 -u \
          ${_aa_syslogHost} 514 )
  unset _la_tag _la_priority _la_date _la_hostname _la_syslogMsg
EOF
          unset _aa_facilityCode _aa_syslogHost _aa_hostname
        else
          # no netcat alternative set; doing nothing
          :
        fi
      fi
      unset _aa_facilityName
      ;;

    *)
      _log4sh_error "unrecognized appender type (${_aa_type})"
      __log4sh_return=${LOG4SH_ERROR}
      ;;
  esac

  # footer
  cat <<EOF
  unset _la_level _la_message _la_layout
}
EOF

  # override the activateOptions function as we don't need it anymore
  cat <<EOF
${__LOG4SH_APPENDER_FUNC_PREFIX}${_aa_appender}_activateOptions() { :; }
EOF

  # restore STDOUT
  exec 1>&4 4>&-

  # source the newly created function
  ${__LOG4SH_TRACE} 're-sourcing the newly created function'
  . "${_aa_inc}"
  __log4sh_return=$?

  unset _aa_appender _aa_inc _aa_layout _aa_pattern _aa_type
  return ${__log4sh_return}
}

#-----------------------------------------------------------------------------
# FileAppender
#

#/**
# <s:function group="FileAppender" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_appender_file_getFileByIndex</function></funcdef>
#       <paramdef>integer <parameter>index</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Get the filename of a FileAppender at the given array index</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_appender_file_getFileByIndex 3</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_appender_file_getFileByIndex()
{
  ${__LOG4SH_TRACE_CALL} _appender_file_getFileByIndex \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _log4sh_getArrayElement "${__log4shAppender_file_files}" $1
  # return value passed through
}

#/**
# <s:function group="FileAppender" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_file_getFile</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Get the filename of a FileAppender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_file_getFile myAppender</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_file_getFile()
{
  ${__LOG4SH_TRACE_CALL} appender_file_getFile \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _appender_getData "${__log4shAppender_file_files}" $1
  # return value passed through
}

#/**
# <s:function group="FileAppender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_file_setFile</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>filename</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Set the filename for a FileAppender (e.g. <filename>STDERR</filename> or
#     <filename>/var/log/log4sh.log</filename>).
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_file_setFile myAppender STDERR</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_file_setFile()
{
  ${__LOG4SH_TRACE_CALL} appender_file_setFile \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  afsf_appender=$1
  afsf_file=$2
  __log4sh_return=${LOG4SH_TRUE}
  ${__LOG4SH_TRACE} "afsf_appender='${afsf_appender}' afsf_file='${afsf_file}'"

  if [ -n "${afsf_appender}" -a -n "${afsf_file}" ]; then
    # set the file
    afsf_index=`_log4sh_findArrayElement "${__log4shAppenders}" ${afsf_appender}`
    if [ $? -eq ${LOG4SH_TRUE} ]; then
      __log4shAppender_file_files=`_log4sh_setArrayElement \
          "${__log4shAppender_file_files}" ${afsf_index} "${afsf_file}"`

      # create the file (if it isn't already)
      if [ ${__log4sh_return} -eq ${LOG4SH_TRUE} \
        -a ! "${afsf_file}" '=' "${__LOG4SH_NULL}" \
        -a ! "${afsf_file}" '=' 'STDERR' \
        -a ! -f "${afsf_file}" \
      ]; then
        touch "${afsf_file}" 2>/dev/null
        afsf_result=$?
        # determine success of touch command
        if [ ${afsf_result} -eq 1 ]; then
          appender_setLevel ${afsf_appender} ${__LOG4SH_LEVEL_CLOSED_STR}
          _log4sh_error "appender_file_setFile(): could not create file (${afsf_file}); closing appender"
          __log4sh_return=${LOG4SH_ERROR}
        fi
      fi
    else
      _log4sh_error 'appender_file_setFile(): missing appender and/or file'
      __log4sh_return=${LOG4SH_ERROR}
    fi

    # resource the appender
    _appender_cache ${afsf_appender}
    # inheriting __log4sh_return from _appender_cache
  fi

  unset afsf_appender afsf_file afsf_index afsf_result
  return ${__log4sh_return}
}

#/**
# <s:function group="FileAppender" modifier="public">
# <entry align="right">
#   <code>integer</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_file_getMaxBackupIndex</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Returns the value of the MaxBackupIndex option.</para>
#   <para><emphasis role="strong">Since:</emphasis> 1.3.7</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_file_getMaxBackupIndex myAppender</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_file_getMaxBackupIndex()
{
  ${__LOG4SH_TRACE_CALL} appender_file_getMaxBackupIndex \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _appender_getData "${__log4shAppender_rollingFile_maxBackupIndexes}" $1
  # return value passed through
}

#/**
# <s:function group="FileAppender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_file_setMaxBackupIndex</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>integer <parameter>index</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Set the maximum number of backup files to keep around.</para>
#   <para>
#     The <emphasis role="strong">MaxBackupIndex</emphasis> option determines
#     how many backup files are kept before the oldest is erased. This option
#     takes a positive integer value. If set to zero, then there will be no
#     backup files and the log file will be truncated when it reaches
#     <option>MaxFileSize</option>.
#   </para>
#   <para><emphasis role="strong">Since:</emphasis> 1.3.7</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_file_setMaxBackupIndex myAppender 3</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_file_setMaxBackupIndex()
{
  ${__LOG4SH_TRACE_CALL} appender_file_setMaxBackupIndex \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  afsmbi_appender=$1
  afsmbi_maxIndex=$2

  _appender_setData __log4shAppender_rollingFile_maxBackupIndexes \
      ${afsmbi_appender} "${afsmbi_maxIndex}"
  # inheriting __log4sh_return from _appender_setData
  if [ $? -ne ${LOG4SH_TRUE} ]; then
    _log4sh_error "unable to set the 'maxBackupIndex' for appender (${afsmbi_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset afsmbi_appender afsmbi_maxIndex
  return ${__log4sh_return}
}

#/**
# <s:function group="FileAppender" modifier="public">
# <entry align="right">
#   <code>integer</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_file_getMaxFileSize</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Get the maximum size that the output file is allowed to reach before
#     being rolled over to backup files.
#   </para>
#   <para><emphasis role="strong">Since:</emphasis> 1.3.7</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>maxSize=`appender_file_getMaxBackupSize myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_file_getMaxFileSize()
{
  ${__LOG4SH_TRACE_CALL} appender_file_getMaxFileSize \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _appender_getData "${__log4shAppender_rollingFile_maxFileSizes}" $1
  # return value passed through
}

#/**
# <s:function group="FileAppender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_file_setMaxFileSize</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>size</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Set the maximum size that the output file is allowed to reach before
#     being rolled over to backup files.
#   </para>
#   <para>
#     In configuration files, the <option>MaxFileSize</option> option takes an
#     long integer in the range 0 - 2^40. You can specify the value with the
#     suffixes "KiB", "MiB" or "GiB" so that the integer is interpreted being
#     expressed respectively in kilobytes, megabytes or gigabytes. For example,
#     the value "10KiB" will be interpreted as 10240.
#   </para>
#   <para><emphasis role="strong">Since:</emphasis> 1.3.7</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_file_setMaxBackupSize myAppender 10KiB</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_file_setMaxFileSize()
{
  ${__LOG4SH_TRACE_CALL} appender_file_setMaxFileSize \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_ERROR}

  afsmfs_appender=$1
  afsmfs_size=$2
  __log4sh_return=${LOG4SH_TRUE}

  # split the file size into parts
  afsmfs_value=`expr ${afsmfs_size} : '\([0-9]*\)'`
  afsmfs_unit=`expr ${afsmfs_size} : '[0-9]* *\([A-Za-z]\{1,3\}\)'`

  # determine multiplier
  if [ ${__log4sh_wa_strictBehavior} -eq ${LOG4SH_TRUE} ]; then
    case "${afsmfs_unit}" in
      KB) afsmfs_unit='KiB' ;;
      MB) afsmfs_unit='MiB' ;;
      GB) afsmfs_unit='GiB' ;;
      TB) afsmfs_unit='TiB' ;;
    esac
  fi
  case "${afsmfs_unit}" in
    B) afsmfs_mul=1 ;;
    KB) afsmfs_mul=1000 ;;
    KiB) afsmfs_mul=1024 ;;
    MB) afsmfs_mul=1000000 ;;
    MiB) afsmfs_mul=1048576 ;;
    GB) afsmfs_mul=1000000000 ;;
    GiB) afsmfs_mul=1073741824 ;;
    TB) afsmfs_mul=1000000000000 ;;
    TiB) afsmfs_mul=1099511627776 ;;
    '')
      _log4sh_warn 'missing file size unit; assuming bytes'
      afsmfs_mul=1
      ;;
    *)
      _log4sh_error "unrecognized file size unit '${afsmfs_unit}'"
      __log4sh_return=${LOG4SH_ERROR}
      ;;
  esac

  # calculate maximum file size
  if [ ${__log4sh_return} -eq ${LOG4SH_TRUE} ]; then
    afsmfs_maxFileSize=`(expr ${afsmfs_value} \* ${afsmfs_mul} 2>&1)`
    if [ $? -gt 0 ]; then
      _log4sh_error "problem calculating maximum file size: '${afsmfs_maxFileSize}'"
      __log4sh_return=${LOG4SH_FALSE}
    fi
  fi

  # store the maximum file size
  if [ ${__log4sh_return} -eq ${LOG4SH_TRUE} ]; then
    _appender_setData __log4shAppender_rollingFile_maxFileSizes \
        ${afsmfs_appender} "${afsmfs_maxFileSize}"
    # inheriting __log4sh_return from _appender_setData
    if [ $? -ne ${LOG4SH_TRUE} ]; then
      _log4sh_error "unable to set the 'maxFileSize' for appender (${afsmfs_appender})"
      __log4sh_return=${LOG4SH_ERROR}
    fi
  fi

  unset afsmfs_appender afsmfs_size
  unset afsmfs_value afsmfs_unit afsmfs_mul afsmfs_maxFileSize
  return ${__log4sh_return}
}

#-----------------------------------------------------------------------------
# SMTPAppender
#

#/**
# <s:function group="SMTPAppender" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_smtp_getTo</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Get the to address for the given appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>email=`appender_smtp_getTo myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_smtp_getTo()
{
  ${__LOG4SH_TRACE_CALL} appender_smtp_getTo \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  asgt_to=`_appender_getData "${__log4shAppender_smtp_tos}" $1`
  __log4sh_return=$?

  [ "${asgt_to}" = "${__LOG4SH_NULL}" ] && asgt_to=''
  echo "${asgt_to}"

  unset asgt_to
  return ${__log4sh_return}
}

#/**
# <s:function group="SMTPAppender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_smtp_setTo</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>email</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Set the to address for the given appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_smtp_setTo myAppender user@example.com</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_smtp_setTo()
{
  ${__LOG4SH_TRACE_CALL} appender_smtp_setTo \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  asst_appender=$1
  asst_email=$2

  _appender_setData __log4shAppender_smtp_tos \
      ${asst_appender} "${asst_email}"
  # inheriting __log4sh_return from _appender_setData
  if [ $? -ne ${LOG4SH_TRUE} ]; then
    _log4sh_error "unable to set the 'to' for appender (${asst_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset asst_appender asst_email
  return ${__log4sh_return}
}

#/**
# <s:function group="SMTPAppender" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_smtp_getSubject</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Get the email subject for the given appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>subject=`appender_smtp_getSubject myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_smtp_getSubject()
{
  ${__LOG4SH_TRACE_CALL} appender_smtp_getSubject \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  asgs_subject=`_appender_getData "${__log4shAppender_smtp_subjects}" $1`
  __log4sh_return=$?

  [ "${asgs_subject}" = "${__LOG4SH_NULL}" ] && asgs_subject=''
  echo "${asgs_subject}"

  unset asgs_appender asgs_subject
  return ${__log4sh_return}
}

#/**
# <s:function group="SMTPAppender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_smtp_setSubject</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>subject</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Sets the email subject for an SMTP appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_smtp_setSubject myAppender "This is a test"</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_smtp_setSubject()
{
  ${__LOG4SH_TRACE_CALL} appender_smtp_setSubject \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  asss_appender=$1
  asss_subject=$2

  _appender_setData __log4shAppender_smtp_subjects \
      ${asss_appender} "${asss_subject}"
  # inheriting __log4sh_return from _appender_setData
  if [ $? -ne ${LOG4SH_TRUE} ]; then
    _log4sh_error "unable to set the 'subject' for appender (${asss_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset asss_appender asss_subject
  return ${__log4sh_return}
}

#-----------------------------------------------------------------------------
# SyslogAppender
#

#/**
# <s:function group="SyslogAppender" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef>
#         <function>_appender_syslog_getFacilityByIndex</function>
#       </funcdef>
#       <paramdef>integer <parameter>index</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Get the syslog facility of the specified appender by index</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>
#       facility=`_appender_syslog_getFacilityByIndex 3`
#     </funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_appender_syslog_getFacilityByIndex()
{
  ${__LOG4SH_TRACE_CALL} _appender_syslog_getFacilityByIndex \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _log4sh_getArrayElement "$__log4shAppender_syslog_facilities" $1
  # return value passed through
}

#/**
# <s:function group="SyslogAppender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_syslog_getFacility</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Get the syslog facility for the given appender.
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>facility=`appender_syslog_getFacility myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_syslog_getFacility()
{
  ${__LOG4SH_TRACE_CALL} appender_syslog_getFacility \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _appender_getData "${__log4shAppender_syslog_facilities}" $1
  # return value passed through
}

#/**
# <s:function group="SyslogAppender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_syslog_setFacility</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>facility</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Set the syslog facility for the given appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_syslog_setFacility myAppender local4`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_syslog_setFacility()
{
  ${__LOG4SH_TRACE_CALL} appender_syslog_setFacility \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  assf_appender=$1
  assf_facility=$2

  # check for valid facility
  echo "${__LOG4SH_TYPE_SYSLOG_FACILITY_NAMES}" |\
      grep " ${assf_facility} " >/dev/null
  if [ $? -ne 0 ]; then
    # the facility is not valid
    _log4sh_warn "[${assf_facility}] is an unknown syslog facility. Defaulting to [user]."
    assf_facility='user'
  fi

  # set appender facility
  _appender_setData __log4shAppender_syslog_facilities \
      ${assf_appender} "${assf_facility}"
  # inheriting __log4sh_return from _appender_setData
  if [ $? -ne ${LOG4SH_TRUE} ]; then
    _log4sh_error "unable to set syslog facility for appender (${assf_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset assf_appender assf_facility
  return ${__log4sh_return}
}

#/**
# <s:function group="SyslogAppender" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_syslog_getHost</function></funcdef>
#       <paramdef>integer <parameter>index</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Get the syslog host of the specified appender.</para>
#   <para><emphasis role="strong">Since:</emphasis> 1.3.7</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>host=`appender_syslog_getHost myAppender`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
appender_syslog_getHost()
{
  ${__LOG4SH_TRACE_CALL} appender_syslog_getHost \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  asgh_host=`_appender_getData "${__log4shAppender_syslog_hosts}" $1`
  __log4sh_return=$?

  [ "${asgh_host}" = "${__LOG4SH_NULL}" ] && asgh_host=''
  echo "${asgh_host}"

  unset asgh_appender asgh_host
  return ${__log4sh_return}
}

#/**
# <s:function group="SyslogAppender" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>appender_syslog_setHost</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#       <paramdef>string <parameter>host</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Set the syslog host for the given appender. Requires that the 'nc'
#   command alternative has been previously set with the
#   log4sh_setAlternative() function.</para>
#   <para><emphasis role="strong">Since:</emphasis> 1.3.7</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>appender_syslog_setHost myAppender localhost</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
#
# The BSD syslog Protocol
#   http://www.ietf.org/rfc/rfc3164.txt
#
appender_syslog_setHost()
{
  ${__LOG4SH_TRACE_CALL} appender_syslog_setHost \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  assh_appender=$1
  assh_host=$2

  [ -z "${__log4sh_alternative_nc:-}" ] \
      && _log4sh_warn 'the nc (netcat) command alternative is required for remote syslog logging. see log4sh_setAlternative().'

  _appender_setData __log4shAppender_syslog_hosts \
      ${assh_appender} "${assh_host}"
  # inheriting __log4sh_return from _appender_setData
  if [ $? -ne ${LOG4SH_TRUE} ]; then
    _log4sh_error "unable to set the 'syslog host' for appender (${assh_appender})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset assh_appender assh_host
  return ${__log4sh_return}
}

#=============================================================================
# Level
#

#/**
# <s:function group="Level" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_level_toLevel</function></funcdef>
#       <paramdef>integer <parameter>val</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Converts an internally used level integer into its external level
#   equivalent</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>level=`logger_level_toLevel 3`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
# TODO use arrays instead of case statement ??
logger_level_toLevel()
{
  ${__LOG4SH_TRACE_CALL} logger_level_toLevel \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  ltl_val=$1

  ltl_level=''
  __log4sh_return=${LOG4SH_TRUE}

  case ${ltl_val} in
    ${__LOG4SH_LEVEL_TRACE}) ltl_level=${__LOG4SH_LEVEL_TRACE_STR} ;;
    ${__LOG4SH_LEVEL_DEBUG}) ltl_level=${__LOG4SH_LEVEL_DEBUG_STR} ;;
    ${__LOG4SH_LEVEL_INFO}) ltl_level=${__LOG4SH_LEVEL_INFO_STR} ;;
    ${__LOG4SH_LEVEL_WARN}) ltl_level=${__LOG4SH_LEVEL_WARN_STR} ;;
    ${__LOG4SH_LEVEL_ERROR}) ltl_level=${__LOG4SH_LEVEL_ERROR_STR} ;;
    ${__LOG4SH_LEVEL_FATAL}) ltl_level=${__LOG4SH_LEVEL_FATAL_STR} ;;
    ${__LOG4SH_LEVEL_OFF}) ltl_level=${__LOG4SH_LEVEL_OFF_STR} ;;
    ${__LOG4SH_LEVEL_CLOSED}) ltl_level=${__LOG4SH_LEVEL_CLOSED_STR} ;;
    *) __log4sh_return=${LOG4SH_FALSE} ;;
  esac

  echo ${ltl_level}
  unset ltl_val ltl_level
  return ${__log4sh_return}
}

#/**
# <s:function group="Level" modifier="public">
# <entry align="right">
#   <code>integer</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_level_toInt</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Converts an externally used level tag into its integer
#   equivalent</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>levelInt=`logger_level_toInt WARN`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_level_toInt()
{
  ${__LOG4SH_TRACE_CALL} logger_level_toInt \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  lti_level=$1

  lti_int=0
  __log4sh_return=${LOG4SH_TRUE}

  case ${lti_level} in
    ${__LOG4SH_LEVEL_TRACE_STR}) lti_int=${__LOG4SH_LEVEL_TRACE} ;;
    ${__LOG4SH_LEVEL_DEBUG_STR}) lti_int=${__LOG4SH_LEVEL_DEBUG} ;;
    ${__LOG4SH_LEVEL_INFO_STR}) lti_int=${__LOG4SH_LEVEL_INFO} ;;
    ${__LOG4SH_LEVEL_WARN_STR}) lti_int=${__LOG4SH_LEVEL_WARN} ;;
    ${__LOG4SH_LEVEL_ERROR_STR}) lti_int=${__LOG4SH_LEVEL_ERROR} ;;
    ${__LOG4SH_LEVEL_FATAL_STR}) lti_int=${__LOG4SH_LEVEL_FATAL} ;;
    ${__LOG4SH_LEVEL_OFF_STR}) lti_int=${__LOG4SH_LEVEL_OFF} ;;
    ${__LOG4SH_LEVEL_CLOSED_STR}) lti_int=${__LOG4SH_LEVEL_CLOSED} ;;
    *) __log4sh_return=${LOG4SH_FALSE} ;;
  esac

  echo ${lti_int}
  unset lti_int lti_level
  return ${__log4sh_return}
}

#=============================================================================
# Logger
#

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_addAppender</function></funcdef>
#       <paramdef>string <parameter>appender</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Add and initialize a new appender</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_addAppender $appender</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_addAppender()
{
  ${__LOG4SH_TRACE_CALL} logger_addAppender \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  laa_appender=$1

  # FAQ should we be using setter functions here?? for performance, no.
  __log4shAppenders=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppenders}" ${laa_appender}`
  __log4shAppenderCount=`expr ${__log4shAppenderCount} + 1`
  __log4shAppenderCounts="${__log4shAppenderCounts} ${__log4shAppenderCount}"
  __log4shAppenderLayouts=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "$__log4shAppenderLayouts" "${__LOG4SH_LAYOUT_SIMPLE}"`
  __log4shAppenderLevels=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppenderLevels}" "${__LOG4SH_NULL}"`
  __log4shAppenderPatterns=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppenderPatterns}" "${__LOG4SH_PATTERN_DEFAULT}"`
  __log4shAppenderTypes=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppenderTypes}" ${__LOG4SH_TYPE_CONSOLE}`
  __log4shAppender_file_files=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppender_file_files}" ${__LOG4SH_NULL}`
  __log4shAppender_rollingFile_maxBackupIndexes=`_log4sh_join \
      "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppender_rollingFile_maxBackupIndexes}" \
      ${__LOG4SH_TYPE_ROLLING_FILE_MAX_BACKUP_INDEX}`
  __log4shAppender_rollingFile_maxFileSizes=`_log4sh_join \
      "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppender_rollingFile_maxFileSizes}" \
      ${__LOG4SH_TYPE_ROLLING_FILE_MAX_FILE_SIZE}`
  __log4shAppender_smtp_tos=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppender_smtp_tos}" ${__LOG4SH_NULL}`
  __log4shAppender_smtp_subjects=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppender_smtp_subjects}" ${__LOG4SH_NULL}`
  __log4shAppender_syslog_facilities=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppender_syslog_facilities}" ${__LOG4SH_TYPE_SYSLOG_FACILITY}`
  __log4shAppender_syslog_hosts=`_log4sh_join "${__LOG4SH_IFS_ARRAY}" \
      "${__log4shAppender_syslog_hosts}" "${__LOG4SH_NULL}"`

  _appender_cache ${laa_appender}
  __log4sh_return=$?

  unset laa_appender
  return ${__log4sh_return}
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_getFilename</function></funcdef>
#       <void />
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Get the filename that would be shown when the '%F' conversion character
#     is used in a PatternLayout.
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>filename=`logger_getFilename`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_getFilename()
{
  ${__LOG4SH_TRACE_CALL} logger_getFilename \
      $# -ne 0 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  echo "${__log4sh_filename}"
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_setFilename</function></funcdef>
#       <paramdef>string <parameter>filename</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Set the filename to be shown when the '%F' conversion character is
#   used in a PatternLayout.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_setFilename 'myScript.sh'</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_setFilename()
{
  ${__LOG4SH_TRACE_CALL} logger_setFilename \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  __log4sh_filename=$1
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_getLevel</function></funcdef>
#       <void />
#     </funcprototype>
#   </funcsynopsis>
#   <para>Get the global default logging level (e.g. DEBUG).</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>level=`logger_getLevel`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_getLevel()
{
  ${__LOG4SH_TRACE_CALL} logger_getLevel \
      $# -ne 0 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  logger_level_toLevel ${__log4shLevel}
  # return value passed through
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_setLevel</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Sets the global default logging level (e.g. DEBUG).</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_setLevel INFO</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_setLevel()
{
  ${__LOG4SH_TRACE_CALL} logger_setLevel \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  lsl_level=$1
  __log4sh_return=${LOG4SH_TRUE}

  lsl_int=`logger_level_toInt ${lsl_level}`
  if [ $? -eq ${LOG4SH_TRUE} ]; then
    __log4shLevel=${lsl_int}
  else
    _log4sh_error "attempt to set invalid log level '${lsl_level}'"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset lsl_int lsl_level
  return ${__log4sh_return}
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>log</function></funcdef>
#       <paramdef>string <parameter>level</parameter></paramdef>
#       <paramdef>string[] <parameter>message(s)</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>The base logging command that logs a message to all defined
#     appenders</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>log DEBUG 'This is a test message'</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
log()
{
  ${__LOG4SH_TRACE_CALL} log \
      $# -lt 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  l_level=$1
  shift
  # if no message was passed, read it from STDIN
  [ $# -ne 0 ] && l_msg="$@" || l_msg=`cat`

  __log4sh_return=${LOG4SH_TRUE}
  l_levelInt=`logger_level_toInt ${l_level}`
  if [ $? -eq ${LOG4SH_TRUE} ]; then
    # update seconds elapsed
    _log4sh_updateSeconds

    l_oldIFS=${IFS} IFS=${__LOG4SH_IFS_DEFAULT}
    for l_appenderIndex in ${__log4shAppenderCounts}; do
      ${__LOG4SH_TRACE} "l_appenderIndex='${l_appenderIndex}'"
      # determine appender level
      l_appenderLevel=`_appender_getLevelByIndex ${l_appenderIndex}`
      if [ "${l_appenderLevel}" = "${__LOG4SH_NULL}" ]; then
        # continue if requested is level less than general level
        [ ! ${__log4shLevel} -le ${l_levelInt} ] && continue
      else
        l_appenderLevelInt=`logger_level_toInt ${l_appenderLevel}`
        # continue if requested level is less than specific appender level
        ${__LOG4SH_TRACE} "l_levelInt='${l_levelInt}' l_appenderLevelInt='${l_appenderLevelInt}'"
        [ ! ${l_appenderLevelInt} -le ${l_levelInt} ] && continue
      fi

      # execute dynamic appender function
      l_appenderName=`_log4sh_getArrayElement \
          "${__log4shAppenders}" ${l_appenderIndex}`
      ${__LOG4SH_APPENDER_FUNC_PREFIX}${l_appenderName}_append \
          ${l_level} "${l_msg}"
    done
    IFS=${l_oldIFS}
  else
    _log4sh_error "invalid logging level requested (${l_level})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset l_msg l_oldIFS l_level l_levelInt
  unset l_appenderIndex l_appenderLevel l_appenderLevelInt l_appenderName
  return ${__log4sh_return}
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_trace</function></funcdef>
#       <paramdef>string[] <parameter>message</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is a helper function for logging a message at the TRACE
#     priority</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_trace 'This is a trace message'</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_trace()
{
  log ${__LOG4SH_LEVEL_TRACE_STR} "$@"
  # return value passed through
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_debug</function></funcdef>
#       <paramdef>string[] <parameter>message</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is a helper function for logging a message at the DEBUG
#     priority</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_debug 'This is a debug message'</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_debug()
{
  log ${__LOG4SH_LEVEL_DEBUG_STR} "$@"
  # return value passed through
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_info</function></funcdef>
#       <paramdef>string[] <parameter>message</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is a helper function for logging a message at the INFO
#     priority</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_info 'This is a info message'</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_info()
{
  log ${__LOG4SH_LEVEL_INFO_STR} "$@"
  # return value passed through
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_warn</function></funcdef>
#       <paramdef>string[] <parameter>message</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     This is a helper function for logging a message at the WARN priority
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_warn 'This is a warn message'</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_warn()
{
  log ${__LOG4SH_LEVEL_WARN_STR} "$@"
  # return value passed through
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_error</function></funcdef>
#       <paramdef>string[] <parameter>message</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     This is a helper function for logging a message at the ERROR priority
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_error 'This is a error message'</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_error()
{
  log ${__LOG4SH_LEVEL_ERROR_STR} "$@"
  # return value passed through
}

#/**
# <s:function group="Logger" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_fatal</function></funcdef>
#       <paramdef>string[] <parameter>message</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is a helper function for logging a message at the FATAL
#     priority</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_fatal 'This is a fatal message'</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_fatal()
{
  log ${__LOG4SH_LEVEL_FATAL_STR} "$@"
  # return value passed through
}

#==============================================================================
# Property
#

#/**
# <s:function group="Property" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_getPropPrefix</function></funcdef>
#       <paramdef>string <parameter>property</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Takes a string (eg. "log4sh.appender.stderr.File") and returns the
#   prefix of it (everything before the first '.' char). Normally used in
#   parsing the log4sh configuration file.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>prefix=`_log4sh_getPropPrefix property"`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_getPropPrefix()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_getPropPrefix \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lgpp_oldIFS=${IFS}
  IFS='.'; set -- $1; IFS=${_lgpp_oldIFS}

  echo $1
  unset _lgpp_oldIFS
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Property" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_stripPropPrefix</function></funcdef>
#       <paramdef>string <parameter>property</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Strips the prefix off a property configuration command and returns
#   the string. E.g. "log4sh.appender.stderr.File" becomes
#   "appender.stderr.File".</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>newProperty=`_log4sh_stripPropPrefix property`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_stripPropPrefix()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_stripPropPrefix \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  expr "$1" : '[^.]*\.\(.*\)'
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Property" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_propAlternative</function></funcdef>
#       <paramdef>string <parameter>property</parameter></paramdef>
#       <paramdef>string <parameter>value</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Configures log4sh to use an alternative command.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_propAlternative property value</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_propAlternative()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_propAlternative \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lpa_key=$1
  _lpa_value=$2

  # strip the leading 'alternative.'
  _lpa_alternative=`_log4sh_stripPropPrefix ${_lpa_key}`

  # set the alternative
  log4sh_setAlternative ${_lpa_alternative} "${_lpa_value}"
  __log4sh_return=$?

  unset _lpa_key _lpa_value _lpa_alternative
  return ${__log4sh_return}
}

#/**
# <s:function group="Property" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_propAppender</function></funcdef>
#       <paramdef>string <parameter>property</parameter></paramdef>
#       <paramdef>string <parameter>value</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Configures log4sh using an appender property configuration
#   statement</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_propAppender property value</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_propAppender()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_propAppender \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lpa_key=$1
  _lpa_value=$2

  _lpa_appender=''

  # strip the leading 'appender' keyword prefix
  _lpa_key=`_log4sh_stripPropPrefix ${_lpa_key}`

  # handle appender definitions
  if [ "${_lpa_key}" '=' "`expr \"${_lpa_key}\" : '\([^.]*\)'`" ]; then
    _lpa_appender="${_lpa_key}"
  else
    _lpa_appender=`_log4sh_getPropPrefix ${_lpa_key}`
  fi

  # does the appender exist?
  appender_exists ${_lpa_appender}
  if [ $? -eq ${LOG4SH_FALSE} ]; then
    _log4sh_error "attempt to configure the non-existant appender (${_lpa_appender})"
    unset _lpa_appender _lpa_key _lpa_value
    return ${LOG4SH_ERROR}
  fi

  # handle the appender type
  if [ "${_lpa_appender}" = "${_lpa_key}" ]; then
    case ${_lpa_value} in
      ${__LOG4SH_TYPE_CONSOLE})
        appender_setType ${_lpa_appender} ${_lpa_value} ;;
      ${__LOG4SH_TYPE_FILE})
        appender_setType ${_lpa_appender} ${_lpa_value} ;;
      ${__LOG4SH_TYPE_DAILY_ROLLING_FILE})
        appender_setType ${_lpa_appender} ${_lpa_value} ;;
      ${__LOG4SH_TYPE_ROLLING_FILE})
        appender_setType ${_lpa_appender} ${_lpa_value} ;;
      ${__LOG4SH_TYPE_SMTP})
        appender_setType ${_lpa_appender} ${_lpa_value} ;;
      ${__LOG4SH_TYPE_SYSLOG})
        appender_setType ${_lpa_appender} ${_lpa_value} ;;
      *)
        _log4sh_error "appender type ($_lpa_value) unrecognized"
        __log4sh_return=${LOG4SH_ERROR}
        ;;
    esac
    unset _lpa_appender _lpa_key _lpa_value
    # expecting __log4sh_return to be implicitly set in function calls
    return ${__log4sh_return}
  fi

  # handle appender values and methods
  _lpa_key=`_log4sh_stripPropPrefix $_lpa_key`
  if [ "$_lpa_key" '=' "`expr \"${_lpa_key}\" : '\([^.]*\)'`" ]; then
    case $_lpa_key in
      # General
      Threshold) appender_setLevel $_lpa_appender "$_lpa_value" ;;
      layout) appender_setLayout $_lpa_appender "$_lpa_value" ;;

      # FileAppender
      DatePattern) ;;  # unsupported
      File)
        _lpa_value=`eval echo "${_lpa_value}"`
        appender_file_setFile ${_lpa_appender} "${_lpa_value}"
        ;;
      MaxBackupIndex)
        appender_file_setMaxBackupIndex ${_lpa_appender} "${_lpa_value}" ;;
      MaxFileSize)
        appender_file_setMaxFileSize ${_lpa_appender} "${_lpa_value}" ;;

      # SMTPAppender
      To) appender_smtp_setTo ${_lpa_appender} "${_lpa_value}" ;;
      Subject) appender_smtp_setSubject ${_lpa_appender} "${_lpa_value}" ;;

      # SyslogAppender
      SyslogHost) appender_syslog_setHost ${_lpa_appender} "${_lpa_value}" ;;
      Facility) appender_syslog_setFacility ${_lpa_appender} "${_lpa_value}" ;;

      # catch unrecognized
      *)
        _log4sh_error "appender value/method ($_lpa_key) unrecognized"
        __log4sh_return=${LOG4SH_ERROR}
        ;;
    esac
    unset _lpa_appender _lpa_key _lpa_value
    # expecting __log4sh_return to be implicitly set in function calls
    return ${__log4sh_return}
  fi

  # handle appender layout values and methods
  _lpa_key=`_log4sh_stripPropPrefix $_lpa_key`
  case $_lpa_key in
    ConversionPattern) appender_setPattern $_lpa_appender "$_lpa_value" ;;
    *)
      _log4sh_error "layout value/method ($_lpa_key) unrecognized"
      __log4sh_return=${LOG4SH_ERROR}
      ;;
  esac
  unset _lpa_appender _lpa_key _lpa_value
  # expecting __log4sh_return to be implicitly set in function calls
  return ${__log4sh_return}
}

#/**
# <s:function group="Property" modifier="private">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_propLogger</function></funcdef>
#       <paramdef>string <parameter>property</parameter></paramdef>
#       <paramdef>string <parameter>value</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>(future) Configures log4sh with a <code>logger</code> configuration
#   statement. Sample output: "logger: property value".</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>result=`_log4sh_propLogger $property $value`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_propLogger()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_propLogger \
      $# -ne 2 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lpl_property=$1
  _lpl_value=$2
  __log4sh_return=${LOG4SH_TRUE}

  _lpl_stripped=`_log4sh_stripPropPrefix ${_lpl_property}`
  if [ $? -eq ${LOG4SH_TRUE} ]; then
    echo "logger: ${_lpl_stripped} ${_lpl_value}"
  else
    echo ''
    _log4sh_error "problem stripping prefix from property (${_lpl_property})"
    __log4sh_return=${LOG4SH_ERROR}
  fi

  unset _lpl_property _lpl_value _lpl_stripped
  return ${__log4sh_return}
}

#/**
# <s:function group="Property" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_propRootLogger</function></funcdef>
#       <paramdef>string <parameter>rootLogger</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>Configures log4sh with a <code>rootLogger</code> configuration
#   statement. It expects a comma separated string similar to the
#   following:</para>
#   <para><code>log4sh.rootLogger=ERROR, stderr, R</code></para>
#   <para>The first option is the default logging level to set for all of the
#   following appenders that will be created, and all following options are the
#   names of appenders to create. The appender names must be unique.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_propRootLogger $value</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_propRootLogger()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_propRootLogger \
      $# -eq 0 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lprl_rootLogger=`echo "$@" |sed 's/ *, */,/g'`
  __log4sh_return=${LOG4SH_TRUE}

  _lprl_count=`echo "${_lprl_rootLogger}" |sed 's/,/ /g' |wc -w`
  _lprl_index=1
  while [ ${_lprl_index} -le ${_lprl_count} ]; do
    _lprl_operand=`echo "${_lprl_rootLogger}" |cut -d, -f${_lprl_index}`
    if [ ${_lprl_index} -eq 1 ]; then
      logger_setLevel "${_lprl_operand}"
    else
      appender_exists "${_lprl_operand}"
      if [ $? -eq ${LOG4SH_FALSE} ]; then
        logger_addAppender "${_lprl_operand}"
      else
        _log4sh_error "attempt to add already existing appender of name (${_lprl_operand})"
        __log4sh_return=${LOG4SH_ERROR}
        break
      fi
    fi
    _lprl_index=`expr ${_lprl_index} + 1`
  done

  unset _lprl_count _lprl_index _lprl_operand _lprl_rootLogger
  return ${__log4sh_return}
}

#/**
# <s:function group="Property" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>log4sh_doConfigure</function></funcdef>
#       <paramdef>string <parameter>configFileName</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Read configuration from a file. <emphasis role="strong">The existing
#     configuration is not cleared or reset.</emphasis> If you require a
#     different behavior, then call the <code>log4sh_resetConfiguration</code>
#     before calling <code>log4sh_doConfigure</code>.
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>log4sh_doConfigure myconfig.properties</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
log4sh_doConfigure()
{
  ${__LOG4SH_TRACE_CALL} log4sh_doConfigure \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  # prepare the environment for configuration
  log4sh_resetConfiguration

  ldc_file=$1

  # strip the config prefix and dump output to a temporary file
  ldc_tmpFile="${__log4sh_tmpDir}/properties"
  ${__LOG4SH_TRACE} "__LOG4SH_CONFIG_PREFIX='${__LOG4SH_CONFIG_PREFIX}'"
  grep "^${__LOG4SH_CONFIG_PREFIX}\." "${ldc_file}" >"${ldc_tmpFile}"

  # read the file in. using a temporary file and a file descriptor here instead
  # of piping the file into the 'while read' because the pipe causes a fork
  # under some shells which makes it impossible to get the variables passed
  # back to the parent script.
  exec 3<&0 <"${ldc_tmpFile}"
  while read ldc_line; do
    ldc_key=`expr "${ldc_line}" : '\([^= ]*\) *=.*'`
    ldc_value=`expr "${ldc_line}" : '[^= ]* *= *\(.*\)'`

    # strip the leading 'log4sh.'
    ldc_key=`_log4sh_stripPropPrefix ${ldc_key}`
    ldc_keyword=`_log4sh_getPropPrefix ${ldc_key}`
    case ${ldc_keyword} in
      alternative) _log4sh_propAlternative ${ldc_key} "${ldc_value}" ;;
      appender) _log4sh_propAppender ${ldc_key} "${ldc_value}" ;;
      logger) _log4sh_propLogger ${ldc_key} "${ldc_value}" ;;
      rootLogger) _log4sh_propRootLogger "${ldc_value}" ;;
      *) _log4sh_error "unrecognized properties keyword (${ldc_keyword})" ;;
    esac
  done
  exec 0<&3 3<&-

  # remove the temporary file
  rm -f "${ldc_tmpFile}"

  # activate all of the appenders
  for ldc_appender in ${__log4shAppenders}; do
    ${__LOG4SH_APPENDER_FUNC_PREFIX}${ldc_appender}_activateOptions
  done

  unset ldc_appender ldc_file ldc_tmpFile ldc_line ldc_key ldc_keyword
  unset ldc_value
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Property" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>log4sh_resetConfiguration</function></funcdef>
#       <void />
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     This function completely resets the log4sh configuration to have no
#     appenders with a global logging level of ERROR.
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>log4sh_resetConfiguration</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
log4sh_resetConfiguration()
{
  ${__LOG4SH_TRACE_CALL} log4sh_resetConfiguration \
      $# -ne 0 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  __log4shAppenders=''
  __log4shAppenderCount=0
  __log4shAppenderCounts=''
  __log4shAppenderLayouts=''
  __log4shAppenderLevels=''
  __log4shAppenderPatterns=''
  __log4shAppenderTypes=''
  __log4shAppender_file_files=''
  __log4shAppender_rollingFile_maxBackupIndexes=''
  __log4shAppender_rollingFile_maxFileSizes=''
  __log4shAppender_smtp_tos=''
  __log4shAppender_smtp_subjects=''
  __log4shAppender_syslog_facilities=''
  __log4shAppender_syslog_hosts=''

  logger_setLevel ERROR
  return ${LOG4SH_TRUE}
}

#==============================================================================
# Thread
#

#/**
# <s:function group="Thread" modifier="public">
# <entry align="right">
#   <code>string</code>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_getThreadName</function></funcdef>
#       <void />
#     </funcprototype>
#   </funcsynopsis>
#   <para>Gets the current thread name.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>threadName=`logger_getThreadName`</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_getThreadName()
{
  ${__LOG4SH_TRACE_CALL} logger_getThreadName \
      $# -ne 0 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  echo ${__log4sh_threadName}
  return ${LOG4SH_TRUE}
}

#/**
# <s:function group="Thread" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>/boolean
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>logger_setThreadName</function></funcdef>
#       <paramdef>string <parameter>threadName</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>
#     Sets the thread name (e.g. the name of the script). This thread name can
#     be used with the '%t' conversion character within a
#     <option>PatternLayout</option>.
#   </para>
#   <funcsynopsis>
#     <funcsynopsisinfo>logger_setThreadName "myThread"</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
logger_setThreadName()
{
  ${__LOG4SH_TRACE_CALL} logger_setThreadName \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  lstn_thread=$1

  lstn_length=`_log4sh_getArrayLength "${__log4sh_threadStack}"`
  __log4sh_threadStack=`_log4sh_setArrayElement \
      "${__log4sh_threadStack}" ${lstn_length} ${lstn_thread}`
  __log4sh_threadName=${lstn_thread}

  unset lstn_thread lstn_length
  return ${LOG4SH_TRUE}
}

#==============================================================================
# Trap
#

#/**
# <s:function group="Trap" modifier="public">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>log4sh_cleanup</function></funcdef>
#       <void />
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is a cleanup function to remove the temporary directory used by
#   log4sh. It is provided for scripts who want to do log4sh cleanup work
#   themselves rather than using the automated cleanup of log4sh that is
#   invoked upon a normal exit of the script.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>log4sh_cleanup</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
log4sh_cleanup()
{
  ${__LOG4SH_TRACE_CALL} log4sh_cleanup \
      $# -ne 0 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _log4sh_cleanup 'EXIT'
}

#/**
# <s:function group="Trap" modifier="private">
# <entry align="right">
#   <emphasis>void</emphasis>
# </entry>
# <entry>
#   <funcsynopsis>
#     <funcprototype>
#       <funcdef><function>_log4sh_cleanup</function></funcdef>
#       <paramdef>string <parameter>signal</parameter></paramdef>
#     </funcprototype>
#   </funcsynopsis>
#   <para>This is a cleanup function to remove the temporary directory used by
#   log4sh. It should only be called by log4sh itself when it is taking
#   control of traps.</para>
#   <para>If there was a previously defined trap for the given signal, log4sh
#   will attempt to call the original trap handler as well so as not to break
#   the parent script.</para>
#   <funcsynopsis>
#     <funcsynopsisinfo>_log4sh_cleanup EXIT</funcsynopsisinfo>
#   </funcsynopsis>
# </entry>
# </s:function>
#*/
_log4sh_cleanup()
{
  ${__LOG4SH_TRACE_CALL} _log4sh_cleanup \
      $# -ne 1 ${BASH_LINENO:-} || return ${LOG4SH_FALSE}

  _lc__trap=$1
  ${__LOG4SH_INFO} "_log4sh_cleanup(): the ${_lc__trap} signal was caught"

  _lc__restoreTrap=${LOG4SH_FALSE}
  _lc__oldTrap=''

  # match trap to signal value
  case "${_lc__trap}" in
    EXIT) _lc__signal=0 ;;
    INT) _lc__signal=2 ;;
    TERM) _lc__signal=15 ;;
  esac

  # do we possibly need to restore a previous trap?
  if [ -r "${__log4sh_trapsFile}" -a -s "${__log4sh_trapsFile}" ]; then
    # yes. figure out what we need to do
    if [ `grep "^trap -- " "${__log4sh_trapsFile}" >/dev/null; echo $?` -eq 0 ]
    then
      # newer trap command
      ${__LOG4SH_DEBUG} 'newer POSIX trap command'
      _lc__restoreTrap=${LOG4SH_TRUE}
      _lc__oldTrap=`egrep "(${_lc__trap}|${_lc__signal})$" "${__log4sh_trapsFile}" |\
        sed "s/^trap -- '\(.*\)' [A-Z]*$/\1/"`
    elif [ `grep "[0-9]*: " "${__log4sh_trapsFile}" >/dev/null; echo $?` -eq 0 ]
    then
      # older trap command
      ${__LOG4SH_DEBUG} 'older style trap command'
      _lc__restoreTrap=${LOG4SH_TRUE}
      _lc__oldTrap=`grep "^${_lc__signal}: " "${__log4sh_trapsFile}" |\
        sed 's/^[0-9]*: //'`
    else
      # unrecognized trap output
      _log4sh_error 'unable to restore old traps! unrecognized trap command output'
    fi
  fi

  # do our work
  rm -fr "${__log4sh_tmpDir}"

  # execute the old trap
  if [ ${_lc__restoreTrap} -eq ${LOG4SH_TRUE} -a -n "${_lc__oldTrap}" ]; then
    ${__LOG4SH_INFO} 'restoring previous trap of same type'
    eval "${_lc__oldTrap}"
  fi

  # exit for all non-EXIT signals
  if [ "${_lc__trap}" != 'EXIT' ]; then
    # disable the EXIT trap
    trap 0

    # add 128 to signal value and exit
    _lc__signal=`expr ${_lc__signal} + 128`
    exit ${_lc__signal}
  fi

  unset _lc__oldTrap _lc__signal _lc__restoreTrap _lc__trap
  return
}


#==============================================================================
# main
#

# create a temporary directory
__log4sh_tmpDir=`_log4sh_mktempDir`

# preserve old trap(s)
__log4sh_trapsFile="${__log4sh_tmpDir}/traps"
trap >"${__log4sh_trapsFile}"

# configure traps
${__LOG4SH_INFO} 'setting traps'
trap '_log4sh_cleanup EXIT' 0
trap '_log4sh_cleanup INT' 2
trap '_log4sh_cleanup TERM' 15

# alternative commands
log4sh_setAlternative mail "${LOG4SH_ALTERNATIVE_MAIL:-mail}" ${LOG4SH_TRUE}
[ -n "${LOG4SH_ALTERNATIVE_NC:-}" ] \
    && log4sh_setAlternative nc "${LOG4SH_ALTERNATIVE_NC}"

# load the properties file
${__LOG4SH_TRACE} "__LOG4SH_CONFIGURATION='${__LOG4SH_CONFIGURATION}'"
if [ "${__LOG4SH_CONFIGURATION}" != 'none' -a -r "${__LOG4SH_CONFIGURATION}" ]
then
  ${__LOG4SH_INFO} 'configuring via properties file'
  log4sh_doConfigure "${__LOG4SH_CONFIGURATION}"
else
  if [ "${__LOG4SH_CONFIGURATION}" != 'none' ]; then
    _log4sh_warn 'No appenders could be found.'
    _log4sh_warn 'Please initalize the log4sh system properly.'
  fi
  ${__LOG4SH_INFO} 'configuring at runtime'

  # prepare the environment for configuration
  log4sh_resetConfiguration

  # note: not using the constant variables here (e.g. for ConsoleAppender) so
  # that those perusing the code can have a working example
  logger_setLevel ${__LOG4SH_LEVEL_ERROR_STR}
  logger_addAppender stdout
  appender_setType stdout ConsoleAppender
  appender_setLayout stdout PatternLayout
  appender_setPattern stdout '%-4r [%t] %-5p %c %x - %m%n'
  appender_activateOptions stdout
fi

# restore the previous set of shell flags
for _log4sh_shellFlag in ${__LOG4SH_SHELL_FLAGS}; do
  echo ${__log4sh_oldShellFlags} |grep ${_log4sh_shellFlag} >/dev/null \
    || set +${_log4sh_shellFlag}
done
unset _log4sh_shellFlag

#/**
# </s:shelldoc>
#*/
