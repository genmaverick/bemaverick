<?php

/*
 * Class provided to maintian a hash of strings as long as possible
 * while not breaking code that assumes it has a string via the __toString
 * magic method: http://www.php.net/manual/en/language.oop5.magic.php#language.oop5.magic.tostring.
 *
 * @description 
 */
class Sly_StringHash implements Countable {

    private $hash;

    /*
     * @param array  $hash An array of strings.
     *                     Must be a valid input to 'implode'
     * @param string $implodeGlue Defaults to an empty string
     */
    public function __construct(/* array */ $hash, $implodeGlue = "") {
        $this->setHash($hash);
        $this->implodeGlue = $implodeGlue;
    }

    public function getHash() {
        return $this->hash;
    }

    public function setHash(/* array */ $hash) {
        $this->hash = $hash;
    }

    public function keyExists($key) {
        return array_key_exists($key, $this->hash);
    }

    public function getKeyValue($key) {
        $value = null;
        if (array_key_exists($key, $this->hash)) {
            $value = $this->hash[$key];
        }
        return $value;
    }

    public function setKeyValue($key, $value) {
        $this->hash[$key] = $value;
    }


    /*
     * Adapter function to owned hash
     */
    public function count() {
        return count($this->hash);
    }
    
    public function __toString() {
        return implode($this->implodeGlue, $this->hash);
    }


    /*
     * More adapter functions, may be useful down the road
     */
    /*
    public function prepend ($var) {
        array_unshift($this->hash, $var);
    }

    public function addToEndOfHash ($var) {
        array_push($this->hash, $var);
    }
    */

}

?>
