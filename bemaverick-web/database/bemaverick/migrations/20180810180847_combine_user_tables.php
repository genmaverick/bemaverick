<?php

use Phinx\Migration\AbstractMigration;

class CombineUserTables extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'ALTER TABLE `user` ADD `bio` VARCHAR(1028) DEFAULT NULL AFTER `last_name`;' );
        $this->execute( 'ALTER TABLE `user` ADD `parent_email_address` VARCHAR(255) DEFAULT NULL AFTER `email_address`;' );
        $this->execute( 'ALTER TABLE `user` ADD `vpc_status` TINYINT(1)  NOT NULL  DEFAULT \'0\'  AFTER `email_verified`;' );
    }
}
