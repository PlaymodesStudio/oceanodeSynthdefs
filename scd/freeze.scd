
(
SynthDef(\freeze, {
	arg out=0, inp=0;
    var in, chain;
    in = SoundIn.ar(inp);
    chain = FFT(LocalBuf(1024), in);
    chain = PV_Freeze(chain, MouseY.kr > 0.5 );
	chain=PV_Diffuser(chain,MouseY.kr >0.5);
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

(//test amb overlap... no acaba d'anar
SynthDef(\freeze13, {
    arg in, out=0;
    var sig, chain, overlaps=2, fftSize=2048, fftBuf, pos;

    // Input signal
    sig = In.ar(in, 13);

    // Allocate local buffers for FFT processing
    fftBuf = LocalBuf(fftSize!13*overlaps, 1);

    // Create FFT chains with overlapping
    chain = FFT(fftBuf, sig, hop: 1.0/overlaps);
    chain = PV_Freeze(chain, \trigger.kr(0!13));

    // Adding phase diffusion
    chain = PV_Diffuser(chain, chain > -1);

    // IFFT and mixdown
    sig = IFFT(chain).dup;

    // Outputting the audio
    Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\freezefeed13, {
	arg in=0, out=0;
	var freezeAmt=\feed.kr(1!13), wet = \mix.kr(1!13);
	var local, input, fft, freeze, ifft;

	local = LocalIn.ar(13);
	input = In.ar(in, 13);
	fft = FFT(LocalBuf(1024.dup(13), 1), input+(local*freezeAmt), 0.5);
	freeze = PV_Freeze(fft, Impulse.ar(1/(2.pow(16)))); // try to trigger per window size
	ifft = IFFT.ar(freeze);
	LocalOut.ar(ifft);
	Out.ar(out, ifft.dup(13)*wet + ((1.0 - wet) * input));
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\freezefeed13, {
	arg in = 0, out = 0;
	var freezeAmt = \feed.kr(1!13), wet = \mix.kr(1!13);
	var local, input, fft, freeze, ifft, mix;

	local = LocalIn.ar(13);
	input = In.ar(in, 13);
	fft = FFT(LocalBuf(1024, 1), input + (local * freezeAmt), 0.5);
	freeze = PV_Freeze(fft, Impulse.ar(1 / (2.pow(16)))); // trigger per window size
	ifft = IFFT.ar(freeze);

	// Process each channel independently
	LocalOut.ar(ifft);
	mix = Mix.fill(13, { |i| ifft[i] * wet + (1.0 - wet) * input[i] });

	Out.ar(out, mix);
}).writeDefFile(d);
)

(
SynthDef(\freezemod, {
	arg out=0,in,in2;
	var amp=0.5;
	var sig1,sig2,l,r,chain1,chain2,winsize=1024;

	var freeze = \trigger.kr(0);

	in = SoundIn.ar(0, 2);
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
}).play();
)


