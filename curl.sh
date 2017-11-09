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

	response=$(curl --output - --location --silent --cookie "${CurlCookies}" --cookie-jar "${CurlCookies}" -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36" -w '\n@%{http_code}@\n' "${request}")
	response=${response//@000@/}
	array[returncode]=$(grep -oE "^@([0-9]+)@$" <<< "${response}")
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
# source curl.sh
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
