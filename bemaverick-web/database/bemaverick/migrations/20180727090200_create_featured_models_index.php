<?php

use Phinx\Migration\AbstractMigration;

class CreateFeaturedModelsIndex extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'CREATE INDEX featured_models_status_index ON featured_models (status);' );
        $this->execute( 'CREATE INDEX featured_models_model_id_model_type_featured_type_status_index ON featured_models (model_id, model_type, featured_type, status);' );
    }
}
