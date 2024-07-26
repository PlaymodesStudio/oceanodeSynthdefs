(//stereo downmixer
SynthDef.new(\stereomix, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 78);
	sig=Splay.ar(sig,1,1,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//stereo downmixer
SynthDef.new(\stereomix13, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 13);
	sig=Splay.ar(sig,1,1,0);
	ReplaceOut.ar(out, sig);
}).writeDefFile(d);
)

(//stereo downmixer
SynthDef.new(\stereomix48, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 48);
	sig=Splay.ar(sig,1,1,0);
	Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
