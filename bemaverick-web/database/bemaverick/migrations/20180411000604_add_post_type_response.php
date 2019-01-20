<?php

use Phinx\Migration\AbstractMigration;

class AddPostTypeResponse extends AbstractMigration
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
        $this->execute( 'ALTER TABLE `response` MODIFY `challenge_id` INT(11);' );
        $this->execute( 'ALTER TABLE `response` ADD `title` VARCHAR(255) NULL AFTER `cover_image_id`;' );
        $this->execute( 'ALTER TABLE `response` ADD `post_type` ENUM(\'response\', \'content\');' );
    }
}
