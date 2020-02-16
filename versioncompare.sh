#!/usr/bin/env bash

#===============================================================================
#
#   DESCRIPTION: simple compare of two version strings using sort -V
#
#===============================================================================

compare_version() {
  local versionOne="${1}"
  local comparision="${2}"
  local versionTwo="${3}"
  local result=
  local sortOpt=
  local returncode=1

  if [[ "${versionOne}" == "${versionTwo}" ]] ; then
    return 3
  fi

  case ${comparision} in
    lower|smaller|older|lt|"<" ) sortOpt= ;;
    higher|bigger|newer|bt|">" ) sortOpt='r' ;;
    * ) return 2 ;;
  esac

  result=($(printf "%s\n" "${versionOne}" "${versionTwo}" | sort -${sortOpt}V ))
  if [[ "${versionOne}" == "${result[0]}" ]] ; then
    returncode=0
  fi

  return ${returncode}
} # end of function compare_version
