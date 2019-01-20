<?php

use Phinx\Migration\AbstractMigration;

class UserStatusChanges extends AbstractMigration
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
        $this->execute( 'ALTER TABLE `user` CHANGE `status` `status` ENUM(\'draft\',\'active\',\'inactive\',\'revoked\',\'deleted\')  CHARACTER SET utf8mb4  COLLATE utf8mb4_general_ci  NOT NULL  DEFAULT \'active\';' );
        $this->execute( 'ALTER TABLE `user` DROP `account_revoked`;' );
        $this->execute( 'ALTER TABLE `user_parent` CHANGE `id_verified` `id_verification_status` ENUM(\'pending\',\'verified\',\'rejected\')  NOT NULL  DEFAULT \'pending\';' );
        $this->execute( 'ALTER TABLE `user_parent` ADD `id_verification_ts` DATETIME  NULL  AFTER `id_verification_status`;' );
    }
}
