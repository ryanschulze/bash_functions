#!/usr/bin/env bash
#===============================================================================
#
#          FILE:  Name.sh
#
#         USAGE:  ./Name.sh
#
#   DESCRIPTION:  Short description of script
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Ryan Schulze (rs), email@address
#       COMPANY:  Company
#       CREATED:  YYYY-MM-DD
#      REVISION:  ---
#===============================================================================

# switch into the script directory
SCRIPTDIR=${0}
cd "${SCRIPTDIR%/*}" || exit

#===  FUNCTION  ================================================================
#          NAME:  initialize and cleanup
#   DESCRIPTION:  define and cleanup the environment for our needs
#===============================================================================
initialize() {
  # Treat unset variables as an error
  set -o nounset

  Variable=

  # source "${HOME}/bash_functions/colortext.sh"
  # source "${HOME}/bash_functions/flock.sh"
  # source "${HOME}/bash_functions/try.sh"
  # source "${HOME}/bash_functions/forking.sh"
  # source "${HOME}/bash_functions/ip2long.sh"
  # source "${HOME}/bash_functions/networking.sh"
  # source "${HOME}/bash_functions/debugging.sh"
  # source "${HOME}/bash_functions/logging.sh"

  # clean up if script exits
  trap cleanup TERM EXIT INT
} # end of function initialize
cleanup() {
  exit 0
} # end of function cleanup

#===  FUNCTION  ================================================================
#          NAME:  parse_args
#   DESCRIPTION:  parses the cli args
#    PARAMETERS:  $@
#===============================================================================
parse_args() {
  while getopts ":hx:" Option; do
    case ${Option} in
      x) Variable="${OPTARG}" ;;
      *) print_help ;; # DEFAULT
    esac
  done
  shift $((OPTIND - 1))
} # end of function parse_args

#===  FUNCTION  ================================================================
#          NAME:  print_help
#   DESCRIPTION:  Prints help and exits
#===============================================================================
print_help() {
  local printffomat=' %-13s %-s\n'

  echo "Usage: ${0##*/} [ -h ]"
  # shellcheck disable=SC2059
  printf "${printffomat}" "-h" "prints this help"
  echo
  echo "e.g. ./${0##*/} -h"
  echo
  exit 0
} # end of function print_help

#===  MAIN =====================================================================
main() {
  local foo=

  #code goes here

} # end of function main
#===============================================================================

initialize
parse_args "${@}" # parses any args passed
main              # main code
