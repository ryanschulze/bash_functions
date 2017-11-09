#!/usr/bin/env bash

#===============================================================================
#
#   DESCRIPTION:  to be included by other shell scripts, logging functions
#
#===============================================================================

log_level=${log_level:-info}
log_timestamp=${log_timestamp:-%e/%b %H:%M:%S}
[[ -z ${log_file+x} || -z "${log_file}" ]] && log_file="/var/log/${0%/*}.log"

declare -gA _loglevels=
_loglevels[none]=0
_loglevels[error]=1
_loglevels[warn]=2
_loglevels[info]=3
_loglevels[debug]=4

log() {
	local this_loglevel="${1}"
	shift
	[[ ${_loglevels[$this_loglevel]} -le ${_loglevels[$log_level]} ]] && \
	printf "%($log_timestamp)T - %-5s - %s\n" "-1" "${this_loglevel^^}" "${*}" >> "${log_file}"
} # end of function log

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# source logging.sh
#
# log debug "low level message"
# log error "important message"
#
# # default settings that can be changed:
# log_level=debug
# log_file=/var/log/something.log
# log_timestamp='%d %b %Y %H:%M:%S %z'
#
# # to send the logs to stderr you can set log_file to /proc/self/fd/2
#

logrotate() {
	local action=${1:-check}
	local logsize=
	# Limit in Megabytes
	local sizelimit=50
	# assumes the global variable ${log_file} is set

	# if we aren't forcing a rotate, check if the main log grew too big
	if [[ "${action}" != 'force' ]]; then
		# check if the logfile is getting too big, rotate if neccisary
		logsize=$(stat -c '%s' "${log_file}"); logsize=$((logsize/1024/1024))
		if [[ ${logsize} -lt ${sizelimit} ]]; then
			return
		fi
	fi

	log info "rotating logs"
	[[ -e "${log_file}.5.gz" ]] && rm "${log_file}.5.gz"
	for i in {5..3}; do
		[[ -e "${log_file}.$((i-1)).gz" ]] && mv "${log_file}.$((i-1)).gz" "${log_file}.${i}.gz"
	done
	[[ -e "${log_file}.1" ]] && { gzip --best --quiet "${log_file}.1" && mv "${log_file}.1.gz" "${log_file}.2.gz"; }
	[[ -e "${log_file}.1" ]] && rm "${log_file}.1"
	[[ -e "${log_file}" ]] && cp "${log_file}" "${log_file}.1"
	cat /dev/null > "${log_file}"
} # end of function logrotate

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# # check if the log is too big, and rotate it if necessary
# logrotate
#
# # force a rotation of the log files (e.g. when a script starts up)
# logrotate force

