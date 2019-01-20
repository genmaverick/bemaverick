<?php

use Phinx\Migration\AbstractMigration;

class AddImageTextField extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'ALTER TABLE challenge ADD image_text varchar(1028) NULL;' );
        $this->execute( 'ALTER TABLE challenge MODIFY COLUMN image_text varchar(1028) AFTER hashtags;' );
    }
}
