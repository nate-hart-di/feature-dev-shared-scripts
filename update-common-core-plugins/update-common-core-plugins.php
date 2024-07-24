<?php

/**
 * Updates Core and CommonTheme, and composer updates Plugins for DealerTheme
 * 
 * This is essentially a simplified, PHP version of the Update Common, 
 * Core, Plugins code found in DI Developer Tools.app local-environment.js.
 * 1. git fetches Core and CommonTheme; 
 * 2. checks for directories added to a skip-composer.json file and temp 
 *    renames those so composer won't wipe them out; 
 * 3. runs composer_vagrant.php (copied from vagrant shared files) to merge 
 *    CommonTheme and DealerTheme composer.json files; 
 * 4. runs composer update with the merged file; (5) reverts the temp
 *    renaming of the skipped plugins.
 * 
 * WARNING: composer will wipe out/overwrite plugins unless you've added them
 * to the skip-composer.json
 * 
 * SETUP:
 * - CREATE skip-composer.json:
 *   - cd into /plugins, and run
 *   - echo "{\n  \"directories\": [\n    \"dealerinspire-inventory-display\"\n  ]\n}" >skip-composer.json
 * 
 * USAGE:
 * - cd into where this file is, and run:
 * - php ./update-plugins-for-dealer-theme.php
 * 
 * OPTIONALLY: make a shell alias in your shell profile file, like:
 * - alias uccp="php $DI_HOME_DIR/wp-content/plugins/update-common-core-plugins.php"
 * and then you can run from anywhere:
 * - uccp
 * 
 * @author Keith Wyland
 * 
 */

$yellow_bold="\033[1;33m";
$blue="\033[0;36m";
$normal_style="\033[0m";


$processUser = posix_getpwuid(posix_geteuid())['name'];

$diCorePath = "/Users/$processUser/code/dealerinspire/dealerinspire-core";

$diCommonPath = $diCorePath . '/dealer-inspire/wp-content/themes/DealerInspireCommonTheme';
$diPluginsPath = $diCorePath . '/dealer-inspire/wp-content/plugins';
$skipComposerFilePath = $diPluginsPath . '/skip-composer.json';

$skipComposerContents = file_exists($skipComposerFilePath) ? file_get_contents($skipComposerFilePath) : null;

$coreAndCommonScript = "
  cd $diCorePath
  git fetch --all
  git reset --hard origin/master
  cd $diCommonPath
  git fetch --all
  git reset --hard origin/5.x
  git checkout 5.x
";

$inventoryRenameScript = "
mv $diPluginsPath/inventory/ $diPluginsPath/inventory-repo/
mv $diPluginsPath/inventory-composer/ $diPluginsPath/inventory/
";

$pluginRenameScript = "";

$composerScript = "
  cd $diCorePath
  git archive --remote=git@bitbucket.org:dealerinspire/vagrant.git HEAD:shared-modules/dealerinspire/files/web/var/www/domains/com.dealerinspire.wordpress composer_vagrant.php | tar -x
  git checkout composer.json
  docker exec -it $(docker ps --filter name=web -q) /bin/bash -c 'export XDEBUG_MODE=off && php composer_vagrant.php >/dev/null'
  cp merged_composer_generated_vagrant.json composer.json
  docker exec -it $(docker ps --filter name=web -q) /bin/bash -c 'export XDEBUG_MODE=off && php composer.phar config --no-plugins allow-plugins.composer/installers true && php composer.phar update --prefer-dist'
";

$pluginRevertScript = "";

$inventoryRevertScript = "
  mv $diPluginsPath/inventory/ $diPluginsPath/inventory-composer/
  mv $diPluginsPath/inventory-repo/ $diPluginsPath/inventory/
  if [ -d \"$diPluginsPath/inventory/.git\" ]; then (cd $diPluginsPath/inventory && git fetch --all && git checkout v10 && git pull && git restore --source origin/local-redis-v10 classes/cache.php); fi
  cd $diCorePath
";

if ($skipComposerContents) {
  $pluginDirectoriesToSkip = json_decode(html_entity_decode($skipComposerContents), true)['directories'];
  // prior to running composer update, if a skip-composer.json file exists, 
  // it will rename the directories listed there to preserve their code.
  // after the composer update, it renames them back
  foreach ($pluginDirectoriesToSkip as $directory) {
      $pluginRenameScript .= "
          printf \"$blue renaming '$directory' dir to skip it$normal_style\n\"
          mv $diPluginsPath/$directory/ $diPluginsPath/$directory-repo/
          mv $diPluginsPath/$directory-composer/ $diPluginsPath/$directory/
      ";

      $pluginRevertScript .= "
          mv $diPluginsPath/$directory/ $diPluginsPath/$directory-composer/
          mv $diPluginsPath/$directory-repo/ $diPluginsPath/$directory/
          printf \"$blue reverting '$directory' dir rename$normal_style\n\" && if [ -d \"$diPluginsPath/$directory/.git\" ]; then (cd $diPluginsPath/$directory && git fetch --all); fi
      ";
  }
}

echo `export UCCP_OLD_PWD=$(pwd)`;

echo "$yellow_bold \nSTART UPDATE COMMON, CORE, PLUGINS\n\n $normal_style";
echo "$yellow_bold \n...GET LATEST CORE & COMMON...\n\n $normal_style";

echo `$coreAndCommonScript`;

echo "$yellow_bold \n...INVENTORY SKIP...\n\n $normal_style";
echo "$blue renaming 'inventory' dir to skip it\n$normal_style";

echo `$inventoryRenameScript`;

if ($pluginRenameScript != "") {
  echo "$yellow_bold \n...SKIP-COMPOSER.JSON PLUGINS...\n\n $normal_style";
  echo `$pluginRenameScript`;
}

echo "$yellow_bold \n...DOCKER: MERGE & RUN COMPOSER FILES...\n";
echo "$blue THIS MAY TAKE A MINUTE OR TWO\n\n $normal_style";

echo `$composerScript`;

if ($pluginRevertScript != "") {
  echo "$yellow_bold \n...SKIP-COMPOSER.JSON REVERT...\n\n $normal_style";
  echo `$pluginRevertScript`;
}

echo "$yellow_bold \n...INVENTORY PLUGIN SKIP REVERT...\n\n $normal_style";
echo "$blue reverting 'inventory' dir rename, and updating via git\n\n$normal_style";

echo `$inventoryRevertScript`;

echo "$yellow_bold \n\nEND UPDATE COMMON, CORE, PLUGINS\n\n$normal_style";

echo `cd \$UCCP_OLD_PWD`;
