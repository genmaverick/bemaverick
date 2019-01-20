<?php

use Phinx\Migration\AbstractMigration;

class AddBadgeDescriptions extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'ALTER TABLE `badge` ADD `description` varchar(1028) NULL AFTER `secondary_image_url`;');
    }
}
