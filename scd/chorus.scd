d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\chorusb13, {
	arg out=0, in=0;
    var dry, wet, snd, tapCount, numchans,mx,freq;
	numchans = 13;
	freq=\frequency.kr(0.01, 1/30, fixedLag: true);
	mx=\mix.kr(1!numchans, 1/30, fixedLag: true);
	dry = In.ar(in,numchans);
    tapCount = 6;


	wet = LeakDC.ar(LocalIn.ar(numchans)).tanh * \feedback.kr(0.495);
    wet = wet + dry;

    wet = numchans.collect { |channel|
        tapCount.collect { |tap|
            DelayC.ar(
                wet[channel],
                0.03,
                SinOsc.ar(
                    freq,
                    ((tap + (channel / numchans)) / tapCount) * 2pi
                ).linlin(-1, 1, 5e-3, 20e-3)
            )
        }.sum / sqrt(tapCount)
    };

    LocalOut.ar(wet);
	snd = (dry * (1 - mx)) + (wet * mx);
	Out.ar(out, snd);
}).writeDefFile(d);
)

(//chorus
SynthDef(\chorus, {
	arg out, in, amp = 1, loDelay = 0.001, hiDelay = 0.005,
	maxDelayTime = 0.1, mx;
	var sig, dry, freq, inSig;

	inSig = In.ar(in, 78);
	dry=In.ar(in, 78);
	mx=\mix.kr(0!78);
	freq=\frequency.kr(1!78);
	inSig = Mix.fill(10, { |i|
		DelayL.ar(inSig, maxDelayTime, LFDNoise3.ar(freq).range(loDelay, hiDelay))
	});
	inSig=inSig/2;
	sig=(dry*(1-mx))+(inSig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//chorus
SynthDef(\chorus13, {
	arg out, in, amp = 1, loDelay = 0.001, hiDelay = 0.005,
	maxDelayTime = 0.1, mx;
	var sig, dry, freq, inSig;

	inSig = In.ar(in, 13);
	dry=In.ar(in, 13);
	mx=\mix.kr(0!13);
	freq=\frequency.kr(1!13);
	inSig = Mix.fill(10, { |i|
		DelayL.ar(inSig, maxDelayTime, LFDNoise3.ar(freq).range(loDelay, hiDelay))
	});
	inSig=inSig/2;
	sig=(dry*(1-mx))+(inSig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//chorus
SynthDef(\chorus6, {
	arg out, in, amp = 1, loDelay = 0.001, hiDelay = 0.005,
	maxDelayTime = 0.1, mx;
	var sig, dry, freq, inSig;

	inSig = In.ar(in, 6);
	dry=In.ar(in, 6);
	mx=\mix.kr(0!6);
	freq=\frequency.kr(1!6);
	inSig = Mix.fill(10, { |i|
		DelayL.ar(inSig, maxDelayTime, LFDNoise3.ar(freq).range(loDelay, hiDelay))
	});
	inSig=inSig/2;
	sig=(dry*(1-mx))+(inSig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)

(//chorus
SynthDef(\chorusmono, {
	arg out, in, amp = 1, loDelay = 0.001, hiDelay = 0.005,
	maxDelayTime = 0.1, mx;
	var sig, dry, freq, inSig;

	inSig = In.ar(in, 1);
	dry=In.ar(in, 1);
	mx=\mix.kr(0!1);
	freq=\frequency.kr(1!1);
	inSig = Mix.fill(10, { |i|
		DelayL.ar(inSig, maxDelayTime, LFDNoise3.ar(freq).range(loDelay, hiDelay))
	});
	inSig=inSig/2;
	sig=(dry*(1-mx))+(inSig*mx);
	Out.ar(out, sig);
}).writeDefFile(d);
)