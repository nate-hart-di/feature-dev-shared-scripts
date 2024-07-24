#!/bin/bash

devtools_php_usage()
{
    local usage="
    Usage: devtools php [OPTIONS] [VERSION]
    
    Switch local PHP versions. MacOS only. Must remove old versions manually if they are in your PATH (./zshrc).
    
    Options:
    -h      show this help text

"
    printf "$usage" >&2
}