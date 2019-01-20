<?php

class BeMaverick_Image_Processor
{

    /**
     * @var Sly_Image_BackingStore_Abstract
     * @access private
     */
    private $_externalBackingStore;

    /**
     * @var Sly_Image_BackingStore_Abstract
     * @access private
     */
    private $_localBackingStore;

    /**
     * @var string
     * @access private
     */
    private $_url;

    /**
     * @var hash
     * @access private
     */
    private $_urlParts;

    /**
     * @param Sly_Image_BackingStore_Abstract $externalBackingStore
     * @param Sly_Image_BackingStore_Abstract $localBackingStore
     * @param string $url
     * @return void
     */
    public function __construct( $externalBackingStore, $localBackingStore, $url )
    {
        $this->_externalBackingStore = $externalBackingStore;
        $this->_localBackingStore = $localBackingStore;
        $this->_url = $url;
        $this->_urlParts = self::getUrlParts( $url );
    }

    /**
     * @return boolean
     */
    public function hasValidSignature( $uri, $signature, $imageSalt )
    {
        if ( md5( $imageSalt . $uri ) == $signature ) {
            return true;
        }

        return false;
    }

    /**
     * @param string $imageSalt
     * @param hash $args
     * @return binary
     */
    public function getProcessedImageBlob( $imageSalt, $args )
    {

        // First things first, verify it has a valid signature.
        $hasValidSignature = $this->hasValidSignature( $this->_urlParts['sigUri'], @$_GET['sig'], $imageSalt );
        // die(var_export($hasValidSignature));

        if ( ! $hasValidSignature ) {
            return false;
        }

        $cacheVersion = 1;
        $baseFilename = $this->getBaseFilename();
        $processedFilename = $this->getProcessedFilename($cacheVersion);

        // first check to see if the image is local and already processed
        $imageBlob = $this->_localBackingStore->getImageBlob( $processedFilename );

        $disableLocalCache = false;

        // Set this block to check for false if you are testing and don't want
        // to load the cached image
        if ( $imageBlob && ! $disableLocalCache ) {
            return $imageBlob;
        }

        // image is not local, so get it from external source and process it
        $imageBlob = $this->_externalBackingStore->getImageBlob( $baseFilename );

        if ( ! $imageBlob ) {
            return null;
        }

        // Animated gifs can take a while
        set_time_limit( 300 );
        $image = $this->processImageBlob( $imageBlob, $args );

        if ( isset( $_GET['frame'] ) ) {

            $frameCount = 0;
            foreach ( $image as $frame ) {
                $frameCount++;
            }

            $i = round( $_GET['frame'] / 10 * ( $frameCount - 1 ) );
            $image = $image->coalesceImages();
            foreach ( $image as $j => $frame ) {
                if ( ! $j || $i == $j ) {
                    $image = $frame->getImage();
                }
            }
        }

        $imageBlob = $image->getImagesBlob();

        // lets save the processed file locally for next time
        $this->_localBackingStore->putImageBlob( $imageBlob, $processedFilename );

        return $imageBlob;
    }

    /**
     * @return string
     */
    public function getContentTypeHeader()
    {
        $processedFilename = $this->getProcessedFilename();

        if ( ! $processedFilename ) {
            return 'Content-type: image/png';
        }

        $parts = explode( '.', $processedFilename );
        $extension = @substr( $parts[1], 0, 3 );

        if ( $extension == 'jpg' ) {
            return 'Content-type: image/jpeg';
        } else if ( $extension == 'png' ) {
            return 'Content-type: image/png';
        } else if ( $extension == 'gif' ) {
            return 'Content-type: image/gif';
        }

        return '';
    }

    /**
     * @return string
     */
    protected function getBaseFilename()
    {
        $path = $this->_urlParts['path'];
        $parts = explode( '/', $path );
        return end( $parts );
    }

    /**
     * @return string
     */
    protected function getProcessedFilename($version = 0)
    {
        $filename = $this->getBaseFilename();

        // Check all the arguments and append those on to the end of the filename.
        $argsNoSig = $this->_urlParts['argsNoSig'];

        $flattenedArgs = str_replace( array( '=', '&' ), array( '_', '_' ), $argsNoSig );

        if ( ! empty( $flattenedArgs ) ) {
            $filename .= '_' . $flattenedArgs;
        }

        if ($version > 0) {
            $filename .= '_v'.$version;
        }

        return $filename;
    }

    /**
     * Process the image and resize as necessary from the args passed in
     *
     * @param binary $imageBlob
     * @param hash $args
     * @return Imagick
     */
    protected function processImageBlob( $imageBlob, $args )
    {
        $image = new Imagick();
        $image->readImageBlob( $imageBlob );

        if ( empty( $image ) ) {
            return;
        }

        if ( isset( $args['nmd'] ) && $args['nmd'] == 'bb' && isset( $args['x'] ) ) {

            // Named Algorithm - BB (Bounding Box)
            $origWidth = $image->getImageWidth();
            $origHeight = $image->getImageHeight();

            if ( $origWidth > $origHeight ) {
                $image->scaleImage( $args['x'], 0 );
            } else {
                $image->scaleImage( 0, $args['x'] );
            }
            
            return;

        } else if ( isset( $args['nmd'] ) && $args['nmd'] == 'aspect' && isset( $args['x'] ) && isset( $args['y'] ) ) {

            $colorStr = '#FFFFFF';
            if ( isset( $args['color'] ) ) {
                $colorStr = '#'.$args['color'];
            }
            
            // Need to create this new image and blt $image
            // on to it. We then replace $image with this new image
            // we've created
            $final = new Imagick();
            $final->newImage( $args['x'], $args['y'], $colorStr );

            $origAspect = $image->getImageWidth() / $image->getImageHeight();
            $newAspect = $final->getImageWidth() / $final->getImageHeight();

            if ( $origAspect > $newAspect ) {
                // Center vertically.
                $image->resizeImage( $args['x'], 0, 0, 1 );

                $final->compositeImage(
                    $image,
                    Imagick::COMPOSITE_DEFAULT,
                    0,
                    ( $args['y'] - $image->getImageHeight() ) / 2
                );
    
            } else {
                // Center horizontally
                $image->resizeImage( 0, $args['y'], 0, 1 );
    
                $final->compositeImage(
                    $image,
                    Imagick::COMPOSITE_DEFAULT,
                    ( $args['x'] - $image->getImageWidth() ) / 2,
                    0
                );
            }

            $final->setImageFormat( $image->getImageFormat() );

            // Replace img with what we just created
            $image = $final;

            // compress image if needed
            if ( isset( $args['icq'] ) ) {
                error_log('Imagick::COMPRESSION_JPEG => '.Imagick::COMPRESSION_JPEG);
                error_log('$args[\'icq\'] => '.$args['icq']);
                $image->setImageCompression( Imagick::COMPRESSION_JPEG );
                $image->setImageCompressionQuality( $args['icq'] );
            }

            return;
            
        } else if ( isset( $args['nmd'] ) && $args['nmd'] == 'stt' && isset( $args['x'] ) ) {

            // Named Algorithm - ST (Square Thumb Top)
            $origWidth = $image->getImageWidth();
            $origHeight = $image->getImageHeight();

            // Just fake the crop information and fallthough
            if ( $origWidth > $origHeight ) {
                $args['cw'] = $args['ch'] = $origHeight;               
            } else if ( $origHeight > $origWidth ) {
                $args['cw'] = $args['ch'] = $origWidth;
            }

            $args['cy'] = 0;
            $args['cx'] = 0;

            if ( ! isset( $args['y'] ) ) {
                $args['y'] = $args['x'];
            }
            
        } else if ( isset( $args['nmd'] ) && $args['nmd'] == 'st' && isset( $args['x'] ) ) {

            // Named Algorithm - ST (Square Thumb)
            $origWidth = $image->getImageWidth();
            $origHeight = $image->getImageHeight();

            // Just fake the crop information and fallthough
            if ( $origWidth > $origHeight ) {

                $args['cw'] = $args['ch'] = $origHeight;
                $args['cy'] = 0;
                $args['cx'] = round( ( $origWidth - $origHeight ) / 2 );
                
            } else if ( $origHeight > $origWidth ) {

                // Have the square be more towards the top of the image
                $args['cw'] = $args['ch'] = $origWidth;
                $args['cx'] = 0;
                $args['cy'] = round( ( $origHeight - $origWidth ) / 3 );

            } // origHeight = origWith falls through completely

            if ( ! isset( $args['y'] ) ) {
                $args['y'] = $args['x'];
            }
            
            // FALLTHROUGH
        }
        
        /*  Get down to the image processing business */
        /*  Check to see if we need to crop the image. */
        $doCrop = isset($args['cx']) && is_numeric($args['cx']) &&
                  isset($args['cy']) && is_numeric($args['cy']) &&
                  isset($args['ch']) && is_numeric($args['ch']) &&
                  isset($args['cw']) && is_numeric($args['cw']);
        
        if ( $doCrop ) {
            $image->cropImage( $args['cw'], $args['ch'], $args['cx'], $args['cy'] );
        }

        if ( isset( $args['x'] ) && is_numeric( $args['x'] ) && isset( $args['y'] ) && is_numeric( $args['y'] ) ) {
            
            /*
                If there are no crop dimenions, we need to compare the desired x and y
                against the actual dimensions of the photo.
            */
            $resolution = array();
            $resolution['x'] = $image->getImageWidth();
            $resolution['y'] = $image->getImageHeight();
        
            if ( isset( $args['nmd'] ) && $args['nmd'] == 'noexpand' && ( $args['x'] > $resolution['x'] || $args['y'] > $resolution['y'] ) ) {
                
                if ($args['x'] - $resolution['x'] > $args['y'] - $resolution['y']) {
                    $args['y'] *= $resolution['x'] / $args['x'];
                    $args['x'] = $resolution['x'];
                } else {
                    $args['x'] *= $resolution['y'] / $args['y'];
                    $args['y'] = $resolution['y'];
                }
            }

            $actualAspect = $resolution['x']/$resolution['y'];
            $desiredAspect = $args['x'] > 0 && $args['y'] > 0 ? $args['x']/$args['y'] : $actualAspect;
            
            if ( ! $doCrop && ( $actualAspect != $desiredAspect ) ) {

                if ( $desiredAspect > $actualAspect ) {

                    $scaledHeight = $resolution['x'] / $desiredAspect;
                    
                    $cw = $resolution['x'];
                    $ch = $scaledHeight;

                    $cx = 0;
                    $cy = ( $resolution['y'] - $scaledHeight ) / 2;

                } else {

                    $scaledWidth = $resolution['y'] * $desiredAspect;
                    $cw = $scaledWidth;
                    $ch = $resolution['y'];

                    $cx = ( $resolution['x'] - $scaledWidth ) / 2;
                    $cy = 0;
                }
                
                $image->cropImage( $cw, $ch, $cx, $cy );
            }
            
            if ( $args['x'] != $resolution['x'] && $args['y'] != $resolution['y'] ) {
            
                $image->scaleImage( $args['x'], $args['y'] );
            }
        }

        // strip the image of its meta data
        $image->stripImage();

        // add a gradient to the image if asked to
        if ( isset( $args['gradientTop'] ) && isset( $args['gradientBottom'] ) ) {
            $resolution = array();
            $resolution['x'] = $image->getImageWidth();
            $resolution['y'] = $image->getImageHeight();

            $gradientTopR = hexdec( substr( $args['gradientTop'], 0, 2 ) );
            $gradientTopG = hexdec( substr( $args['gradientTop'], 2, 2 ) );
            $gradientTopB = hexdec( substr( $args['gradientTop'], 4, 2 ) );
            $gradientTopA = hexdec( substr( $args['gradientTop'], 6, 2 ) );

            $gradientBottomR = hexdec( substr( $args['gradientBottom'], 0, 2 ) );
            $gradientBottomG = hexdec( substr( $args['gradientBottom'], 2, 2 ) );
            $gradientBottomB = hexdec( substr( $args['gradientBottom'], 4, 2 ) );
            $gradientBottomA = hexdec( substr( $args['gradientBottom'], 6, 2 ) );

            $gradientString = sprintf("gradient:rgba(%s,%s,%s,%s)-rgba(%s,%s,%s,%s)",
                                      $gradientTopR, $gradientTopG, $gradientTopB, $gradientTopA / 255,
                                      $gradientBottomR, $gradientBottomG, $gradientBottomB, $gradientBottomA / 255);

            $gradient = new Imagick();
            $gradient->newPseudoImage( $resolution['x'], $resolution['y'], $gradientString );
            
            $image->compositeImage( $gradient, Imagick::COMPOSITE_DEFAULT, 0, 0 );
        }
        
        // blur image if asked to (blur value is actually the sigma. we
        // choose the radius to be 3 times the sigma. might allow user to
        // specify that later)
        if ( isset( $args['blur'] ) ) {
            $blur = $args['blur'];
            if ($blur > 50) {
                $blur = 50;
            }
            $image->blurImage( 3 * $blur, $blur );
        }
        
        // compress image if needed
        if ( isset( $args['icq'] ) ) {
            //convert PNG to JPG before compression
            $type = $image->getImageFormat();
            if (in_array( $image->getImageFormat(), ['png', 'PNG'] )) {
                $image->setImageFormat('jpg');
            }
            // $args['icq'] = 70;
            $image->setImageCompression( Imagick::COMPRESSION_JPEG );
            $image->setImageCompressionQuality( $args['icq'] );
        }

        return $image;
    }

    /**
     * @return hash
     */
    protected static function getUrlParts( $url )
    {

        $urlParts = parse_url( $url );

        if ( $url == '/favicon.ico' ) {
            return;
        }
        
        /* Origin Server. */
        $urlParts['origin'] = substr($urlParts['path'], 1,
                                     strpos($urlParts['path'], '/', 1) - 1);


        /* Uri used to verify signature. */
        if ( isset( $urlParts['query'] ) ) {
            $sigPos = strpos( $urlParts['query'], '&sig=' );
            $argsNoSig = substr( $urlParts['query'], 0, $sigPos );
            if ($sigPos > 0 && ($nextAmp = strpos( $urlParts['query'], '&', $sigPos + 1)) !== FALSE) {
                $argsNoSig .= substr( $urlParts['query'], $nextAmp );
            }
        }
        else {
            $argsNoSig = '';
        }
        
        $urlParts['argsNoSig'] = $argsNoSig;
        $urlParts['sigUri'] = $urlParts['path'] . '?' . $argsNoSig;

        return $urlParts;
    }
    
}

?>
