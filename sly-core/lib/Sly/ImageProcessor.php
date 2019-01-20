<?php

/*
    Url:

    http://<akamai>/<origin>/<file>?x=76&y=120&sig=asldjkaldkj&nmd=sqthmb
    cx, cy, cw, ch
*/

/* Base class for backing store (and storing locally) */

abstract class Sly_ImageBackingStore {

    /*! Get a file handle to the image */
    abstract public function getImageHandle($fileName);
    abstract public function putImage($img, $fileName);
}

class NOT_ISED_Sly_ImageContainer {
    
    /**
     * Wrapper
     */
    public function __construct()
    {
        $this->img = new Imagick();
    }
    
    /**
     * Wrapper
     */
    public function getImage()
    {
        return $this->img;
    }
    
    /**
     * Wrapper
     */
    public function readImageFile( $fh )
    {
        $this->img->readImageFile($fh);
    }
    
    /**
     * Wrapper
     */
    public function getImageWidth()
    {
        return $this->img->getImageWidth();
    }
    
    /**
     * Wrapper
     */
    public function getImageHeight()
    {
        return $this->img->getImageHeight();
    }
    
    /**
     * Wrapper
     */
    public function cropImage($cw, $ch, $cx, $cy)
    {
        $this->img = $this->img->coalesceImages();
        foreach ( $this->img as $frame ) {
            $frame->cropImage($cw, $ch, $cx, $cy);
            $frame->setImagePage($cw, $ch, 0, 0);
        }
        $this->img = $this->img->deconstructImages();
    }
    
    /**
     * Wrapper
     */
    public function scaleImage($x, $y)
    {
        $this->img = $this->img->coalesceImages();
        foreach ( $this->img as $frame ) {
            $frame->resizeImage($x, $y, imagick::FILTER_BOX, 1);
        }
        $this->img = $this->img->deconstructImages();
    }

    /**
     * Wrapper
     */
    public function stripImage()
    {
        $this->img->stripImage();
    }

    /**
     * Wrapper
     */
    public function writeImage($path)
    {
        $this->img->writeImages($path, true);
    }

    /**
     * Wrapper
     */
    public function setImageCompression($type)
    {
        $this->img->setImageCompression($type);
    }

    /**
     * Wrapper
     */
    public function setImageCompressionQuality($quality)
    {
        $this->img->setImageCompressionQuality($quality);
    }

    /**
     * Wrapper
     */
    public function setInterlaceScheme($interlaceScheme)
    {
        $this->img->setInterlaceScheme($interlaceScheme);
    }
    
    public function getFrameCount()
    {
        $count = 0;
        foreach ($this->img as $frame) {
            $count++;
        }
        return $count;
    }
}

class Sly_LocalImageBackingStore extends Sly_ImageBackingStore {

    /*!
        Constructs a new LocalImageBackingStore object.

        @param[baseDir] - base directory which will hold all of the images.
    */
    public function __construct($baseDir) {

        $this->baseDir = $baseDir;
    }
    
    public function getRelativePath($fileName) {

        $levelOnePath = substr($fileName, 0, 2);
        $levelTwoPath = $levelOnePath . "/" . substr($fileName, 2, 2);

        return($levelTwoPath);
    }

    public function getFullPath($fileName) {

        $fullPath = sprintf('%s/%s/%s',
                            $this->baseDir,
                            $this->getRelativePath($fileName),
                            $fileName);

        return($fullPath);
    }
    
    public function getImageHandle($fileName) {
        
        $fullPath = $this->getFullPath($fileName);

        $fh = @fopen($fullPath, 'r');

        return($fh);
    }

    /*!
        Saves the image to the local filesystem. This method
        assumes that the filename of the file is the md5 hash
        of the file contents.

        Location of the file is:

        $baseDir/<first 2 chars of filename>/<second 2 chars of filename>/<file>

        @param Sly_ImageContainer $img
        @return bool 
    */
    public function putImage($img, $fileName) {

        if (empty($fileName))
            return(false);

        $levelTwoPath = $this->getRelativePath($fileName);
        $levelTwoDir = $this->baseDir . '/' . $levelTwoPath;

        if ( ! file_exists($levelTwoDir) ) {
            if ( ! @mkdir($levelTwoDir, 0777, true /* recursive */) ) {
                
                // there is a chance we got here even though the directory exists, because
                // there are several images being served at the exact same time and so all of them
                // think the directory DOES NOT exist, but only 1 is going to win the battle to
                // create it.  so not really an error
                
                // lets check to see if it really does exist already
                if ( ! file_exists( $levelTwoDir ) ) {
                    error_log("Sly_LocalImageBackingStore::putImage couldn't create dir $levelTwoDir, probably already exists.");
                    return false;
                }
            }
        }

        $fullImagePath = $levelTwoDir . "/" . $fileName;

        // error_log("Wrote image to $fullImagePath");
        $ret = $this->writeImage($img, $fullImagePath);
        chmod($fullImagePath, 0777);
        return($ret);
    }
    
    /**
     * Simple function but let's break it out.  In the default case
     *   we use ImageMagick functions in PHP.  We may want to use 
     *   things like GD in other cases ( i.e. Colorspot ).
     * 
     * @param Sly_ImageContainer $img
     * @param string $fullImagePath
     * 
     * @return boolean
     */
    public function writeImage($img, $fullImagePath)
    {
        // for some reason the writeImage was not working for animated gifs
        //return $img->writeImage($fullImagePath);
        return file_put_contents( $fullImagePath, $img->getImagesBlob() );

    }
    
}

class Sly_ImageProcessor {

    public function __construct(Sly_ImageBackingStore $backingStore, $url) {

        $this->backingStore = $backingStore;

        $this->url = $url;
        $this->urlParts = self::getUrlParts($url);
    }

    public function getBaseFilename() {

        $path = $this->urlParts['path'];
        $parts = explode('/', $path);
        return end($parts);
    }
    
    public function getProcessedFilename() {

        $fileName = $this->getBaseFilename();
        
        /*  Check all the arguments and append those on to the end of the filename. */
        $argsNoSig = $this->urlParts['argsNoSig'];
        
        $flattenedArgs = str_replace(array('=', '&'), array('_','_'), $argsNoSig);

        if (!empty($flattenedArgs)) {
            $fileName .= '_' . $flattenedArgs;
        }

        return($fileName);
    }

    public function getImageAssetsBaseDir() {

        $systemConfig = Zend_Registry::get('systemConfig');

        $imageSaveDir = $systemConfig->getAssetsDir();

        return $imageSaveDir;
    }

    protected function getProcessorArgs()
    {
        return $_GET;
    }
    
    /*!
        Code to actually resize $this->img based on the args passed
        to the processor.
    */
    protected function process() {

        if (empty($this->img)) {
            return;
        }
        
        $args = $this->getProcessorArgs();

        if (isset($args['nmd']) && $args['nmd'] == 'bb' &&
            isset($args['x'])) {

            // Named Algorithm - BB (Bounding Box)
            $origWidth = $this->img->getImageWidth();
            $origHeight = $this->img->getImageHeight();

            if ($origWidth > $origHeight) {
                $this->img->scaleImage($args['x'], 0);
            } else {
                $this->img->scaleImage(0, $args['x']);
            }
            
            return;

        } else if (isset($args['nmd']) && $args['nmd'] == 'aspect' &&
                   isset($args['x']) && isset($args['y'])) {

            $colorStr = '#FFFFFF';
            if (isset($args['color'])) {
                $colorStr = '#'.$args['color'];
            }
            
            // Need to create this new image and blt $this->img
            // on to it. We then replace $this->img with this new image
            // we've created
            $final = new Imagick();
            $final->newImage($args['x'], $args['y'], $colorStr);

            $origAspect = $this->img->getImageWidth() / $this->img->getImageHeight();
            $newAspect = $final->getImageWidth() / $final->getImageHeight();

            if ($origAspect > $newAspect) {
                // Center vertically.
                $this->img->resizeImage($args['x'], 0, 0, 1);

                $final->compositeImage($this->img, Imagick::COMPOSITE_DEFAULT,
                    0, ($args['y'] - $this->img->getImageHeight()) / 2);    
    
            } else {
                // Center horizontally
                $this->img->resizeImage(0, $args['y'], 0, 1);
    
                $final->compositeImage($this->img, Imagick::COMPOSITE_DEFAULT,
                    ($args['x']- $this->img->getImageWidth()) / 2, 0);    
            }

            $final->setImageFormat($this->img->getImageFormat());

            // Replace img with what we just created
            $this->img = $final;

            // compress image if needed
            if ( isset( $args['icq'] ) ) {
                $this->img->setImageCompression( Imagick::COMPRESSION_JPEG );
                $this->img->setImageCompressionQuality($args['icq']);
            }

            return;
            
        } else if (isset($args['nmd']) && $args['nmd'] == 'stt' &&
                   isset($args['x'])) {

            // Named Algorithm - ST (Square Thumb Top)
            $origWidth = $this->img->getImageWidth();
            $origHeight = $this->img->getImageHeight();

            // Just fake the crop information and fallthough
            if ($origWidth > $origHeight) {
                $args['cw'] = $args['ch'] = $origHeight;               
            } else if ($origHeight > $origWidth) {
                $args['cw'] = $args['ch'] = $origWidth;
            }

            $args['cy'] = 0;
            $args['cx'] = 0;


            if (!isset($args['y'])) {
                $args['y'] = $args['x'];
            }
            
        } else if (isset($args['nmd']) && $args['nmd'] == 'st' &&
                   isset($args['x'])) {

            // Named Algorithm - ST (Square Thumb)
            $origWidth = $this->img->getImageWidth();
            $origHeight = $this->img->getImageHeight();

            // Just fake the crop information and fallthough
            if ($origWidth > $origHeight) {

                $args['cw'] = $args['ch'] = $origHeight;
                $args['cy'] = 0;
                $args['cx'] = round(($origWidth - $origHeight) / 2);
                
            } else if ($origHeight > $origWidth) {

                // Have the square be more towards the top of the image
                $args['cw'] = $args['ch'] = $origWidth;
                $args['cx'] = 0;
                $args['cy'] = round(($origHeight - $origWidth) / 3);

            } // origHeight = origWith falls through completely

            if (!isset($args['y'])) {
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
        
        if ($doCrop) {
            $this->img->cropImage($args['cw'], $args['ch'],
                                  $args['cx'], $args['cy']);
        }

        if (isset($args['x']) && is_numeric($args['x']) &&
            isset($args['y']) && is_numeric($args['y'])) {
            
            /*
                If there are no crop dimenions, we need to compare the desired x and y
                against the actual dimensions of the photo.
            */
            $resolution = array();
            $resolution['x'] = $this->img->getImageWidth();
            $resolution['y'] = $this->img->getImageHeight();
        
            if (isset($args['nmd']) && $args['nmd'] == 'noexpand' &&
                ($args['x'] > $resolution['x'] || $args['y'] > $resolution['y'])) {
                
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
            
            if (!$doCrop && ($actualAspect != $desiredAspect)) {

                if ($desiredAspect > $actualAspect) {

                    $scaledHeight = $resolution['x']/$desiredAspect;
                    
                    $cw = $resolution['x'];
                    $ch = $scaledHeight;

                    $cx = 0;
                    $cy = ($resolution['y'] - $scaledHeight)/2;

                } else {

                    $scaledWidth = $resolution['y']*$desiredAspect;
                    $cw = $scaledWidth;
                    $ch = $resolution['y'];

                    $cx = ($resolution['x'] - $scaledWidth)/2;
                    $cy = 0;
                }
                
                if (false) {
                    print "block = $block<br/>\n";
                    print_r($resolution);
                    print "$actualAspect, $desiredAspect<br/>\n";
                    print "$cw, $ch, $cx, $cy<br/>\n";
                    exit;
                }
                
                $this->img->cropImage($cw, $ch, $cx, $cy);
                
            }
            
            if ($args['x'] != $resolution['x'] && $args['y'] != $resolution['y']) {
            
                $this->img->scaleImage($args['x'], $args['y']);
            }
        }

        // strip the image of its meta data
        $this->img->stripImage();

        // add a gradient to the image if asked to
        if ( isset( $args['gradientTop'] ) && isset( $args['gradientBottom'] ) ) {
            $resolution = array();
            $resolution['x'] = $this->img->getImageWidth();
            $resolution['y'] = $this->img->getImageHeight();

            $gradientTopR = hexdec(substr($args['gradientTop'], 0, 2));
            $gradientTopG = hexdec(substr($args['gradientTop'], 2, 2));
            $gradientTopB = hexdec(substr($args['gradientTop'], 4, 2));
            $gradientTopA = hexdec(substr($args['gradientTop'], 6, 2));            

            $gradientBottomR = hexdec(substr($args['gradientBottom'], 0, 2));
            $gradientBottomG = hexdec(substr($args['gradientBottom'], 2, 2));
            $gradientBottomB = hexdec(substr($args['gradientBottom'], 4, 2));
            $gradientBottomA = hexdec(substr($args['gradientBottom'], 6, 2));            

            $gradientString = sprintf("gradient:rgba(%s,%s,%s,%s)-rgba(%s,%s,%s,%s)",
                                      $gradientTopR, $gradientTopG, $gradientTopB, $gradientTopA / 255,
                                      $gradientBottomR, $gradientBottomG, $gradientBottomB, $gradientBottomA / 255);

            /*
                drc- currently not supported in the version of imagemagick that we are using
            $validDirections = array('northwest', 'north', 'northeast', 'west', 'east', 'southwest', 'south', 'southeast');
            if ( isset( $args['gradientDirection'] ) &&
                 in_array( strtolower($args['gradientDirection']), $validDirections ) ) {
                //$gradientString .= ' -direction='.$args['gradientDirection'];
                $gradientString .= ' -angle=270';
            }
            error_log($gradientString);
            */
            $gradient = new Imagick();
            $gradient->newPseudoImage($resolution['x'], $resolution['y'], $gradientString);
            
            $this->img->compositeImage($gradient, Imagick::COMPOSITE_DEFAULT, 0, 0);
        }
        
        // blur image if asked to (blur value is actually the sigma. we
        // choose the radius to be 3 times the sigma. might allow user to
        // specify that later)
        if ( isset( $args['blur'] ) ) {
            $blur = $args['blur'];
            if ($blur > 50) {
                $blur = 50;
            }
            $this->img->blurImage(3*$blur, $blur);
        }
        
        // compress image if needed
        if ( isset( $args['icq'] ) ) {
            $this->img->setImageCompression( Imagick::COMPRESSION_JPEG );
            $this->img->setImageCompressionQuality($args['icq']);
        }
        
        //$this->img->setInterlaceScheme( Imagick::INTERLACE_PLANE );
        
    }

    /**
     * Break this out so it can be overridden in derived classes
     *   there is a possibility that in a derived class you may
     *   not want to use Image Magick.  This allows you to replace
     *   those functions with another library like GD.
     */
    protected function NOT_USED_getImageContainer()
    {
        return new Sly_ImageContainer();
    }
    
    /**
     * Need to allow override
     */
    protected function getLocalImageBackingStore( $imageSaveDir )
    {
        return new Sly_LocalImageBackingStore($imageSaveDir);
    }

    public function getProcessedImage() {
        
        /*  First things first, verify it has a valid signature. */
        $hasValidSignature = $this->hasValidSignature($this->urlParts['sigUri'],
                                                      @$_GET['sig']);
        
        if (!$hasValidSignature) {
            return(false);
        }
        
        /*
            Construct a local backing store object and see if the processed
            image already exists locally. If it does, we can just return that.
            If it doesn't, we can pull the image down from the external
            backing store.
        */
        $imageSaveDir = $this->getImageAssetsBaseDir();
        
        $processedFilename = $this->getProcessedFilename();
        $this->processedFilename = $processedFilename;
        $localBackingStore = $this->getLocalImageBackingStore($imageSaveDir);
        $fh = $localBackingStore->getImageHandle($processedFilename);

        // Set this block to check for false if you are testing and don't want
        // to load the cached image
        if ( $fh ) {
            //$this->img = $this->getImageContainer();
            $this->img = new Imagick();
            $this->img->readImageFile($fh);
            return($this->img);
        }
        
        /*
            The image isn't local. Pull it down locally and then we
            can process.
        */
        $fileName = $this->getBaseFilename();
        $fh = $this->backingStore->getImageHandle($fileName);

        if (!$fh)
            return(false);
        
        //$this->img = $this->getImageContainer();
        $this->img = new Imagick();
        $this->img->readImageFile($fh);
        
        // Animated gifs can take a while
        set_time_limit(300);
        $this->process();
        
        if (isset($_GET['frame'])) {

            $frameCount = 0;
            foreach( $this->img as $frame ) {
                $frameCount++;
            }
            
            $i = round($_GET['frame'] / 10 * ($frameCount-1));
            $this->img = $this->img->coalesceImages();
            foreach ($this->img as $j => $frame) {
                if (!$j || $i == $j) {
                    $this->img = $frame->getImage();
                }
            }
        }

        /*  Write the processed image out to the local store. */
        $localBackingStore->putImage($this->img, $processedFilename);
        
        return($this->img);
    }

    /*!
        Returns the content type header for the image currently being
        processed.
    */
    public function getContentTypeHeader() {

        if (empty($this->img)) {
            return '';
        }

        if (empty($this->processedFilename)) {
            return 'Content-type: image/png';
        }

        $parts = explode('.', $this->processedFilename);
        $extension = @substr($parts[1], 0, 3);

        if ($extension == 'jpg') {
            return 'Content-type: image/jpeg';
        } else if ($extension == 'png') {
            return 'Content-type: image/png';            
        } else if ($extension == 'gif') {
            return 'Content-type: image/gif';
        }

        return '';
    }
    
    public function hasValidSignature($uri, $sig) {
        /*  Base class implementation always returns true. */
        return(true);
    }

    protected static function getUrlParts($url) {

        $urlParts = parse_url($url);

        if ($url == '/favicon.ico')
            return;
        
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
    
    private $backingStore;
}

?>
