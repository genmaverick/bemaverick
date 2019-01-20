<?php
/**
 * Class for formatting video objects
 *
 * @category BeMaverick
 * @package  BeMaverick_View_Helper
 */
class BeMaverick_View_Helper_FormatVideo
{
    /**
     * The view object that created this helper object.
     *
     * @var Zend_View
     */
    public $view;

    /**
     * Returns this helper
     *
     * @return BeMaverick_View_Helper_FormatVideo
     */
    public function formatVideo()
    {
        return $this;
    }

    /**
     * Get a video player markup
     *
     * @param BeMaverick_Video $video
     * @param array $config
     * @return string
     */
    public function getPlayer( $video, $config = array() )
    {
        if ( !$video ) {
            return '';
        }

        $configObj = new Sly_DataObject( $config );
        $autoplay = $configObj->getAutoplay( false );
        $thumbnailUrl = $video->getThumbnailUrl();
        $videoUrl = $video->getVideoUrl();

        $videoAttributes = array(
            'playsinline'
        );
        $attributes = array(
            "class" => "video-player proxy-video-player",
            "data-video-status" => "not-playing",
            "data-autoplay" => $autoplay
        );

        $sources = array(
            array(
                'filename' => $videoUrl,
                'type' => "video/mp4",
                'mobile' => true,
                'desktop' => true
            )
        );

        return '
            <div '.$this->view->htmlAttributes( $attributes ).'>
                <div class="proxy-inline-video video-player-container"
                    data-video-attributes="'.join( ' ', $videoAttributes ).'"
                    data-video-poster="'.$thumbnailUrl.'"
                    data-video-sources=\''.json_encode( $sources ).'\'
                >
                </div>
                <div class="video-player__controls">
                    <div class="video-player__play-button">
                    </div>
                    <div class="video-player__mute-button">
                        <div class="svgicon--sound-on video-player__sound-on"></div>
                        <div class="svgicon--sound-off video-player__sound-off"></div>
                    </div>
                    <div class="video-player__timeline">
                        <div class="video-player__timeline-elapsed">
                        </div>
                    </div>
                </div>
            </div>
        ';
    }

    /**
     * Set the view to this object
     *
     * @param Zend_View_Interface $view
     * @return void
     */
    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }

}
