(
SynthDef.new(\testmc, {
	arg out;
	var p,sig;
	p=\pitch.kr(36).midicps;
	sig=SinOsc.ar(p);
	Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
