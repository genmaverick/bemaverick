<?php

use Phinx\Migration\AbstractMigration;

class UserAccountVerified extends AbstractMigration
{
    /**
     * Change Method.
     *
     * Write your reversible migrations using this method.
     *
     * More information on writing migrations is available here:
     * http://docs.phinx.org/en/latest/migrations.html#the-abstractmigration-class
     *
     * The following commands can be used in this method and Phinx will
     * automatically reverse them when rolling back:
     *
     *    createTable
     *    renameTable
     *    addColumn
     *    renameColumn
     *    addIndex
     *    addForeignKey
     *
     * Remember to call "create()" or "update()" and NOT "save()" when working
     * with the Table class.
     */
    public function change()
    {
        $this->execute( 'ALTER TABLE `user` ADD `account_verified` BOOL  NOT NULL  DEFAULT \'0\'   AFTER `birthdate`;' );
        $this->execute( 'ALTER TABLE `user_kid` CHANGE `parent_email_address` `parent_email_address` VARCHAR(255)  CHARACTER SET utf8mb4  COLLATE utf8mb4_general_ci  NULL  DEFAULT NULL;' );
    }
}
