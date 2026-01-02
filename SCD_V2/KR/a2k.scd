(
File.mkdir(d ++ "/" ++ "a2k");
[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,24,25,30].do({arg n;
	var numChan = n;
	SynthDef.new(\a2k ++ (numChan).asSymbol, {
		arg in, value;
		var sig;
		sig = In.ar(in, numChan);
		Out.kr(value, A2K.kr(sig));
	}).writeDefFile(d ++ "/a2k");
})
)