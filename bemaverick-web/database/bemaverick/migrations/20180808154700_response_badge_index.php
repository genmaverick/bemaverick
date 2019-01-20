<?php

use Phinx\Migration\AbstractMigration;

class ResponseBadgeIndex extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'create index response_badge_user_id_badge_id_index on response_badge (user_id, badge_id);' );
        $this->execute( 'create index response_badge_user_id_index on response_badge (user_id);' );
        $this->execute( 'create index response_badge_user_id_response_id_index on response_badge (user_id, response_id);' );
    }
}
