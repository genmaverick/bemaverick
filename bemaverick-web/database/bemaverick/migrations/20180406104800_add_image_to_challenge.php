<?php

use Phinx\Migration\AbstractMigration;

class AddImageToChallenge extends AbstractMigration
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
        $this->execute( 'ALTER TABLE `challenge` ADD `challenge_type` ENUM(\'video\', \'image\')  NOT NULL  DEFAULT \'video\'  AFTER `challenge_id`;' );
        $this->execute( 'ALTER TABLE `challenge` ADD `image_id` INT  NULL  DEFAULT NULL  AFTER `video_id`;' );
        $this->execute( 'ALTER TABLE `challenge` CHANGE `video_id` `video_id` INT(11)  NULL  DEFAULT NULL;' );
    }
}
