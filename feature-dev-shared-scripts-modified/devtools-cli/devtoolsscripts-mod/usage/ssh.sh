#!/bin/bash

devtools_ssh_usage()
{
  local usage="
Usage:  devtools ssh [OPTIONS] [POD# | SLUG | DOMAIN]

SSH into a pod.
Can pass a pod#, slug, or domain.
Nothing passed defaults to getting pod# of current local dealer.

Options:
  -h          Show this help text

"

  printf "$usage"
}