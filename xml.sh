#!/usr/bin/env bash

#===============================================================================
#
#   DESCRIPTION:  to be included by other shell scripts, rudimentary XML parsing
#
#===============================================================================

#-------------------------------------------------------------------------------
#  A small function to help up parse the xml file by splitting stuff on < and >
#-------------------------------------------------------------------------------
parse_xml () {
	local IFS=\>
	local returncode=
	local key=
	local value=
	declare -g Tag
	declare -g Content

	read -r -d \< Tag Content
	returncode=$?

	unset Attribute
	declare -gA Attribute

	# shellcheck disable=SC1101
	IFS=\   
	for attr in ${Tag#* }
	do
		if [[ $attr =~ = ]]; then
			key=${attr%%=*}
			value=$(tidy ${attr#*=})
			Attribute[${key}]=${value}
		fi
	done

	Tag="$(trim "${Tag%% *}")"
	Content="$(trim "${Content}")"

	return ${returncode}
} # end of function parse_xml

#-------------------------------------------------------------------------------
#  Helper functions for cleaning up the data
#-------------------------------------------------------------------------------
tidy() {
	trim "${@}" | sed "s/^[\'\"]\(.*\)[\'\"]$/\1/"
} # end of function tidy
trim() {
	local var="$*"
	var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
	var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
	echo -n "$var"
} # end of function trim

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# while parse_xml ; do
#  echo "-${Tag}-${Attribute[@]}-${Content}-"
# done < ${xmlfile}
#
