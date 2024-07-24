#!/bin/bash

###########################################
# Dev Tools SSH Scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# Run gulp in CommonTheme
#
# E.g. `devtools gulp ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/gulp.sh"

# ssh into pod
devtools_gulp() 
{
    COMMAND="$(basename "$1")"
    local GULPCOMMAND=$2
    shift
    
    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools docker up` matches `docker_up`
    file_has_function "$@" # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$GULPCOMMAND "$@"
        exit
    fi
    
    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_gulp_usage
                exit
            ;;
            *)
                devtools_gulp_usage
                exit 1
            ;;
        esac
    done
    shift $((OPTIND -1))

    cd ${WP_CORE_DIRECTORY}dealer-inspire/wp-content/themes/DealerInspireCommonTheme
    gulp
}