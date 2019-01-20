<?php

use Phinx\Migration\AbstractMigration;

class FollowingUserIndex extends AbstractMigration
{
    public function change()
    {
        $this->execute( 'CREATE INDEX user_following_users_user_id_index ON user_following_users (user_id);' );
        $this->execute( 'CREATE INDEX user_following_users_following_user_id_index ON user_following_users (following_user_id);' );
    }
}
