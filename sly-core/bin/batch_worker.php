<?php
$args = 'h:';

$options = getopt( $args );

if ( ! @$options['h']  ) {
    print "You must specify the following options:\n";
    print "-h hosts (comma delimited)\n";
    print "\n";
    exit;
}

$hosts = explode( ',', $options['h'] );
$port = 4730;

$worker = new GearmanWorker();

// add servers
foreach( $hosts as $host ) {
    $worker->addServer( $host, $port );
}

// test the servers
if ( ! $worker->echo( "test" ) ) {
    print "Unable to connect to all gearman servers!\n";
    exit( 1 );
}

$worker->addFunction("reverse", "my_reverse_function");
$worker->addFunction("runScript", "runScript" );

while ($worker->work());

function my_reverse_function($job)
{
  return strrev($job->workload());
}

function runScript( $job )
{
    try {
        $data = array();
        
        $data['host'] = php_uname( 'n' );
        
        $workload = unserialize( $job->workload() );
    
        $command = $workload['command'];
    
        $elements = $workload['elements'];
        
        // dump elements into file
        $tempName = tempnam( sys_get_temp_dir(), 'sly' );
        file_put_contents( $tempName, implode( "\n", $elements ) );
    
        $command .= " --file $tempName";
        
        $data['status'] = 'starting';
        $data['command'] = $command;
        $data['file'] = $tempName;
        
        // send starting message
        $job->sendData( serialize( $data ) );
        
        $data['output'] = array();
        
        exec( $command . ' 2>&1', $data['output'], $data['retval'] );
        
        unlink( $tempName );
        
        if ( $data['retval'] == 0 ) {
            // success
            $data['status'] = 'complete';
            
            $job->sendData( serialize( $data ) );
            $job->sendComplete( serialize( $data ) );
        }
        else {
            // failure
            $data['status'] = 'fail';
            
            $job->sendData( serialize( $data) );
            $job->sendFail();
        }
        
    }
    catch ( Exception $e ) {
        $data['retval'] = 1;
        $data['output'][] = $e->getMessage();
        $data['status'] = 'fail';
        
        $job->sendData( serialize( $data ) );
        
        $job->sendFail();
    }

}

?>
