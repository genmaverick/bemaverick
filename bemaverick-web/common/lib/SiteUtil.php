<?php

/**
 * Class utility for the site
 *
 */
class BeMaverick_SiteUtil
{

    /**
     * Get a list of recent response ids
     *
     * @param BeMaverick_Site $site
     * @param integer $count
     * @return integer[]
     */
    public static function getRecentResponseIds( $site, $count )
    {
        $filterBy = array(
            'responseStatus' => 'active',
            'hideFromStreams' => false,
        );

        $sortBy = array(
            'sort' => 'createdTimestamp',
            'sortOrder' => 'desc',
        );

        return $site->getResponseIds( $filterBy, $sortBy, $count );
    }

}

?>
