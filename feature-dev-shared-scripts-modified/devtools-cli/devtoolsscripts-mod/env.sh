#!/bin/bash

###########################################
# Dev Tools Environment Scripts
#
# DO NOT USE FUNCTIONS FROM ../helpers.sh
#
# Always meant to be called from within the
# `devtools` script - not standalone
#
# E.g. `devtools env ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/env.sh"

# Check if the env file exists, and walk through prompt
# for any and all missing variables
env_init()
{
    # Get the variables, if the file exists
    [ -f $SCRIPTPATH/.devtools.env ] && source $SCRIPTPATH/.devtools.env
    
    # Check for each mandatory variable, and prompt for it if missing
    local requiredvars=("SSH_USERNAME" "DOCKER_DIRECTORY" "WP_CORE_DIRECTORY" "VAGRANT_DIRECTORY" "ENVIRONMENT")
    
    for var in "${requiredvars[@]}"; do
        if [ -z ${!var} ]; then
            case $var in
                DOCKER_DIRECTORY)
                    local hint="Include trailing slash \nMaybe /Users/$(whoami)/code/dealerinspire/feature-dev-shared-scripts/di-wp-docker/\n"
                ;;
                VAGRANT_DIRECTORY)
                    local hint="Include trailing slash \nMaybe /Users/$(whoami)/code/dealerinspire/vagrant/com.dealerinspire.wordpress.local/\n"
                ;;
                WP_CORE_DIRECTORY)
                    local hint="Include trailing slash \nMaybe /Users/$(whoami)/code/dealerinspire/dealerinspire-core/\n"
                ;;
                ENVIRONMENT)
                    local hint="Do you use docker or vagrant?\n[docker|vagrant]\n"
                ;;
                *)
                    local hint=''
                ;;
            esac
            
            printf "$hint"
            read -e -p "Enter value for $var: " value
            
            if [ ! -f "$SCRIPTPATH/.devtools.env" ]; then
                env_insert $var $value
            else
                env_update $var $value
            fi
            
            # load in the new variable
            source "$SCRIPTPATH/.devtools.env"
        fi
    done
}

# Query the value of a variable
env_get()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                env_get_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    local envfile="$SCRIPTPATH/.devtools.env"
    local pattern="$1\="
    local value=$(cat $envfile | grep $pattern | cut -d "'" -f2)
    
    echo $value
}

# Insert or Replace an environment variable
env_set()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                env_set_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    local isset=$(env_get $1)
    
    if [ ! -f "$SCRIPTPATH/.devtools.env" ] || [ -z $isset ]; then
        env_insert $@
    else
        env_update $@
    fi
}

# Insert an environment variable
env_insert()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                env_insert_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    echo "$1='$2'" >> "$SCRIPTPATH/.devtools.env"
}

# Remove the current row with this key, and append a new row with the new value
env_update()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                env_update_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    local file="$SCRIPTPATH/.devtools.env"
    sed -i '' "/$1=/d" $file
    echo "$1='$2'" >> $file
}

# Main devtools docker process
devtools_env()
{
    COMMAND="$(basename "$1")"
    local ENVCOMMAND=$2
    shift
    
    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools env set` matches `env_set`
    file_has_function $@ # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$ENVCOMMAND $@
        exit
    fi
    
    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_env_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    devtools_env_usage
}
