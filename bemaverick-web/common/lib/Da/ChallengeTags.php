<?php

require_once( BEMAVERICK_COMMON_ROOT_DIR . '/lib/Da.php' );

class BeMaverick_Da_ChallengeTags extends BeMaverick_Da
{

    /**
     * @static
     * @var BeMaverick_Da_ChallengeTags
     * @access protected
     */    
    protected static $_instance = null;

    /**
     * @var string
     * @access protected
     */
    protected $_table = 'challenge_tags';

    /**
     * @var array
     * @access protected
     */
    protected $_primary = array( 'challenge_id', 'tag_id' );

    /**
     * @var array
     * @access protected
     */
    protected $_functions = array(
    );
    
    /**
     * Retrieves the da instance.
     *
     * @return BeMaverick_Da_ChallengeTags
     */
    public function getInstance()
    {
        if (null === self::$_instance) {
            self::$_instance = new self();
        }

        return self::$_instance;
    }

    /**
     * Constructor to set tags
     */
    public function __construct()
    {
        $this->_tags = array( $this->_database.'.'.$this->_table );
    }

    /**
     * Get a list of tags ids
     *
     * @param integer $challengeId
     * @return integer[]
     */
    public function getChallengeTagIds( $challengeId )
    {
        $select = array( 'tag_id' );

        $where = array();
        $where[] = "challenge_id = $challengeId";

        $sql = $this->createSqlStatement( $select, $where );

        return $this->fetchColumns( $sql, $this->_tags );
    }

    /**
     * Add a new tag
     *
     * @param integer $challengeId
     * @param integer $tagId
     * @return void
     */
    public function addChallengeTag( $challengeId, $tagId )
    {
        $data = array(
            'challenge_id' => $challengeId,
            'tag_id' => $tagId,
        );

        $this->insert( $data, $this->_tags );
    }

    /**
     * Delete the challenge
     *
     * @param integer $challengeId
     * @return void
     */
    public function deleteChallenge( $challengeId )
    {
        $this->delete( "challenge_id = $challengeId", $this->_tags );
    }

}

?>
