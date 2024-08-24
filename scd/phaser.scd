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

d = thisProcess.nowExecutingPath.dirname;

(//phaser
SynthDef(\phaserb13, {
	arg out=0, in=0;
	var input,dsig, sig,freq,mx;
	freq=\frequency.kr(2!13, 1/30, fixedLag: true);
	mx=\mix.kr(0!13, 1/30, fixedLag: true);
	input = In.ar(in, 13);
	dsig = AnalogPhaser.ar(input,SinOsc.ar(freq),\skew.kr(0!13, 1/30, fixedLag: true),\feedback.kr(0.5!13, 1/30, fixedLag: true),\mod.kr(0.5!13, 1/30, fixedLag: true),\stages.kr(25!13));
	sig=(input*(1-mx))+(dsig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)
(
SynthDef(\phaserc13, {
    arg out=0, in=0;
    var snd, wet, k, sig;
    var freq = \frequency.kr(0.2!13, 1/30, fixedLag: true);
    var mx = \mix.kr(0.5!13, 1/30, fixedLag: true);
    snd = In.ar(in, 13);
    k = SinOsc.ar(freq).linlin(-1, 1, \min.kr(0.5!13), \max.kr(1!13));
    wet = snd;
    wet = wet + (LocalIn.ar(13) * \feedback.kr(0.4!13, 1/30, fixedLag: true));
    wet = 13.collect { |i|
        var channel = wet[i];
        6.do {
            channel = FOS.ar(channel, k[i].neg, 1, k[i]);
        };
        channel
    };
    LocalOut.ar(wet);
    sig = (snd * (1 - mx)) + (wet * mx);
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