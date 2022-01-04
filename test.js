(function ($global) { "use strict";
function $extend(from, fields) {
	var proto = Object.create(from);
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) {
		return undefined;
	}
	return x;
};
HxOverrides.now = function() {
	return Date.now();
};
Math.__name__ = true;
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
var haxe_Exception = function(message,previous,native) {
	Error.call(this,message);
	this.message = message;
	this.__previousException = previous;
	this.__nativeException = native != null ? native : this;
};
haxe_Exception.__name__ = true;
haxe_Exception.thrown = function(value) {
	if(((value) instanceof haxe_Exception)) {
		return value.get_native();
	} else if(((value) instanceof Error)) {
		return value;
	} else {
		var e = new haxe_ValueException(value);
		return e;
	}
};
haxe_Exception.__super__ = Error;
haxe_Exception.prototype = $extend(Error.prototype,{
	get_native: function() {
		return this.__nativeException;
	}
});
var haxe_ValueException = function(value,previous,native) {
	haxe_Exception.call(this,String(value),previous,native);
	this.value = value;
};
haxe_ValueException.__name__ = true;
haxe_ValueException.__super__ = haxe_Exception;
haxe_ValueException.prototype = $extend(haxe_Exception.prototype,{
});
var haxe_iterators_ArrayIterator = function(array) {
	this.current = 0;
	this.array = array;
};
haxe_iterators_ArrayIterator.__name__ = true;
haxe_iterators_ArrayIterator.prototype = {
	hasNext: function() {
		return this.current < this.array.length;
	}
	,next: function() {
		return this.array[this.current++];
	}
};
var js_Boot = function() { };
js_Boot.__name__ = true;
js_Boot.__string_rec = function(o,s) {
	if(o == null) {
		return "null";
	}
	if(s.length >= 5) {
		return "<...>";
	}
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) {
		t = "object";
	}
	switch(t) {
	case "function":
		return "<function>";
	case "object":
		if(((o) instanceof Array)) {
			var str = "[";
			s += "\t";
			var _g = 0;
			var _g1 = o.length;
			while(_g < _g1) {
				var i = _g++;
				str += (i > 0 ? "," : "") + js_Boot.__string_rec(o[i],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( _g ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") {
				return s2;
			}
		}
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		var k = null;
		for( k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) {
			str += ", \n";
		}
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "string":
		return o;
	default:
		return String(o);
	}
};
var test_Test = function() { };
test_Test.__name__ = true;
test_Test.assertEquals = function(a,b) {
	if(a != b) {
		throw haxe_Exception.thrown("assertEquals failed: " + Std.string(a) + " differs from " + Std.string(b));
	}
};
test_Test.utf8ToEcs2 = function(s) {
	return s;
};
test_Test.main = function() {
	console.log("test/Test.hx:31:","DONE");
	test_Test.assertEquals(20320,20320);
	test_Test.assertEquals(HxOverrides.cca("你",0),20320);
};
var wcwidth_Wcwidth = function() { };
wcwidth_Wcwidth.__name__ = true;
wcwidth_Wcwidth.wcwidth = function(ucs) {
	if(ucs == 0) {
		return 0;
	}
	if(ucs < 32 || ucs >= 127 && ucs < 160) {
		return -1;
	}
	if(wcwidth_Wcwidth._bisearch(ucs,wcwidth_Wcwidth.combining,wcwidth_Wcwidth.combining.length)) {
		return 0;
	}
	return 1 + (ucs >= 4352 && (ucs <= 4447 || ucs == 9001 || ucs == 9002 || ucs >= 11904 && ucs <= 42191 && ucs != 12351 || ucs >= 44032 && ucs <= 55203 || ucs >= 63744 && ucs <= 64255 || ucs >= 65040 && ucs <= 65049 || ucs >= 65072 && ucs <= 65135 || ucs >= 65280 && ucs <= 65376 || ucs >= 65504 && ucs <= 65510 || ucs >= 131072 && ucs <= 196605 || ucs >= 196608 && ucs <= 262141) ? 1 : 0);
};
wcwidth_Wcwidth.wclength = function(s) {
	var w = 0;
	var _g = 0;
	var _g1 = s.length;
	while(_g < _g1) {
		var i = _g++;
		w += wcwidth_Wcwidth.wcwidth(HxOverrides.cca(s,i));
	}
	return w;
};
wcwidth_Wcwidth._bisearch = function(ucs,table,max) {
	var min = 0;
	var mid;
	if(ucs < table[0].first || ucs > table[max].last) {
		return false;
	}
	while(max >= min) {
		mid = (min + max) / 2 | 0;
		if(ucs > table[mid].last) {
			min = mid + 1;
		} else if(ucs < table[mid].first) {
			max = mid - 1;
		} else {
			return true;
		}
	}
	return false;
};
if(typeof(performance) != "undefined" ? typeof(performance.now) == "function" : false) {
	HxOverrides.now = performance.now.bind(performance);
}
String.__name__ = true;
Array.__name__ = true;
js_Boot.__toStr = ({ }).toString;
wcwidth_Wcwidth.combining = [{ first : 768, last : 879},{ first : 1155, last : 1158},{ first : 1160, last : 1161},{ first : 1425, last : 1469},{ first : 1471, last : 1471},{ first : 1473, last : 1474},{ first : 1476, last : 1477},{ first : 1479, last : 1479},{ first : 1536, last : 1539},{ first : 1552, last : 1557},{ first : 1611, last : 1630},{ first : 1648, last : 1648},{ first : 1750, last : 1764},{ first : 1767, last : 1768},{ first : 1770, last : 1773},{ first : 1807, last : 1807},{ first : 1809, last : 1809},{ first : 1840, last : 1866},{ first : 1958, last : 1968},{ first : 2027, last : 2035},{ first : 2305, last : 2306},{ first : 2364, last : 2364},{ first : 2369, last : 2376},{ first : 2381, last : 2381},{ first : 2385, last : 2388},{ first : 2402, last : 2403},{ first : 2433, last : 2433},{ first : 2492, last : 2492},{ first : 2497, last : 2500},{ first : 2509, last : 2509},{ first : 2530, last : 2531},{ first : 2561, last : 2562},{ first : 2620, last : 2620},{ first : 2625, last : 2626},{ first : 2631, last : 2632},{ first : 2635, last : 2637},{ first : 2672, last : 2673},{ first : 2689, last : 2690},{ first : 2748, last : 2748},{ first : 2753, last : 2757},{ first : 2759, last : 2760},{ first : 2765, last : 2765},{ first : 2786, last : 2787},{ first : 2817, last : 2817},{ first : 2876, last : 2876},{ first : 2879, last : 2879},{ first : 2881, last : 2883},{ first : 2893, last : 2893},{ first : 2902, last : 2902},{ first : 2946, last : 2946},{ first : 3008, last : 3008},{ first : 3021, last : 3021},{ first : 3134, last : 3136},{ first : 3142, last : 3144},{ first : 3146, last : 3149},{ first : 3157, last : 3158},{ first : 3260, last : 3260},{ first : 3263, last : 3263},{ first : 3270, last : 3270},{ first : 3276, last : 3277},{ first : 3298, last : 3299},{ first : 3393, last : 3395},{ first : 3405, last : 3405},{ first : 3530, last : 3530},{ first : 3538, last : 3540},{ first : 3542, last : 3542},{ first : 3633, last : 3633},{ first : 3636, last : 3642},{ first : 3655, last : 3662},{ first : 3761, last : 3761},{ first : 3764, last : 3769},{ first : 3771, last : 3772},{ first : 3784, last : 3789},{ first : 3864, last : 3865},{ first : 3893, last : 3893},{ first : 3895, last : 3895},{ first : 3897, last : 3897},{ first : 3953, last : 3966},{ first : 3968, last : 3972},{ first : 3974, last : 3975},{ first : 3984, last : 3991},{ first : 3993, last : 4028},{ first : 4038, last : 4038},{ first : 4141, last : 4144},{ first : 4146, last : 4146},{ first : 4150, last : 4151},{ first : 4153, last : 4153},{ first : 4184, last : 4185},{ first : 4448, last : 4607},{ first : 4959, last : 4959},{ first : 5906, last : 5908},{ first : 5938, last : 5940},{ first : 5970, last : 5971},{ first : 6002, last : 6003},{ first : 6068, last : 6069},{ first : 6071, last : 6077},{ first : 6086, last : 6086},{ first : 6089, last : 6099},{ first : 6109, last : 6109},{ first : 6155, last : 6157},{ first : 6313, last : 6313},{ first : 6432, last : 6434},{ first : 6439, last : 6440},{ first : 6450, last : 6450},{ first : 6457, last : 6459},{ first : 6679, last : 6680},{ first : 6912, last : 6915},{ first : 6964, last : 6964},{ first : 6966, last : 6970},{ first : 6972, last : 6972},{ first : 6978, last : 6978},{ first : 7019, last : 7027},{ first : 7616, last : 7626},{ first : 7678, last : 7679},{ first : 8203, last : 8207},{ first : 8234, last : 8238},{ first : 8288, last : 8291},{ first : 8298, last : 8303},{ first : 8400, last : 8431},{ first : 12330, last : 12335},{ first : 12441, last : 12442},{ first : 43014, last : 43014},{ first : 43019, last : 43019},{ first : 43045, last : 43046},{ first : 64286, last : 64286},{ first : 65024, last : 65039},{ first : 65056, last : 65059},{ first : 65279, last : 65279},{ first : 65529, last : 65531},{ first : 68097, last : 68099},{ first : 68101, last : 68102},{ first : 68108, last : 68111},{ first : 68152, last : 68154},{ first : 68159, last : 68159},{ first : 119143, last : 119145},{ first : 119155, last : 119170},{ first : 119173, last : 119179},{ first : 119210, last : 119213},{ first : 119362, last : 119364},{ first : 917505, last : 917505},{ first : 917536, last : 917631},{ first : 917760, last : 917999}];
wcwidth_Wcwidth.ambiguous = [{ first : 161, last : 161},{ first : 164, last : 164},{ first : 167, last : 168},{ first : 170, last : 170},{ first : 174, last : 174},{ first : 176, last : 180},{ first : 182, last : 186},{ first : 188, last : 191},{ first : 198, last : 198},{ first : 208, last : 208},{ first : 215, last : 216},{ first : 222, last : 225},{ first : 230, last : 230},{ first : 232, last : 234},{ first : 236, last : 237},{ first : 240, last : 240},{ first : 242, last : 243},{ first : 247, last : 250},{ first : 252, last : 252},{ first : 254, last : 254},{ first : 257, last : 257},{ first : 273, last : 273},{ first : 275, last : 275},{ first : 283, last : 283},{ first : 294, last : 295},{ first : 299, last : 299},{ first : 305, last : 307},{ first : 312, last : 312},{ first : 319, last : 322},{ first : 324, last : 324},{ first : 328, last : 331},{ first : 333, last : 333},{ first : 338, last : 339},{ first : 358, last : 359},{ first : 363, last : 363},{ first : 462, last : 462},{ first : 464, last : 464},{ first : 466, last : 466},{ first : 468, last : 468},{ first : 470, last : 470},{ first : 472, last : 472},{ first : 474, last : 474},{ first : 476, last : 476},{ first : 593, last : 593},{ first : 609, last : 609},{ first : 708, last : 708},{ first : 711, last : 711},{ first : 713, last : 715},{ first : 717, last : 717},{ first : 720, last : 720},{ first : 728, last : 731},{ first : 733, last : 733},{ first : 735, last : 735},{ first : 913, last : 929},{ first : 931, last : 937},{ first : 945, last : 961},{ first : 963, last : 969},{ first : 1025, last : 1025},{ first : 1040, last : 1103},{ first : 1105, last : 1105},{ first : 8208, last : 8208},{ first : 8211, last : 8214},{ first : 8216, last : 8217},{ first : 8220, last : 8221},{ first : 8224, last : 8226},{ first : 8228, last : 8231},{ first : 8240, last : 8240},{ first : 8242, last : 8243},{ first : 8245, last : 8245},{ first : 8251, last : 8251},{ first : 8254, last : 8254},{ first : 8308, last : 8308},{ first : 8319, last : 8319},{ first : 8321, last : 8324},{ first : 8364, last : 8364},{ first : 8451, last : 8451},{ first : 8453, last : 8453},{ first : 8457, last : 8457},{ first : 8467, last : 8467},{ first : 8470, last : 8470},{ first : 8481, last : 8482},{ first : 8486, last : 8486},{ first : 8491, last : 8491},{ first : 8531, last : 8532},{ first : 8539, last : 8542},{ first : 8544, last : 8555},{ first : 8560, last : 8569},{ first : 8592, last : 8601},{ first : 8632, last : 8633},{ first : 8658, last : 8658},{ first : 8660, last : 8660},{ first : 8679, last : 8679},{ first : 8704, last : 8704},{ first : 8706, last : 8707},{ first : 8711, last : 8712},{ first : 8715, last : 8715},{ first : 8719, last : 8719},{ first : 8721, last : 8721},{ first : 8725, last : 8725},{ first : 8730, last : 8730},{ first : 8733, last : 8736},{ first : 8739, last : 8739},{ first : 8741, last : 8741},{ first : 8743, last : 8748},{ first : 8750, last : 8750},{ first : 8756, last : 8759},{ first : 8764, last : 8765},{ first : 8776, last : 8776},{ first : 8780, last : 8780},{ first : 8786, last : 8786},{ first : 8800, last : 8801},{ first : 8804, last : 8807},{ first : 8810, last : 8811},{ first : 8814, last : 8815},{ first : 8834, last : 8835},{ first : 8838, last : 8839},{ first : 8853, last : 8853},{ first : 8857, last : 8857},{ first : 8869, last : 8869},{ first : 8895, last : 8895},{ first : 8978, last : 8978},{ first : 9312, last : 9449},{ first : 9451, last : 9547},{ first : 9552, last : 9587},{ first : 9600, last : 9615},{ first : 9618, last : 9621},{ first : 9632, last : 9633},{ first : 9635, last : 9641},{ first : 9650, last : 9651},{ first : 9654, last : 9655},{ first : 9660, last : 9661},{ first : 9664, last : 9665},{ first : 9670, last : 9672},{ first : 9675, last : 9675},{ first : 9678, last : 9681},{ first : 9698, last : 9701},{ first : 9711, last : 9711},{ first : 9733, last : 9734},{ first : 9737, last : 9737},{ first : 9742, last : 9743},{ first : 9748, last : 9749},{ first : 9756, last : 9756},{ first : 9758, last : 9758},{ first : 9792, last : 9792},{ first : 9794, last : 9794},{ first : 9824, last : 9825},{ first : 9827, last : 9829},{ first : 9831, last : 9834},{ first : 9836, last : 9837},{ first : 9839, last : 9839},{ first : 10045, last : 10045},{ first : 10102, last : 10111},{ first : 57344, last : 63743},{ first : 65533, last : 65533},{ first : 983040, last : 1048573},{ first : 1048576, last : 1114109}];
test_Test.main();
})({});
