import Wcwidth.wcwidth;

class Wclength {
    /**
     * Applying a count of wcwidth() for all characters in a String.
     */
    public static function wclength(s:String) : Int {
        var w = 0;
        for (i in 0...s.length) w += wcwidth(s.charCodeAt(i));
        return w;
    }    
}
