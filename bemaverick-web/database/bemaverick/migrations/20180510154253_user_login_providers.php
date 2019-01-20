<?php

use Phinx\Migration\AbstractMigration;

class UserLoginProviders extends AbstractMigration
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
        $this->execute( 'CREATE TABLE `user_login_providers` (
  `user_id` int(11) NOT NULL,
  `login_provider` enum(\'facebook\',\'twitter\') NOT NULL,
  `login_provider_user_id` varchar(255) NOT NULL,
  `updated_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`,`login_provider`),
  UNIQUE KEY `login_provider_user_id` (`login_provider`,`login_provider_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;' );

    }
}
