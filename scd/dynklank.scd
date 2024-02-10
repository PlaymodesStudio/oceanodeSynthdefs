//// dynklank
(
SynthDef(\dynklank, {
	arg out=0, in=0;
	var partials = 16;
	var chans = 78;
	var sig = In.ar(in, 78);
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var decays = \decayarray.kr(0.5.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = Ringz.ar(sig,freqs,decays,amps,0);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)

(
SynthDef(\dynklank13, {
	arg out=0, in=0;
	var partials = 16;
	var chans = 13;
	var sig = In.ar(in, 13);
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var decays = \decayarray.kr(0.5.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = Ringz.ar(sig,freqs,decays,amps,0);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)

(
SynthDef(\dynklankmono, {
	arg out=0, in=0;
	var partials = 16;
	var chans = 1;
	var sig = In.ar(in, 1);
	var freqs = \freqarray.kr(220.dup(partials*chans)).reshape(chans, partials).flop;
	var decays = \decayarray.kr(0.5.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var amps = \amparray.kr(0.0.dup(partials*chans), 1/30, fixedLag:true).reshape(chans, partials).flop;
	var largeSig = Ringz.ar(sig,freqs,decays,amps,0);
	var flat8 = Mix.ar(largeSig);
	Out.ar(out, flat8);
}).writeDefFile(d);
)