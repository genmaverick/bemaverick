<?php

use Phinx\Migration\AbstractMigration;

class UserEmailAddressAndDob extends AbstractMigration
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
        $this->execute( 'ALTER TABLE `user` ADD `email_address` VARCHAR(255)  NULL  DEFAULT NULL  AFTER `password`;' );
        $this->execute( 'ALTER TABLE `user` ADD `birthdate` DATE  NULL  AFTER `last_name`;' );
        $this->execute( 'update user join user_parent on user_parent.user_id = user.user_id set user.email_address = user_parent.email_address' );
    }
}
