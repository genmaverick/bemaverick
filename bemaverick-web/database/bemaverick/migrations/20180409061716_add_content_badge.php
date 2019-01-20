<?php

use Phinx\Migration\AbstractMigration;

class AddContentBadge extends AbstractMigration
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
        $this->execute( 'ALTER TABLE `content` ADD `uuid` VARCHAR(36) NULL AFTER `content_id`;' );
        $this->execute( 'ALTER TABLE `content` MODIFY `content_type` ENUM(\'video\', \'image\')  NOT NULL  DEFAULT \'video\'  AFTER `uuid`;' );
        $this->execute( 'ALTER TABLE `content` ADD `image_id` INT  NULL  DEFAULT NULL  AFTER `video_id`;' );
        $this->execute( 'ALTER TABLE `content` CHANGE `main_image_id` `cover_image_id` INT  NULL  DEFAULT NULL  AFTER `image_id`;' );
        $this->execute( 'ALTER TABLE `content` MODIFY `status`  ENUM(\'draft\', \'active\', \'inactive\', \'deleted\') NOT NULL  DEFAULT \'active\' ;' );
        $this->execute( 'ALTER TABLE `content` DROP `card_image_id` ;' );
        $this->execute( 'ALTER TABLE `content` DROP `sort_order` ;' );
        $this->execute( 'CREATE TABLE `content_badge` (
                      `content_id` int(11) unsigned NOT NULL,
                      `badge_id` int(11) unsigned NOT NULL,
                      `user_id` int(11) unsigned NOT NULL,
                      `status`   ENUM(\'active\', \'deleted\') NOT NULL DEFAULT \'active\',
                      `created_ts` DATETIME NULL,
                      `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                      PRIMARY KEY (`user_id`,`content_id`,`badge_id`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );
    }
}
