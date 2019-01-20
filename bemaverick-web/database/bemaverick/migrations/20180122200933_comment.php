<?php

use Phinx\Migration\AbstractMigration;

class Comment extends AbstractMigration
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
        $this->execute( 'CREATE TABLE `comment` (
        `comment_id` int(11) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `comment_provider` enum(\'twilio\') NOT NULL DEFAULT \'twilio\',
        `messageId` VARCHAR(255) NOT NULL DEFAULT \'\',
        `channelId` varchar(255) NOT NULL DEFAULT \'\',
        `description` varchar(1028) DEFAULT NULL,
        `attributes` varchar(1028) DEFAULT NULL,
        `createdBy` varchar(1028) DEFAULT NULL,
        `updatedBy` varchar(1028) DEFAULT NULL,
        `isFlagged` enum(\'true\', \'false\') NOT NULL DEFAULT \'true\',
        `created_ts` datetime DEFAULT NULL,
        `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );
    }
}
