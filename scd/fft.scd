( SynthDef(\magabove, {
	arg in, out=0;
	var sig, chain;
	var mag=\magavobe.kr(1!13); //range 1 to 30
	sig = In.ar(in, 13);
	chain = FFT(LocalBuf(2048.dup(13), 1), sig);
	chain = PV_MagAbove(chain, mag);
	chain = IFFT(chain);
	sig=chain;
	Out.ar(out, sig);
}).writeDefFile(d);
)


d = thisProcess.nowExecutingPath.dirname;

( SynthDef(\fftblur, {
	arg in, out=0;
	var sig, chain;
	var blur=\blur.kr(0!13); //range 0 to 1
	sig = In.ar(in, 13);
	chain = FFT(LocalBuf(1024.dup(13), 1), sig);
	chain = PV_MagSmooth(chain, blur);
	sig = IFFT(chain);
	Out.ar(out, sig);
}).writeDefFile(d);
)

( SynthDef(\brickwallfilter, {
	arg in, out=0;
	var sig, chain;
	var cut=\cutoff.kr(0!13); //range -1 to 1
	sig = In.ar(in, 13);
	chain = FFT(LocalBuf(2048.dup(13), 1), sig);
	chain = PV_BrickWall(chain, cut);
	sig = IFFT(chain);
	Out.ar(out, sig);
}).writeDefFile(d);
)

//////

( SynthDef(\frequencywholes, {
	arg in, out=0;
	var sig, chain;
	var teeth=\teeth.kr(8!13); //range 1 to 512
	var ph=\ph.kr(0!13); //-1 to 1
	var pw=\pw.kr(0.5!13); //0 to 1
	sig = In.ar(in, 13);
	chain = FFT(LocalBuf(2048.dup(13) , 1), sig);
	chain = PV_RectComb(chain, teeth, ph, pw);
	sig = IFFT(chain);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(
{
    var sig, chain;
    sig = SoundIn.ar(0.2);
    chain = FFT(LocalBuf(2048), sig);
    chain = PV_RectComb(chain, 8, LFTri.kr(0.097, 0, 0.4, 0.5),
    LFTri.kr(0.24, 0, -0.5, 0.5));
    IFFT(chain).dup
}.play;
)

//

( SynthDef(\spectralmorph,
	{ arg in=0, in2=0, out=0;
		var sigA, sigB, inB, chainA, chainB, sig;
		var morph=\morph.kr(0!13, 0.05, fixedLag:true); //range 0-1
		sigA = In.ar(in, 13);
		sigB = In.ar(in2, 13);
		chainA = FFT(LocalBuf.new(2048.dup(13) , 1), sigA);
		chainB = FFT(LocalBuf.new(2048.dup(13) , 1), sigB);
		sig = PV_Morph(chainA, chainB, morph);
		sig = IFFT(sig);
		Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\binshift, {
    arg in, out=0;
    var sig, chain;
    var shift = \shift.kr(0!13);
	var stretch = \stretch.kr(1!13);
    sig = In.ar(in, 13);
    chain = FFT(LocalBuf(2048.dup(13), 1), sig);
    chain = PV_BinShift(chain, stretch, shift, 1);
    sig = IFFT(chain);
    Out.ar(out, sig);
}).writeDefFile(d);
)

///
(
SynthDef(\freeze_spectra, {
	arg out=0, pan=0, amp=0.5, buf=0;
	var sig, in, chain, winsize=1024;

	// the condition will be used in hundreds of places now
	// so be sure to calculate it only once!
	var freeze = MouseY.kr > 0.5;
	// used this for testing
	var modOn = MouseY.kr > 0.75;

	in = PlayBuf.ar(1, buf, BufRateScale.kr(buf), loop: 1);
	chain = FFT(LocalBuf(winsize), in);
	chain = PV_Freeze(chain, freeze);

	chain = chain.pvcollect(winsize, {
		arg mag, phase, index;
		var pmod;
		pmod = LFNoise1.kr(rrand(0.5, 1.1)).range(-pi, pi);
		// freeze instead of modOn here, for the final version I guess
		[mag, (pmod - phase) * /*freeze*/ modOn + phase]
	},
	frombin: 0, tobin: 250, zeroothers: 1);

	// you will Pan2 in a moment so no need to dup here
	sig = IFFT(chain) /*.dup*/;

	//sig = TPV.ar(chain, winsize, winsize/2, 50, 20, 1, 4, 0.1);

	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)


