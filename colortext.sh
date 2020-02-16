#!/usr/bin/env bash

#===  FUNCTION  ================================================================
#          NAME:  text
#     PARAMETER:  color, string
#   DESCRIPTION:  outputs strung in the desired color
#===============================================================================
text() {
  local color=${1}
  shift
  local text="${*}"

  case ${color} in
    red    ) tput setaf 1 ; tput bold ;;
    green  ) tput setaf 2 ; tput bold ;;
    yellow ) tput setaf 3 ; tput bold ;;
    blue   ) tput setaf 4 ; tput bold ;;
    white  ) tput setaf 7 ; tput bold ;;
    grey   ) tput setaf 5 ;;
  esac

  echo -en "${text}"
  tput sgr0
} # end of function text
