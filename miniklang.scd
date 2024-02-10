(// miniklang
SynthDef(\miniklang, {
	arg out=0;
	var partials = 32;
	var chans = 2;
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = SinOsc.ar(freqs, mul: amps);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)