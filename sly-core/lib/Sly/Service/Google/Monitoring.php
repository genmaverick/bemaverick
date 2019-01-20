<?php

class Sly_Service_Google_Monitoring
{

    /**
     * Defined here: https://cloud.google.com/monitoring/api/v3/metrics#metric-kinds
     */
    const METRIC_KIND_GAUGE               = 'GAUGE';
    const METRIC_KIND_DELTA               = 'DELTA';
    const METRIC_KIND_CUMULATIVE          = 'CUMULATIVE';

    const METRIC_VALUE_TYPE_BOOL          = 'BOOL';
    const METRIC_VALUE_TYPE_INT64         = 'INT64';
    const METRIC_VALUE_TYPE_DOUBLE        = 'DOUBLE';
    const METRIC_VALUE_TYPE_STRING        = 'STRING';
    const METRIC_VALUE_TYPE_DISTRIBUTION  = 'DISTRIBUTION';
    const METRIC_VALUE_TYPE_MONEY         = 'MONEY';

    const LABEL_VALUE_TYPE                  = "LABEL_VALUE_TYPE";
    const LABEL_KEY                         = "LABEL_KEY";
    const LABEL_VALUE                       = "LABEL_VALUE";
    const LABEL_DESCRIPTION                 = "LABEL_DESCRIPTION";

    /**
     * Create a new metric descriptor
     *
     * @param string $projectId
     * @param string $keyFilePath
     * @param string $metricName
     * @param string $metricDisplayName
     * @param string $metricDescription
     * @param string $metricKind https://cloud.google.com/monitoring/api/v3/metrics#metric-kinds
     * @param string $metricValueType https://cloud.google.com/monitoring/api/v3/metrics#metric-kinds
     * @param array $labels
     * @return void
     */
    public static function createMetricDescriptor(
        $projectId,
        $keyFilePath,
        $metricName,
        $metricDisplayName,
        $metricDescription,
        $metricKind,
        $metricValueType,
        $labels = null
    ) {
        putenv( "GOOGLE_APPLICATION_CREDENTIALS=$keyFilePath" );

        $client = new Google_Client();
        $client->useApplicationDefaultCredentials();
        $client->addScope( Google_Service_Monitoring::MONITORING_WRITE );

        $monitoring = new Google_Service_Monitoring( $client );

        $projectName = "projects/$projectId";

        $labelDescriptors = array();
        if ( $labels && is_array( $labels ) ) {
            foreach ( $labels as $label ) {
                $descriptor = new Google_Service_Monitoring_LabelDescriptor();
                $descriptor->setDescription( $label[Sly_Service_Google_Monitoring::LABEL_DESCRIPTION] );
                $descriptor->setKey( $label[Sly_Service_Google_Monitoring::LABEL_KEY] );
                $descriptor->setValueType( $label[Sly_Service_Google_Monitoring::LABEL_VALUE_TYPE] );
                $labelDescriptors[] = $descriptor;
            }
        }

        $metricDescriptor = new Google_Service_Monitoring_MetricDescriptor();
        $metricDescriptor->setDisplayName( $metricDisplayName );
        $metricDescriptor->setDescription( $metricDescription );
        $metricDescriptor->setType( 'custom.googleapis.com/'.$metricName );
        $metricDescriptor->setMetricKind( $metricKind );
        $metricDescriptor->setValueType( $metricValueType );
        if ( count( $labelDescriptors ) ) {
            $metricDescriptor->setLabels( $labelDescriptors );
        }

        $monitoring->projects_metricDescriptors->create( $projectName, $metricDescriptor );
    }

    /**
     * Create a new metric value
     *
     * @param string $projectId
     * @param string $keyFilePath
     * @param string $metricName Essentially the name of the metric
     * @param string $metricKind https://cloud.google.com/monitoring/api/v3/metrics#metric-kinds
     * @param string $metricValueType https://cloud.google.com/monitoring/api/v3/metrics#metric-kinds
     * @param string $metricValue
     * @param array $labels array( '<key 1'> => '<value 1>', ..., '<key n>' => '<value n>' )
     * @return void
     */
    public static function addMetricValue(
        $projectId,
        $keyFilePath,
        $metricName,
        $metricKind,
        $metricValueType,
        $metricValue,
        $labels = null
    ) {

        putenv( "GOOGLE_APPLICATION_CREDENTIALS=$keyFilePath" );

        $client = new Google_Client();
        $client->useApplicationDefaultCredentials();
        $client->addScope( Google_Service_Monitoring::MONITORING_WRITE );

        $monitoring = new Google_Service_Monitoring( $client );

        $projectName = "projects/$projectId";

        $resource = new Google_Service_Monitoring_MonitoredResource();
        $resource->setLabels( array( 'project_id' => $projectId ) );
        $resource->setType( 'global' );

        $metric = new Google_Service_Monitoring_Metric();
        $metric->setLabels( $labels );
        $metric->setType( 'custom.googleapis.com/' . $metricName );

        $timeInterval = new Google_Service_Monitoring_TimeInterval();
        $timeInterval->setEndTime( Sly_Date::formatDate( time(), 'ISO_8601' ) );

        $typedValue = new Google_Service_Monitoring_TypedValue();
        switch ( $metricValueType ) {
            case Sly_Service_Google_Monitoring::METRIC_VALUE_TYPE_BOOL:
                $typedValue->setBoolValue( $metricValue );
                break;
            case Sly_Service_Google_Monitoring::METRIC_VALUE_TYPE_INT64:
                $typedValue->setInt64Value( $metricValue );
                break;
            case Sly_Service_Google_Monitoring::METRIC_VALUE_TYPE_DOUBLE:
                $typedValue->setDoubleValue( $metricValue );
                break;
            case Sly_Service_Google_Monitoring::METRIC_VALUE_TYPE_STRING:
                $typedValue->setStringValue( $metricValue );
                break;
        }

        $point = new Google_Service_Monitoring_Point();
        $point->setInterval( $timeInterval );
        $point->setValue( $typedValue );

        $timeSeries = new Google_Service_Monitoring_TimeSeries();
        $timeSeries->setMetric( $metric );
        $timeSeries->setMetricKind( $metricKind );
        $timeSeries->setPoints( array( $point ) );
        $timeSeries->setResource( $resource );
        $timeSeries->setValueType( $metricValueType );

        $timeSeriesRequest = new Google_Service_Monitoring_CreateTimeSeriesRequest();
        $timeSeriesRequest->setTimeSeries( array( $timeSeries ) );

        $monitoring->projects_timeSeries->create( $projectName, $timeSeriesRequest );
    }

}

?>
