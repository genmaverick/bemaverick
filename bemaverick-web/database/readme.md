# [Phinx](https://phinx.org/) is the database schema migration tool used here.

# Installation and setup in dev environment
From the database folder, execute:
```
$ PROJECT_ROOT=`cd .. && pwd` && cd ..
$ composer install
$ alias phinx="$PROJECT_ROOT/vendor/robmorgan/phinx/bin/phinx"
$ cd $PROJECT_ROOT/database/config
$ ln -s defines_slytrunk_devel.php defines.php
$ cd $PROJECT_ROOT
```
# Example Usage
### Creating new Migration
```
$ phinx create MyNewMigration -c database/bemaverick/phinx.php
```
### Updating Migration
Example of a migration update:
```
<?php
use Phinx\Migration\AbstractMigration;

class MyNewMigration extends AbstractMigration {

    public function up() {
        $this->execute( 'CREATE TABLE `test` (
            `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
            PRIMARY KEY (`id`) )
            ENGINE=InnoDB DEFAULT CHARSET=utf8;');
    }

    public function down() {
        $this->execute( 'DROP TABLE `test`' );
    }
}
```

### Running the Migration
```
$ phinx migrate -c database/bemaverick/phinx.php
```

### Rolling back the migration
```
$ phinx rollback -c database/bemaverick/phinx.php
```

Please visit the phinx documentation more detailed info:
http://docs.phinx.org/en/latest/index.html

# Other Info
`PROJECT_ROOT/packages/install_package.php` runs the migration the database package during production installations.
