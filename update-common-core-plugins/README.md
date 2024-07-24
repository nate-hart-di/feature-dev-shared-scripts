# Update Common, Core, Plugins

Updates local Core, CommonTheme, and Plugins required by CommonTheme and DealerTheme, with the option to skip specified plugins

This little script mimics a site rebuild updating a dealer site to the latest everything, bringing your local closer to parity with production. It is a simplified, PHP version of the Update Common, Core, Plugins code found in DI Developer Tools.app [local-environment.js](https://bitbucket.org/dealerinspire/di-developer-tools/src/master/app/src/integrations/local-environment.js).

1. `git fetch`es Core and CommonTheme
2. temp renames any directories in plugins/skip-composer.json so composer won't wipe them out
3. runs `php composer_vagrant.php` (pulled from di-vagrant shared files) to merge CommonTheme and DealerTheme composer.json files; 
4. runs composer update with the merged file (*__WARNING__: this will wipe out/overwrite plugins except for those plugins directories you've added to skip-composer.json*)
5. reverts the temp renaming of the skipped plugins.

## Why?

When our work focuses on just one or two repos, we forget about the other things (or we remember, and :anxiety: at the prospect of git pull/clone-ing all of that)

Here are a few reasons you might use this:

* Because managing the 100s of potentially required packages manually is not fun
* DealerTheme we pulled down isn't working as expected because we're missing plugins that it requires.
* If our Core, CommonTheme, or Plugins are stale, our local solutions might introduce uncaught bugs when deployed with latest versions.
* PR testing steps reviewed with more consistent local environment.

## About skip-composer.json

The PHP script will first look in your plugins/ dir for a `skip-composer.json` file, in this format:

```
{
  "directories": 
    [
	  "plugin-dir-name-one",
	  "plugin-dir-name-two"
	]
}
```

Any dir names here will get temporarily renamed with a suffix, so that the proceeding `composer update` will not delete or change them.

Reasons you might want a directory(ies) skipped:

* cloning/installing the plugin is time consuming
* your cloned copy has local changes
* you're testing a specific branch of the plugin

## Setup

### Create skip-composer.json
To quickly create a plugins/skip-composer.json, __pre-populated with IDP directory__, run this:

```
cd ~/code/dealerinspire/dealerinspire-core/dealer-inspire/wp-content/plugins && echo "{\n  \"directories\": [\n    \"dealerinspire-inventory-display\"\n  ]\n}" >skip-composer.json
```

### Optional: shell alias 

In your `.bash_profile|.zprofile|.zshrc` file, add an `alias` for quickly running this:

```
alias uccp="php /Users/$(whoami)/code/dealerinspire/feature-dev-shared-scripts/update-common-core-plugins/update-common-core-plugins.php"
```

and then you can run from anywhere:

```
uccp
```

## Usage

0.  Pull down a DT
1.  Add/remove plugin dirs to skip in skip-composer.json
2.  With alias, run this anywhere
    * `uccp`
3.  No alias, cd into where this php file is, then run
    * `php ./update-plugins-for-dealer-theme.php`