#!/usr/bin/env bash

#-------------------------------------------------------------------------------
#   includable functions to convert ipv4 to long integer and back
#   behaves like the mysql funtions with the same name.
#   Partially based off code found on http://stackoverflow.com
#
#   Functions:
#     inet_aton      - IP -> integer
#     inet_ntoa      - integer -> IP
#     inet_broadcast - Braodcast IP for a subnet
#     in_subnet      - check if a IP is in a subnet
#     split_subnet   - split a large network into smaller networks
#     list_ips       - list all IPs in a subnet
#
#-------------------------------------------------------------------------------

#===  FUNCTION  ================================================================
#          NAME:  inet_ntoa
#   DESCRIPTION:  converts IP in long integer format to a string
#    PARAMETERS:  ip as an long integer
#===============================================================================
inet_ntoa() {
  local x ip ui32
  ui32=${1}
  for ((x = 1; x <= 4; x++)); do
    ip=$((ui32 & 0xff))${ip:+.}${ip}
    ui32=$((ui32 >> 8))
  done
  echo "${ip}"
} # end of function inet_ntoa

#===  FUNCTION  ================================================================
#          NAME:  inet_aton
#   DESCRIPTION:  converts a IP to a long integer
#    PARAMETERS:  ip as string
#===============================================================================
inet_aton() {
  local a b c d
  { IFS=. read -r a b c d; } <<<"${1}"
  echo $(((((((a << 8) | b) << 8) | c) << 8) | d))
} # end of function inet_aton

#===  FUNCTION  ================================================================
#          NAME:  inet_broadcast
#   DESCRIPTION:  calculates the broadcast IP of a network
#    PARAMETERS:  CIDR network as string
#===============================================================================
inet_broadcast() {
  local network netmask
  network=${1%/*}
  [[ ${1} =~ / ]] && netmask=${1#*/} || netmask=32
  network=$(inet_aton "${1}")
  netmask=$((0xffffffff << (32 - netmask)))
  inet_ntoa $((network | ~netmask))
} # end of function inet_broadcast

getCidrFromMask() {
  local mask="${1}"
  local -i bits n=32
  bits=$(inet_aton "${1}")
  while [[ $((bits & 1)) -eq 0 ]] && [[ $((--n)) -gt 0 ]]; do
    bits=$((bits >> 1))
  done
  echo "${n}"
}

getIntFromCidr() {
  local bits=$(((0xffffffff << (32 - ${1})) & 0xffffffff))
  echo ${bits}
}

#===  FUNCTION  ================================================================
#          NAME:  in_subnet
#   DESCRIPTION:  checks if an IP is in a specific subnet
#    PARAMETERS:  ip as string, CIDR network as string
#===============================================================================
in_subnet() {
  local ip=${1} network=${2%%/*} mask=${2##*/} cidr
  local -i intip intmask intnet
  intip=$(inet_aton "${ip}")
  intnet=$(inet_aton "${network}")
  if [[ ${mask} =~ .*\..* ]] || ! [[ 32 -ge ${mask} ]] 2>/dev/null; then
    cidr=$(getCidrFromMask "${mask}")
  else
    cidr=${mask}
  fi
  intmask=$(getIntFromCidr "${cidr}")
  intnet=$((intnet & intmask))
  [[ $((intip & intmask)) -eq ${intnet} ]]
} # end of function in_subnet

#===  FUNCTION  ================================================================
#          NAME:  split_subnet
#   DESCRIPTION:  takes a large network and outputs $maxSubnet sized
#                 smaller networks
#    PARAMETERS:  bits and list of subnets
#       EXAMPLE:
#       split_subnet 26 10.1.0.0/24 10.2.0.0/27
#       10.1.0.0/26 10.1.0.64/26 10.1.0.128/26 10.1.0.192/26 10.2.0.0/27
#===============================================================================
split_subnet() {
  local maxSubnet=${1}
  shift
  local SubnetList="${*}"
  local network=
  local netmask=

  for pair in ${SubnetList}; do
    # split up the network and netmask
    network=${pair%/*}
    netmask=${pair#*/}
    if [[ ${netmask} -ge ${maxSubnet} ]]; then # network is smaller than max. size. add it to the array
      echo -n "${network}/${netmask} "
    else # network is too big. split it up into smaller chunks and add them to the array
      for i in $(
        # convert network to long integer, add n * ${maxSubnet} and then convert back to string
        seq 0 $(($((2 ** (maxSubnet - netmask))) - 1))
      ); do
        echo -n "$(inet_ntoa $(($(inet_aton "${network}") + $((2 ** (32 - maxSubnet) * i)))))/${maxSubnet} "
      done
    fi
  done
  echo
} # end of function split_subnet

#===  FUNCTION  ================================================================
#          NAME:  list_ips
#   DESCRIPTION:  lists all IPs in a subnet
#    PARAMETERS:  CIDR notation (i.e. 1.1.1.0/24)
#===============================================================================
list_ips() {
  local ip=
  local cidr="${1#*/}"
  ip=$(inet_aton "${1%/*}")
  # -2 to discard the network and broadcast IPs, this has the side affect of also discarding /31 and /32 nets :-(
  local range="$((2 ** (32 - cidr) - 2))"

  for ((i = 1; i <= range; i++)); do
    inet_ntoa $((ip + i))
  done
} # end of function list_ips
