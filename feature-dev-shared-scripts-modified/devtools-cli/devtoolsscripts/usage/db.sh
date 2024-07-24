#!/bin/bash

db_clean_usage()
{
local usage="
Usage:  devtools db clean [OPTIONS]

Drop and then Create the database in the database Container

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_definer_usage()
{
local usage="
Usage:  devtools db definer [OPTIONS]

If the definer is in the /tmp/backup.sql file, remove it so we import correctly

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_getDev_usage()
{
local usage="
Usage:  devtools db getDev [OPTIONS]

Pull down the development database and place in /tmp/backup.sql

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_getProd_usage()
{
local usage="
Usage:  devtools db getProd [OPTIONS]

Pull down the production database and place in /tmp/backup.sql

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_import_usage()
{
local usage="
Usage:  devtools db import [OPTIONS]

Cleanup the database Container, and insert the new sql file

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_unzip_usage()
{
local usage="
Usage:  devtools db unzip [OPTIONS]

Unzip and cleanup the database file in /tmp

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_ls_usage()
{
local usage="
Usage:  devtools db ls [OPTIONS]

Lists the local database volumes

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_prune_usage()
{
local usage="
Usage:  devtools db prune [OPTIONS]

Removes all local database volumes

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_rm_usage()
{
local usage="
Usage:  devtools db rm [OPTIONS]

Remove one, multiple or all local database volumes

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_prodSize_usage()
{
local usage="
Usage:  devtools db prodSize [OPTIONS] BRANCH

Returns the DB backup size for the Production database

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

db_devSize_usage()
{
local usage="
Usage:  devtools db devSize [OPTIONS] BRANCH

Returns the DB backup size for the Development database

Options:
  -h          Show this help text
"

    printf "$usage" >&2
}

devtools_db_usage()
{
local usage="
Usage:  devtools db [OPTIONS] COMMAND

Manage database related items on your localhost

Options:
  -h          Show this help text

Commands:
  clean       Drop and then Create the database
  definer     If the definer is in the /tmp/backup.sql file, remove it so we import correctly
  getDev      Pull down the Development database and place in /tmp/backup.sql
  getProd     Pull down the Production database and place in /tmp/backup.sql
  import      Cleanup the database Container and insert the new sql file
  ls|list     Lists the local database volumes
  prune       Removes all local database volumes
  rm          Remove one, multiple or all local database volumes
  unzip       Unzip and cleanup the database backup file in /tmp
  user        On production database's, the DI user is not set for local environments

Run 'devtools db COMMAND -h' for more information on a command (if we have any).
"

    printf "$usage" >&2
}
