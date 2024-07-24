#!/bin/bash

###########################################
# Dev Tools Dashboard Scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# E.g. `devtools dash ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/dash.sh"

# Get the active dealers
dash_dealers()
{
    local FORCEUPDATE=false
    while getopts ":hf" opt; do
        case $opt in
            h)
                dash_dealers_usage
                exit
                ;;
            f)
                local FORCEUPDATE=true
                ;;
        esac
    done
    shift $((OPTIND -1))

    if [ ! -x "$(command -v jq)" ]; then
        error "Active Dealers can not be parsed from dashboard because the ${YELLOW}jq${RED} package is not installed"
        error "Run ${YELLOW}brew install jq${RED} to install"
        exit 1
    fi

    local JSONPATH="$SCRIPTPATH/.cache/dealers.json"
    local LASTMOD=$(date -r $JSONPATH "+%s")
    local HRS24=$(date -v-1d "+%s")

    if [ -e $JSONPATH ] && [ $LASTMOD -gt $HRS24 ] && [ $FORCEUPDATE != true ]; then
        info "Active Dealers updated within last 24 hours; using cached version"
        return
    fi

    notify "Getting the active dealers from Dashboard"
    local url="https://dashboard.dealerinspire.com/api/v1/dealer/active_dealers"
    local DEALERS="$(curl --get $url \
                      --data-urlencode api_key=${DASH_API_KEY} \
                      | jq -r '.dealers | map({(.slug):.}) | add')" # {"slug":{dealerInfo}}

    if [ -z "$DEALERS" ]; then
        error "Error while fetching active dealers"
        error "run 'devtools dash pod -h' for more info on this command."
        exit
    else
        if [ ! -d "$SCRIPTPATH/.cache" ]; then
            mkdir -p "$SCRIPTPATH/.cache"
        fi

        echo $DEALERS > $JSONPATH
        info "Saved active dealers to $JSONPATH"
    fi
}

# Get dealer's info from cached JSON file
get_dealer_json()
{
    dash_dealers > /dev/null # Update the dealers if necessary

    local JSONPATH="$SCRIPTPATH/.cache/dealers.json"

    # If no branch passed, then get current local branch
    # otherwise use passed branch
    if [[ -z "$1" ]]; then
        local SLUG=$(hg_which)
    else 
        local SLUG=$1
    fi
    
     # if passed branch includes a "." then we'll assume it's actually a domain
    if [[ $SLUG == *\.* ]]; then
        DOMAIN=${SLUG##*://} # remove protocol
        DOMAIN=${DOMAIN#www.}  # remove www.
        DOMAIN=${DOMAIN%%/*}   # remove path
        DEALERINFO=$(cat $JSONPATH | jq --arg s "$DOMAIN" '.[] | select(.domain == $s)')
    else
        local JQPATH=".$SLUG"
        DEALERINFO=$(cat $JSONPATH | jq $JQPATH)
    fi

    if [[ -z $DEALERINFO || "$DEALERINFO" == "null" ]]; then
        error "\n$SLUG didn't match any active dealers\n"
        exit 1
    fi
}

# Get all the cached dashboard info for a dealer
dash_info()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                dash_info_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    get_dealer_json $1
    # if [ $? -ne 0 ]; then exit 1; fi
    local SLUG=$(jq '.slug' <<< $DEALERINFO | sed s/\"//g)
    local DEVURL="  devurl: http://$SLUG.dev.dealerinspire.com"
    local INFO=$(echo "$DEALERINFO" | sed s/\"//g)

    printf "\n${INFO%\}}$DEVURL\n}\n\n"
}

# Get the dealer's domain
dash_domain()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                dash_domain_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    get_dealer_json $1
    
    local JQPATH=".domain"
    local DOMAIN=$(jq $JQPATH <<< $DEALERINFO | sed s/\"//g)
    
    echo "$DOMAIN"
}

# Get the dealer's slug
dash_slug()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                dash_slug_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    get_dealer_json $1
    
    local JQPATH=".slug"
    local SLUG=$(jq $JQPATH <<< $DEALERINFO | sed s/\"//g)
    
    echo "$SLUG"
}

# Convert a list of slugs to their respective domains
dash_slugstodomains()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                dash_slug_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))

    read -ra arr <<<"$@"
    for slug in "${arr[@]}"; do 
        get_dealer_json $slug
        local JQPATH=".domain"
        local DOMAIN=$(jq $JQPATH <<< $DEALERINFO | sed s/\"//g)
        echo "$DOMAIN"; 
    done
}

# Convert a list of domains to their respective slugs
dash_domainstoslugs()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                dash_slug_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))

    read -ra arr <<<"$@"
    for slug in "${arr[@]}"; do 
        get_dealer_json $slug
        local JQPATH=".slug"
        local SLUG=$(jq $JQPATH <<< $DEALERINFO | sed s/\"//g)
        echo "$SLUG"; 
    done
}

# Opens dealer's site
dash_open()
{
    local PRODUCTION=false
    while getopts ":hp" opt; do
        case $opt in
            h)
                dash_open_usage
                exit
            ;;
            p)
                local PRODUCTION=true
            ;;
        esac
    done
    shift $((OPTIND -1))

    get_dealer_json $1

    if [[ $PRODUCTION == true ]]; then 
        local JQURLPATH=".url"
        local URL=$(jq $JQURLPATH <<< $DEALERINFO | sed s/\"//g)
    else 
        local JQURLPATH=".slug"
        local SLUG=$(jq $JQURLPATH <<< $DEALERINFO | sed s/\"//g)
        local URL="http://$SLUG.dev.dealerinspire.com"
    fi

    notify "Opening $URL\n"
    open $URL
}

# Get the dealer's URLs
dash_urls()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                dash_urls_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))

    get_dealer_json $1
    
    local URL=$(jq '.url' <<< $DEALERINFO | sed s/\"//g)
    
    local SLUG=$(jq '.slug' <<< $DEALERINFO | sed s/\"//g)
    local DEVURL="http://$SLUG.dev.dealerinspire.com"
    
    info "\nSLUG: $SLUG"
    emphasize "PROD: $URL\nDEV:  $DEVURL\n"
}

# Get the dealer's pod
dash_pod()
{   
    while getopts ":h" opt; do
        case $opt in
            h)
                dash_pod_usage
                exit
                ;;
        esac
    done
    shift $((OPTIND -1))

    local BRANCH=$1
    # first, look in cached dealer json
    # (also updates json if more than 24hr old)
    get_dealer_json $BRANCH
    POD=$(jq '.pod' <<< $DEALERINFO | sed s/\"//g)

    # then, if not in json, go directly at Dashboard API
    if [[ -z "$POD" ]]; then
        notify "Getting the pod number for $BRANCH from Dashboard"
        local url="https://dashboard.dealerinspire.com/api/v1/dealer/podnumber"
        POD="$(curl --get $url \
            --data branchName=${BRANCH} \
            --data-urlencode api_key=${DASH_API_KEY} \
            | jq -r '.pod')"
    fi
    
    # By now, there has to be a pod. It should've been set manually in the call to our script, found in the
    # cached json, or we should've received it from dashboard. If it's still not set, then we're wasting 
    # our time pulling prod
    if [[ -z "$POD" ]]; then
        error "No pod number could be found in the Dashboard."
        error "run 'devtools dash pod -h' for more info on this command."
        exit
    else
        # if we have a pod, but no branch, that means dash_pod wasn't passed a branch and get_dealers_json
        # defaulted to current local site, so get the slug from the dealerinfo cache we stored before
        if [[ -z "$BRANCH" ]]; then # if $
            local BRANCH=$(jq '.slug' <<< $DEALERINFO | sed s/\"//g)
        fi
        info "$BRANCH is on Pod number $POD\n"
    fi
}

# Main devtools dash process
devtools_dash()
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
                devtools_dash_usage
                exit
                ;;
        esac
    done
    shift $((OPTIND -1))

    if [[ -z $1 ]]; then
        devtools_dash_usage
        exit
    fi
}
