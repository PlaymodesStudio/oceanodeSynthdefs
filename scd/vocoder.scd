
d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\vocoder, {
	arg out=0, in=0, in2=0;
	var sig, sig2, chain, chain2, size=1024;
	var numchans=2;
	var chains, chains2;
	var blend=\blend.kr(1);

	sig = In.ar(in, numchans);
	sig2 = In.ar(in2, numchans);

	chains = Array.fill(numchans, { |i|
		FFT(LocalBuf(size), sig[i])
	});
	chains2 = Array.fill(numchans, { |i|
		FFT(LocalBuf(size), sig2[i])
	});

	chains = chains.collect({ |chain, i|
		chain.pvcalc2(chains2[i], size, {
			arg mag, phs, mag2, phs2;
			mag = (mag * blend) + (mag2 * (1 - blend));
			[mag, phs2];
		})
	});

	sig = Mix.fill(numchans, { |i| IFFT(chains[i]) }) * \levels.kr(0.5);
	Out.ar(out, sig);
}).writeDefFile(d);
)

//another model

(
{
	var voicedCarrier;
	var snd, numBands, bandFreqs, carrier;
	numBands = 32;
	bandFreqs = (0..numBands - 1).linexp(0, numBands - 1, 100, 8000);
	snd = PlayBuf.ar(1, ~buffer, BufRateScale.kr(~buffer));
	voicedCarrier = Saw.ar((60 + [0, 3, 7]).midicps);
	carrier = SelectX.ar((ZeroCrossing.ar(snd).cpsmidi.lag(0.05) > 5000.cpsmidi).lag(0.05), [voicedCarrier, PinkNoise.ar]);
	snd = Amplitude.ar(BPF.ar(snd, bandFreqs, 0.05), 0.01, 0.05);
	snd = BPF.ar(carrier, bandFreqs, 0.05) * snd;
	snd = snd.sum;
	snd = snd * 30.dbamp;
	snd = Limiter.ar(snd);
	snd ! 2;
}.play;
)