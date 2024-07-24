#!/bin/bash

###########################################
# Dev Tools hg scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# E.g. `devtools hg ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/hg.sh"

# Print which dealer theme is checked out
hg_which()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                hg_which_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    hg -R $DEALERTHEME_DIRECTORY branch
}

# Checkout a Dealer Theme
hg_getdt()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                hg_getdt_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    local BRANCH=$1
    
    hg_wipedt
    
    notify "Checking out $BRANCH"
    result=$(hg -R $DEALERTHEME_DIRECTORY pull -r $BRANCH)
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        error "Unknown Branch: $BRANCH"
        exit
    fi
    hg -R $DEALERTHEME_DIRECTORY up $BRANCH
    info "Checked out $BRANCH"
}

# Check for uncommitted changes on the Dealer Theme, and prompt to clean if present
hg_wipedt()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                hg_wipedt_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    # check if there's uncommitted changes
    hg -R $DEALERTHEME_DIRECTORY summary | grep -q 'commit: (clean)'
    local isclean=$?
    
    if [ $isclean -ne 0 ]; then
        error "There are uncommitted changes on dealer theme:"
        hg -R $DEALERTHEME_DIRECTORY status
        read -p "Discard changes and proceed? [Yn]" yn
        case $yn in
            "n" | "no" | "nope")
                exit
            ;;
            *)
                hg -R $DEALERTHEME_DIRECTORY up -C
            ;;
        esac
    fi
}

# show git-like diffs for each hash log of the current branch
hg_diff()
{
    hg -R $DEALERTHEME_DIRECTORY log --verbose --patch --git --exclude "re:.*(\.css|\.min\.js|\.map)$" --branch .
}

# Main devtools hg process
devtools_hg()
{
    COMMAND="$(basename "$1")"
    local HGCOMMAND=$2
    shift
    
    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools docker up` matches `docker_up`
    file_has_function $@ # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$HGCOMMAND $@
        exit
    fi
    
    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_hg_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    devtools_hg_usage
}
