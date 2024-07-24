#!/bin/bash

devtools_rebuild_usage()
{
    local usage="
    Usage: devtools rebuild [OPTIONS] [SLUG]
    
    Rebuild individual websites and satis. MacOS only. Sorry, Andrew.
    Requires websites-console

    Options:
            Rebuild dev site
    -h      Show this help text
    -c|-l   Rebuild current local site (does not need slug).
    -p      Rebuild production site
    -s      Rebuild satis (does not need slug).

"
    printf "$usage" >&2
}