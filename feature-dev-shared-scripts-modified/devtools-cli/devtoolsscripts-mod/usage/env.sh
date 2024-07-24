#!/bin/bash

env_get_usage()
{
local usage="
Usage:  devtools env get [OPTIONS] KEY

Query the value of a variable

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

env_set_usage()
{
local usage="
Usage:  devtools env set [OPTIONS] KEY VALUE

Insert or Replace an environment variable.

Wrapper function for env_update and env_insert. This
determines which of those to use.

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

env_insert_usage()
{
local usage="
Usage:  devtools env insert [OPTIONS] KEY VALUE

Insert an environment variable.

Always appends to end of env file.

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

env_update_usage()
{
local usage="
Usage:  devtools env update [OPTIONS] KEY VALUE

Remove the current row with this key, and append a new row with the new value.

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

devtools_env_usage()
{
local usage="
Usage:  devtools env [OPTIONS] COMMAND

Query or Set environment variables

Options:
  -h          Show this help text

Commands:
  get         Query the value of a variable
  init        Check if the env file exists, and walk through prompt for any and all missing variables
  insert      Insert an environment variable
  set         Insert or Replace an environment variable
  update      Remove the current row with this key, and append a new row with the new value

Run 'devtools env COMMAND -h' for more information on a command (if we have any).
"

    printf "$usage" >&2
}
