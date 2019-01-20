<?php

use Phinx\Migration\AbstractMigration;

class FeaturedModelTable extends AbstractMigration
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
        $this->execute( 'CREATE TABLE `featured_models` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `featured_type` ENUM(\'maverick-stream\',\'challenge-stream\') NOT NULL DEFAULT \'maverick-stream\',
  `model_id` INT(11) NOT NULL,
  `model_type` ENUM(\'challenge\',\'response\',\'user\') NOT NULL DEFAULT \'challenge\',
  `sort_order` INT(11) NOT NULL,
  `status` ENUM(\'active\',\'inactive\') NOT NULL DEFAULT \'active\',
  `created_ts` DATETIME NOT NULL,
  `updated_ts` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );

        $this->execute( 'ALTER TABLE `challenge` DROP `sort_order`;' );

        $this->execute( 'ALTER TABLE `response` DROP `featured_sort_order`;' );

        $this->execute( 'ALTER TABLE `challenge` ADD `created_ts` DATETIME  NOT NULL  DEFAULT CURRENT_TIMESTAMP  AFTER `status`;' );
    }
}
