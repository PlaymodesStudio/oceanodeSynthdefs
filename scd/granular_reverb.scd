(
~bus = Dictionary.new;
~bus.add(\granular_reverb -> Bus.audio(s, 2));
)

(
SynthDef(\granular_reverb, {
	arg out=0, in=0;
	var inAmp=\inamp.kr(1), outAmp=\levels.kr(1), overlap=\overlap.kr(2),
	tFreq=\tfreq.kr(20), tFreqMF=\tfreqmf.kr(0), tFreqMD=\tfreqmd.kr(0),
	rate=\rate.kr(1), rateMF=\ratemf.kr(0), rateMD=\ratemd.kr(0),
	offset=\offset.kr(0), offsetMF=\offsetmf.kr(0), offsetMD=\offsetmd.kr(0), minGrainDur=\mingrain.kr(0.001), mix=\mix.kr(0.5);

	var sig, inSig, gDur, readPos, writePos, grained, balance, grainDur, pan;
	var trig, bufFrames, bufRateScale;
	var sndBuf, bufDur;

	var tFreqMod = {
		SinOsc.ar(tFreqMF, Rand(0.0,2pi)) * tFreqMD;
	};

	var rateMod = {
		SinOsc.ar(rateMF, Rand(0.0,2pi)).range(0, rateMD);
	};

	var offsetMod = {
		SinOsc.ar(offsetMF, Rand(0.0,2pi)).range(0, offsetMD);
	};

	tFreq = tFreq + tFreqMod.dup;
	rate = rate - rateMod.dup;

	bufFrames = 2**16;
	sndBuf = {LocalBuf(bufFrames).clear}!2;
	bufDur = BufDur.ir(sndBuf);

	writePos = Phasor.ar(end: bufFrames);

	trig = Impulse.ar(tFreq);
	grainDur = max(tFreq.reciprocal * overlap.lag(5), minGrainDur);

	readPos = writePos - 64 / bufFrames - offset - offsetMod.dup;
	readPos = Wrap.ar(readPos, 0, 1);

	grained = GrainBufJ.ar(
		numChannels: 1,
		loop: 1,
		trigger: trig,
		dur: grainDur,
		sndbuf: sndBuf,
		rate: rate,
		pos: readPos,
		interp: 4,
	);

	grained = HPF.ar(grained, \grhpf.kr(40));
	grained = LPF.ar(grained, \grlpf.kr(15000));

	inSig = In.ar(in, 2) * inAmp;

	// writing granulated + input back to grain buffer
	sndBuf.do { |b i|
		BufWr.ar(grained[i] * \feedback.kr(0.3) + inSig[i], b, writePos)
	};

	sig = XFade2.ar(inSig, grained, mix * 2 - 1)*outAmp;
	Out.ar(out, sig.tanh);
}).add;
)

(
SynthDef(\test, {
	arg out=0, pan=0, amp=0.35, freq=150;
	var env = Env.perc.kr(2);
	var sig = Saw.ar(freq);
	sig = Pan2.ar(sig, pan, amp * env);
	Out.ar(out, sig);
}).add;
)

(
Pdef(\granular_reverb,
	Pmono(\granular_reverb,
		\overlap, 12,
		\tfreq, 26.60,
		\tfreqmd, 0.0,
		\tfreqmf, 25.10,
		\offset, 0.032,
		\offsetmf, 0.11,
		\offsetmf, 94,
		\rate, 1,
		\ratemf, 0.0,
		\ratemd, 1.0,
		\inamp, 1,
		\levels, 1,
		\grlpf, 14400,
		\grhpf, 93,
		\mix, 0.50,
		\feedback, 0.525,
		\in, ~bus[\granular_reverb],
	)
).play;
)

(
Pdef(\test,
	Pbind(
		\instrument, \test,
		\midinote, 60,
		\dur, 1,
		\out, ~bus[\granular_reverb],
	)
).play;
)