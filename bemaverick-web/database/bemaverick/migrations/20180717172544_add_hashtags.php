<?php

use Phinx\Migration\AbstractMigration;

class AddHashtags extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'ALTER TABLE `response` ADD `hashtags` VARCHAR(1028) NULL AFTER `description`;' );
        $this->execute( 'ALTER TABLE `challenge` ADD `hashtags` VARCHAR(1028) NULL AFTER `description`;' );
        $this->execute( 'ALTER TABLE `user` ADD `hashtags` VARCHAR(1028) NULL AFTER `last_name`;' );
    }
}
