# Haxe port of wcwidth()

Following is a [Haxe](https://haxe.org) port of an implementation of wcwidth() as provided by Markus Kuhn.
 
## What is this used for?

When you output characters in a so-called "monospace" font (e.g. in a Terminal)
some character instead of occupying 1 character actually occupy 2!
So trying to align this:
 
```
foo bar
-------
a   1  (3 spaces between a and 1)
b   2  (3 spaces)
百  3  (2 spaces occupied only in a terminal with fixed-size font, not on github website however)
```
 
In a terminal if you need alignment this can be a serious problem. 
wcwidth() comes to the rescue: 

* `wcwidth("x")` returns `1`,
* `wcwidth("白")` returns `2`. 

At least that's the basic idea. 
Read below to discover why it sometimes return `0` or even `-1`.

Follows a verbatim of original Stack Overflow question where found this (
https://stackoverflow.com/questions/3634627/how-to-know-the-preferred-display-width-in-columns-of-unicode-characters).

# How to know the preferred display width (in columns) of Unicode characters?

Sounds like you're looking for something like wcwidth and wcswidth, defined in IEEE Std 1003.1-2001, but removed from ISO C:

> The `wcwidth()` function shall determine the number of column positions required for the wide character wc. The `wcwidth()` function shall either return 0 (if wc is a null wide-character code), or return the number of column positions to be occupied by the wide-character code wc, or return -1 (if wc does not correspond to a printable wide-character code).

**Markus Kuhn** wrote an open source version, [wcwidth.c](http://www.cl.cam.ac.uk/~mgk25/ucs/wcwidth.c), based on Unicode 5.0. It includes a description of the problem, and an acknowledgement of the lack of standards in the area:

> In fixed-width output devices, Latin characters all occupy a single "cell" position of equal width, whereas ideographic CJK characters occupy two such cells. Interoperability between terminal-line applications and (teletype-style) character terminals using the UTF-8 encoding requires agreement on which character should advance the cursor by how many cell positions. No established formal standards exist at present on which Unicode character shall occupy how many cell positions on character terminals. These routines are a first attempt of defining such behavior based on simple rules applied to data provided by the Unicode Consortium. [...]

It implements the following rules:

* The null character (U+0000) has a column width of 0.
* Other C0/C1 control characters and DEL will lead to a return value of -1.
* Non-spacing and enclosing combining characters (general category code Mn or Me in the Unicode database) have a column width of 0.
* SOFT HYPHEN (U+00AD) has a column width of 1.
* Other format characters (general category code Cf in the Unicode database) and ZERO WIDTH SPACE (U+200B) have a column width of 0.
* Hangul Jamo medial vowels and final consonants (U+1160-U+11FF) have a column width of 0.
* Spacing characters in the East Asian Wide (W) or East Asian Full-width (F) category as defined in Unicode Technical Report #11 have a column width of 2.
* All remaining characters (including all printable ISO 8859-1 and WGL4 characters, Unicode control characters, etc.) have a column width of 1.

