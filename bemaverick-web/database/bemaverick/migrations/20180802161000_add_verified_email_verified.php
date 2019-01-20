<?php

use Phinx\Migration\AbstractMigration;

class AddVerifiedEmailVerified extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'ALTER TABLE user CHANGE account_verified email_verified tinyint(1) NOT NULL DEFAULT \'0\';' );
        $this->execute( 'ALTER TABLE user ADD verified tinyint(1) DEFAULT 0 NULL;' );
        $this->execute( 'ALTER TABLE user MODIFY COLUMN verified tinyint(1) NOT NULL DEFAULT 0 AFTER phone_number;' );
    }
}
