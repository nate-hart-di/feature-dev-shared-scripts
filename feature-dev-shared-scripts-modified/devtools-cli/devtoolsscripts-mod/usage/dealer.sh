#!/bin/bash

dealer_open_usage()
{
local usage="
Usage:  devtools dealer open [SLUG]

NOTE: 'devtools dealer open' now simply points to 'devtools dash open'.
      run 'devtools dash open -h' for more information on that command.

Opens the [SLUG], otherwise current local, site in default browser.
Default is to open the dev site.

Options:
  -h          Show this help text
  -p          Opens the production site
"

    printf "$usage"
}

devtools_dealer_usage()
{
local usage="
Usage:  devtools dealer COMMAND

NOTE: 'devtools dash' has been updated to include various dealer info commands.
      run 'devtools dash -h' for more information on that command.

Options:
  -h          Show this help text

Commands:
  open        Open the current dealer's site in default browser

Run 'devtools dealer COMMAND -h' for more information on a command (if we have any).
"

    printf "$usage" >&2
}
