<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da/Tag.php' );

class BeMaverick_Tag
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
    protected $_tagId = null;

    /**
     * @var BeMaverick_Da_Tag
     * @access protected
     */
    protected $_daTag;

    /**
     * Class constructor
     *
     * @param BeMaverick_Site $site
     * @param integer $tagId
     * @return void
     */
    public function __construct( $site, $tagId )
    {
        $this->_site = $site;
        $this->_tagId = $tagId;
        $this->_daTag = BeMaverick_Da_Tag::getInstance();
    }

    /**
     * Retrieves the tag instance.
     *
     * @param BeMaverick_Site $site
     * @param integer $tagId
     * @return BeMaverick_Tag
     */
    public static function getInstance( $site, $tagId )
    {
        if ( ! $tagId ) {
            return null;
        }
        
        if ( ! isset( self::$_instance[$tagId] ) ) {

            $daTag = BeMaverick_Da_Tag::getInstance();

            // make sure tag exists
            if ( ! $daTag->isKeysExist( array( $tagId ) ) ) {
                self::$_instance[$tagId] = null;
            } else {
                self::$_instance[$tagId] = new self( $site, $tagId );
            }
        }

        return self::$_instance[$tagId];

    }

    /**
     * Create a tag
     *
     * @param BeMaverick_Site $site
     * @param string $type
     * @param string $name
     * @return BeMaverick_Tag
     */
    public static function createTag( $site, $type, $name )
    {
        $daTag = BeMaverick_Da_Tag::getInstance();

        $tagId = $daTag->createTag( $type, $name );
        
        // we might have already tried to get this tag for some reason, so update
        // the self instance here and return it
        self::$_instance[$tagId] = new self( $site, $tagId );
        
        return self::$_instance[$tagId];
    }

    /**
     * Get a tag by name
     *
     * @param BeMaverick_Site $site
     * @param string $name
     * @return BeMaverick_Tag
     */
    public static function getTagByName( $site, $name )
    {
        $daTag = BeMaverick_Da_Tag::getInstance();

        $tagId = $daTag->getTagIdByName( $name );

        return self::getInstance( $site, $tagId );
    }

    /**
     * Get a list of tags
     *
     * @param BeMaverick_Site $site
     * @param hash $filterBy
     * @param hash $sortBy
     * @param integer $count
     * @param integer $offset
     * @return BeMaverick_Tag[]
     */
    public static function getTags( $site, $filterBy = null, $sortBy = null, $count = null, $offset = 0 )
    {
        $daTag = BeMaverick_Da_Tag::getInstance();

        $tagIds = $daTag->getTagIds( $filterBy, $sortBy, $count, $offset );

        $tags = array();
        foreach ( $tagIds as $tagId ) {
            $tags[] = self::getInstance( $site, $tagId );
        }

        return $tags;
    }

    /**
     * Get a count of tags
     *
     * @param hash $filterBy
     * @return integer
     */
    public static function getTagCount( $filterBy = null )
    {
        $daTag = BeMaverick_Da_Tag::getInstance();

        return $daTag->getTagCount( $filterBy );
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
        return $this->_tagId;
    }

    /**
     * Get the type
     *
     * @return string
     */
    public function getType()
    {
        return $this->_daTag->getType( $this->getId() );
    }

    /**
     * Set the type
     *
     * @param string $type
     * @return void
     */
    public function setType( $type )
    {
        $this->_daTag->setType( $this->getId(), $type );
    }

    /**
     * Get the name
     *
     * @return string
     */
    public function getName()
    {
        return $this->_daTag->getName( $this->getId() );
    }

    /**
     * Set the name
     *
     * @param string $name
     * @return void
     */
    public function setName( $name )
    {
        $this->_daTag->setName( $this->getId(), $name );
    }

    /**
     * Save the tag
     *
     * @return void
     */
    public function save()
    {
        $this->_daTag->save();
    }

    /**
     * Delete the tag
     *
     * @return void
     */
    public function delete()
    {
        $this->_daTag->deleteTag( $this->getId() );
    }
}

?>
