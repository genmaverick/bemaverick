<?php

use Phinx\Migration\AbstractMigration;

class AddModelMentionTable extends AbstractMigration
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
        $this->execute( 'CREATE TABLE `model_mention` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `model_type` ENUM(\'challenge\',\'response\',\'comment\') NOT NULL DEFAULT \'challenge\',
          `model_id` INT(11) NOT NULL,
          `user_id` int(11) unsigned NOT NULL,
          `updated_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );
    }
}
