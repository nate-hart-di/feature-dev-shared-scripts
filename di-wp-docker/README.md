# DI Wordpress on Docker

## Warnings

1. This is a Docker stand-in for the DI Vagrant setup. This should only be used if you're willing to support issues related to your development yourself. The systems team will almost certainly not help to troubleshoot your issues. It is recommended to use the Vagrant environment anyway, as it replicates our Production environment more similarly and is officially supported.
2. You do not get the luxury of DI Dev Tools. You get the devtools-cli (also in this repo, different directory).


## Setup

### Requirements

Please have these installed prior to running the setup script.

- [Docker Daemon](https://docs.docker.com/install/)
- Your preferred mysql cli tool. Supported:
    - mysql - `brew install mysql`
    - mycli - `brew install mycli`

### Automated Script

`./setup.sh`

This will prompt you for a few values, including:

1. The path to your `dealerinspire-core/` directory
2. The path to this directory
3. Your preferred mysql cli tool

### Manual Setup things

These must be done in addition to the automated script.

1. `source ~/.bash_profile` so you get the new commands.
2. Update the DB settings in the DI WP directory. `dealerinspire-core/db.php` is the file. We're changing the array at key `local`. I would recommend commenting out the current entry at `local` and adding this one, so you can easily switch back to the Vagrant DB settings if needed. This is what you need for this docker setup:

    ```
    'local' => array(
            'adapter' => 'mysql',
            'host' => 'di_platform_db',
            'name' => 'dealerinspire_dev',
            'user' => 'dealer_inspire',
            'pass' => 'awesome1234',
            'port' => 3306
    )
    ```
3. `cp php/php.ini.example php/php.ini` to get the opcache performnce upgrades and default xdebug overrides. Make changes to this `php.ini` file as you want - it won't be overwritten by future changes to this repo.
4. Wherever Redis gets used, we need to make sure it's config is not looking just for `127.0.0.1`, since we run Redis in a separate container. (Don't commit these changes).
    - Inventory Plugin
        - `inventory/classes/cache.php`. Look for the Redis config host and change it to `'host' => $_SERVER['REDIS_HOST'] ?? '127.0.0.1',`

## Running

1. Make sure your Docker Daemon is running.
2. `dup` (alias) will run the `docker-compose up -d` from the correct directory for you.
3. The first time you do this, you'll need to import a database. See notes in `devtools-cli` to do this.

You should be good to go. Visit http://127.0.0.1:9081

## Docker Aliases

- `df` takes you into this folder
- `dup` starts your docker containers
- `dssh` puts you into the `web` container. It's basically like sshing into the Vagrant machine.
- `dhalt` stops the containers
- `ddb` puts you into MySQL on the command line
- `dreboot` is equivalient to doing a `dhalt` and `dup`
- `dredis` puts you in the Redis container running `redis-cli`
- `dtoggle` enables or disables XDebug in the `web` container

## MySQL Client

The MySQL client is available in the `di_wp_docker_web` container.

This means you can `dssh` into the web container and have mysql access to the `di_platform_db` container.

Example:  `mysql -u dealer_inspire -pawesome1234 -h di_platform_db dealerinspire_dev`

### XDebug

XDebug is Enabled by default.  

XDebug can degrade performance on Docker.  It is recommended that you disable XDebug unless you need to use it. (See `dtoggle`)

You can edit the XDebug settings in your local `di-wp-docker/php/conf.d/docker-php-ext-xdebug.ini` file.

## VSCode XDebug Launch file
Replace USERNAME with your actual username

    {
        "version": "0.2.0",
        "configurations": [
          {
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
              "/var/www": "/Users/USERNAME/code/dealerinspire/dealerinspire-core"
            },
            "log": true,
          }
        ]
      }
      
### Opcache

Opcache is Enabled by default.

You can edit the Opcache settings in your local `di-wp-docker/php/conf.d/docker-php-ext-opcache.ini` file.
