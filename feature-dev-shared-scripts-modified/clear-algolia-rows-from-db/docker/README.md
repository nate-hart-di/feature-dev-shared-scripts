# Clear Algolia Rows From DB - Docker Edition

These are the same instructions for those running everything on their local machine.

## Setup

- Update the MySQL variables
    - If you don't know, check `dealerinspire-core/db.php`, and use the `local` settings.
- Move this script into your `$PATH`.
- Change permissions to make this script executable.
    - `chmod 755 clearAlgoliaRowsFromOptionsTable`

## Running

From anywhere, call the name of your file. Default is `clearAlgoliaRowsFromOptionsTable`

`$ clearAlgoliaRowsFromOptionsTable`

done.
