<?php

use Phinx\Migration\AbstractMigration;

class UserProfileCover extends AbstractMigration
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
        $this->execute( 'ALTER TABLE `user` ADD `first_name` VARCHAR(255)  NULL  DEFAULT NULL  AFTER `password`;' );
        $this->execute( 'ALTER TABLE `user` ADD `last_name` VARCHAR(255)  NULL  DEFAULT NULL  AFTER `first_name`;' );

        $this->execute( 'ALTER TABLE `user_kid` ADD `profile_cover_preset_image_id` INT  NULL  DEFAULT NULL  AFTER `profile_cover_image_id`;' );
        $this->execute( 'ALTER TABLE `user_kid` ADD `profile_cover_tint` VARCHAR(10)  NULL  DEFAULT NULL  AFTER `profile_cover_preset_image_id`;' );
        $this->execute( 'ALTER TABLE `user_kid` ADD `profile_cover_image_type` ENUM(\'preset\', \'custom\')  NULL  DEFAULT NULL  AFTER `profile_image_id`;' );
    }
}
