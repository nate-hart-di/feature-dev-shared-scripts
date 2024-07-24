#!/bin/bash

dash_dealers_usage()
{
local usage="
Usage:  devtools dash [OPTIONS] [SLUG|DOMAIN]

Query the active dealers from the Dashboard and cache the results
Default only queries Dashboard if cache is 24hr+ old

Options:
  -f          Force query the Dashboard API and override cached blob
  -h          Show this help text

"

    printf "$usage"
}

dash_pod_usage()
{
local usage="
Usage:  devtools dash pod [OPTIONS] [SLUG|DOMAIN]

Get the pod# a branch lives on

Options:
  -h          Show this help text

"

    printf "$usage"
}

dash_info_usage()
{
local usage="
Usage:  devtools dash info [OPTIONS] [SLUG|DOMAIN]

Get all basic info for a branch

Options:
  -h          Show this help text

"

    printf "$usage"
}

dash_domain_usage()
{
local usage="
Usage:  devtools dash domain [OPTIONS] [SLUG]

Get the domain for a branch

Options:
  -h          Show this help text

"

    printf "$usage"
}

dash_slug_usage()
{
local usage="
Usage:  devtools dash slug [OPTIONS] [SLUG]

Get the slug for a branch

Options:
  -h          Show this help text

"

    printf "$usage"
}

dash_domainstoslugs_usage()
{
local usage="
Usage:  devtools dash domainstoslugs [DOMAIN] [DOMAIN] [DOMAIN] ...

Convert a list of domains to their respective slugs

Options:
  -h          Show this help text

"

    printf "$usage"
}

dash_slugstodomains_usage()
{
local usage="
Usage:  devtools dash slugstodomains [SLUG] [SLUG] [SLUG] ...

Convert a list of slugs to their respective domains

Options:
  -h          Show this help text

"

    printf "$usage"
}

dash_urls_usage()
{
local usage="
Usage:  devtools dash urls [OPTIONS] [SLUG|DOMAIN]

Get the Prod and Dev URLs for a branch

Options:
  -h          Show this help text

"

    printf "$usage"
}

dash_open_usage()
{
local usage="
Usage:  devtools dash open [OPTIONS] [SLUG|DOMAIN]

Open in browser the URL for a branch
Default is DEV URL

Options:
  -p          Open PROD URL for a branch
  -h          Show this help text

"

    printf "$usage"
}

devtools_dash_usage()
{
local usage="
Usage:  devtools dash [OPTIONS] COMMAND

Query data from the Dealer Dashboard

Options:
  -f          Force query the Dashboard API and override cached blob
  -h          Show this help text

Commands:
  info              Get all basic info for a slug|domain
  pod               Get the pod# a slug|domain lives on
  domain            Get the domain for a slug
  urls              Get the Prod and Dev URLs for a slug|domain
  open              Open the Dev or Prod URL for a slug|domain
  slugstodomains    Convert a list of slugs to their respective domains
  domainstoslugs    Convert a list of domains to their respective slugs

Run 'devtools dash COMMAND -h' for more information on a command (if we have any).

"

    printf "$usage" >&2
}
