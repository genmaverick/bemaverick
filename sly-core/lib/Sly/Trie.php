<?php

/*!
    Trie data structure.

    Can be used for creating a small auto-suggest index.
*/
class Sly_Trie
{
    /*!
        Constructs a new Sly_trie object.

        @param [index] - optional - underlying trie datastructure. Used
                                   to load a trie from cache.
    */
    public function __construct($data = null) {
        
        if (!empty($data))
            $this->data = $data;
    }

    /*!
        Returns the trie datastructure so that it can be saved externally.
    */
    public function getData() {
        return($this->data);
    }

    /*!
        Returns the number of entries in the index. 
    */
    public function getNumEntries() {
        return(count(@$this->data['entities']));
    }
    
    /*!
        Add an entry to the trie. [value] must have a key named 'id' which
        is a unique key for this entry.

        @param [string] - string value key
        @param [value] - php data structure to save (hash)
    */
    public function add($string, $value) {

        $valueKey = $value['id'];

        if (!isset($this->data['entities'][$valueKey])) {
            $this->data['entities'][$valueKey] = $value;
        }

        $this->addInternal($string, $valueKey, $this->data);
    }

    private function addInternal($string, $value, &$node) {
        
        if (empty($string) && !empty($value)) {

            if ($this->debug)
                print "empty string\n";
            
            $node['values'][] = $value; 
            return;
        }

        if (count($node['prefixes'])) {
        
            foreach($node['prefixes'] as $prefix => &$childNode){
            
                $prefixLength = strlen($prefix);
                $head = substr($string, 0, $prefixLength);
                $headLength = strlen($head);

                $equals = true;
                $equalPrefix = "";
            
                for($i = 0; $i< $prefixLength; ++$i){

                    //Split
                    if ($i >= $headLength){

                        if ($this->debug)
                            print "i headlength $i $headLength $prefix\n";
                    
                        $newNode = array('prefixes' => array(substr($prefix,$i) => $node), 'values' => array($value));
                        $newNode['prefixes'][substr($prefix, $i)] = $childNode;                    
                        $node['prefixes'][$equalPrefix] = $newNode;

                        unset($node['prefixes'][$prefix]);
                        return;
                    
                    } else if ($prefix[$i] != $head[$i]){
                    
                        if ($i > 0) {

                            if ($this->debug)
                                print "prefix head $i > 0 ($prefix, $head, $equalPrefix)\n";
                    
                            $newNode = array('prefixes' => array(), 'values' => array());
                            $newNode['prefixes'][substr($prefix,$i)] = $childNode;
                            $newNode['prefixes'][substr($string,$i)] = array('prefixes' => array(), 'values' => array($value));
                            $node['prefixes'][$equalPrefix] = $newNode;

                            unset($node['prefixes'][$prefix]);

                            return;
                        }

                        if ($this->debug)
                            print "prefix head {$prefix[$i]}, {$head[$i]}\n";
                    
                        $equals = false;
                        break;
                    }

                    $equalPrefix .= $head[$i];
                }

                if ($equals) {

                    if ($this->debug) 
                        print "Equals - " . substr($string, $prefixLength) . "\n";
                
                    $this->addInternal(substr($string, $prefixLength), $value, $childNode);
                    return;
                }            
            }
        }
        
        if($this->debug)
            print "end insert ($string)\n";
                    
        $node['prefixes'][$string] = array('prefixes' => array(), 'values' => array($value));
    }

    /*!
        Search for an entry in the trie.

        @param [string] - string key
        @param [result] - array. results (values) are added to this structure.
    */
    public function search($string, &$result) {

        return($this->searchInternal($string, $result, $this->data));
    }

    private function searchInternal($string, &$result, $node = null) {
        
        if (empty($string)) {

            if (count($node['values'])) {

                /* Note that $value is an index into the entities array. */
                foreach ($node['values'] as $valueKey) {
                    $result[] = $this->data['entities'][$valueKey];
                }
            }

            // Find all matches and return them
            if (count($node['prefixes']) > 0) {
                foreach ($node['prefixes'] as $prefix => $childNode) {
                    $this->searchInternal('', $result, $childNode);
                }
            }
            
            return;
        }

        if (isset($node['prefixes']) && count($node['prefixes']) > 0) {
            
            foreach($node['prefixes'] as $prefix => $childNode){

                $prefixLength = strlen($prefix);
                $head = substr($string, 0, $prefixLength);

                if ($head == $prefix){

                    if ($this->debug)
                        print "head == prefix ($string, $prefix)\n";
                
                    $this->searchInternal(substr($string,$prefixLength), $result, $childNode);
                
                } else if (strpos($prefix, $head) === 0) {

                    // If it's a prefix, return me everything underneath
                    $this->searchInternal('', $result, $childNode);
                }
            }
        }

        return null;
    }

    protected $data = array('prefixes' => array(), 'values' => array(), 'entities' => array());
    protected $debug = false;
}

?>