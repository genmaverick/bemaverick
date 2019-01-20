<?php

use Phinx\Migration\AbstractMigration;

class ExtendBadgeTable extends AbstractMigration
{
    /**
     * Add columns: 
     *      status 
     *      color
     *      sort_order
     *      primary_image_url
     *      secondary_image_url
     */
    public function change()
    {
        $this->execute( 'ALTER TABLE badge ADD status enum(\'draft\', \'active\', \'inactive\', \'deleted\') DEFAULT \'active\' NOT NULL;' );
        $this->execute( 'ALTER TABLE badge ADD color varchar(255) NULL;' );
        $this->execute( 'ALTER TABLE badge ADD sort_order int(11) DEFAULT 99 NULL;' );
        $this->execute( 'ALTER TABLE badge ADD primary_image_url varchar(255) NULL;' );
        $this->execute( 'ALTER TABLE badge ADD secondary_image_url varchar(255) NULL;' );
        $this->execute( 'ALTER TABLE badge ADD offset_x decimal(5,0) DEFAULT 0 NOT NULL;');
        $this->execute( 'ALTER TABLE badge ADD offset_y decimal(5,0) DEFAULT 0 NOT NULL;');
    }
}
