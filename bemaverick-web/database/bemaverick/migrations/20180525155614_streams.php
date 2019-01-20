<?php

use Phinx\Migration\AbstractMigration;

class Streams extends AbstractMigration
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
        $this->execute( 'CREATE TABLE `stream` (
  `stream_id` INT(11) NOT NULL AUTO_INCREMENT,
  `label` VARCHAR(255) NOT NULL DEFAULT \'\',
  `definition` TEXT NOT NULL,
  `sort_order` INT(11) NOT NULL,
  `status` ENUM(\'active\',\'inactive\',\'deleted\',\'draft\') NOT NULL DEFAULT \'active\',
  `stream_type` VARCHAR(255) NOT NULL DEFAULT \'\',
  `model_type` ENUM(\'challenge\',\'response\',\'user\',\'advertisement\') NOT NULL DEFAULT \'challenge\',
  `updated_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stream_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );
    }
}
