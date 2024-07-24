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
source "$SCRIPTPATH/devtoolsscripts/usage/ssh.sh"

# ssh into pod
devtools_ssh() 
{
    COMMAND="$(basename "$1")"
    local SSHCOMMAND=$2
    shift
    
    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools docker up` matches `docker_up`
    file_has_function $@ # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$SSHCOMMAND $@
        exit
    fi
    
    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_ssh_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))

    local IS_INTEGER='^[0-9]+$' # regex
    
    if [[ $1 =~ $IS_INTEGER || $1 = "dev" ]]; then
        local DASHPODNUM=$1
    else
        dash_pod $1
        local DASHPODNUM=$POD
        local DASHDOMAIN=$(dash_domain $1)
    fi

    if [[ "$DASHPODNUM" = "null" ]]; then 
        error "$1 not found in dealer sites. No pod returned. \n"
        exit
    fi

    notify "Logging in to POD $DASHPODNUM server"
    if [[ "$DASHPODNUM" = "dev" ]]; then
        printf "\n"
        ssh -t $SSH_USERNAME@a.dev.dealerinspire.com "cd /var/www/dealers; exec \$SHELL -l"
    elif [ ! -z $DASHDOMAIN ]; then # if we have a domain, cd to it
        notify "and navigating to $DASHDOMAIN dir \n"
        ssh -t $SSH_USERNAME@deploy.pod$DASHPODNUM.dealerinspire.com "cd /var/www/domains/$DASHDOMAIN; exec \$SHELL -l"
    else # otherwise, just to domains directory
        printf "\n"
        ssh -t $SSH_USERNAME@deploy.pod$DASHPODNUM.dealerinspire.com "cd /var/www/domains; exec \$SHELL -l"
    fi
}