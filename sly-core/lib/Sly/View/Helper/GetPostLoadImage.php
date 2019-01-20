<?php

class Sly_View_Helper_GetPostLoadImage 
{
    public function getPostLoadImage($image, $postLoad = true, $overrideDimensions = null, $attributes = array() )
    {
        $xhtml = '';
        
        // TODO - fix this
        
        $urlPrefix = '';//'http://' . Zend_Registry::get( 'systemConfig' )->getHttpHost();

        if(!$image) {
            return $xhtml;   
        }
        
        if($image instanceof Sly_Image || $image instanceof Sly_FakeImage){
            if ( $overrideDimensions ) {
                $height = $overrideDimensions['height'];
    	        $width  = $overrideDimensions['width'];                    
            } else {
                $height = $image->getHeight();
    	        $width  =  $image->getWidth();
            }
            
            if ( $image instanceof Sly_Image_MySpace || $image instanceof Sly_FakeImage ) {
                $url = $this->view->url( $image->getUrl() );    
            } else {            
                $url = $this->view->url( 'image', array( 'imageId' => $image->getId() ), false, 'kontend');
            }
        } else {
            if ( $overrideDimensions ) {
                $height = $overrideDimensions['height'];
    	        $width  = $overrideDimensions['width'];                    
            } else {            
                $height = $image['height'];
	            $width  =  $image['width'];
            }    

            $url = $this->view->url( 'imageStatic', array( 'imageName' => $image['url'] ), false );
        }
        
        $transparentImage = $this->view->url( 'imageStatic', array( 'imageName' => '1x1_tpnt.gif' ), false);

        $attributes['height'] = $height;
        $attributes['width'] = $width;
        $attributes['alt'] = '';
        $attributes['src'] =  $url;
        
        
        

        if ($postLoad) {     
            $attributes = $this->view->formatUtil()->addItemToAttributes($attributes, 'class', 'pli' );       
            $attributes =  $this->view->formatUtil()->addItemToAttributes($attributes, 'class', 'image-' . $url );           
	        $attributes['src'] =  $transparentImage;
        }
        
        $xhtml = $this->view->htmlElement()->getClosedTag('img',$attributes );
        return $xhtml;
    }    
    
    public function setView( Zend_View_Interface $view )
    {
        $this->view = $view;
    }    
}
?>
