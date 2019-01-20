<?php

use Phinx\Migration\AbstractMigration;

class FeaturedModelPrimaryKeyUpdate extends AbstractMigration
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
        $this->execute( "delete from featured_models where status = 'inactive';" );
        $this->execute( "ALTER TABLE `featured_models` DROP `status`;" );
        $this->execute( "ALTER TABLE `featured_models` DROP `id`;" );
        $this->execute( "ALTER TABLE `featured_models` DROP INDEX `featured_models_model_id_model_type_featured_type_status_index`;" );
        $this->execute( "CREATE TABLE tmp_featured_models SELECT * FROM featured_models;" );
        $this->execute( "TRUNCATE TABLE featured_models;" );
        $this->execute( "ALTER TABLE `featured_models` ADD PRIMARY KEY (`featured_type`, `model_id`, `model_type`);" );
        $this->execute( "INSERT IGNORE INTO featured_models SELECT * from tmp_featured_models;" );
    }
}
