(
SynthDef(\ikedabass, {

	arg out = 0;
	var freq = 0, amp = 1, harmonic = 8, iphase = pi/3;
	var env, snd;

	freq=\pitch.kr(36!78).midicps;
	amp=\levels.kr(0!78, 1/30, fixedLag:true);
	harmonic=\harm.kr(8!78);
	snd = SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq) + iphase).wrap(-pi, pi))+SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq * harmonic) + iphase).wrap(-pi, pi));
snd=snd*amp;
	snd = (snd/2).tanh;
	snd = LeakDC.ar(snd);
	snd = snd ;
    Out.ar(out, snd);

}).writeDefFile(d);
)

(
SynthDef(\ikedabass13, {

	arg out = 0;
	var freq = 0, amp = 1, harmonic = 8, iphase = pi/3;
	var env, snd;

	freq=\pitch.kr(36!13).midicps;
	amp=\levels.kr(0!13, 1/30, fixedLag:true);
	harmonic=\harm.kr(8!13);

	snd = SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq) + iphase).wrap(-pi, pi))+SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq * harmonic) + iphase).wrap(-pi, pi));
snd=snd*amp;
	snd = (snd/2).tanh;
	snd = LeakDC.ar(snd);
	snd = snd ;
    Out.ar(out, snd);
}).writeDefFile(d);
)

(
SynthDef(\ikedabassmono, {

	arg out = 0;
	var freq = 0, amp = 1, harmonic = 8, iphase = pi/3;
	var env, snd;

	freq=\pitch.kr(36!1).midicps;
	amp=\levels.kr(0!1, 1/30, fixedLag:true);
	harmonic=\harm.kr(8!1);

	snd = SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq) + iphase).wrap(-pi, pi))+SinOsc.ar(freq: 0,phase:(Sweep.ar(rate: 2pi * freq * harmonic) + iphase).wrap(-pi, pi));
	snd=snd*amp;
	snd = (snd/2).tanh;
	snd = LeakDC.ar(snd);
	snd = snd ;
    Out.ar(out, snd);
}).writeDefFile(d);
)