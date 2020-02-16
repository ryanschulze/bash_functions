#!/usr/bin/env bash

exec 500>"${LOCKFILE:-/var/tmp/script.lock}"

#===  FUNCTION  ================================================================
#          NAME:  write_lock
#   DESCRIPTION:  create an exclusive lock
#===============================================================================
write_lock() {
	flock -xn 500
} # end of function write_lock

#===  FUNCTION  ================================================================
#          NAME:  read_lock
#   DESCRIPTION:  create a shared lock
#===============================================================================
read_lock() {
	flock -sn 500
} # end of function read_lock

#===  FUNCTION  ================================================================
#          NAME:  write_lock_wait
#   DESCRIPTION:  create an exclusive lock with timeout
#===============================================================================
write_lock_wait() {
	local timeout=${1:-300}
	flock -xw ${timeout} 500
} # end of function write_lock_wait

#===  FUNCTION  ================================================================
#          NAME:  read_lock_wait
#   DESCRIPTION:  create a shared lock with timeout
#===============================================================================
read_lock_wait() {
	local timeout=${1:-300}
	flock -sw ${timeout} 500
} # end of function read_lock_wait

#===  FUNCTION  ================================================================
#          NAME:  release_lock
#   DESCRIPTION:  release the lock
#===============================================================================
release_lock() {
	flock -u 500
} # end of function release_lock

#===  FUNCTION  ================================================================
#          NAME:  lock_failed
#   DESCRIPTION:  simple message and exit to be used if a lock failed
#===============================================================================
lock_failed() {
	echo "failed to get a required lock, (check '${LOCKFILE:-/var/tmp/script.lock}') exiting"
	exit 1
} # end of function lock_failed

