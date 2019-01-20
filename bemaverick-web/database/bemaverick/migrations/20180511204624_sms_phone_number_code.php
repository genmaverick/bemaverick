<?php

use Phinx\Migration\AbstractMigration;

class SmsPhoneNumberCode extends AbstractMigration
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
        $this->execute( 'ALTER TABLE `user` ADD `phone_number` VARCHAR(20)  NULL  DEFAULT NULL  AFTER `birthdate`;' );

        $this->execute( 'ALTER TABLE `user` ADD UNIQUE INDEX `phone_number` (`phone_number`);' );

        $this->execute( 'CREATE TABLE `sms_code` (
  `phone_number` varchar(20) NOT NULL,
  `code` int(4) NOT NULL,
  `updated_ts` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`phone_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );
    }
}
