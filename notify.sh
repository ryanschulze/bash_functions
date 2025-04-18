#!/usr/bin/env bash

#===  FUNCTION  ================================================================
#          NAME:  notify
#   DESCRIPTION:  Calls notify-send with some addational logic and defaults
#    PARAMETERS:  [ -t <topic> ] [ -t <timeout in seconds> ] [ -i <icon> ]
#===============================================================================
notify() {
  local timeout=30
  local topic='Notify'
  local icon='info'

  while [[ ${1} =~ ^-[ti]$ ]]; do
    if [[ ${1} == '-t' && ${2} =~ ^[0-9]+$ ]]; then
      timeout=${2}
    elif [[ ${1} == '-t' ]]; then
      topic=${2}
    elif [[ ${1} == '-i' ]]; then
      icon=${2}
    fi
    shift
    shift
  done
  timeout=$((timeout * 1000))
  notify-send -i "${icon}" -t "${timeout}" "${topic}" " ${*}"
} # end of function notify

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# notify test
# notify -t test the topic is test
# notify -t 10 message with a 10 second timeout
# notify -t 10 -t test a 10 second timeout and topic test
# notify -t 10 -i error -t test an error icon and a 10 second timeout and topic test
