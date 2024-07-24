#!/bin/bash

###########################################
# Dev Tools Search Scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# Search for text in Name/Slug/URL
#
# E.g. `devtools search ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/search.sh"

# Search for text in Name/Slug/URL
devtools_search()
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
    
    local FLAGS="gi"
    local EXACTLY=0
    while getopts ":hes" opt; do
        case $opt in
            h)
                devtools_search_usage
                exit
            ;;
            e)
                local EXACTLY=1
            ;;
            s)
                local FLAGS="g"
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    if [ ! -x "$(command -v jq)" ]; then
        error "Active Dealers can not be parsed from dashboard because the ${YELLOW}jq${RED} package is not installed"
        error "Run ${YELLOW}brew install jq${RED} to install"
        exit
    fi
    
    local JSONPATH="$SCRIPTPATH/.cache"
    
    if [ ! -d "$JSONPATH" ]; then
        error "Directory does not exist:\n${YELLOW}$JSONPATH\n"
        error "Run ${YELLOW}devtools dash dealers -f${RED} to install"
        exit
    fi
    
    local JSONFILE="$JSONPATH/dealers.json"
    
    if [ ! -f "$JSONFILE" ]; then
        error "File does not exist:\n${YELLOW}$JSONFILE\n"
        error "Run ${YELLOW}devtools dash dealers -f${RED} to install"
        exit
    fi

    dash_dealers # Update the dealers if necessary
    
    local SEARCH="$@"
    
    if [ "$SEARCH" == "" ]; then
        devtools_search_usage
        exit
    fi
    
    if [ "$EXACTLY" -eq 1 ]; then SEARCH="\b$SEARCH\b"; fi
    
    local RESULTS=$(jq --arg s "$SEARCH" --arg f "$FLAGS" '[.[] | .devl = "http://" + .slug + ".dev.dealerinspire.com" | select(.name,.slug,.url,.devl | match($s;$f)) | {name: .name, slug: .slug, prod:.url, devl:.devl, "pod#":.pod} ] | unique_by(.slug)' $JSONFILE)
    
    if [ "$RESULTS" == "[]" ]
    then
        echo "{\"message\": \"Nothing matched $SEARCH\"}"
    else
        echo "$RESULTS"
    fi
}
