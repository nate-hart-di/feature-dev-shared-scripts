#!/bin/bash

######################################################
# array_contains checks if a string exists in an array
# Takes two arguments:
#   string
#   array
#
# Example:
#   local myString="foo"
#   local myArray=(foo bar baz)
#   array_contains $myString ${myArray[@]}
#   return $?
######################################################
array_contains() {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 1; done
    return 0
}


######################################################
# file_has_function Retreives a list of functions
# that exist in a file, then checks if a particular
# function exists in that list.
######################################################
file_has_function()
{
    # get the path to the file that called this function
    local filename="$SCRIPTPATH/devtoolsscripts/$COMMAND.sh"
    
    # create the regex pattern to find the functions in the file
    # Assumes that functions are namespaced with `$COMMAND_`
    local pattern="${COMMAND}_[\w_]*\(\)"
    
    # Parse the functions out of the file
    local filefunctions=($(cat $filename | grep $pattern | cut -d '(' -f1))
    
    # Create the full function name we're looking for
    # Assumes that functions are namespaced with `$COMMAND_`
    local fullFunctionName="${COMMAND}_$1"
    
    # Call the array_contains function
    array_contains $fullFunctionName ${filefunctions[@]}
    
    # return the response from array_contains
    return $?
}

# Function to switch Docker volume
switch_docker_volume() {
    local site=$1

    echo "Stopping MySQL container"
    docker stop mysql_container

    echo "Switching volume to ${site}"
    docker volume rm ${site}_volume
    docker volume create --name ${site}_volume

    echo "Starting MySQL container with new volume"
    docker run -d --name mysql_container -v ${site}_volume:/var/lib/mysql mysql
}
