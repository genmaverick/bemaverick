<?php

use Phinx\Migration\AbstractMigration;

class ResponseUserModeration extends AbstractMigration
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
        $this->execute( 'ALTER TABLE `response` MODIFY `status` ENUM(\'draft\',\'active\',\'inactive\',\'deleted\')  CHARACTER SET utf8mb4  COLLATE utf8mb4_general_ci  NULL  DEFAULT \'active\';' );
        $this->execute( 'ALTER TABLE `response` ADD `moderation_status` ENUM(\'allow\',\'authorOnly\',\'replace\',\'queuedForApproval\',\'reject\')  CHARACTER SET utf8mb4  COLLATE utf8mb4_general_ci  NULL  DEFAULT \'allow\' AFTER `status`;' );
        $this->execute( 'ALTER TABLE `response` ADD `uuid` VARCHAR(36) NULL AFTER `response_id`;' );
        $this->execute( 'ALTER TABLE `user` ADD `uuid` VARCHAR(36) NULL AFTER `user_id`;' );
    }
}
