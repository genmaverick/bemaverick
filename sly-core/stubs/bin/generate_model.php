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

    $slyTemplateModelName = implode('', $tableNameParts);

    $slyTemplateModelRepositoryUppercaseName = strtoupper( $databaseName );
    $slyTemplateModelClassPrefix = $classPrefix;
    $slyTemplateModelLowercaseName = strtolower( $slyTemplateModelName );
    $slyTemplateModelFunctions = '';

    $columns = $daSchema->getColumns($databaseName, $tableName);
    $primaryKeyColumns = array();

    foreach ($columns as $column) {

        // skip the primary key
        if ($column['COLUMN_KEY'] == 'PRI') {
            continue;
        }

        $slyTemplateFunctionName = getNameFromColumn($column['COLUMN_NAME']);
        $slyTemplateFunctionCamelcaseName = lcfirst( $slyTemplateFunctionName );
        $slyTemplateFunctionSentenceName = str_replace( '_', ' ', $column['COLUMN_NAME'] );
        $slyTemplateFunctionDaName = $slyTemplateModelName;

        $function = '
    /**
     * Get the __SLY_TEMPLATE_FUNCTION_SENTENCE_NAME__
     *
     * @return string
     */
    public function get__SLY_TEMPLATE_FUNCTION_NAME__()
    {
        return $this->_da__SLY_TEMPLATE_FUNCTION_DA_NAME__->get__SLY_TEMPLATE_FUNCTION_NAME__( $this->getId() );
    }

    /**
     * Set the __SLY_TEMPLATE_FUNCTION_SENTENCE_NAME__
     *
     * @return void
     */
    public function set__SLY_TEMPLATE_FUNCTION_NAME__( $__SLY_TEMPLATE_FUNCTION_CAMELCASE_NAME__ )
    {
        $this->_da__SLY_TEMPLATE_FUNCTION_DA_NAME__->set__SLY_TEMPLATE_FUNCTION_NAME__( $this->getId(), $__SLY_TEMPLATE_FUNCTION_CAMELCASE_NAME__ );
    }
    ';
    
        $function = str_replace(
            array(
                '__SLY_TEMPLATE_FUNCTION_NAME__', 
                '__SLY_TEMPLATE_FUNCTION_CAMELCASE_NAME__', 
                '__SLY_TEMPLATE_FUNCTION_SENTENCE_NAME__',
                '__SLY_TEMPLATE_FUNCTION_DA_NAME__', 
            ),

            array(
                $slyTemplateFunctionName,
                $slyTemplateFunctionCamelcaseName,
                $slyTemplateFunctionSentenceName,
                $slyTemplateFunctionDaName,
            ),

            $function
        );
    
        $slyTemplateModelFunctions .= $function;
    }

    // load the template
    $template = file_get_contents('../templates/template_model.txt');

    // do the replacement
    $fileContents = str_replace(

        array(
            '__SLY_TEMPLATE_MODEL_REPOSITORY_UPPERCASE_NAME__',
            '__SLY_TEMPLATE_MODEL_CLASS_PREFIX__',
            '__SLY_TEMPLATE_MODEL_NAME__',
            '__SLY_TEMPLATE_MODEL_LOWERCASE_NAME__',
            '__SLY_TEMPLATE_MODEL_FUNCTIONS__',
        ),

        array(
            $slyTemplateModelRepositoryUppercaseName,
            $slyTemplateModelClassPrefix,
            $slyTemplateModelName,
            $slyTemplateModelLowercaseName,
            $slyTemplateModelFunctions,
        ),

        $template);

    // save the file
    file_put_contents( "$outputDir/$slyTemplateModelName.php", $fileContents );
}

?>