~synthCreator.value("Wavelet", {|n|
    var sig, shape, duration, trigger;
    var phase, wavelet, running;
    var minVal, maxVal, triggerPulse;
    var skew, pow, invert, quant, level;

    // Morphable LFO functions
    var getTriangle = { |phase, skew|
        phase = phase.linlin(0, 1, skew.neg, 1 - skew);
        phase.bilin(0, skew.neg, 1 - skew, 1, 0, 0);
    };
    var getSine = { |phase|
        1 - cos(phase * pi) / 2;
    };
    var getTrapezoid = { |phase, duty, shape, skew|
        var offset = phase - (1 - duty);
        var steepness = 1 / (1 - shape);
        var trapezoid = (offset * steepness + (1 - duty)).clip(0, 1);
        var pulse = offset > 0;
        Select.ar((shape |==| 1).asInteger, [trapezoid, pulse]);
    };
    var getMultiLFO = { |phase, skew, shape|
        var triangle = getTriangle.(phase, skew);
        var trapezoidShape = shape.linlin(0, 1, 0, 1);  // Map shape to trapezoid internal shape
        var lfoMix = shape.linlin(0, 1, 0, 1);  // Map shape to sine mix amount
        var trapezoid = getTrapezoid.(triangle, 1.0, trapezoidShape);  // Always use full width (1.0)
        var sine = getSine.(trapezoid);
        trapezoid * (1 - lfoMix) + (sine * lfoMix);
    };

    // Parameters
    trigger = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    duration = OceanodeParameterLag.ar(\duration, 50, n, 1, 200, "vf", 1/30, true);  // Duration in ms
    shape = OceanodeParameterLag.ar(\shape, 0.5, n, 0, 1, "vf", 1/30, true);         // 0: triangle, 0.5: mixed, 1: sine
    skew = OceanodeParameterLag.ar(\skew, 0.5, n, 0, 1, "vf", 1/30, true);           // Asymmetry control
    pow = OceanodeParameterLag.ar(\pow, 1, n, 0.1, 4, "vf", 1/30, true);             // Power shaping
    invert = OceanodeParameterLag.ar(\invert, 0, n, 0, 1, "vf", 1/30, true);         // Inversion
    quant = OceanodeParameter.ar(\quant, 0, n, 0, 64, "vi");                         // Quantization
    level = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true);          // Amplitude
    minVal = OceanodeParameterLag.ar(\min, 0, n, -1, 1, "vf", 1/30, true);          // Minimum value
    maxVal = OceanodeParameterLag.ar(\max, 1, n, -1, 1, "vf", 1/30, true);          // Maximum value

    // Convert duration from ms to seconds
    duration = duration * 0.001;

    // Create a trigger pulse from level changes (0->1) at audio rate
    triggerPulse = Trig.ar(trigger, 0.001);

    // Create a ramp that goes from 0 to 1 over the duration
    phase = Sweep.ar(triggerPulse, 1/duration);

    // Detect when we're in an active cycle
    running = (phase < 1);

    // Latch the running state at audio rate
    running = Latch.ar(running, running);

    // Apply the latch to the phase - keep it at 1 when cycle is complete
    phase = phase.clip(0, 1);

    // Generate morphable wavelet using our LFO functions
    wavelet = getMultiLFO.(phase, skew, shape);

    // Apply power transformation
    wavelet = wavelet.pow(pow);

    // Apply quantization
    wavelet = Select.ar(quant > 1, [
        wavelet,
        (wavelet * (quant - 1)).round / (quant - 1)
    ]);

    // Apply inversion
    wavelet = (wavelet * (1 - invert)) + ((1 - wavelet) * invert);

    // Gate the wavelet so it only outputs during the ramp
    wavelet = wavelet * running;

    // Apply level control with natural curve
    sig = wavelet * level;

    // Scale normalized signal (0-1) to the requested min-max range
    sig = sig.linlin(0, 1, minVal, maxVal);

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Enhanced wavelet generator with morphable shape (triangle/sine/square), skew for asymmetry, power shaping, inversion, quantization, and amplitude range control", category: "Source/Pulsar");