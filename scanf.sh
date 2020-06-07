#!/usr/bin/env bash

#===  FUNCTION  ================================================================
#          NAME:  scanf
#   DESCRIPTION:  Opposite of printf, scans a string and assigns variables
#    PARAMETERS:  <string> <regex with grouping> <variables ....>
#===============================================================================
scanf() {
    local input=${1} regex=${2} group=1

    [[ ${input} =~ ${regex} ]] || return 1

    shift 2
    for varname in "${@}"
    do
        local -n ref=${varname}
        # shellcheck disable=2034
        ref=${BASH_REMATCH[group++]}
    done
    return 0
}
# end of function scanf

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# string="Test string containing number 23453 and value 'secret'"
# scanf "${string}" "number ([0-9]+) and value '(.+)'$" number value
# printf "Number: %d - Value: %s\n" "${number}" "${value}"
#
# string="systemd[1]: kubelet.service: Scheduled restart job, restart counter is at 38351."
# scanf "${string}" "^([^\[]+)\[[0-9]\]: ([^:]+): Scheduled restart job, restart counter is at ([0-9]+)\.$" service app counter
# printf "Service: %s - App: %s - Counter: %d\n" "${service}" "${app}" "${counter}"
#