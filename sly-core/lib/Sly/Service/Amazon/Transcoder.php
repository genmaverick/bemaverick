<?php

use Aws\ElasticTranscoder\ElasticTranscoderClient;

class Sly_Service_Amazon_Transcoder
{
    # HLS Presets that will be used to create an adaptive bitrate playlist.
    const HLS_64K_AUDIO_PRESET_ID = '1523894524096-b53wbf';
    const HLS_0400K_PRESET_ID     = '1523906905846-j77kas';
    const HLS_0600K_PRESET_ID     = '1523906284985-8p0k8e';
    const HLS_1000K_PRESET_ID     = '1523906429733-rsa3ki';
    const HLS_1500K_PRESET_ID     = '1523906537891-5kcyut';
    const HLS_2000K_PRESET_ID     = '1523906599692-iyk6cd';


    /**
     * Start a job for transcoding a video file
     *
     * @param string $filename
     * @param string $pipelineId
     * @param string $presetId
     * @param hash $config
     * @return Guzzle\Service\Resource\Model
     */
    public static function startJob( $filename, $pipelineId, $presetId, $config )
    {
        $client = ElasticTranscoderClient::factory( $config );

        $pathInfo = pathinfo( $filename );

        $jobConfig = array(

            'PipelineId' => $pipelineId,

            'Input' => array(
                'Key' => $filename,
                'FrameRate' => 'auto',
                'Resolution' => 'auto',
                'AspectRatio' => 'auto',
                'Interlaced' => 'auto',
                'Container' => 'auto',
            ),

            'Outputs' => array(
                array(
                    'Key' => $filename,
                    'ThumbnailPattern' => $pathInfo['filename'] . '-thumbnail-{count}',
                    'PresetId' => $presetId,
                )
            ),
        );

        $create_job_result = $client->createJob( $jobConfig );
        return $create_job_result['Job'];
    }


    /**
     * Create a AWS Encoder job to output a HLS video file
     *
     * @param string $filename
     * @param string $pipelineId
     * @param hash $config
     * @return String
     */
    public static function createHLSJob( $filename, $pipelineId, $config )
    {

        $client = ElasticTranscoderClient::factory( $config );
        $pathInfo = pathinfo( $filename );

        $hls_presets = array(
            'hlsAudio' => Sly_Service_Amazon_Transcoder::HLS_64K_AUDIO_PRESET_ID,
            'hls0400k' => Sly_Service_Amazon_Transcoder::HLS_0400K_PRESET_ID,
            'hls1000k' => Sly_Service_Amazon_Transcoder::HLS_1000K_PRESET_ID,
            'hls1500k' => Sly_Service_Amazon_Transcoder::HLS_1500K_PRESET_ID,
            'hls2000k' => Sly_Service_Amazon_Transcoder::HLS_2000K_PRESET_ID,
        );

        # HLS Segment duration that will be targeted.
        $segment_duration = '2';

        #All outputs will have this prefix prepended to their output key.
        $output_key_prefix = $pathInfo['filename'];

        # Setup the job input using the provided filename.
        $input = array('Key' => $filename);

        #Setup the job outputs using the HLS presets.
        $output_key = hash('sha256', utf8_encode($filename));

        # Specify the outputs based on the hls presets array specified.
        $outputs = array();
        foreach ( $hls_presets as $prefix => $presetId ) {
            $output = array(
                'Key' => "$prefix/$output_key",
                'PresetId' => $presetId,
                'SegmentDuration' => $segment_duration );
            if( $presetId == Sly_Service_Amazon_Transcoder::HLS_2000K_PRESET_ID ) {
                $output['ThumbnailPattern'] = $pathInfo['filename'] . '-thumbnail-{count}';
            }
            array_push( $outputs, $output);
        }

        # Setup master playlist which can be used to play using adaptive bitrate.
        $playlist = array(
            'Name' => 'hls_' . $output_key,
            'Format' => 'HLSv3',
            'OutputKeys' => array_map(function($x) { return $x['Key']; }, $outputs)
        );

        # Create the job.
        $create_job_request = array(
            'PipelineId' => $pipelineId,
            'Input' => $input,
            'Outputs' => $outputs,
            'OutputKeyPrefix' => "$output_key_prefix/",
            'Playlists' => array($playlist)
        );

        $create_job_result = $client->createJob($create_job_request)->toArray();
        return $job = $create_job_result['Job'];
    }

}

?>
