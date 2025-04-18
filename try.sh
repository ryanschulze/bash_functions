#!/usr/bin/env bash

#===============================================================================
#
#   DESCRIPTION:  function to ease catching return codes of processes/commands
#
#===============================================================================

# use the text() function for making pretty output,
# should probably check if function already exists and make this conditional
source "${HOME}/bash_functions/colortext.sh"

#command_status is global
command_status=
function try() {
  if [ "$#" = "0" ]; then # not enough parameters were provided
    echo "ERROR: sytnax is 'try <silent|warn|fatal> command'"
    exit 1
  fi
  local returncode=0
  local severity=${1}
  shift
  local cmd="${*}"

  $cmd
  returncode=$?

  if [[ ${returncode} -gt 0 ]]; then
    case ${severity} in
      silent)
        command_status=${returncode}
        ;;
      warn)
        printf "%s: '%s' failed with return code -%s-\n" "$(text yellow "Warning")" "$(text blue "${cmd}")" "$(text yellow "${returncode}") "
        command_status=${returncode}
        ;;
      fatal)
        printf "%s: '%s' failed with return code -%s-\n" "$(text red "Error")" "$(text blue "${cmd}")" "$(text yellow "${returncode}")"
        exit ${returncode}
        ;;
      *)
        printf "%s: Wrong usage of the try() function\n" "$(text red "Error")"
        exit 1
        ;;
    esac
  fi
} # end of function try

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
#	try silent ls -al doesnotexist
#	echo ${command_status}
#	try warn   ls -al doesnotexist
#	try warn   false
#	try fatal  ls -al doesnotexist

#	try fatal cmake -DCMAKE_INSTALL_PREFIX=${installprefix%/} .
#	try fatal make
#	try warn  make man
#	try warn  make doc
#	try fatal make install
