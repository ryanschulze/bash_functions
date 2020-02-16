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

#===  FUNCTION  ================================================================
#          NAME:  IN_SUBNET
#   DESCRIPTION:  checks if an IP is in a specific subnet
#    PARAMETERS:  ip as string, CIDR network as string
#===============================================================================
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

    for pair in ${SubnetList}
    do
        # split up the network and netmask
        network=${pair%/*}
        netmask=${pair#*/}
        if [[ ${netmask} -ge ${maxSubnet} ]]
        then # network is smaller than max. size. add it to the array
            echo -n "${network}/${netmask} "
        else # network is too big. split it up into smaller chunks and add them to the array
            for i in $(seq 0 $(( $(( 2 ** (maxSubnet - netmask) )) - 1 )) )
            do # convert network to long integer, add n * ${maxSubnet} and then convert back to string
                echo -n "$( INET_NTOA $(( $( INET_ATON "${network}" ) + $(( 2 ** ( 32 - maxSubnet ) * i )) )) )/${maxSubnet} "
            done
        fi
    done
    echo
}

#===  FUNCTION  ================================================================
#          NAME:  list_ips
#   DESCRIPTION:  lists all IPs in a subnet
#    PARAMETERS:  CIDR notation (i.e. 1.1.1.0/24)
#===============================================================================
list_ips() {
    local ip=
    local cidr="${1#*/}"
    ip=$(INET_ATON "${1%/*}")
    # -2 to discard the network and broadcast IPs, this has the side affect of also discarding /31 and /32 nets :-(
    local range="$(( 2 ** ( 32 - cidr ) - 2 ))"

    for ((i=1; i<=range; i++));
    do
        INET_NTOA $(( ip + i ))
    done
}
