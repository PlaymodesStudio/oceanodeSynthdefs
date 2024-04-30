

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