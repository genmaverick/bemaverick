<?php

use Phinx\Migration\AbstractMigration;

class ChallengeHideFromStreams extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'ALTER TABLE response CHANGE hide_in_stream hide_from_streams tinyint(4) NOT NULL DEFAULT \'0\';' );
        $this->execute( 'ALTER TABLE `challenge` ADD `hide_from_streams` TINYINT  NOT NULL  DEFAULT \'0\'  AFTER `status`;' );
    }
}
