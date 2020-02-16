#!/usr/bin/env bash

#===============================================================================
#
#   DESCRIPTION: getopts unfortunately only handles short arguments (-x)
#                this function support both long (--foo) and short (-f)
#                arguments
#
#===============================================================================
parse_longargs() {
	while : ;do
		case "${1}" in
			-f | --file)
				file="${2}"   # You may want to check validity of $2
				shift 2
		  		;;
			-h | --help)
				print_help
				exit 0
				;;
			-v | --verbose)
				verbose="verbose"
				shift
				;;
			--) # End of all options
				shift
				break;
				;;
			-*)
				echo "Error: Unknown option: $1" >&2
				exit 1
				;;
			*)
				break
				;;
		esac
	done
} # end of function parse_longargs

