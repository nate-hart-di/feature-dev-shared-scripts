#!/bin/bash

hg_which_usage()
{
local usage="
Usage:  devtools hg which [OPTIONS]

Equivalent to calling 'hg branch' in the dealer theme

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

hg_getdt_usage()
{
local usage="
Usage:  devtools hg getdt [OPTIONS]

Checkout and pull a branch - will also call 'wipedt'

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

hg_wipedt_usage()
{
local usage="
Usage:  devtools hg getdt [OPTIONS]

Wipe uncommitted changes in dealer theme (has prompt)

Options:
  -h          Show this help text

"

    printf "$usage" >&2
}

hg_diff_usage()
{
local usage="
Usage:  devtools hg diff [OPTIONS]

Show git-like file diffs for each hg log hash
Type 'q' to exit the log diff

Options:
  -h          Show this help text

"

    printf "$usage" >&2
}

devtools_hg_usage()
{
local usage="
Usage:  devtools hg [OPTIONS] COMMAND

Manage the Dealer Theme from anywhere

Options:
  -h          Show this help text

Commands:
  diff        Show git-like file diffs for each hg log hash
  getdt       Checkout and pull a branch - will also call 'wipedt'
  which       Equivalent to calling 'hg branch' in the dealer theme
  wipedt      Wipe uncommitted changes in dealer theme (has prompt)

Run 'devtools hg COMMAND -h' for more information on a command (if we have any).

"

    printf "$usage" >&2
}
