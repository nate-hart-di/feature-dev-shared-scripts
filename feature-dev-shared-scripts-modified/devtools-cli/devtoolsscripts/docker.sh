#!/bin/bash

###########################################
# Dev Tools Docker Scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# E.g. `devtools docker ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/docker.sh"

# Start the docker containers
docker_up()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                docker_up_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    notify "Running docker-compose up"
    docker-compose -f $DOCKER_COMPOSE_FILE up -d
    info "Docker containers are running\n"
}

# Stop and remove the docker containers
docker_down()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                docker_down_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    notify "Running docker-compose down"
    docker-compose -f $DOCKER_COMPOSE_FILE down
    info "Docker containers are now down\n"
}

# Stop the docker containers (without removing them)
docker_stop()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                docker_stop_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    notify "Running docker-compose stop"
    docker-compose -f $DOCKER_COMPOSE_FILE stop
    info "Docker containers are now stopped\n"
}

docker_clearcache() {
    while getopts ":h" opt; do
        case $opt in
            h)
                docker_clearcache_usage
                exit
            ;;
        esac
    done
    docker exec -it "$(docker ps --filter name=web -q)" /bin/bash -c 'env APPLICATION_ENV=local php bootstrap/clear_cache.php'
}

# Make sure the docker db container is stopped
docker_stop_db_container()
{
    notify "Stopping Docker database container"
    docker container stop di_platform_db &> /dev/null
    info "Stopped Docker database container\n"
}

# Gets the current docker db downloaded meta name
docker_get_db_downloaded_current()
{
    echo $(grep 'com.di_platform_db.downloaded' $DOCKER_COMPOSE_FILE | sed 's/"//g' | cut -d'=' -f2)
}

# Gets the current docker volume meta name
docker_get_volume_current()
{
    echo $(grep 'com.di_platform_db.active' $DOCKER_COMPOSE_FILE | sed 's/"//g' | cut -d'=' -f2)
}

# Gets the new docker volume name
docker_get_volume_new()
{
    
    if [ "$PRODUCTION" == true ]
    then
        echo "db_${1}_prod"
    else
        echo "db_${1}_dev"
    fi
}

# Check if database is a current volume
docker_volume_check()
{



    local volume_new="$(docker_get_volume_new "$1")"
    
    if [ "$(docker volume ls | grep -c $volume_new)" -eq 1 ]; then
        echo
        success "Found an existing local database for $1:"
        docker_volume_list "$volume_new"
        
        echo
        echo -e "(${YELLOW}U${NC})se this existing local database"
        echo -e "(${YELLOW}D${NC})ownload a new database backup"
        echo
        
        while true; do
            read -r -p "Choose [U/d]: " RESPONSE
            RESPONSE=${RESPONSE:-U}
            case "$RESPONSE" in
                [uU])
                    DOWNLOAD_DB=false
                    break
                ;;
                [dD])
                    DOWNLOAD_DB=true
                    break
                ;;
                *)
                    error "Invalid choice\n"
            esac
        done
    fi

    if [ "$DOWNLOAD_DB" == true ]; then
        if [ "$PRODUCTION" == true ]; then db_prodSize "$BRANCH"; else db_devSize "$BRANCH"; fi
    fi 

    docker_volume_use "$1"
    echo
}

docker_volume_use()
{
    local volume_current="$(docker_get_volume_current)"
    local volume_new="$(docker_get_volume_new "$1")"
    
    docker compose -f $DOCKER_COMPOSE_FILE config -q
    local validate_before_status=$?
    
    if [ "$validate_before_status" -ne 0 ]; then
        error "Docker compose file was not valid prior to edits.\n"
        exit 1
    fi
    
    cp $DOCKER_COMPOSE_FILE $DOCKER_COMPOSE_BAK_FILE
    perl -i -pe "s/$volume_current/$volume_new/g;" $DOCKER_COMPOSE_FILE
    local swap_volume_status=$?
    
    if [ "$swap_volume_status" -ne 0 ]; then
        cp $DOCKER_COMPOSE_BAK_FILE $DOCKER_COMPOSE_FILE
        rm $DOCKER_COMPOSE_BAK_FILE
        error "Edit to swap volumes in docker compose file failed. Backup was restored.\n"
        exit 1
    fi
    
    if [ "$DOWNLOAD_DB" == true ]; then
        local db_downloaded_current="$(docker_get_db_downloaded_current)"
        local db_downloaded_new="$(date +'%a %m-%d-%Y %I:%M:%S%p')"
        perl -i -pe "s/$db_downloaded_current/$db_downloaded_new/g;" $DOCKER_COMPOSE_FILE
        local update_downloaded_date_status=$?
        
        if [ "$update_downloaded_date_status" -ne 0 ]; then
            cp $DOCKER_COMPOSE_BAK_FILE $DOCKER_COMPOSE_FILE
            rm $DOCKER_COMPOSE_BAK_FILE
            error "Edit to update downloaded date in docker compose file failed. Backup was restored.\n"
            exit 1
        fi
    fi
    
    docker compose -f $DOCKER_COMPOSE_FILE config -q
    local validate_after_status=$?
    
    if [ "$validate_after_status" -ne 0 ]; then
        cp $DOCKER_COMPOSE_BAK_FILE $DOCKER_COMPOSE_FILE
        rm $DOCKER_COMPOSE_BAK_FILE
        error "Docker compose file was not valid after edits. Backup was restored.\n"
        exit 1
    fi
    
    rm $DOCKER_COMPOSE_BAK_FILE
}

# Lists one or more docker volumes
docker_volume_list()
{
    local volume_node
    local db_date
    local status
    local i=1
    local prefix=' '
    local columns=70
    local space
    
    local volume_current="$(docker_get_volume_current)"
    
    if [ $(docker volume ls | grep -c "$1") -eq 0 ]; then
        error "No Docker database volumes found.\n"
        exit 1
    fi
   
    if [ $2 ]; then space='    '; else space=''; fi
       

    printf %${columns}s | tr " " "-"
    notify "\n${space} Downloaded                   Type     Branch"
    printf %${columns}s | tr " " "-"
    echo
    
    while IFS= read -r VOLUMES
    do
        status=''
        volume_node="${VOLUMES//local     /}"
        db_date=$(docker volume inspect --format '{{ index .Labels "com.di_platform_db.downloaded" }}' $volume_node)
        
        if [ $volume_node == $volume_current ]; then status=" ${YELLOW} Active${NC}"; fi
        
        if [ $2 ]; then
            if [ "$i" -lt 10 ]; then space='  '; else space=' '; fi
            prefix="${NC}${space}${i}.${BLUE} "
        fi
        
        if [ $(echo $VOLUMES | grep -c "_dev") -eq 1 ]; then
            VOLUMES="${VOLUMES/_dev/}"
            VOLUMES="${VOLUMES/local /Dev  }"
        fi
        
        if [ $(echo $VOLUMES | grep -c "_prod") -eq 1 ]; then
            VOLUMES="${VOLUMES/_prod/}"
            VOLUMES="${VOLUMES/local /Prod }"
        fi
        
        info "${prefix}${db_date}    ${VOLUMES/db_/}$status"
        
        i=$((i+1))
    done < <(docker volume ls | grep "$1")
    
    echo
}

docker_volume_delete()
{
    local volume_node
    local volume_current="$(docker_get_volume_current)"
    
    while IFS= read -r VOLUMES
    do
        volume_node="${VOLUMES/local     /}"
        
        if [ $volume_node == $volume_current ]
        then
            notify "Skipped $volume_current"
        else
            info "Deleted $volume_node"
            docker volume rm $volume_node &> /dev/null
        fi
    done < <(docker volume ls | grep "$1")
}

docker_volume_rm()
{
    local i=1
    
    echo
    docker_volume_list "db_" true
    echo -e "\n- Enter a single number to delete a database."
    echo -e "- Enter multiple numbers seperated with a space."
    echo -e "- Enter (${YELLOW}A${NC}) to delete ${YELLOW}all${NC} databases."
    echo -e "- Enter (${YELLOW}C${NC}) to ${YELLOW}Cancel${NC}.\n"
    printf "Choice: "
    read -a RESPONSE
    
    case "${RESPONSE[0]}" in
        [cC])
            notify "\nCanceled"
            exit
        ;;
        [aA])
            docker_volume_prune true
            exit
        ;;
        *)
        ;;
    esac
    
    local volume_array=()
    
    while IFS= read -r VOLUMES
    do
        volume_array[${i}]="${VOLUMES//local     /}"
        i=$((i+1))
    done < <(docker volume ls | grep "db_")

    for VALUE in "${RESPONSE[@]}"
    do
        if [ ! -z "${volume_array[${VALUE}]}" ]; then
            docker_volume_delete "${volume_array[${VALUE}]}"
        fi
    done
}

docker_volume_prune()
{
    if [ ! $1 ]; then
        echo
        docker_volume_list "db_" true
    fi
    echo
    read -r -p "$(echo -e "${YELLOW}Do you want to delete all of these local databases? ${NC}[y/n]: ")" RESPONSE
    case $RESPONSE in
        [yY])
            echo
            docker_volume_delete "db_"
            exit
        ;;
        [nN])
            exit
        ;;
        *)
            exit
        ;;
    esac
}

docker_mysql_health()
{
    printf "${YELLOW}Waiting for MySQL to initialize"
    local mysql_waiting=0
    local mysql_alive=false
    
    while [ "$mysql_waiting" -le 15 ];
    do
        printf "${NC}...."
        MYSQL_HEALTH=$(docker inspect --format "{{.State.Health.Status}}" di_platform_db)
        if [ "$MYSQL_HEALTH" == "healthy" ]; then
            mysql_alive=true
            break
        fi
        sleep 2
        mysql_waiting=$((mysql_waiting+1))
    done
    if [ "$mysql_alive" == false ]
    then
        error "\nMySQL did not initialize correctly :("
        exit 1
    else
        info "MySQL initialized\n"
    fi
}

# Main devtools docker process
devtools_docker()
{
    COMMAND="$(basename "$1")"
    local DOCKERCOMMAND=$2
    shift
    
    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools docker up` matches `docker_up`
    file_has_function $@ # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$DOCKERCOMMAND $@
        exit
    fi
    
    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_docker_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    devtools_docker_usage
}
