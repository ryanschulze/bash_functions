#!/usr/bin/env bash
#===============================================================================
#
#   DESCRIPTION:  to be included by other shell scripts, logging functions
#
#===============================================================================

log_max_level=${log_max_level:-info}

# set a logfile if none is defined
if [[ -z ${logfile+x} || -z "${logfile}" ]]; then
  logfile="/var/log/${0%/*}.log"
fi

logrotate() {
  local action=${1:-check}
  local logsize=
  # Limit in Megabytes
  local sizelimit=50
  # assumes the global variable ${logfile} is set

  # if we aren't forcing a rotate, check if the main log grew too big
  if [[ "${action}" != 'force' ]]; then
    # check if the logfile is getting too big, rotate if neccisary
    logsize=$(stat -c '%s' "${logfile}")
    logsize=$((logsize / 1024 / 1024))
    if [[ ${logsize} -lt ${sizelimit} ]]; then
      return
    fi
  fi

  log info "rotating logs"
  [[ -e "${logfile}.5.gz" ]] && rm "${logfile}.5.gz"
  for i in {5..3}; do
    [[ -e "${logfile}.$((i - 1)).gz" ]] && mv "${logfile}.$((i - 1)).gz" "${logfile}.${i}.gz"
  done
  [[ -e "${logfile}.1" ]] && { gzip --best --quiet "${logfile}.1" && mv "${logfile}.1.gz" "${logfile}.2.gz"; }
  [[ -e "${logfile}.1" ]] && rm "${logfile}.1"
  [[ -e "${logfile}" ]] && cp "${logfile}" "${logfile}.1"
  cat /dev/null >"${logfile}"
} # end of function logrotate

log() {
  local this_loglevel="${1}"
  shift
  declare -A loglevels=
  loglevels[error]=1
  loglevels[warn]=3
  loglevels[info]=5
  loglevels[debug]=10

  [[ ${loglevels[$this_loglevel]} -le ${loglevels[$log_max_level]} ]] && printf "%15s PID:%i %-5s - %s\n" "$(date "+%e/%b %H:%M:%S")" "$$" "${this_loglevel^^}" "${*}" >>"${logfile}"
} # end of function log

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# log_max_level=debug
# logfile=/var/log/something.log
#
# source "${HOME}/bash_functions/logging.sh"
# log debug "low level message"
# log error "important message"
#
