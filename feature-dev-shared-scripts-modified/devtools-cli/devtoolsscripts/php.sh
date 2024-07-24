#!/bin/bash

###########################################
# Dev Tools PHP Scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# Switch PHP versions
#
# E.g. `devtools php ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/php.sh"
source "$SCRIPTPATH/devtoolsscripts/rebuild.sh"

devtools_php()
{
	COMMAND="$(basename "$1")"
    local HGCOMMAND=$2
    shift

	while getopts ":h" opt; do
		case ${opt} in
			h)
				devtools_php_usage
				exit 0
				;;
			\?)
				echo "Invalid option: -$OPTARG" >&2
      			;;
		esac
	done

	shift $((OPTIND -1))

	if [[ -z "${1}" ]]; then
		devtools_php_usage && exit;
	else
		switchphp ${1}
	fi
}