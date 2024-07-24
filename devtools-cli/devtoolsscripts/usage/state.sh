#!/bin/bash

state_get_usage()
{
local usage="
Usage:  devtools state get KEY

Retrieve a saved DealerTheme state

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

state_save_usage()
{
local usage="
Usage:  devtools state save KEY

Save the state of DealerTheme to be retrieved later

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

state_list_usage()
{
local usage="
Usage:  devtools state list

List all saved states

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

state_reset_usage()
{
local usage="
Usage:  devtools state reset

Delete all saved states

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

devtools_state_usage()
{
local usage="
Usage:  devtools state COMMAND

Manage the state of your DealerTheme, for switching branches and databases. CURRENTLY ONLY SUPPORTS DATABASE; NOT HG!

Options:
  -h          Show this help text

Commands:
  get         Retrieve a saved DealerTheme state
  save        Save the state of DealerTheme to be retrieved later
  list        List all saved states
  reset       Delete all saved states

Run 'devtools state COMMAND -h' for more information on a command (if we have any).
"

    printf "$usage" >&2
}
