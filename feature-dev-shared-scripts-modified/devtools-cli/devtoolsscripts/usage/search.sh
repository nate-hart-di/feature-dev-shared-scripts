#!/bin/bash

devtools_search_usage()
{
local usage="
Usage:  devtools search [OPTIONS] [SEARCH TEXT]

Search for text in Dealer Name/Slug/URL

By default matches partial words and is case insensitive

Options:
  -h          Show this help text
  -e          Exact word match
  -s          Case sensitive search
  
"

    printf "$usage"
}