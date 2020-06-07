#!/usr/bin/env bash

#===  FUNCTION  ================================================================
#          NAME:  require
#   DESCRIPTION:  checks if script can access requirements
#    PARAMETERS:  list of programs
#===============================================================================
require() {
	local returncode=0

	# check if requirement exists
	for check in "${@}"; do
		if ! type -t "${check}" &>/dev/null ; then
			text red "Error: "
			text white "Could not find requirement '${check}'\n"
			returncode=1
		fi
	done

	return "${returncode}"
} # end of function require

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# require jq bc grep

