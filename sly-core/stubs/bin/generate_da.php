<?php

$siteHome = getenv('SITE_HOME');
if (empty($siteHome)) {
    echo "Must set SITE_HOME environment variable.\n";
    exit(1);
}

require_once( $siteHome . '/config/setup_environment.php' );
require_once( ZEND_ROOT_DIR . '/lib/Zend/Console/Getopt.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Log.php' );
require_once( SLY_ROOT_DIR . '/lib/Sly/Da/InformationSchema.php' );

try {
    $options = new Zend_Console_Getopt(
        array(
            'class_prefix=s'  => '[Required] The class prefix',
            'database_name=s' => '[Required] The database name',
            'table_name=s'    => '[Required] The table name',
            'output_dir=s'    => '[Required] The output dir',
            'log'             => '[Optional] Set for logging output to log file',
        )
    );

    $options->parse();
}
catch( Zend_Console_Getopt_Exception $e ) {
    print $e->getUsageMessage();
    exit( 1 );
}

function getNameFromColumn($columnName)
{
    $parts = explode('_', $columnName);

    foreach ($parts as &$part) {
        if ($part == 'ts') {
            $part = 'timestamp';
        }
        $part = ucfirst($part);
    }

    return implode('', $parts);
}

$daSchema = Sly_Da_InformationSchema::getInstance();

$classPrefix = $options->class_prefix;
$databaseName = $options->database_name;
$tableName = $options->table_name;
$outputDir = $options->output_dir;

// get the list of table names
if ( $options->table_name ) {
    $tableNames = array( $options->table_name );
}
else {

    $tableNames = array();

    $columns = $daSchema->getColumns( $databaseName );
    foreach( $columns as $column ) {

        $tableName = $column['TABLE_NAME'];
    
        if ( ! in_array( $tableName, $tableNames ) ) {
            $tableNames[] = $tableName;
        }
    }
}

foreach( $tableNames as $tableName ) {

    $tableNameParts = explode('_', $tableName);
    foreach ($tableNameParts as &$partName) {
        $partName = ucfirst($partName);
    }

    $tableToClass = implode('', $tableNameParts);

    $slyTemplateDaClassName = "${classPrefix}_Da_${tableToClass}";
    $slyTemplateDaDatabaseName = $databaseName;
    $slyTemplateDaTableName = $tableName;
    $slyTemplateDaPrimaryKey = '';
    $slyTemplateDaFunctions = '';

    $columns = $daSchema->getColumns($databaseName, $tableName);
    $primaryKeyColumns = array();

    foreach ($columns as $column) {

        $name = getNameFromColumn($column['COLUMN_NAME']);

        if ($column['COLUMN_KEY'] == 'PRI') { // Primary key check
            $primaryKeyColumns[] = "'{$column['COLUMN_NAME']}'";
        }

        $slyTemplateDaFunctions .= "        " . "'get$name' => '{$column['COLUMN_NAME']}',\n";
        $slyTemplateDaFunctions .= "        " . "'set$name' => '{$column['COLUMN_NAME']}',\n";       
    }

    $slyTemplateDaPrimaryKey = implode(',', $primaryKeyColumns);

    // load the template
    $template = file_get_contents('../templates/template_da.txt');

    // do the replacement
    $fileContents = str_replace(

        array(
            '__SLY_TEMPLATE_DA_CLASS_NAME__',
            '__SLY_TEMPLATE_DA_DATABASE_NAME__',
            '__SLY_TEMPLATE_DA_TABLE_NAME__',
            '__SLY_TEMPLATE_DA_PRIMARY_KEY__',
            '__SLY_TEMPLATE_DA_FUNCTIONS__',        
        ),

        array(
            $slyTemplateDaClassName,
            $slyTemplateDaDatabaseName,
            $slyTemplateDaTableName,
            $slyTemplateDaPrimaryKey,
            $slyTemplateDaFunctions,
        ),

        $template);

    // save the file
    file_put_contents( "$outputDir/$tableToClass.php", $fileContents );
}

?>