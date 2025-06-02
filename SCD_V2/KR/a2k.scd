(
File.mkdir(d ++ "/" ++ "a2k");
(1..~maxVoices).do({arg n;
	var numChan = n;
	SynthDef.new(\a2k ++ (numChan).asSymbol, {
		arg in, value;
		var sig;
		sig = In.ar(in, numChan);
		Out.kr(value, A2K.kr(sig));
	}).writeDefFile(d ++ "/a2k");
})
)