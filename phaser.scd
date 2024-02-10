(//phaser
SynthDef(\phaser, {
	arg out=0, in=0;
	var input,dsig, sig,freq,mx;
	freq=\frequency.kr(2!78);
	mx=\mix.kr(0!78);
	input = In.ar(in, 78);
	dsig = AllpassL.ar(input, 4, SinOsc.ar(freq, 0, 0.005, 0.005), 0);
	sig=(input*(1-mx))+(dsig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//phaser
SynthDef(\phaser13, {
	arg out=0, in=0;
	var input,dsig, sig,freq,mx;
	freq=\frequency.kr(2!13);
	mx=\mix.kr(0!13);
	input = In.ar(in, 13);
	dsig = AllpassL.ar(input, 4, SinOsc.ar(freq, 0, 0.005, 0.005), 0);
	sig=(input*(1-mx))+(dsig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//phaser
SynthDef(\phasermono, {
	arg out=0, in=0;
	var input,dsig, sig,freq,mx;
	freq=\frequency.kr(2!1);
	mx=\mix.kr(0!1);
	input = In.ar(in, 1);
	dsig = AllpassL.ar(input, 4, SinOsc.ar(freq, 0, 0.005, 0.005), 0);
	sig=(input*(1-mx))+(dsig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)