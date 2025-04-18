#!/usr/bin/env bash

#===============================================================================
#
#   DESCRIPTION:  to be included by other shell scripts, adds some generic
#                 tcp / udp networking stuff
#
#===============================================================================

net_proto=${net_proto:-tcp}
net_ip=${net_ip:-127.0.0.1}
net_port=${net_port:-80}
declare -ga net_data

#===  FUNCTION  ================================================================
#          NAME:  net_send
#     PARAMETER:  string
#===============================================================================
net_send() {
  local input="${*}"

  exec 5<>"/dev/${net_proto}/${net_ip}/${net_port}"

  echo -e "${input}" >&5

  unset net_data[@]
  while read <&5; do
    net_data[${#net_data[*]}]="${REPLY}"
  done
  return
} # end of function net_send
