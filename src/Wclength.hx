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

	/**
		Appends `c` to `s` until `s.length` is at least `l`.

		If `c` is the empty String `""` or if `l` does not exceed `s.length`,
		`s` is returned unchanged.

		If `c.length` is 1, the resulting String length is exactly `l`.

		Otherwise the length may exceed `l`.

		If `c` is null, the result is unspecified.
	**/
    public static function wcrpad(s:String, c:String, l:Int) : String {
		if (wclength(c) <= 0)
			return s;

		var buf = new StringBuf();
		buf.add(s);
		while (wclength(buf.toString()) < l) {
			buf.add(c);
		}
		return buf.toString();
    }    

	/**
		Concatenates `c` to `s` until `s.length` is at least `l`.

		If `c` is the empty String `""` or if `l` does not exceed `s.length`,
		`s` is returned unchanged.

		If `c.length` is 1, the resulting String length is exactly `l`.

		Otherwise the length may exceed `l`.

		If `c` is null, the result is unspecified.
	**/
	public static function wclpad(s:String, c:String, l:Int):String {
		if (wclength(c) <= 0)
			return s;

		var buf = new StringBuf();
		l -= wclength(s);
		while (wclength(buf.toString()) < l) {
			buf.add(c);
		}
		buf.add(s);
		return buf.toString();
	}
}
