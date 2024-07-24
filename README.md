# Feature Dev Shared Scripts

## RULES

- Make a new folder per script.
- Leave a little README.md in each script's folder describing:
	- what it is.
	- how to set it up.
	- how to run it.
- Don't commit executables - leave that up to the end user.
- Try to add a brief description to this README of what your script(s) does.

## Scripts

- `di-wp-docker`: Docker drop-in replacement for the DI Vagrant VM
- `clear-algolia-rows-from-db`: Scripts to clear the Algolia rows from the options table.
- `update-common-core-plugins`: PHP version of a DI Dev Tools.app feature, to update local stuff for what current DealerTheme requires.

## Upgrade to Use Multiple Databases:

1. Edit your existing ```~/code/dealerinspire/feature-dev-shared-scripts/di-wp-docker/docker-compose.yml``` file

2. Replace this line:

``` - ./mysql/lib:/var/lib/mysql:cached ```

3. With this block (See docker-compose-example.yml) for full example:

<pre>
<code>
	- db_demo_dev:/var/lib/mysql
healthcheck:
	test: ["CMD-SHELL", "mysqladmin ping -pdealer_inspire | grep 'mysqld is alive' || exit 1"]
  	start_period: 5s
  	interval: 5s
  	timeout: 5s
  	retries: 10
</code>
</pre>

4. Finally add this block to the end of the docker-compose.yml file:

<pre>
<code>
volumes:
	db_demo_dev:
		name: db_demo_dev
		labels:
			- "com.di_platform_db.active=db_demo_dev"
			- "com.di_platform_db.downloaded=db_demo_date" 
</code>
</pre>