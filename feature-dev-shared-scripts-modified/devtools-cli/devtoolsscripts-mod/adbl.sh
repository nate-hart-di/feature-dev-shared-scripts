#!/bin/bash

###########################################
# Dev Tools DebugLog Scripts
#
# E.g. `devtools adbl ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/adbl.sh"

# Archive WP debuglog
adbl_a()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                adbl_a_usage
                exit
            ;;
        esac
    done
    
    mv ${WP_CORE_DIRECTORY}dealer-inspire/wp-content/debug.log ${WP_CORE_DIRECTORY}dealer-inspire/wp-content/debug.log.old
    touch ${WP_CORE_DIRECTORY}dealer-inspire/wp-content/debug.log
    info "Archived debuglog to ${WP_CORE_DIRECTORY}dealer-inspire/wp-content/debug.log.old\n"
    
}
# Delete the contents of you WP debuglog
adbl_d()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                adbl_d_usage
                exit
            ;;
        esac
    done
    
    : > ${WP_CORE_DIRECTORY}dealer-inspire/wp-content/debug.log
    info "Deleted debuglog contents at: ${WP_CORE_DIRECTORY}dealer-inspire/wp-content/debug.log.old\n"
    
}
devtools_adbl()
{
    COMMAND="$(basename "$1")"
    local DASHCOMMAND=$2
    shift
    
    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools adbl a` matches `adbl_a`
    file_has_function $@ # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$DASHCOMMAND $@
        exit
    fi
    
    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_adbl_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    devtools_adbl_usage
}
