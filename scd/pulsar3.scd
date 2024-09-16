d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\pulsetrain, {
    arg out=0;
	var triggerRate=\trigrate.kr(20, 1/30, fixedLag:true), grainFreq=\grainfreq.kr(1000, 1/30, fixedLag:true), overlap=\overlap.kr(30, 1/30, fixedLag:true), pmRatio=\phmod.kr(3, 1/30, fixedLag:true), pmIndex=\phmodidx.kr(2, 1/30, fixedLag:true), amp=\amp.kr(0.1, 1/30, fixedLag:true);

    var rampToSlope = { |phase|
        var history = Delay1.ar(phase);
        var delta = (phase - history);
        delta.wrap(-0.5, 0.5);
    };

    var rampToTrig = { |phase|
        var history = Delay1.ar(phase);
        var delta = (phase - history);
        var sum = (phase + history);
        var trig = (delta / sum).abs > 0.5;
        Trig1.ar(trig, SampleDur.ir);
    };

    var getSubSampleOffset = { |phase, trig|
        var slope = rampToSlope.(phase);
        var sampleCount = phase - (slope < 0) / slope;
        Latch.ar(sampleCount, trig);
    };

    var accumulatorSubSample = { |trig, subSampleOffset|
        var accum = Duty.ar(SampleDur.ir, trig, Dseries(0, 1));
        accum + subSampleOffset;
    };

    var stepPhase, stepSlope, stepTrigger, subSampleOffsets, accumulator;
    var windowSlope, windowPhase, maxOverlap;
    var modSlope, modPhase, pmod;
    var grainSlope, grainPhase, grainWindow, sig;



    stepPhase = (Phasor.ar(0, triggerRate * SampleDur.ir) - SampleDur.ir).wrap(0, 1);
    stepTrigger = rampToTrig.(stepPhase);
    stepSlope = rampToSlope.(stepPhase);
    subSampleOffsets = getSubSampleOffset.(stepPhase, stepTrigger);
    accumulator = accumulatorSubSample.(stepTrigger, subSampleOffsets);

    grainSlope = grainFreq * SampleDur.ir;
    grainPhase = (grainSlope * accumulator).wrap(0, 1);
    maxOverlap = grainSlope / Latch.ar(stepSlope, stepTrigger);
    overlap = min(overlap, maxOverlap);
    windowSlope = grainSlope / max(0.001, overlap);
    windowPhase = (windowSlope * accumulator).clip(0, 1);

    modSlope = grainSlope * pmRatio;
    modPhase = (modSlope * accumulator).wrap(0, 1);

    grainWindow = IEnvGen.ar(Env([0, 1, 0], [0.03, 0.97], [4.0, -4.0]), windowPhase);

    pmod = sin(modPhase * 2pi) * pmIndex;
    pmod = OnePole.ar(pmod, exp(-2pi * modSlope));

    sig = sin(grainPhase + (pmod / 2pi) * 2pi);
    sig = sig * grainWindow;

    Out.ar(out, sig ! 2 * amp);
}).writeDefFile(d);
)

(
SynthDef(\pulsetrain_multi, {
    arg out=0;
    var triggerRate=\trigrate.kr(20, 1/30, fixedLag:true),
        grainFreq=\grainfreq.kr(1000, 1/30, fixedLag:true),
        overlap=\overlap.kr(30, 1/30, fixedLag:true),
        pmRatio=\phmod.kr(3, 1/30, fixedLag:true),
        pmIndex=\phmodidx.kr(2, 1/30, fixedLag:true),
        amp=\amp.kr(0.1, 1/30, fixedLag:true),
        waveform=\waveform.kr(0, 1/30, fixedLag:true),
        attackTime=\attack.kr(0.03, 1/30, fixedLag:true),  // New parameter for attack time
        releaseTime=\release.kr(0.97, 1/30, fixedLag:true);  // New parameter for release time
    var rampToSlope = { |phase|
        var history = Delay1.ar(phase);
        var delta = (phase - history);
        delta.wrap(-0.5, 0.5);
    };
    var rampToTrig = { |phase|
        var history = Delay1.ar(phase);
        var delta = (phase - history);
        var sum = (phase + history);
        var trig = (delta / sum).abs > 0.5;
        Trig1.ar(trig, SampleDur.ir);
    };
    var getSubSampleOffset = { |phase, trig|
        var slope = rampToSlope.(phase);
        var sampleCount = phase - (slope < 0) / slope;
        Latch.ar(sampleCount, trig);
    };
    var accumulatorSubSample = { |trig, subSampleOffset|
        var accum = Duty.ar(SampleDur.ir, trig, Dseries(0, 1));
        accum + subSampleOffset;
    };
    var stepPhase, stepSlope, stepTrigger, subSampleOffsets, accumulator;
    var windowSlope, windowPhase, maxOverlap;
    var modSlope, modPhase, pmod;
    var grainSlope, grainPhase, grainWindow, sig;
    stepPhase = (Phasor.ar(0, triggerRate * SampleDur.ir) - SampleDur.ir).wrap(0, 1);
    stepTrigger = rampToTrig.(stepPhase);
    stepSlope = rampToSlope.(stepPhase);
    subSampleOffsets = getSubSampleOffset.(stepPhase, stepTrigger);
    accumulator = accumulatorSubSample.(stepTrigger, subSampleOffsets);
    grainSlope = grainFreq * SampleDur.ir;
    grainPhase = (grainSlope * accumulator).wrap(0, 1);
    maxOverlap = grainSlope / Latch.ar(stepSlope, stepTrigger);
    overlap = min(overlap, maxOverlap);
    windowSlope = grainSlope / max(0.001, overlap);
    windowPhase = (windowSlope * accumulator).clip(0, 1);
    modSlope = grainSlope * pmRatio;
    modPhase = (modSlope * accumulator).wrap(0, 1);
    grainWindow = IEnvGen.ar(Env([0, 1, 0], [attackTime, releaseTime], [4.0, -4.0]), windowPhase);  // Updated envelope
    pmod = sin(modPhase * 2pi) * pmIndex;
    pmod = OnePole.ar(pmod, exp(-2pi * modSlope));
    // Multi-waveform oscillator
    sig = SelectX.ar(waveform,
        [
            sin(grainPhase * 2pi + pmod),                            // Sine
            (grainPhase * 2 - 1 + (pmod / pi)).fold(-1, 1),          // Triangle
            ((grainPhase + (pmod / (2pi))) * 2 - 1).sign,            // Square
            (PinkNoise.ar * 2 - 1) * (1 + (pmod.abs / pi)).clip(0, 1), // Noise (amplitude modulated)
            ((grainPhase + (pmod / (2pi))).wrap(0, 1) * 2 - 1)       // Sawtooth
        ]
    );
    sig = sig * grainWindow;
    Out.ar(out, sig ! 2 * amp);
}).writeDefFile(d);
)

(
SynthDef.new(\fm_pulsar, {|out=0, gate=1, dur=10, durScale=1|
    var a,b,c,d,e,f;
    var car, mod, ind;
    var overlap;

    overlap = \overlap.kr(0.2);

    f = \freq.kr(50);
    car = \cf.kr(100);
    mod = car * (\mf.kr(20));
    ind = \ind.kr(1);
    a = GrainFM.ar(
        numChannels: 1,
        trigger: Impulse.ar(f),
        dur: overlap/f,
        modfreq: mod,
        carfreq: car,
        index: ind
    );
    a = Splay.ar(a);
    a = LeakDC.ar(a) * \amp.kr(0.1);
    Out.ar(out,a);
}).play;
)

// Usage example:
// x = Synth(\granularPM);
// x.set(\triggerRate, 30, \grainFreq, 660, \pmIndex, 4);
// x.free;