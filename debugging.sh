#!/usr/bin/env bash

DEBUG=${DEBUG:-true}

#===  FUNCTION  ================================================================
#          NAME:  debug_on
#   DESCRIPTION:  turns on bash debugging output
#===============================================================================
debug_on() {
	$DEBUG || return
	set -x
} # end of function debug_on

#===  FUNCTION  ================================================================
#          NAME:  debug_off
#   DESCRIPTION:  turns off bash debugging output
#===============================================================================
debug_off() {
	$DEBUG || return
	set +x
} # end of function debug_off

#===  FUNCTION  ================================================================
#          NAME:  debug
#     PARAMETER:  string
#   DESCRIPTION:  outputs parameter(s) to stderr
#===============================================================================
debug() {
	$DEBUG || return
	echo -e "[$(date '+%H:%M:%S')] ${*}" > /dev/stderr
} # end of function debug

#===  FUNCTION  ================================================================
#          NAME:  breakpoint
#     PARAMETER:  string
#   DESCRIPTION:  outputs parameter(s) to stderr and then pauses
#===============================================================================
breakpoint() {
	$DEBUG || return
	debug "-breakpoint- ${*}"
	echo "press any key to continue"
	read -r
} # end of function breakpoint
