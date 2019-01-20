<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Badge.php' );

class BeMaverick_Badge
{
    /**
     * @static
     * @var array
     * @access protected
     */
    protected static $_instance = array();

    /**
     * @access protected
     */
    protected $_site;

    /**
     * @var integer
     * @access protected
     */
    protected $_badgeId = null;

    /**
     * @var BeMaverick_Da_Badge
     * @access protected
     */
    protected $_daBadge;

    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $badgeId
     * @return void
     */
    public function __construct( $site, $badgeId )
    {
        $this->_site = $site;
        $this->_badgeId = $badgeId;
        $this->_daBadge = BeMaverick_Da_Badge::getInstance();
    }

    /**
     * Retrieves the badge instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $badgeId
     * @return BeMaverick_Badge
     */
    public static function getInstance( $site, $badgeId )
    {
        if ( ! $badgeId ) {
            return null;
        }
        
        if ( ! isset( self::$_instance[$badgeId] ) ) {

            $daBadge = BeMaverick_Da_Badge::getInstance();

            // make sure badge exists
            if ( ! $daBadge->isKeysExist( array( $badgeId ) ) ) {
                self::$_instance[$badgeId] = null;
            }
            else {
                self::$_instance[$badgeId] = new self( $site, $badgeId );
            }
        }

        return self::$_instance[$badgeId];

    }

    /**
     * Create a badge
     *
     * @param BeMaverick_Site $site
     * @param string $name
     * @return BeMaverick_Badge
     */
    public static function createBadge( $site, $name )
    {
        $daBadge = BeMaverick_Da_Badge::getInstance();

        $badgeId = $daBadge->createBadge( $name );
        
        // we might have already tried to get this badge for some reason, so update
        // the self instance here and return it
        self::$_instance[$badgeId] = new self( $site, $badgeId );
        
        return self::$_instance[$badgeId];
    }

    /**
     * Get a list of badges
     *
     * @param array $badgeIds
     * @param BeMaverick_Site $site
     * @return BeMaverick_Badge[]
     */
    public static function getBadges( $site, $status = null )
    {
        // Default to Active badges filter
        $status = (is_null($status)) ? 'active' : $status;

        $daBadge = BeMaverick_Da_Badge::getInstance();
        $badgeIds = $daBadge->getBadgeIds( $status );

        $badges = array();
        foreach ( $badgeIds as $badgeId ) {
            $badges[] = self::getInstance( $site, $badgeId );
        }

        return $badges;
    }

    /**
     * Get a count of badges
     *
     * @param hash $filterBy
     * @return integer
     */
    public static function getBadgeCount( $filterBy = null )
    {
        $daBadge = BeMaverick_Da_Badge::getInstance();

        return $daBadge->getBadgeCount( $filterBy );
    }

    /**
     * Get the toString function
     *
     * @return string
     */
    public function __toString()
    {
        return $this->getId();
    }

    /**
     * Get the id
     *
     * @return integer
     */
    public function getId()
    {
        return $this->_badgeId;
    }

    /**
     * Get the name
     *
     * @return string
     */
    public function getName()
    {
        return $this->_daBadge->getName( $this->getId() );
    }

    /**
     * Set the name
     *
     * @param string $name
     * @return void
     */
    public function setName( $name )
    {
        $this->_daBadge->setName( $this->getId(), $name );
    }

    /**
     * Get the status
     *
     * @return string
     */
    public function getStatus()
    {
        return $this->_daBadge->getStatus( $this->getId() );
    }

    /**
     * Set the status
     *
     * @param string $status
     * @return void
     */
    public function setStatus( $status )
    {
        $this->_daBadge->setStatus( $this->getId(), $status );
    }

    /**
     * Get the color
     *
     * @return string
     */
    public function getColor()
    {
        return $this->_daBadge->getColor( $this->getId() );
    }

    /**
     * Set the color
     *
     * @param string $color
     * @return void
     */
    public function setColor( $color )
    {
        $this->_daBadge->setColor( $this->getId(), $color );
    }

    /**
     * Get the sort order
     *
     * @return string
     */
    public function getSortOrder()
    {
        return $this->_daBadge->getSortOrder( $this->getId() );
    }

    /**
     * Set the sort order
     *
     * @param string $sortOrder
     * @return void
     */
    public function setSortOrder( $sortOrder )
    {
        $this->_daBadge->setSortOrder( $this->getId(), $sortOrder );
    }

    /**
     * Get the primary image url
     *
     * @return string
     */
    public function getPrimaryImageUrl()
    {
        return $this->_daBadge->getPrimaryImageUrl( $this->getId() );
    }

    /**
     * Set the primary image url
     *
     * @param string $primaryImageUrl
     * @return void
     */
    public function setPrimaryImageUrl( $primaryImageUrl )
    {
        $this->_daBadge->setPrimaryImageUrl( $this->getId(), $primaryImageUrl );
    }

    /**
     * Get the secondary image url
     *
     * @return string
     */
    public function getSecondaryImageUrl()
    {
        return $this->_daBadge->getSecondaryImageUrl( $this->getId() );
    }

    /**
     * Set the secondary image url
     *
     * @param string $secondaryImageUrl
     * @return void
     */
    public function setSecondaryImageUrl( $secondaryImageUrl )
    {
        $this->_daBadge->setSecondaryImageUrl( $this->getId(), $secondaryImageUrl );
    }

    /**
     * Get the badge description
     *
     * @return string
     */
    public function getDescription()
    {
        return $this->_daBadge->getDescription( $this->getId() );
    }

    /**
     * Set the badge description
     *
     * @param string $description
     * @return void
     */
    public function setDescription( $description )
    {
        $this->_daBadge->setDescription( $this->getId(), $description );
    }

    /**
     * Get the offset x
     *
     * @return float
     */
    public function getOffsetX()
    {
        return (float) $this->_daBadge->getOffsetX( $this->getId() );
    }

    /**
     * Set the offset x
     *
     * @param float $offsetX
     * @return void
     */
    public function setOffsetX( $offsetX )
    {
        $this->_daBadge->setOffsetX( $this->getId(), $offsetX );
    }

    /**
     * Get the offset y
     *
     * @return float
     */
    public function getOffsetY()
    {
        return (float) $this->_daBadge->getOffsetY( $this->getId() );
    }

    /**
     * Set the offset Y
     *
     * @param float $offsetY
     * @return void
     */
    public function setOffsetY( $offsetY )
    {
        $this->_daBadge->setOffsetY( $this->getId(), $offsetY );
    }

    /**
     * Save the badge
     *
     * @return void
     */
    public function save()
    {
        $this->_daBadge->save();
    }

    /**
     * Delete the badge
     *
     * @return void
     */
    public function delete()
    {
        $this->_daBadge->deleteBadge( $this->getId() );
    }
}

?>
