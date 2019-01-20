<?php

interface Sly_Image_BackingStore_Interface
{
    /**
     * @param string $filename
     * @return binary
     */
    public function getImageBlob( $filename );

    /**
     * @param binary $imageBlob
     * @param string $filename
     * @return boolean
     */
    public function putImageBlob( $imageBlob, $filename );
}

?>
