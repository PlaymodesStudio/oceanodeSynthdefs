(
SynthDef.new(\output, {
	arg in = 0, out=0;
	var sig;
	sig = In.ar(in, ~maxVoices);
	sig=LeakDC.ar(sig);
	sig=Sanitize.ar(sig);
	sig = DelayN.ar(sig, 5, \delay.kr(0));
	ReplaceOut.ar(out, sig.tanh * \levels.kr(0));
}).writeDefFile(d);
)