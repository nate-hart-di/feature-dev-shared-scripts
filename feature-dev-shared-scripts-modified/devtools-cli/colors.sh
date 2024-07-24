#!/bin/bash

######################
# Example:
#   notify "This is some yellow text"
#
# Multiple colors:
#   error "Red text until ${BLUE}we decide to use blue and now switch to ${NC}no color."
######################

# Colors
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
GREEN='\033[1;32m'
NC='\033[0m'
BOLD='\033[1m'

# Colored output
notify()
{
    printf "${YELLOW}${1}${NC}\n"
}

error()
{
    printf "${RED}${1}${NC}\n" >&2 
}

info()
{
    printf "${BLUE}${1}${NC}\n"
}

success()
{
    printf "${GREEN}${1}${NC}\n"
}

emphasize()
{
    printf "${BOLD}${1}${NC}\n"
}