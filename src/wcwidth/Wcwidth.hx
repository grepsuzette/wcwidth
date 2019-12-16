package wcwidth;

/**
 * Haxe port of an implementation of wcwidth() as provided by Markus Kuhn.
 *
 * Why is this used for?
 * When you output characters in a Monospace font (e.g. in a Terminal)
 * some character instead of occupying 1 character actually occupy 2!
 * So trying to align this:
 * 
 * foo bar
 * -------
 * a   1  (3 spaces between a and 1)
 * b   2  (3 spaces)
 * 百  3  (2 spaces only)
 *
 * In a terminal if you need alignment this can be a serious problem. 
 * So wcwidth() to the rescue! Here's how:
 *
 * wcwidth("x") returns 1.
 * wcwidth("白") returns 2. That's it pretty much.
 *
 * Follows original header by Markus Kuhn: {{{2
 * This is an implementation of wcwidth() and wcswidth() (defined in
 * IEEE Std 1002.1-2001) for Unicode.
 *
 * http://www.opengroup.org/onlinepubs/007904975/functions/wcwidth.html
 * http://www.opengroup.org/onlinepubs/007904975/functions/wcswidth.html
 *
 * In fixed-width output devices, Latin characters all occupy a single
 * "cell" position of equal width, whereas ideographic CJK characters
 * occupy two such cells. Interoperability between terminal-line
 * applications and (teletype-style) character terminals using the
 * UTF-8 encoding requires agreement on which character should advance
 * the cursor by how many cell positions. No established formal
 * standards exist at present on which Unicode character shall occupy
 * how many cell positions on character terminals. These routines are
 * a first attempt of defining such behavior based on simple rules
 * applied to data provided by the Unicode Consortium.
 *
 * For some graphical characters, the Unicode standard explicitly
 * defines a character-cell width via the definition of the East Asian
 * FullWidth (F), Wide (W), Half-width (H), and Narrow (Na) classes.
 * In all these cases, there is no ambiguity about which width a
 * terminal shall use. For characters in the East Asian Ambiguous (A)
 * class, the width choice depends purely on a preference of backward
 * compatibility with either historic CJK or Western practice.
 * Choosing single-width for these characters is easy to justify as
 * the appropriate long-term solution, as the CJK practice of
 * displaying these characters as double-width comes from historic
 * implementation simplicity (8-bit encoded characters were displayed
 * single-width and 16-bit ones double-width, even for Greek,
 * Cyrillic, etc.) and not any typographic considerations.
 *
 * Much less clear is the choice of width for the Not East Asian
 * (Neutral) class. Existing practice does not dictate a width for any
 * of these characters. It would nevertheless make sense
 * typographically to allocate two character cells to characters such
 * as for instance EM SPACE or VOLUME INTEGRAL, which cannot be
 * represented adequately with a single-width glyph. The following
 * routines at present merely assign a single-cell width to all
 * neutral characters, in the interest of simplicity. This is not
 * entirely satisfactory and should be reconsidered before
 * establishing a formal standard in this area. At the moment, the
 * decision which Not East Asian (Neutral) characters should be
 * represented by double-width glyphs cannot yet be answered by
 * applying a simple rule from the Unicode database content. Setting
 * up a proper standard for the behavior of UTF-8 character terminals
 * will require a careful analysis not only of each Unicode character,
 * but also of each presentation form, something the author of these
 * routines has avoided to do so far.
 *
 * http://www.unicode.org/unicode/reports/tr11/
 *
 * Markus Kuhn -- 2007-05-26 (Unicode 5.0)
 *
 * Permission to use, copy, modify, and distribute this software
 * for any purpose and without fee is hereby granted. The author
 * disclaims all warranties with regard to this software.
 *
 * Latest version: http://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c }}}2
 */


typedef Interval = {
    var first:Int;
    var last :Int;
}

class Wcwidth {

    /**
     * Character space theorically occupied by the character with ISO 10646 in
     * a terminal.
     * @param (Int ucs) as given by e.g. `s.charCodeAt(14)`
     * @return (Int) Either -1, 0 or a positive value. See below.
     * 
     * The following function define the column width of an ISO 10646
     * (represented as Int as provided by Haxe 4.0 with e.g. charCodeAt())
     * character as follows:
     *
     * - The null character (U+0000) has a column width of 0.
     * - Other C0/C1 control characters and DEL will lead to a return
     *   value of -1.
     * - Non-spacing and enclosing combining characters (general
     *   category code Mn or Me in the Unicode database) have a
     *   column width of 0.
     * - SOFT HYPHEN (U+00AD) has a column width of 1.
     * - Other format characters (general category code Cf in the Unicode
     *   database) and ZERO WIDTH SPACE (U+200B) have a column width of 0.
     * - Hangul Jamo medial vowels and final consonants (U+1160-U+11FF)
     *   have a column width of 0.
     * - Spacing characters in the East Asian Wide (W) or East Asian
     *   Full-width (F) category as defined in Unicode Technical
     *   Report #11 have a column width of 2.
     * - All remaining characters (including all printable
     *   ISO 8859-1 and WGL4 characters, Unicode control characters,
     *   etc.) have a column width of 1.
     *
     * This implementation assumes that Int characters are encoded
     * in ISO 10646.
     */
    public static function wcwidth(ucs:Int) : Int {
      if (ucs == 0) return 0;
      if (ucs < 32 || (ucs >= 0x7f && ucs < 0xa0)) return -1;

      // binary search in table of non-spacing characters
      if (_bisearch(ucs, combining, combining.length)) return 0;

      // if we arrive here, ucs is not a combining or C0/C1 control character
      return 1 + 
        (ucs >= 0x1100 &&
         (ucs <= 0x115f ||                    /* Hangul Jamo init. consonants */
          ucs == 0x2329 || ucs == 0x232a ||
          (ucs >= 0x2e80 && ucs <= 0xa4cf &&
           ucs != 0x303f) ||                  /* CJK ... Yi */
          (ucs >= 0xac00 && ucs <= 0xd7a3) || /* Hangul Syllables */
          (ucs >= 0xf900 && ucs <= 0xfaff) || /* CJK Compatibility Ideographs */
          (ucs >= 0xfe10 && ucs <= 0xfe19) || /* Vertical forms */
          (ucs >= 0xfe30 && ucs <= 0xfe6f) || /* CJK Compatibility Forms */
          (ucs >= 0xff00 && ucs <= 0xff60) || /* Fullwidth Forms */
          (ucs >= 0xffe0 && ucs <= 0xffe6) ||
          (ucs >= 0x20000 && ucs <= 0x2fffd) ||
          (ucs >= 0x30000 && ucs <= 0x3fffd))
        );
    }

    /**
     * Applying a count of wcwidth() for all characters in a String.
     */
    public static function wclength(s:String) : Int {
        var w = 0;
        for (i in 0...s.length) w += wcwidth(s.charCodeAt(i));
        return w;
    }    
    
    /** 
     * sorted list of non-overlapping intervals of non-spacing characters 
     * generated by "uniset +cat=Me +cat=Mn +cat=Cf -00AD +1160-11FF +200B c" 
     **/
    private static var combining : Array<Interval> = [
        { first: 0x0300, last: 0x036F },  { first: 0x0483, last: 0x0486 }, { first: 0x0488, last: 0x0489 },
        { first: 0x0591, last: 0x05BD },  { first: 0x05BF, last: 0x05BF }, { first: 0x05C1, last: 0x05C2 },
        { first: 0x05C4, last: 0x05C5 },  { first: 0x05C7, last: 0x05C7 }, { first: 0x0600, last: 0x0603 },
        { first: 0x0610, last: 0x0615 },  { first: 0x064B, last: 0x065E }, { first: 0x0670, last: 0x0670 },
        { first: 0x06D6, last: 0x06E4 },  { first: 0x06E7, last: 0x06E8 }, { first: 0x06EA, last: 0x06ED },
        { first: 0x070F, last: 0x070F },  { first: 0x0711, last: 0x0711 }, { first: 0x0730, last: 0x074A },
        { first: 0x07A6, last: 0x07B0 },  { first: 0x07EB, last: 0x07F3 }, { first: 0x0901, last: 0x0902 },
        { first: 0x093C, last: 0x093C },  { first: 0x0941, last: 0x0948 }, { first: 0x094D, last: 0x094D },
        { first: 0x0951, last: 0x0954 },  { first: 0x0962, last: 0x0963 }, { first: 0x0981, last: 0x0981 },
        { first: 0x09BC, last: 0x09BC },  { first: 0x09C1, last: 0x09C4 }, { first: 0x09CD, last: 0x09CD },
        { first: 0x09E2, last: 0x09E3 },  { first: 0x0A01, last: 0x0A02 }, { first: 0x0A3C, last: 0x0A3C },
        { first: 0x0A41, last: 0x0A42 },  { first: 0x0A47, last: 0x0A48 }, { first: 0x0A4B, last: 0x0A4D },
        { first: 0x0A70, last: 0x0A71 },  { first: 0x0A81, last: 0x0A82 }, { first: 0x0ABC, last: 0x0ABC },
        { first: 0x0AC1, last: 0x0AC5 },  { first: 0x0AC7, last: 0x0AC8 }, { first: 0x0ACD, last: 0x0ACD },
        { first: 0x0AE2, last: 0x0AE3 },  { first: 0x0B01, last: 0x0B01 }, { first: 0x0B3C, last: 0x0B3C },
        { first: 0x0B3F, last: 0x0B3F },  { first: 0x0B41, last: 0x0B43 }, { first: 0x0B4D, last: 0x0B4D },
        { first: 0x0B56, last: 0x0B56 },  { first: 0x0B82, last: 0x0B82 }, { first: 0x0BC0, last: 0x0BC0 },
        { first: 0x0BCD, last: 0x0BCD },  { first: 0x0C3E, last: 0x0C40 }, { first: 0x0C46, last: 0x0C48 },
        { first: 0x0C4A, last: 0x0C4D },  { first: 0x0C55, last: 0x0C56 }, { first: 0x0CBC, last: 0x0CBC },
        { first: 0x0CBF, last: 0x0CBF },  { first: 0x0CC6, last: 0x0CC6 }, { first: 0x0CCC, last: 0x0CCD },
        { first: 0x0CE2, last: 0x0CE3 },  { first: 0x0D41, last: 0x0D43 }, { first: 0x0D4D, last: 0x0D4D },
        { first: 0x0DCA, last: 0x0DCA },  { first: 0x0DD2, last: 0x0DD4 }, { first: 0x0DD6, last: 0x0DD6 },
        { first: 0x0E31, last: 0x0E31 },  { first: 0x0E34, last: 0x0E3A }, { first: 0x0E47, last: 0x0E4E },
        { first: 0x0EB1, last: 0x0EB1 },  { first: 0x0EB4, last: 0x0EB9 }, { first: 0x0EBB, last: 0x0EBC },
        { first: 0x0EC8, last: 0x0ECD },  { first: 0x0F18, last: 0x0F19 }, { first: 0x0F35, last: 0x0F35 },
        { first: 0x0F37, last: 0x0F37 },  { first: 0x0F39, last: 0x0F39 }, { first: 0x0F71, last: 0x0F7E },
        { first: 0x0F80, last: 0x0F84 },  { first: 0x0F86, last: 0x0F87 }, { first: 0x0F90, last: 0x0F97 },
        { first: 0x0F99, last: 0x0FBC },  { first: 0x0FC6, last: 0x0FC6 }, { first: 0x102D, last: 0x1030 },
        { first: 0x1032, last: 0x1032 },  { first: 0x1036, last: 0x1037 }, { first: 0x1039, last: 0x1039 },
        { first: 0x1058, last: 0x1059 },  { first: 0x1160, last: 0x11FF }, { first: 0x135F, last: 0x135F },
        { first: 0x1712, last: 0x1714 },  { first: 0x1732, last: 0x1734 }, { first: 0x1752, last: 0x1753 },
        { first: 0x1772, last: 0x1773 },  { first: 0x17B4, last: 0x17B5 }, { first: 0x17B7, last: 0x17BD },
        { first: 0x17C6, last: 0x17C6 },  { first: 0x17C9, last: 0x17D3 }, { first: 0x17DD, last: 0x17DD },
        { first: 0x180B, last: 0x180D },  { first: 0x18A9, last: 0x18A9 }, { first: 0x1920, last: 0x1922 },
        { first: 0x1927, last: 0x1928 },  { first: 0x1932, last: 0x1932 }, { first: 0x1939, last: 0x193B },
        { first: 0x1A17, last: 0x1A18 },  { first: 0x1B00, last: 0x1B03 }, { first: 0x1B34, last: 0x1B34 },
        { first: 0x1B36, last: 0x1B3A },  { first: 0x1B3C, last: 0x1B3C }, { first: 0x1B42, last: 0x1B42 },
        { first: 0x1B6B, last: 0x1B73 },  { first: 0x1DC0, last: 0x1DCA }, { first: 0x1DFE, last: 0x1DFF },
        { first: 0x200B, last: 0x200F },  { first: 0x202A, last: 0x202E }, { first: 0x2060, last: 0x2063 },
        { first: 0x206A, last: 0x206F },  { first: 0x20D0, last: 0x20EF }, { first: 0x302A, last: 0x302F },
        { first: 0x3099, last: 0x309A },  { first: 0xA806, last: 0xA806 }, { first: 0xA80B, last: 0xA80B },
        { first: 0xA825, last: 0xA826 },  { first: 0xFB1E, last: 0xFB1E }, { first: 0xFE00, last: 0xFE0F },
        { first: 0xFE20, last: 0xFE23 },  { first: 0xFEFF, last: 0xFEFF }, { first: 0xFFF9, last: 0xFFFB },
        // note: these probably will be useless in UCS-2
        { first: 0x10A01,last: 0x10A03 }, { first: 0x10A05,last: 0x10A06 }, { first: 0x10A0C, last: 0x10A0F },
        { first: 0x10A38,last: 0x10A3A }, { first: 0x10A3F,last: 0x10A3F }, { first: 0x1D167, last: 0x1D169 },
        { first: 0x1D173,last: 0x1D182 }, { first: 0x1D185,last: 0x1D18B }, { first: 0x1D1AA, last: 0x1D1AD },
        { first: 0x1D242,last: 0x1D244 }, { first: 0xE0001,last: 0xE0001 }, { first: 0xE0020, last: 0xE007F },
        { first: 0xE0100,last: 0xE01EF }
    ];

    /** 
     * sorted list of non-overlapping intervals of East Asian Ambiguous
     * characters, generated by "uniset +WIDTH-A -cat=Me -cat=Mn -cat=Cf c" 
     **/
    private static var ambiguous: Array<Interval> = [
        { first: 0x00A1, last: 0x00A1 }, { first: 0x00A4,  last: 0x00A4 }, { first: 0x00A7, last: 0x00A8 },
        { first: 0x00AA, last: 0x00AA }, { first: 0x00AE,  last: 0x00AE }, { first: 0x00B0, last: 0x00B4 },
        { first: 0x00B6, last: 0x00BA }, { first: 0x00BC,  last: 0x00BF }, { first: 0x00C6, last: 0x00C6 },
        { first: 0x00D0, last: 0x00D0 }, { first: 0x00D7,  last: 0x00D8 }, { first: 0x00DE, last: 0x00E1 },
        { first: 0x00E6, last: 0x00E6 }, { first: 0x00E8,  last: 0x00EA }, { first: 0x00EC, last: 0x00ED },
        { first: 0x00F0, last: 0x00F0 }, { first: 0x00F2,  last: 0x00F3 }, { first: 0x00F7, last: 0x00FA },
        { first: 0x00FC, last: 0x00FC }, { first: 0x00FE,  last: 0x00FE }, { first: 0x0101, last: 0x0101 },
        { first: 0x0111, last: 0x0111 }, { first: 0x0113,  last: 0x0113 }, { first: 0x011B, last: 0x011B },
        { first: 0x0126, last: 0x0127 }, { first: 0x012B,  last: 0x012B }, { first: 0x0131, last: 0x0133 },
        { first: 0x0138, last: 0x0138 }, { first: 0x013F,  last: 0x0142 }, { first: 0x0144, last: 0x0144 },
        { first: 0x0148, last: 0x014B }, { first: 0x014D,  last: 0x014D }, { first: 0x0152, last: 0x0153 },
        { first: 0x0166, last: 0x0167 }, { first: 0x016B,  last: 0x016B }, { first: 0x01CE, last: 0x01CE },
        { first: 0x01D0, last: 0x01D0 }, { first: 0x01D2,  last: 0x01D2 }, { first: 0x01D4, last: 0x01D4 },
        { first: 0x01D6, last: 0x01D6 }, { first: 0x01D8,  last: 0x01D8 }, { first: 0x01DA, last: 0x01DA },
        { first: 0x01DC, last: 0x01DC }, { first: 0x0251,  last: 0x0251 }, { first: 0x0261, last: 0x0261 },
        { first: 0x02C4, last: 0x02C4 }, { first: 0x02C7,  last: 0x02C7 }, { first: 0x02C9, last: 0x02CB },
        { first: 0x02CD, last: 0x02CD }, { first: 0x02D0,  last: 0x02D0 }, { first: 0x02D8, last: 0x02DB },
        { first: 0x02DD, last: 0x02DD }, { first: 0x02DF,  last: 0x02DF }, { first: 0x0391, last: 0x03A1 },
        { first: 0x03A3, last: 0x03A9 }, { first: 0x03B1,  last: 0x03C1 }, { first: 0x03C3, last: 0x03C9 },
        { first: 0x0401, last: 0x0401 }, { first: 0x0410,  last: 0x044F }, { first: 0x0451, last: 0x0451 },
        { first: 0x2010, last: 0x2010 }, { first: 0x2013,  last: 0x2016 }, { first: 0x2018, last: 0x2019 },
        { first: 0x201C, last: 0x201D }, { first: 0x2020,  last: 0x2022 }, { first: 0x2024, last: 0x2027 },
        { first: 0x2030, last: 0x2030 }, { first: 0x2032,  last: 0x2033 }, { first: 0x2035, last: 0x2035 },
        { first: 0x203B, last: 0x203B }, { first: 0x203E,  last: 0x203E }, { first: 0x2074, last: 0x2074 },
        { first: 0x207F, last: 0x207F }, { first: 0x2081,  last: 0x2084 }, { first: 0x20AC, last: 0x20AC },
        { first: 0x2103, last: 0x2103 }, { first: 0x2105,  last: 0x2105 }, { first: 0x2109, last: 0x2109 },
        { first: 0x2113, last: 0x2113 }, { first: 0x2116,  last: 0x2116 }, { first: 0x2121, last: 0x2122 },
        { first: 0x2126, last: 0x2126 }, { first: 0x212B,  last: 0x212B }, { first: 0x2153, last: 0x2154 },
        { first: 0x215B, last: 0x215E }, { first: 0x2160,  last: 0x216B }, { first: 0x2170, last: 0x2179 },
        { first: 0x2190, last: 0x2199 }, { first: 0x21B8,  last: 0x21B9 }, { first: 0x21D2, last: 0x21D2 },
        { first: 0x21D4, last: 0x21D4 }, { first: 0x21E7,  last: 0x21E7 }, { first: 0x2200, last: 0x2200 },
        { first: 0x2202, last: 0x2203 }, { first: 0x2207,  last: 0x2208 }, { first: 0x220B, last: 0x220B },
        { first: 0x220F, last: 0x220F }, { first: 0x2211,  last: 0x2211 }, { first: 0x2215, last: 0x2215 },
        { first: 0x221A, last: 0x221A }, { first: 0x221D,  last: 0x2220 }, { first: 0x2223, last: 0x2223 },
        { first: 0x2225, last: 0x2225 }, { first: 0x2227,  last: 0x222C }, { first: 0x222E, last: 0x222E },
        { first: 0x2234, last: 0x2237 }, { first: 0x223C,  last: 0x223D }, { first: 0x2248, last: 0x2248 },
        { first: 0x224C, last: 0x224C }, { first: 0x2252,  last: 0x2252 }, { first: 0x2260, last: 0x2261 },
        { first: 0x2264, last: 0x2267 }, { first: 0x226A,  last: 0x226B }, { first: 0x226E, last: 0x226F },
        { first: 0x2282, last: 0x2283 }, { first: 0x2286,  last: 0x2287 }, { first: 0x2295, last: 0x2295 },
        { first: 0x2299, last: 0x2299 }, { first: 0x22A5,  last: 0x22A5 }, { first: 0x22BF, last: 0x22BF },
        { first: 0x2312, last: 0x2312 }, { first: 0x2460,  last: 0x24E9 }, { first: 0x24EB, last: 0x254B },
        { first: 0x2550, last: 0x2573 }, { first: 0x2580,  last: 0x258F }, { first: 0x2592, last: 0x2595 },
        { first: 0x25A0, last: 0x25A1 }, { first: 0x25A3,  last: 0x25A9 }, { first: 0x25B2, last: 0x25B3 },
        { first: 0x25B6, last: 0x25B7 }, { first: 0x25BC,  last: 0x25BD }, { first: 0x25C0, last: 0x25C1 },
        { first: 0x25C6, last: 0x25C8 }, { first: 0x25CB,  last: 0x25CB }, { first: 0x25CE, last: 0x25D1 },
        { first: 0x25E2, last: 0x25E5 }, { first: 0x25EF,  last: 0x25EF }, { first: 0x2605, last: 0x2606 },
        { first: 0x2609, last: 0x2609 }, { first: 0x260E,  last: 0x260F }, { first: 0x2614, last: 0x2615 },
        { first: 0x261C, last: 0x261C }, { first: 0x261E,  last: 0x261E }, { first: 0x2640, last: 0x2640 },
        { first: 0x2642, last: 0x2642 }, { first: 0x2660,  last: 0x2661 }, { first: 0x2663, last: 0x2665 },
        { first: 0x2667, last: 0x266A }, { first: 0x266C,  last: 0x266D }, { first: 0x266F, last: 0x266F },
        { first: 0x273D, last: 0x273D }, { first: 0x2776,  last: 0x277F }, { first: 0xE000, last: 0xF8FF },
        { first: 0xFFFD, last: 0xFFFD }, { first: 0xF0000, last: 0xFFFFD },{ first: 0x100000, last: 0x10FFFD }
    ];

    /* auxiliary function for binary search in interval table */
    private static function _bisearch(ucs:Int, table:Array<Interval>, max:Int) : Int {
        var min = 0;
        var mid : Int;
        if (ucs < table[0].first || ucs > table[max].last) return 0;
        while (max >= min) {
            mid = Std.int( (min + max) / 2 );
            if (ucs > table[mid].last) min = mid + 1;
            else if (ucs < table[mid].first) max = mid - 1;
            else return 1;
        }
        return 0;
    }


}
// vim: fdm=marker
