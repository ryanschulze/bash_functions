# bash_functions
Various bash functions in separate files that can easily be copied into a main project or included as external files

# Table of Contents
- [Logging.sh](#loggingsh)
  -  [log()](#log)
  - [logrotate()](#logrotate)

---

## logging.sh
### log() 
logs events with a customizable timestamp, severity and destination

**Example**

    source logging.sh
    log debug "low level message"
    log error "important message"
    
    # default settings that can be changed:
    log_level=debug
    log_file=/var/log/something.log
    log_timestamp='%d %b %Y %H:%M:%S %z'
    
    # to send the logs to stderr you can set log_file to /proc/self/fd/2


### logrotate()
checks if a logfile needs to be rotated

**Example**

    source logging.sh
    
    # check if the log is too big, and rotate it if necessary
    logrotate
    
    # force a rotation of the log files (e.g. when a script starts up)
    logrotate force

