<?php

use Phinx\Migration\AbstractMigration;

class AddChallengeLinkUrl extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'ALTER TABLE `challenge` ADD `link_url` varchar(1028) NULL AFTER `image_text`;');
    }
}
