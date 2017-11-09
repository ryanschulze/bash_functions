#!/usr/bin/env bash

#===  FUNCTION  ================================================================
#          NAME:  round
#   DESCRIPTION:  Rounds a number to percision n
#    PARAMETERS:  <number> <percisioon>
#===============================================================================
round()
{
	local number="${1}"
	local percision="${2}"
	printf "%.${percision}f" "$(bc <<< "scale=${percision};(((10^${percision})*${number})+0.5)/(10^${percision})")"
}

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# round 1.5678 2
#
