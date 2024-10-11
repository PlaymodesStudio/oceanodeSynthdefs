(
SynthDef(\vibrato13, {
	arg out=0, in=0;
	var sigout;
	var freq=440, release=0.1;
	var x, sig, mod1, depth, mfreq, mix;
	var nch=13;
	depth = \depth.kr(0.1!nch);
	mfreq = \freq.kr(5!nch);
	mix=\mix.kr(1!nch);
	mod1 = SinOsc.ar(mfreq,0,depth,depth);
	sig =  In.ar(in,nch);
	x = DelayC.ar(sig, 0.2,mod1);
	sigout = XFade2.ar(sig, x, mix * 2 - 1);
	Out.ar(out,sigout);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

