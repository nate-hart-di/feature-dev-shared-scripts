#!/bin/bash

###########################################
# Dev Tools SSH Scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# SSH into pod
#
# E.g. `devtools ssh ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/uccp.sh"

# ssh into pod
devtools_uccp() 
{
    COMMAND="$(basename "$1")"
    local UCCPCOMMAND=$2
    shift
    
    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools docker up` matches `docker_up`
    file_has_function "$@" # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$UCCPCOMMAND "$@"
        exit
    fi
    
    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_uccp_usage
                exit
            ;;
            *)
                devtools_uccp_usage
                exit 1
            ;;
        esac
    done
    shift $((OPTIND -1))

    # Uses the docker container's PHP 7.2 for the composer part
    # so no need to switch PHP versions locally
    php "$SCRIPTPATH/../update-common-core-plugins/update-common-core-plugins.php"
}