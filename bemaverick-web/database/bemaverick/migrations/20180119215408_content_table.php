<?php

use Phinx\Migration\AbstractMigration;

class ContentTable extends AbstractMigration
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
        $this->execute( 'CREATE TABLE `content` (
  `content_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `content_type` enum(\'general\',\'tutorial\') NOT NULL DEFAULT \'general\',
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL DEFAULT \'\',
  `description` varchar(1028) DEFAULT NULL,
  `video_id` int(11) DEFAULT NULL,
  `main_image_id` int(11) DEFAULT NULL,
  `card_image_id` int(11) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT \'1\',
  `status` enum(\'published\',\'draft\',\'hidden\',\'deleted\') NOT NULL DEFAULT \'draft\',
  `created_ts` datetime DEFAULT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`content_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );

        $this->execute( 'CREATE TABLE `content_tags` (
  `content_id` int(11) unsigned NOT NULL,
  `tag_id` int(11) NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`content_id`,`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );

    }
}
