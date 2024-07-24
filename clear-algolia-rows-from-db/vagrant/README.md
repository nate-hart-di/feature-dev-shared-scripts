# Clear Algolia Rows From DB - Docker Edition

## Something to note

This script currently assumes that you only have one site's tables in your DB. I'm not sure what prefix it will get if you have more than one. You might modify the script to accept a prefix that you give it when you call the command, like `clearAlgoliaRowsFromOptionsTable wp12345_`.

## Setup

- Update the MySQL variables
    - If you don't know, check `dealerinspire-core/db.php`, and use the `local` settings.
- Update the Vagrant variables
    - Probably only need to change the directory - the key path should be correct once the directory is set.
- Move this script into your `$PATH`.
- Change permissions to make this script executable.
    - `chmod 755 clearAlgoliaRowsFromOptionsTable`

## Running

From anywhere, call the name of your file. Default is `clearAlgoliaRowsFromOptionsTable`

`$ clearAlgoliaRowsFromOptionsTable`

done.
