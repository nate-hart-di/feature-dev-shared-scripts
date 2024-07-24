#!/bin/bash

docker_up_usage()
{
local usage="
Usage:  devtools docker up [OPTIONS]

Calls 'docker-compose up -d' on the docker-compose file specified for DI WP.

Options:
  -h          Show this help text

"

    printf "$usage" >&2
}

docker_down_usage()
{
local usage="
Usage:  devtools docker down [OPTIONS]

Calls 'docker-compose down' on the docker-compose file specified for DI WP.

Options:
  -h          Show this help text

"

    printf "$usage" >&2
}

docker_stop_usage()
{
local usage="
Usage:  devtools docker stop [OPTIONS]

Calls 'docker-compose stop' on the docker-compose file specified for DI WP.

Options:
  -h          Show this help text

"

    printf "$usage" >&2
}

docker_clearcache_usage()
{
local usage="
Usage:  devtools docker clearcache [OPTIONS]

SSHs into docker web container to run bootstrap/clear_cache.php

Options:
  -h          Show this help text

"

    printf "$usage" >&2
}

devtools_docker_usage()
{
local usage="
Usage:  devtools docker [OPTIONS] COMMAND

Call docker helper scripts related to devtools

Options:
  -h          Show this help text

Commands:
  clearcache    Run bootstrap/clear_cache on the docker web container.
  up            Start the docker containers.
  stop          Stop the docker containers.
  down          Stop and remove the docker containers.

Run 'devtools docker COMMAND -h' for more information on a command (if we have any).

"

    printf "$usage" >&2
}
