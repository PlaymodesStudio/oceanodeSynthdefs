d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\proreverb13, {
    arg in, out = 0;
    var nch = 13; // Number of channels
    var dry, wet, temp, sig;
    var predelay, revtime, lpf, hpf, mx, feedback, samplerate;
    var earlyRefDelayTimes, earlyRefFeedbacks, allpassDelays, combMaxDelays;
    var diffusion, modDepth, modFreq, damp, size;

    // Enhanced controls
    predelay = \predelay.kr(0.1!nch);
    revtime = \time.kr(4!nch);
    lpf = \lowpass.kr(5000!nch).midicps;
    hpf = \hipass.kr(100!nch).midicps;
    mx = \mix.kr(0.33!nch);
    earlyRefDelayTimes = \earlydel.kr(0.03!nch);
    earlyRefFeedbacks = \earlyfeed.kr(0.5!nch);
    allpassDelays = \allpassDel.kr(0.05!nch);
    combMaxDelays = \combdel.kr(0.1!nch);

    // New controls
    diffusion = \diffusion.kr(0.7!nch);
    modDepth = \modDepth.kr(0.1!nch);
    modFreq = \modFreq.kr(0.2!nch);
    damp = \damp.kr(0.5!nch);
    size = \size.kr(1!nch);

    samplerate = SampleRate.ir;

    // Input and preparation for 13 channels
    dry = In.ar(in, nch);
    temp = dry;

    // Apply predelay to simulate initial reflections/distance for each channel
    temp = DelayN.ar(temp, 1, predelay);

    // Early Reflections using Allpass filters
    4.do {
        temp = AllpassC.ar(
            temp,
            earlyRefDelayTimes * size,
            LFNoise1.kr(0.1!nch).range(0.01, 0.05) * size,
            earlyRefFeedbacks
        );
    };

    // Feedback coefficient calculation for late reverb, applied per channel
    feedback = (revtime.reciprocal * (-60 / (samplerate * 0.001.log))).exp;

    // Late reverb using Allpass chain
    32.do {
        temp = AllpassL.ar(
            temp,
            allpassDelays,                          // Max delay time for each channel
            { Rand(0.001, 0.05) } ! nch,            // Random delay times for each channel
            feedback                                // Feedback coefficient calculated for each channel
        );
    };

    // Apply Comb filters for the late reverb stage
    wet = CombC.ar(
        temp,
        combMaxDelays * size,
        { Rand(0.01, 0.1) } ! nch * size,
        revtime * feedback,
        diffusion
    );

    // Apply modulation to the late reverb
    wet = DelayC.ar(
        wet,
        0.05!nch,
        SinOsc.kr(modFreq!nch, 0, modDepth * 0.001)
    );

    // Apply Lowpass and Highpass filters to shape the reverb tail for each channel
    wet = LPF.ar(wet, lpf);
    wet = HPF.ar(wet, hpf);
    wet = BPeakEQ.ar(wet, 3000, 0.5, -3); // Subtle mid-range cut

    // Apply damping
    wet = LPF.ar(wet, (1 - damp) * 10000 + 1000);

    // Improved mixing of dry and wet signals per channel
    sig = (dry * (1 - mx)) + (wet * mx);

    // Output the processed signal
    Out.ar(out, sig);
}).writeDefFile(d);

)

(
SynthDef(\freeverb13, {
	arg out=0, in=0;
	var nch=13;
	var mix=\mix.kr(0.33!nch), room=\room.kr(0.5!nch), damp=\damp.kr(0.5!nch);
    var sig, verb;

    // Input signal
    sig = In.ar(in, nch);

    verb = nch.collect { |i|
        FreeVerb.ar(
            sig[i],
            mix: mix,
            room: room,
            damp: damp
        )
    };

    // Output
    Out.ar(out, verb);
}).add;
)

(//reverb 2
SynthDef(\reverb, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!78);
	revtime=\time.kr(4!78);
	lpf=\lowpass.kr(100!78).midicps;
	hpf=\hipass.kr(12!78).midicps;
	mx=\mix.kr(0!78);

	dry = In.ar(in, 78);
	temp= In.ar(in, 78);

	wet=0;
	temp=DelayN.ar(temp, 1!78, predel);
	32.do {
		temp=AllpassL.ar(temp, 0.05!78, {Rand(0.001,0.05)}!78,revtime);
	};

	wet=LPF.ar(temp,lpf);
	wet=HPF.ar(wet,hpf);

	sig=(dry*(1-mx))+(wet*mx);

	Out.ar(out,sig);
}).writeDefFile(d);
)

(
SynthDef(\reverb13b, {
    arg in, out=0;
    var predel, revtime, lpf, hpf, mx, amp=1, dry, wet, temp, sig, input_level,passes,adjrevtime;
    predel = \predelay.kr(1!13);
    revtime = \time.kr(4!13);
    lpf = \lowpass.kr(100!13).midicps;
    hpf = \hipass.kr(12!13).midicps;
    mx = \mix.kr(0!13);
    input_level = \inputlevel.kr(1!13); // New parameter for input level control
	passes=32;

    dry = In.ar(in, 13);
    temp = In.ar(in, 13) * input_level; // Apply input level control

    // Apply predelay
    temp = DelayN.ar(temp, 1!13, predel);

    // Allpass chain
	adjrevtime = revtime / passes;
    passes.do {
        temp = AllpassL.ar(temp, 0.05!13, {Rand(0.001,0.05)}!13, adjrevtime);
    };

    // Apply filters once per channel after the allpass chain
    wet = LPF.ar(temp, lpf);
    wet = HPF.ar(wet, hpf);

    // Mix dry and wet signals
    sig = (dry * (1 - mx)) + (wet * mx);
    Out.ar(out, sig);
}).writeDefFile(d);
)

(
SynthDef(\reverb13, {
    arg in, out=0;
    var predel, revtime, lpf, hpf, mx, amp=1, dry, wet, temp, sig, input_level;
    predel = \predelay.kr(1!13);
    revtime = \time.kr(4!13);
    lpf = \lowpass.kr(100!13).midicps;
    hpf = \hipass.kr(12!13).midicps;
    mx = \mix.kr(0!13);
    input_level = \inputlevel.kr(1!13); // New parameter for input level control

    dry = In.ar(in, 13);
    temp = In.ar(in, 13) * input_level; // Apply input level control

    // Apply predelay
    temp = DelayN.ar(temp, 1!13, predel);

    // Allpass chain
    32.do {
        temp = AllpassL.ar(temp, 0.05!13, {Rand(0.001,0.05)}!13, revtime);
    };

    // Apply filters once per channel after the allpass chain
    wet = LPF.ar(temp, lpf);
    wet = HPF.ar(wet, hpf);

    // Mix dry and wet signals
    sig = (dry * (1 - mx)) + (wet * mx);
    Out.ar(out, sig);
}).writeDefFile(d);
)

(//reverb 13ch
SynthDef(\reverb6, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!6);
	revtime=\time.kr(4!6);
	lpf=\lowpass.kr(100!6).midicps;
	hpf=\hipass.kr(12!6).midicps;
	mx=\mix.kr(0!6);

	dry = In.ar(in, 6);
	temp= In.ar(in, 6);

	wet=0;
	temp=DelayN.ar(temp, 1!6, predel);
	32.do {
		temp=AllpassL.ar(temp, 0.05!6, {Rand(0.001,0.05)}!6,revtime);
	};

	wet=LPF.ar(temp,lpf);
	wet=HPF.ar(wet,hpf);

	sig=(dry*(1-mx))+(wet*mx);
	Out.ar(out,sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


(//reverb 13ch
SynthDef(\reverbmono, {
	arg in, out=0;
	var predel,revtime,lpf,hpf,mx,amp=1,dry,wet,temp,sig;
	predel=\predelay.kr(1!1);
	revtime=\time.kr(4!1);
	lpf=\lowpass.kr(100!1).midicps;
	hpf=\hipass.kr(12!1).midicps;
	mx=\mix.kr(0!1);

	dry = In.ar(in, 1);
	temp= In.ar(in, 1);

	wet=0;
	temp=DelayN.ar(temp, 1!1, predel);
	32.do {
		temp=AllpassL.ar(temp, 0.05!1, {Rand(0.001,0.05)}!1,revtime);
	};

	wet=LPF.ar(temp,lpf);
	wet=HPF.ar(wet,hpf);

	sig=(dry*(1-mx))+(wet*mx);
	Out.ar(out,sig);
}).writeDefFile(d);
)

(
SynthDef(\fdn_reverb13, {
    arg in, out=0;
    var input, output, delayTimes, delays, feedback, temp;
    var feedbackAmount, damping, mix, lpf, hpf;

    // User-controllable parameters
    feedbackAmount = \feedback.kr(0.5!13);
    damping = \damping.kr(0.1!13);
    mix = \mix.kr(0.33!13);
    lpf = \lowpass.kr(10000!13);
    hpf = \hipass.kr(20!13);

    input = In.ar(in, 13);
    delayTimes = {Rand(0.01, 0.1)}!13;

    delays = DelayC.ar(input, 0.2, delayTimes);
    feedback = Rotate2.ar(delays, delays, 0.23);

    16.do {
        temp = DelayC.ar(feedback, 0.2, delayTimes);
        feedback = (temp * feedbackAmount) + (input * 0.125);
        feedback = Rotate2.ar(feedback, feedback, 0.23);
    };

    // Apply filters outside the loop
    feedback = LPF.ar(feedback, (1 - damping) * 10000 + 1000); // Damping
    feedback = LPF.ar(feedback, lpf); // User-controlled LPF
    feedback = HPF.ar(feedback, hpf); // User-controlled HPF

    output = Mix(feedback) * 0.25;
    output = LeakDC.ar(output);

    // Mix dry and wet signals
    output = (input * (1 - mix)) + (output * mix);

    Out.ar(out, output);
}).writeDefFile(d);
)

(
SynthDef(\jpverb13, {
	arg in = 0, out = 0;
	var source, sig, revtime = 1, damp = 0, size = 1, early = 0.707, low, mid, high, lowcut, highcut, modDepth, modFreq,mx;

	revtime=\time.kr(1!13, 1/30, fixedLag: true);
	damp=\damp.kr(0!13, 1/30, fixedLag: true);
	size=\size.kr(1!13, 1/30, fixedLag: true);
	early=\early.kr(0.7, 1/30, fixedLag: true);
	low=\lowtime.kr(1!13, 1/30, fixedLag: true);
	mid=\midtime.kr(1!13, 1/30, fixedLag: true);
	high=\hitime.kr(1!13, 1/30, fixedLag: true);
	lowcut=\lowcut.kr(200!13, 1/30, fixedLag: true);
	highcut=\hicut.kr(5000!13, 1/30, fixedLag: true);
	modDepth=\moddepth.kr(0.1!13, 1/30, fixedLag: true);
	modFreq=\modfreq.kr(2!13, 1/30, fixedLag: true);
	mx=\mix.kr(0!1);

	source = In.ar (in, 13);
	sig = 0!13 + JPverb.ar (source, revtime, damp, size, early, modDepth, modFreq, low, mid, high, lowcut, highcut);
	sig=(source*(1-mx))+(sig*mx);
	Out.ar (out, sig);
}).writeDefFile(d);
)

(
SynthDef(\greyholereverb13, {
	arg in = 0, out = 0;
	var source, sig, revtime = 1, damp = 0, size = 1, diff, modDepth, modFreq,feed,mx,lowp,hip;

	revtime=\time.kr(1!13, 1/30, fixedLag: true); //0-60
	damp=\damp.kr(0!13, 1/30, fixedLag: true); //0.5-5
	size=\size.kr(1!13, 1/30, fixedLag: true); //0-1
	diff=\diff.kr(0.7, 1/30, fixedLag: true); //0-3
	feed=\feedback.kr(0.9!13, 1/30, fixedLag: true); //0-1
	modDepth=\moddepth.kr(0.1!13, 1/30, fixedLag: true); //0-1
	modFreq=\modfreq.kr(2!13, 1/30, fixedLag: true); //0-10
	mx=\mix.kr(0!1); //0-1
	lowp=\lopass.kr(130!13).midicps;
	hip=\hipass.kr(10!13).midicps;
	source = In.ar (in, 13);
	sig = Greyhole.ar (source, revtime, damp, size, diff, feed, modDepth, modFreq);
	sig=LPF.ar(sig,lowp);
	sig=HPF.ar(sig,hip);
	sig=(source*(1-mx))+(sig*mx);
	Out.ar (out, sig);
}).writeDefFile(d);
)
d = thisProcess.nowExecutingPath.dirname;
