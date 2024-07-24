#!/bin/bash

###########################################
# Dev Tools Environment Scripts
#
# DO NOT USE FUNCTIONS FROM ../helpers.sh
#
# Always meant to be called from within the
# `devtools` script - not standalone
#
# E.g. `devtools state ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/state.sh"

# Retrieve a saved state of DealerTheme (DB ONLY FOR NOW)
state_get()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                state_get_usage
                exit
                ;;
        esac
    done
    shift $((OPTIND -1))

    local STATENAME=$1

    db_clean

    notify "Retrieving saved state $STATENAME"
    $mysqlconnect -D dealerinspire_dev < $SCRIPTPATH/.cache/$STATENAME.sql
    info "Retrieved saved state $STATENAME"
}

# Save the current state of DealerTheme (DB ONLY FOR NOW)
state_save()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                state_set_usage
                exit
                ;;
        esac
    done
    shift $((OPTIND -1))

    local STATENAME=$1

    if [ ! -d "$SCRIPTPATH/.cache" ]; then
        mkdir -p "$SCRIPTPATH/.cache"
    fi

    notify "Saving the current state of the DB"
    mysqldump --defaults-extra-file=$DI_WP_DOCKER/bin/.docker.sql.cnf dealerinspire_dev > $SCRIPTPATH/.cache/$STATENAME.sql
    info "Saved the current state of the DB"
}

# List the current saved states
state_list()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                state_set_usage
                exit
                ;;
        esac
    done
    shift $((OPTIND -1))

    ls $SCRIPTPATH/.cache/*.sql | rev | cut -d / -f 1 | rev | cut -d . -f 1
}

# Delete all saved states
state_reset()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                state_set_usage
                exit
                ;;
        esac
    done
    shift $((OPTIND -1))

    state_list
    rm $SCRIPTPATH/.cache/*.sql
}

# Main devtools docker process
devtools_state()
{
    COMMAND="$(basename "$1")"
    local stateCOMMAND=$2
    shift

    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools state set` matches `state_set`
    file_has_function $@ # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$stateCOMMAND $@
        exit
    fi

    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_state_usage
                exit
                ;;
        esac
    done
    shift $((OPTIND -1))

    devtools_state_usage
}
