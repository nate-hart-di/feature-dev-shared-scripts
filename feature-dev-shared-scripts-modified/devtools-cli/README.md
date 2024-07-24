**[Install devtools CLI Docker Environment](https://carscommerce.atlassian.net/wiki/spaces/FT/pages/470941811/Local+Install+devtools+CLI+Docker+Environment)**

If you previously completed devtools CLI installation, then `git pull` in your `feature-dev-shared-scripts` dir to get the latest updates.

Following the installation steps linked above should make `devtools` commands available globally (for use in Terminal/shell from any directory).

To shorten the command, add the following to your `~/.bashrc` or `~/.zshrc` file. Then everywhere `devtools` is below can be replace with `dt`. Like `dt search advantagebmw` .

```
alias dt="devtools $@"
```

  
[TOC]


## Basic command structure

`devtools [options] [slug|domain|url]`

`devtools [command] [options] [slug|domain|url]`

`devtools [command] [subcommand] [options] [slug|domain|url]`

## Search branches

```
devtools search advantagebmw
devtools search www.advantage
devtools search advantage bmw
```


## Get dealer info

```
devtools dash info advantagebmw
devtools dash info advantagebmwhouston.com
devtools dash info https://www.advantagebmwhouston.com/about-us
```

### Current/local branch

```
devtools dash info
```

## Checkout branch + db (DealerTheme + database)

### Branch + DEV db

```
devtools advantagebmwmidtown
devtools advantagebmwhouston.com
devtools https://www.advantagebmwhouston.com/about-us
```

### Branch + PROD db

```
devtools -p advantagebmwmidtown
devtools -p advantagebmwhouston.com
devtools -p https://www.advantagebmwhouston.com/about-us
```

## Update Common, Core, and Plugins

**WARNING**: This command is **destructive to your local /plugins dir**. Any plugins cloned as repos will be deleted or overwritten unless you have added the dir name to a special plugins/skip-composer.json. Please see [UCCP README](https://bitbucket.org/dealerinspire/feature-dev-shared-scripts/src/master/update-common-core-plugins/README.md) to learn more.

```
devtools uccp
```

## Start gulp

```
devtools gulp
```

## Clear site cache

```
devtools docker clearcache
```

## Rebuild site

*Requires [websites-console](https://bitbucket.org/dealerinspire/websites-console/src/master/readme.md) installed*

### DEV rebuild


```
devtools rebuild advantagebmwmidtown
```

### PROD rebuild

```
devtools rebuild -p advantagebmwmidtown
```

### Rebuild current local site

```
devtools rebuild -c
devtools rebuild -l
```

```
devtools rebuild -pc
devtools rebuild -pl
```

## SSH into Pod

```
devtools ssh
devtools ssh 17
devtools ssh advantagebmwmidtown
devtools ssh advantagebmwhouston.com
```


## DealerTheme file diffs

```
devtools hg diff
```

Scroll or down arrow key to view more log diffs. Type `q` to exit the log diffs.

## Databases

### Update download prompt size

Before downloading a db backup, if the size > MAXDBSIZE (in MB), `devtools` will prompt if you still want to download the backup.

MAXDBSIZE default is 100 MB.

To update MAXDBSIZE to 50 MB:

```
dt env update MAXDBSIZE 50 
```

### DB volume cleanup

Managing db docker volumes is currently manual. When your databases take up too much space, you'll start experiencing db import errors. Use these commands to periodically clean things up.

```
devtools db rm
devtools db prune
```
