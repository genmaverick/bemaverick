<?php

use Phinx\Migration\AbstractMigration;

class CoppaLog extends AbstractMigration
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
        $this->execute( 'CREATE TABLE `coppalog` (
        `id` int(11) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
        `kid_user_id` int(11) unsigned NOT NULL,
        `first_name` varchar(255) NULL,
        `last_name` varchar(255)  NULL,
        `address` varchar(1024)  NULL,
        `zip` varchar(8) NULL,
        `last_four_ssn` int(11) unsigned NULL,
        `confirmation_id` int(11) unsigned NULL,
        `response_action` varchar(255) NULL,
        `response_detail` varchar(2048)  NULL,
        `response_issues` varchar(2048)  NULL,
        `created_ts` datetime DEFAULT NULL,
        `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );
    }
}
