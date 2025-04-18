#!/usr/bin/env bash

#===============================================================================
#
#   DESCRIPTION: safely and cleanly read config file
#
#===============================================================================
# # is more safer than just including a config file with 'source config.sh'
# # can deal with config files that look like this:
# # nothing
# foo=nothing
# fu=" nothing "
# bar= "nothing"
# foobar=nothing # nothing
# fubar= nothing

read_config() {
  local config=${1}
  local key=
  local value=

  # check if we will have to turn off extglob again
  shopt -q -p extglob
  local extglob=$?

  shopt -s extglob

  unset -v CONFIG
  declare -gA CONFIG

  while IFS='= ' read -r key value; do
    if [[ ! ${key} =~ ^[\ ]*# && -n ${key} ]]; then
      value="${value%%\#*}"  # Del inline right comments
      value="${value%%*( )}" # Del trailing spaces
      value="${value%\"*}"   # Del opening string quotes
      value="${value#\"*}"   # Del closing string quotes
      CONFIG[${key}]="${value}"
    fi
  done <"${config}"

  if [[ ${extglob} -gt 0 ]]; then
    shopt -u extglob
  fi
} # end of function read_config
