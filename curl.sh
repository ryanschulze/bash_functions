#!/usr/bin/env bash

#===  FUNCTION  ================================================================
#          NAME:  curl
#   DESCRIPTION:  Puts the response and return code into an associative array
#    PARAMETERS:  [name of an associative array] [curl request]
#       RETURNS:  array[response] - http response
#                 array[returncode] - http return code
#===============================================================================
CurlCookies=$(mktemp)
curl_fetch() {
  # if the first parameter is an array, use it for the result, else use ${curl_result[]}
  if [[ "$(declare -p ${1} 2>/dev/null)" == "declare -A"* ]]; then
    local -n array=${1}
    shift
  else
    # shellcheck disable=SC2034
    declare -gA curl_result
    local -n array=curl_result
  fi
  local request=${*}
  local response=

  # shellcheck disable=SC2086
  response=$(curl --output - --location --silent --cookie "${CurlCookies}" --cookie-jar "${CurlCookies}" -w '\n@%{http_code}@\n' ${request})
  response=${response//@000@/}
  # shellcheck disable=SC2154
  array[returncode]=$(grep -vE "^@000@$" <<<"${response}" | grep -oE "^@([0-9]+)@$")
  array[returncode]=${array[returncode]//@/}
  if [[ ${array[returncode]} -gt 0 ]]; then
    array[response]=${response%@[0-9]*@}
  else
    array[response]=
  fi
  return
} # end of function curl_fetch

curl_cleanup() {
  rm -f "${CurlCookies}"
} # end of function curl_cleanup

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# curl_fetch "http://www.ryanschulze.net/"
#
# echo '--------'
# echo ${curl_result[response]}
# echo '--------'
# echo ${curl_result[returncode]}
# echo '--------'
#
# curl_cleanup
#
