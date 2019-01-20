<?php

use Phinx\Migration\AbstractMigration;

class CreateVideoEncoderJob extends AbstractMigration
{
    /**
     * Change Method.
     *
     * Write your reversible migrations using this method.
     *
     * More information on writing migrations is available here:
     * http://docs.phinx.org/en/latest/migrations.html#the-abstractmigration-class
     *
     * The following commands can be used in this method and Phinx will
     * automatically reverse them when rolling back:
     *
     *    createTable
     *    renameTable
     *    addColumn
     *    renameColumn
     *    addIndex
     *    addForeignKey
     *
     * Remember to call "create()" or "update()" and NOT "save()" when working
     * with the Table class.
     */
    public function change()
    {
        $this->execute( 'CREATE TABLE `video_encoder_job` (
                      `job_id` VARCHAR(255) NOT NULL PRIMARY KEY,
                      `video_id` int(11) unsigned NOT NULL,
                      `job_status` VARCHAR(255),
                      `updated_ts` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;' );
        $this->execute( 'ALTER TABLE `video` DROP `encoder_job_id` ;' );
        $this->execute( 'ALTER TABLE `video` DROP `encoder_job_status` ;' );
        $this->execute( 'ALTER TABLE `video` DROP `thumbnail_url` ;' );
        $this->execute( 'ALTER TABLE `video` CHANGE `playlistname` `hls_playlistname` VARCHAR (255) ;' );
    }
}
