<?php

use Phinx\Migration\AbstractMigration;

class ChallengeUuid extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'ALTER TABLE `challenge` ADD `uuid` VARCHAR(36) NULL AFTER `challenge_id`;' );
    }
}