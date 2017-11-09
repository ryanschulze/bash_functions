# bash_functions
Various bash functions in separate files that can easily be copied into a main project or included as external files

# Table of Contents
- [logging.sh](#loggingsh)
  - [log()](#log)
  - [logrotate()](#logrotate)
- [ip2long.sh](#ip2longsh)
  - [INET_ATON()](#INETATON)
  - [INET_NTOA()](#INETNTOA)
  - [INET_BROADCAST()](#INETBROADCAST)
  - [IN_SUBNET()](#INSUBNET)

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

---

## ip2long.sh

### INET_ATON()
converts a IP to a long integer

**Example**

    source ip2long
    INET_NTOA 127.0.0.1
    

### INET_NTOA()
converts IP in long integer format to a string

**Example**

    source ip2long
    INET_NTOA 2130706433
    

### INET_BROADCAST()
calculates the broadcast IP of a network

**Example**

    source ip2long
    INET_BROADCAST 10.0.0.0/24
    
### IN_SUBNET()
checks if an IP is in a specific subnet

**Example**

    source ip2long
    IN_SUBNET 10.0.0.2 10.0.0.0/24
    echo $?
    
    IN_SUBNET 10.0.1.2 10.0.0.0/24
    echo $?
    
