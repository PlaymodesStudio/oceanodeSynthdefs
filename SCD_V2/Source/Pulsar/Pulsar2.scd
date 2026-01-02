(
~synthCreator.value("Pulsar2", {|n|
    var freq, grainFreq, overlap, index, skew, lfoFreq, lfoAmount, level;
    var trig, phase, windowPhase, rectWindow, mod, sig;
    var measurePhase, measureSlope, accumulator, lfoPhase, transferFunc, lfo;
    
    // Main parameters
    freq = OceanodeParameterLag.ar(\pitch, 36, n, 12, 130, "vf", 1/30, true).midicps;
    grainFreq = OceanodeParameterLag.ar(\grainfreq, 10, n, 0, 10000, "vf", 1/30, true);
    overlap = OceanodeParameter.ar(\overlap, 4, n, 1, 100, "vi");
    index = OceanodeParameterLag.ar(\index, 4, n, 1, 40, "vf", 1/30, true);
    skew = OceanodeParameterLag.ar(\skew, 0, n, 0, 1, "vf", 1/30, true);
    lfoFreq = OceanodeParameterLag.ar(\lfofreq, 1, n, 0.1, 10, "vf", 1/30, true);
    lfoAmount = OceanodeParameterLag.ar(\lfoamp, 1, n, 0, 8, "vf", 1/30, true);
    level = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
    
    // Main phase and slope
    measurePhase = (Phasor.ar(0, freq * SampleDur.ir) - SampleDur.ir).wrap(0, 1);
    measureSlope = (measurePhase - Delay1.ar(measurePhase)).wrap(-0.5, 0.5);
    
    // Accumulator for LFO
    accumulator = Duty.ar(SampleDur.ir, 0, Dseries(0, 1));
    lfoPhase = (measureSlope / lfoFreq * accumulator).wrap(0, 1);
    lfo = sin(lfoPhase * 2pi);
    
    // Pulsar synthesis
    trig = Impulse.ar(freq * (1 + (lfo * lfoAmount)));
    phase = Sweep.ar(trig, grainFreq);
    windowPhase = phase / overlap;
    rectWindow = windowPhase < 1;
    
    // Phase shaping function
    transferFunc = { |ph, sk|
        ph = ph.linlin(0, 1, sk.neg, 1 - sk);
        ph.bilin(0, sk.neg, 1 - sk, 0.5, 0, 1);
    };
    
    mod = cos(transferFunc.(windowPhase, skew) * 2pi).neg * 0.5 + 0.5;
    sig = SinOsc.ar(phase + (mod * (0.5 - skew) * index * overlap) * 2pi);
    sig = sig * rectWindow * level;
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
    
}, description: "Advanced pulsar synthesis with LFO modulation", category: "Source/Pulsar");
)