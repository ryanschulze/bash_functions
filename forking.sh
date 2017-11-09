#!/usr/bin/env bash

#-------------------------------------------------------------------------------
#   includable functions to fork stuff to the background and wait for them
#   Functions:
#     - b "<command>" : Background
#     - wbit_ : wait for all commands we forked off
#     - reset_b : reset the variable tracking processes in the background
#-------------------------------------------------------------------------------

#===  FUNCTION  ================================================================
#          NAME:  b
#   DESCRIPTION:  forks commands to background
#    PARAMETERS:  commands fo be forked
#===============================================================================
b() {
	${*} &
	b_WatchPIDs="${b_WatchPIDs} $!" # add child to list of PIDs to watch
} # end of function b

#===  FUNCTION  ================================================================
#          NAME:  wait_b
#   DESCRIPTION:  waits for the precesses we forked off to finish
#    PARAMETERS:  none
#===============================================================================
wait_b() {
	wait ${b_WatchPIDs} 2>/dev/null # wait till all children are done
	reset_b # reset the variable in case we need to use it later again
}  # end of function wait_b

#===  FUNCTION  ================================================================
#          NAME:  reset_b
#   DESCRIPTION:  resets the variable tracking processes in the background
#    PARAMETERS:  none
#===============================================================================
reset_b() {
	b_WatchPIDs="" # empty variable
}  # end of function reset_b
reset_b

#-------------------------------------------------------------------------------
#  Example usage
#-------------------------------------------------------------------------------
#
# source functions_background_forking.sh
#
# for count in $(seq 1 15)
# do
#   time="$(bc <<< "0.$RANDOM * 15")"
#   b sleep $time
#   echo "+ forked off a sleep waiting $time seconds"
# done
#
# echo "waiting for all background processes to finish"
# wait_b
# echo "done"
#

