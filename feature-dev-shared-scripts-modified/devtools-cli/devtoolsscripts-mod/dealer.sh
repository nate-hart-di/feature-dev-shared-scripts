#!/bin/bash

###########################################
# Dev Tools Dealer Scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# Retreive info about a slug
#
# E.g. `devtools dealer ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/dealer.sh"
source "$SCRIPTPATH/devtoolsscripts/dash.sh"

# Open the current dealer's site
dealer_open()
{
    # points to dash open; dash has been build out with more dashboard commands
    dash_open $@
}

# Main devtools docker process
devtools_dealer()
{
    COMMAND="$(basename "$1")"
    local DASHCOMMAND=$2
    shift
    
    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools dash pod` matches `dash_pod`
    file_has_function $@ # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$DASHCOMMAND $@
        exit
    fi
    
    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_dealer_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    devtools_dealer_usage
}
