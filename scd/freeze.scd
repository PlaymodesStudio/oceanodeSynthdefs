
(
SynthDef(\freeze, {
	arg out=0, inp=0;
    var in, chain;
    in = SoundIn.ar(inp);
    chain = FFT(LocalBuf(1024), in);
    chain = PV_Freeze(chain, MouseY.kr > 0.5 );
    Out.ar(out, 0.5 * IFFT(chain).dup);
}).play();
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\freezemono, {
	arg in, out=0;
    var sig, chain;
	var gate=\trigger.kr(0);
    sig = In.ar(in, 1);
	chain = FFT(LocalBuf(1024), sig);
    chain = PV_Freeze(chain, gate);
	chain = IFFT(chain);
	sig=chain;
    Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\freeze13, {
	arg in, out=0;
    var sig, chain;
	var gate=\trigger.kr(0!13);
    sig = In.ar(in, 13);
    chain = FFT(LocalBuf(1024.dup(13), 1), sig);
    chain = PV_Freeze(chain, gate);
	chain = IFFT(chain);
	sig=chain;
    Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\freezemod, {
	arg out=0,amp=0.5;
	var sig1,sig2,in,in2,l,r,chain1,chain2,winsize=1024;

	var freeze = \trigger.kr(0);

	in = In.ar(0, 2);
	l=in[0];
	r=in[1];
	chain1 = FFT(LocalBuf(1024), l);
	chain1= PV_Freeze(chain1, freeze);
	chain2 = FFT(LocalBuf(1024), r);
	chain2= PV_Freeze(chain2, freeze);

	chain1 = chain1.pvcollect(winsize, {
		arg mag, phase, index;
		var pmod;
		pmod = LFNoise1.kr(rrand(0.5, 1.1)).range(-pi, pi);
		[mag, (pmod - phase) * freeze + phase]
	},
	frombin: 0, tobin: 250, zeroothers: 1);

	chain2 = chain2.pvcollect(winsize, {
		arg mag, phase, index;
		var pmod;
		pmod = LFNoise1.kr(rrand(0.5, 1.1)).range(-pi, pi);
		[mag, (pmod - phase) * freeze + phase]
	},
	frombin: 0, tobin: 250, zeroothers: 1);

	sig1 = IFFT(chain1);
	sig2 = IFFT(chain2);

	Out.ar(out, [sig1,sig2]);
}).writeDefFile(d);
)


