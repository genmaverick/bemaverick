<?php

use Phinx\Migration\AbstractMigration;

class ResponseBadgeActiveColumn extends AbstractMigration
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
        $this->execute( 'ALTER TABLE `response_badge` ADD `status` ENUM(\'active\', \'deleted\')  NOT NULL  DEFAULT \'active\'  AFTER `user_id`;' );
        $this->execute( 'ALTER TABLE `challenge` CHANGE `status` `status` ENUM(\'published\',\'draft\',\'hidden\',\'deleted\')  CHARACTER SET utf8mb4  COLLATE utf8mb4_general_ci  NOT NULL  DEFAULT \'draft\';' );
        $this->execute( 'ALTER TABLE `response` CHANGE `status` `status` ENUM(\'active\',\'hidden\',\'deleted\')  CHARACTER SET utf8mb4  COLLATE utf8mb4_general_ci  NOT NULL  DEFAULT \'active\';' );
    }
}
