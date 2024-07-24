#!/bin/bash

###########################################
# Dev Tools DB Scripts
# Always meant to be called from within the
# `devtools` script - not standalone
#
# E.g. `devtools db ...`
###########################################
source "$SCRIPTPATH/devtoolsscripts/usage/db.sh"

# Pull down the production database, and place in /tmp/backup.sql
db_getProd()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_getProd_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    local BRANCH=$1
    dash_pod "$BRANCH"
    
    if [[ $OSTYPE == 'darwin'* ]]; then
        local DAY="$(date -v -1d +%A)"
    else
        local DAY="$(date +%A  --date='1 day ago')"
    fi
    
    notify "Downloading ${BRANCH} production database"

    ssh $SSH_USERNAME@deploy.pod$POD.dealerinspire.com "cat /mnt/di_backup/daily/databases/${BRANCH}_${DAY}.sql.gz" > /tmp/backup.sql.gz
    
    info "Downloaded ${BRANCH} production database\n"
    
    db_unzip
}

# Pull down the development database, and place in /tmp/backup.sql
db_getDev()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_getDev_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    local BRANCH=$1
    
    notify "Downloading ${BRANCH} development database"

    ssh $SSH_USERNAME@a.dev.dealerinspire.com "cat /var/www/backups/daily/${BRANCH}_current.sql.gz" > /tmp/backup.sql.gz
    
    info "Downloaded ${BRANCH} development database\n"
    
    db_unzip
}

db_devSize()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_devSize_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))

    # Capture the output of the du command, which gives the file size in KB
    local FILE_SIZE_KB=$(ssh $SSH_USERNAME@a.dev.dealerinspire.com "du -k /var/www/backups/daily/${BRANCH}_current.sql.gz" | cut -f1)

    # Convert the file size to MB
    local FILE_SIZE_MB=$((FILE_SIZE_KB / 1024))

    # Check if MAXDBSIZE is set and not empty
    if [[ -z ${MAXDBSIZE} ]]; then
        # If MAXDBSIZE is not set or empty, set it to 100
        devtools env insert MAXDBSIZE 100
        source $SCRIPTPATH/.devtools.env
    fi

    # Check if the file size is greater than MAXDBSIZE
    if (( FILE_SIZE_MB > MAXDBSIZE )); then
        read -p "This DB is $FILE_SIZE_MB MB. Do you want to continue? (y/n) " -n 1 -r
        echo    # Move to a new line
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

}

db_prodSize()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_prodSize_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    if [[ -z $POD ]]; then
        dash_pod "$BRANCH"
    fi

    if [[ $OSTYPE == 'darwin'* ]]; then
        local DAY="$(date -v -1d +%A)"
    else
        local DAY="$(date +%A  --date='1 day ago')"
    fi

    # Capture the output of the du command, which gives the file size in KB
    local FILE_SIZE_KB=$(ssh $SSH_USERNAME@deploy.pod$POD.dealerinspire.com "du -k /mnt/di_backup/daily/databases/${BRANCH}_${DAY}.sql.gz" | cut -f1)

    # Convert the file size to MB
    local FILE_SIZE_MB=$((FILE_SIZE_KB / 1024))

    # source $SCRIPTPATH/.devtools.env

    # Check if MAXDBSIZE is set and not empty
    if [[ -z ${MAXDBSIZE} ]]; then
        # If MAXDBSIZE is not set or empty, set it to 100
        devtools env insert MAXDBSIZE 200
        source $SCRIPTPATH/.devtools.env
    fi

    # Check if the file size is greater than MAXDBSIZE
    if (( FILE_SIZE_MB > MAXDBSIZE )); then
        read -p "This DB is $FILE_SIZE_MB MB. Do you want to continue? (y/n) " -n 1 -r
        echo    # Move to a new line
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Cleanup the DB file in /tmp
db_unzip()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_unzip_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    if [ -f /tmp/backup.sql ]; then
        rm /tmp/backup.sql
    fi
    gunzip /tmp/backup.sql.gz
    db_definer
}

# If the definer is in the sql file, remove it so we import correctly
db_definer()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_definer_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    notify "Updating data in the SQL backup file"
    if [[ $OSTYPE == 'darwin'* ]]; then
        sed -i '' -e "/DEFINER/d" -e "s/^SET @/-- SET @/g" /tmp/backup.sql
    else
        sed -i -e "/DEFINER/d" -e "s/^SET @/-- SET @/g" /tmp/backup.sql
    fi
    info "Updated data in the SQL backup file\n"
}

# Cleanup the DB Container, and insert the new sql file
db_import()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_import_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    db_clean
    
    notify "Importing tables and data from the SQL backup file"
    $mysqlconnect -D dealerinspire_dev < /tmp/backup.sql
    
    db_update_prefix
    
    info "Imported tables and data from the SQL backup file\n"
}

db_update_prefix()
{
        local prefix=$(echo "SELECT REPLACE(TABLE_NAME, 'options', '') AS prefix FROM information_schema.TABLES WHERE TABLE_NAME LIKE 'wp%_options%' LIMIT 1" | $mysqlconnect -D information_schema | sed -n 2p)
        sed -i -e "s/define('TABLE_PREFIX','.*')\;/define('TABLE_PREFIX','$prefix');/g" "${WP_CORE_DIRECTORY}wp-site-config.php"
}

# Drop all views and tables from the database
db_clean()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_clean_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    # faster to just drop database and recreate it!
    notify "Dropping existing SQL tables and data"
    $(echo "DROP DATABASE IF EXISTS dealerinspire_dev; CREATE DATABASE dealerinspire_dev;" | $mysqlconnect -D information_schema | sed -n 2p)
    info "Dropped existing SQL tables and data\n"
}

# Echo the DB Prefix
db_prefix()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_prefix_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    local prefix=$(echo "SELECT REPLACE(TABLE_NAME, 'options', '') AS prefix FROM information_schema.TABLES WHERE TABLE_NAME LIKE 'wp%_options%' LIMIT 1" | $mysqlconnect -D information_schema | sed -n 2p)
    echo $prefix
}

# On production DB's, the DI user is not set for local environments
db_user()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_user_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    notify "Updating the DI User"
    
    # Get the DB Prefix
    local prefix=$(echo "SELECT REPLACE(TABLE_NAME, 'options', '') AS prefix FROM information_schema.TABLES WHERE TABLE_NAME LIKE 'wp%_options%' LIMIT 1" | $mysqlconnect -D information_schema | sed -n 2p)
    
    # Update password to `awesome1234`
    echo "UPDATE ${prefix}users SET user_pass='dbf131c6abe7d0b48490e22e0161c61d' WHERE ID = 1;" | $mysqlconnect -D dealerinspire_dev
    info "Updated the DI User: can now sign in with awesome1234\n"
}

db_list()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_ls_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    docker_volume_list "db_"
}

db_ls() {
    while getopts ":h" opt; do
        case $opt in
            h)
                db_ls_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    db_list
}

db_prune()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_prune_usage
                exit
            ;;
        esac
    done

    docker_volume_prune
}

db_rm()
{
    while getopts ":h" opt; do
        case $opt in
            h)
                db_rm_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    docker_volume_rm
}

# Main devtools docker process
devtools_db()
{
    COMMAND="$(basename "$1")"
    local DBCOMMAND=$2
    shift
    
    # If the command in position $2 exactly matches one of the above
    # functions, call it directly.
    # e.g. `devtools docker up` matches `docker_up`
    file_has_function $@ # file_has_function exists in the `helpers` file
    if [ $? -eq 1 ]; then
        shift
        ${COMMAND}_$DBCOMMAND $@
        exit
    fi
    while getopts ":h" opt; do
        case $opt in
            h)
                devtools_db_usage
                exit
            ;;
        esac
    done
    shift $((OPTIND -1))
    
    devtools_db_usage
}