(
~synthCreator.value("PulseTrain", {|n|
    var rampToSlope, rampToTrig, getSubSampleOffset, accumulatorSubSample;
    var triggerRate, grainFreq, overlap, pmRatio, pmIndex, amp;
    var waveform, attackTime, releaseTime;
    var sig;
    
    // Main parameters
    triggerRate = OceanodeParameterLag.ar(\trigrate, 20, n, 0.1, 1000, "vf", 1/30, true);
    grainFreq = OceanodeParameterLag.ar(\grainfreq, 440, n, 0, 10000, "vf", 1/30, true);
    overlap = OceanodeParameterLag.ar(\overlap, 30, n, 1, 100, "vi", 1/30, true);
    pmRatio = OceanodeParameterLag.ar(\phmod, 3, n, 1, 40, "vf", 1/30, true);
    pmIndex = OceanodeParameterLag.ar(\phmodidx, 2, n, 0, 20, "vi", 1/30, true);
    amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);
    
    // Additional parameters for multi-waveform version
    waveform = OceanodeParameterLag.ar(\waveform, 0, n, 0, 4, "vf", 1/30, true);
    attackTime = OceanodeParameterLag.ar(\attack, 0.03, n, 0, 0.1, "vf", 1/30, true);
    releaseTime = OceanodeParameterLag.ar(\release, 0.97, n, 0, 1, "vf", 1/30, true);
    
    // Helper functions - defined outside the channel loop to avoid redefining them
    rampToSlope = { |phase|
        var history = Delay1.ar(phase);
        var delta = (phase - history);
        delta.wrap(-0.5, 0.5);
    };
    
    rampToTrig = { |phase|
        var history = Delay1.ar(phase);
        var delta = (phase - history);
        var sum = (phase + history);
        var trig = (delta / sum).abs > 0.5;
        Trig1.ar(trig, SampleDur.ir);
    };
    
    getSubSampleOffset = { |phase, trig|
        var slope = rampToSlope.(phase);
        var sampleCount = phase - (slope < 0) / slope;
        Latch.ar(sampleCount, trig);
    };
    
    accumulatorSubSample = { |trig, subSampleOffset|
        var accum = Duty.ar(SampleDur.ir, trig, Dseries(0, 1));
        accum + subSampleOffset;
    };
    
    // Process each channel individually
    sig = n.collect { |i|
        var chan_triggerRate = triggerRate[i];
        var chan_grainFreq = grainFreq[i];
        var chan_overlap = overlap[i];
        var chan_pmRatio = pmRatio[i];
        var chan_pmIndex = pmIndex[i];
        var chan_waveform = waveform[i];
        var chan_attackTime = attackTime[i];
        var chan_releaseTime = releaseTime[i];
        var chan_amp = amp[i];
        
        var stepPhase, stepSlope, stepTrigger, subSampleOffsets, accumulator;
        var windowSlope, windowPhase, maxOverlap;
        var modSlope, modPhase, pmod;
        var grainSlope, grainPhase, grainWindow, chan_sig;
        var noiseSource;
        
        // Generate a unique noise source for this channel
        noiseSource = PinkNoise.ar;
        
        // Pulsar synthesis for this channel
        stepPhase = (Phasor.ar(0, chan_triggerRate * SampleDur.ir) - SampleDur.ir).wrap(0, 1);
        stepTrigger = rampToTrig.(stepPhase);
        stepSlope = rampToSlope.(stepPhase);
        subSampleOffsets = getSubSampleOffset.(stepPhase, stepTrigger);
        accumulator = accumulatorSubSample.(stepTrigger, subSampleOffsets);
        
        grainSlope = chan_grainFreq * SampleDur.ir;
        grainPhase = (grainSlope * accumulator).wrap(0, 1);
        maxOverlap = grainSlope / Latch.ar(stepSlope, stepTrigger);
        chan_overlap = min(chan_overlap, maxOverlap);
        windowSlope = grainSlope / max(0.001, chan_overlap);
        windowPhase = (windowSlope * accumulator).clip(0, 1);
        
        modSlope = grainSlope * chan_pmRatio;
        modPhase = (modSlope * accumulator).wrap(0, 1);
        
        // Custom envelope with adjustable attack/release
        grainWindow = IEnvGen.ar(Env([0, 1, 0], [chan_attackTime, chan_releaseTime], [4.0, -4.0]), windowPhase);
        
        pmod = sin(modPhase * 2pi) * chan_pmIndex;
        pmod = OnePole.ar(pmod, exp(-2pi * modSlope));
        
        // Multi-waveform oscillator
        chan_sig = SelectX.ar(chan_waveform,
            [
                sin(grainPhase * 2pi + pmod),                            // Sine
                (grainPhase * 2 - 1 + (pmod / pi)).fold(-1, 1),          // Triangle
                ((grainPhase + (pmod / (2pi))) * 2 - 1).sign,            // Square
                (noiseSource * 2 - 1) * (1 + (pmod.abs / pi)).clip(0, 1), // Noise (amplitude modulated)
                ((grainPhase + (pmod / (2pi))).wrap(0, 1) * 2 - 1)       // Sawtooth
            ]
        );
        
        chan_sig = chan_sig * grainWindow * chan_amp;
    };
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
    
}, description: "Multi-waveform pulsar train synthesis with envelope control", category: "Source/Pulsar");
)