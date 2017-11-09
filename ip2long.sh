#!/usr/bin/env bash

#-------------------------------------------------------------------------------
#   includable functions to convert ipv4 to long integer and back
#   behaves like the mysql funtions with the same name. Based off code found
#   on http://stackoverflow.com, posted by the user 'ceving'
#   Additional code and fixes by Domink Bürkle
#
#   Functions:
#     INET_ATON      - IP -> integer
#     INET_NTOA      - integer -> IP
#     INET_BROADCAST - Braodcast IP for a subnet
#     IN_SUBNET      - IP in subnet
#-------------------------------------------------------------------------------

#===  FUNCTION  ================================================================
#          NAME:  INET_NTOA
#   DESCRIPTION:  converts IP in long integer format to a string
#    PARAMETERS:  ip as an long integer
#===============================================================================
INET_NTOA() {
    local x ip ui32
    ui32=${1}
    for ((x=1; x<=4; x++)); do
        ip=$((ui32 & 0xff))${ip:+.}${ip}
        ui32=$((ui32 >> 8))
    done
    echo "${ip}"
} # end of function INET_NTOA

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# INET_NTOA 2130706433
#


#===  FUNCTION  ================================================================
#          NAME:  INET_ATON
#   DESCRIPTION:  converts a IP to a long integer
#    PARAMETERS:  ip as string
#===============================================================================
INET_ATON() {
    local a b c d
    { IFS=. read -r a b c d; } <<< "${1}"
    echo $(((((((a << 8) | b) << 8) | c) << 8) | d))
} # end of function INET_ATON

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# INET_ATON 127.0.0.1
#

#===  FUNCTION  ================================================================
#          NAME:  INET_BROADCAST
#   DESCRIPTION:  calculates the broadcast IP of a network
#    PARAMETERS:  CIDR network as string
#===============================================================================
INET_BROADCAST()
{
	local network netmask
	network=${1%/*}
	[[ ${1} =~ / ]] && netmask=${1#*/} || netmask=32
    network=$(INET_ATON "${1}")
    netmask=$((0xffffffff << (32 - netmask)))
    INET_NTOA $((network | ~netmask ))
} # end of function INET_BROADCAST

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# INET_BROADCAST 10.0.0.0/24
#


#===  FUNCTION  ================================================================
#          NAME:  IN_SUBNET
#   DESCRIPTION:  checks if an IP is in a specific subnet
#    PARAMETERS:  ip as string, CIDR network as string
#===============================================================================
getCidrFromMask() {
    local mask="${1}"
    local -i bits n=32
    bits=$(INET_ATON "${1}")
    while [[ $(( bits & 1 )) -eq 0 ]] && [[ $(( --n )) -gt 0 ]]; do
        bits=$(( bits >> 1 ))
    done
    echo "${n}"
}

getIntFromCidr() {
    local bits=$(( (0xffffffff << (32-${1})) & 0xffffffff ))
    echo ${bits}
}

IN_SUBNET() {
    local ip=${1} network=${2%%/*} mask=${2##*/} cidr
    local -i intip intmask intnet
    intip=$(INET_ATON "${ip}")
    intnet=$(INET_ATON "${network}")
    if [[ ${mask} =~ .*\..* ]] || ! [[ 32 -ge ${mask} ]] 2>/dev/null; then
        cidr=$(getCidrFromMask "${mask}")
    else
        cidr=${mask}
    fi
    intmask=$(getIntFromCidr "${cidr}")
    intnet=$(( intnet & intmask ))
    [[ $(( intip & intmask )) -eq ${intnet} ]]
}

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# IN_SUBNET 10.0.0.2 10.0.0.0/24
# echo $?
#
# IN_SUBNET 10.0.1.2 10.0.0.0/24
# echo $?
#