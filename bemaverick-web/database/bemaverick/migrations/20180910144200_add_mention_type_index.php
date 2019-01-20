<?php

use Phinx\Migration\AbstractMigration;

class AddMentionTypeIndex extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'CREATE INDEX model_mention_model_id_model_type_user_id_index ON model_mention (model_id, model_type, user_id);' );
        $this->execute( 'CREATE INDEX model_mention_user_id_model_type_index ON model_mention (user_id, model_type);' );
    }
}

