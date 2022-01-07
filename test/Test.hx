package test;

import wcwidth.Wcwidth.wcwidth;

class Test {
    public static function assertEquals<T>(a:T, b:T) : Void {
        if (a != b) throw "assertEquals failed: " 
            + Std.string(a) + " differs from " + Std.string(b);
    }

    // garbage stuff
    public static function utf8ToEcs2(s:String) : String {
#if (!target.unicode)
    #if sys
         // TODO check if we are on linux or iconv (or uconv) exists
         var pr = new sys.io.Process("iconv", ["-f", "UTF-8", "-t", "ECS-2"]);
         pr.stdin.writeString(s, RawNative);
         pr.stdin.close();
         while ( null == pr.exitCode(true) ) Sys.sleep(0.0015);
         var s = pr.stdout.readLine();
         pr.close();
         return s;
    #else
         #error "Target is not unicode ready yet, and we won't be able to use iconv because it's a non-sys platform"
    #end
#else
         return s;
#end
    }

    public static function main() {
        trace("DONE");
        assertEquals("你".code, 0x4f60);
        assertEquals("你".charCodeAt(0), 0x4f60);
        assertEquals(wcwidth("你".code), 2);
        assertEquals(wcwidth("x".code), 1);
    }
}
