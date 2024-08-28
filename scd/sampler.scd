(
SynthDef(\samplerstretch13, {
    arg out=0;
    var signal, spd, buf, buf2, gain, pos, reverse;
    var windowSize, overlaps, windowRandRatio, interp;

    // Controls
    gain = \levels.kr(0!13, 1/30, fixedLag:true);
    buf = \bufnum.kr(0!13);
	buf2 = \bufnum2.kr(-1!13);
    spd = \pitch.kr(0!13, 1/30, fixedLag:true).midiratio;
    pos = \pos.kr(0!13, 1/30, fixedLag:true);
    reverse = \reverse.kr(0!13);

    // Additional controls
    windowSize = \winsize.kr(0.2!13, 1/30, fixedLag:true);
    overlaps = \overlaps.kr(8!13);
    windowRandRatio = \winrand.kr(0.0!13, 1/30, fixedLag:true);
    interp = \interp.kr(4!13);

    // Calculate final freqScale, applying reverse if needed
    spd = spd * (1 - (2 * reverse)); // This will be -spd when reverse=1, and spd when reverse=0

    signal = Warp1.ar(
        numChannels: 1,
        bufnum: buf,
        pointer: pos,
        freqScale: spd,
        windowSize: windowSize,
        envbufnum: buf2,
        overlaps: overlaps,
        windowRandRatio: windowRandRatio,
        interp: interp
    ) * gain;

    Out.ar(out, signal);
}).writeDefFile(d);
)

(
SynthDef(\oneshotsampler13, {
    arg out=0;
    var t, signal, spd, buf, start, gain;
    var env, envgen, attack, decay, sustain, release, curve;

    t = \trigger.kr(0!13);
    gain = \levels.kr(0!13, 1/30, fixedLag:true);
    buf = \bufnum.kr(0!13);
    spd = \pitch.kr(1!13, 1/30, fixedLag:true).midiratio;
    start = \startpos.kr(0!13) * BufFrames.kr(buf);

    attack = \attack.kr(0.01!13, 1/30, fixedLag:true);
    decay = \decay.kr(0.1!13, 1/30, fixedLag:true);
    sustain = \sustain.kr(0.5!13, 1/30, fixedLag:true);
    release = \release.kr(0.5!13, 1/30, fixedLag:true);

    curve = \curve.kr(0!13, 1/30, fixedLag:true);

    env = Env.adsr(attack, decay, sustain, release, 1, curve);
    envgen = EnvGen.kr(env, t);

    signal = PlayBuf.ar(1, buf, spd, t, start, 0) * envgen;
    Out.ar(out, signal * gain);
}).writeDefFile(d);
)


(// samples
SynthDef(\sampler,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain;
		t=\trigger.kr(0!78);
		gain=\levels.kr(0!78, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!78);
		spd=\speed.kr(1!78);
		bucle=\loop.kr(0!78);
		start=\startpos.kr(0!78)*BufFrames.kr(buf);
		signal=PlayBuf.ar(1, buf, spd, t, start,bucle)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(// samples
SynthDef(\sampler13,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain;
		t=\trigger.kr(0!13);
		gain=\levels.kr(0!13, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!13);
		spd=\speed.kr(1!13);
		bucle=\loop.kr(0!13);
		start=\startpos.kr(0!13)*BufFrames.kr(buf);
		signal=PlayBuf.ar(1, buf, spd, t, start,bucle)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(// samples
SynthDef(\samplermono,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain;
		t=\trigger.kr(0!1);
		gain=\levels.kr(0!1, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!1);
		spd=\speed.kr(1!1);
		bucle=\loop.kr(0!1);
		start=\startpos.kr(0!1)*BufFrames.kr(buf);
		signal=PlayBuf.ar(1, buf, spd, t, start,bucle)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

(// samples
SynthDef(\samplerjump13,
	{
		arg out=0;
		var t, signal, spd, buf,bucle, start, gain,ph,offset,numsamples;
		t=\trigger.kr(0!13);
		gain=\levels.kr(0!13, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!13);
		spd=\speed.kr(1!13);
		bucle=\loop.kr(0!13);
		start=\startpos.kr(0!13)*BufFrames.kr(buf);
		offset=\offset.ar(0!13);
		numsamples=BufFrames.kr(buf);
		offset=offset*numsamples;
		ph=Wrap.ar(Phasor.ar(t, BufRateScale.kr(buf) * spd, start, BufFrames.kr(buf))+offset, 0, numsamples);
		signal=BufRd.ar(1, buf, ph, bucle, 0)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

/*
NOTE: If one wants Phasor to output a signal with frequency freq oscillating between start and end, then the rate should be (end - start) * freq / sr where sr is the sampling rate.
*/

(// samples
SynthDef(\samplersync13,
	{
		arg out=0;
		var t, rates, rate,ratefreq, freq,freqs,ratenorm, signal, fq, buf,bucle, start, end, gain,ph,offset, segdur,playmode,loopmodes;
		t=\trigger.kr(0!13);
		gain=\levels.kr(0!13, 1/30, fixedLag:true);
		buf=\bufnum.kr(0!13);
		fq=\freq.kr(1!13);
		bucle=\loop.kr(0!13);
		start=\startpos.kr(0!13)*BufFrames.kr(buf);
		end=\endpos.kr(1!13)*BufFrames.kr(buf);
		offset=\offset.ar(0!13);
		playmode=\playmode.kr(0);
		segdur=(end - start) / SampleRate.ir;
		ratefreq=(end-start)*fq/SampleRate.ir;
		ratenorm=BufRateScale.kr(buf) * fq;

		rates=[
			ratefreq,
			ratenorm
		];

		freqs=[
			fq,
			(1.0/segdur)*fq
		];

		freq=Select.kr(playmode,freqs);
		rate=Select.kr(playmode,rates);
		offset=offset*(end-start);

		loopmodes=[
			Wrap.ar(Sweep.ar(t,freq).linlin(0,1,start,end)+offset,start,end),
			Wrap.ar(Phasor.ar(t, rate, start, end)+offset, start, end)
		];

		ph=Select.ar(bucle,loopmodes);
		signal=BufRd.ar(1, buf, ph, bucle, 0)*gain;
		Out.ar(out, signal);
}).writeDefFile(d);
)

