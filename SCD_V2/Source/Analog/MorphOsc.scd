(
~synthCreator.value("MorphOSC", {|n|
    var signals, hz, pow, amp, phaseoffset, phasereset, phase;
    var skew, pw, shape, lfo, min, max, invert, quant;
    var getTriangle, getSine, getTrapezoid, getMultiLFO,lev;

    // Define LFO functions (improved version from Tremolo)
    getTriangle = { |phase, skew|
        skew = skew.clip(0.00001, 0.99999);
        phase = phase.linlin(0, 1, skew.neg, 1 - skew);
        phase.bilin(0, skew.neg, 1 - skew, 1, 0, 0);
    };

    getSine = { |phase|
        1 - cos(phase * pi) / 2;
    };

    getTrapezoid = { |phase, shape|
        var steepness = 1 / (1 - shape);
        var trapezoid = (phase * steepness).clip(0, 1);
        var pulse = phase > 0;
        Select.ar(K2A.ar((shape |==| 1).asInteger), [trapezoid, pulse]);
    };

    getMultiLFO = { |phase, skew, shape, pw|
        var effectivePw, scaledPhase, triangle, sine, blend, sineToTriangle, trapShape, triangleToTrap;

        // Adjust pulse width based on shape: as shape increases beyond 0.5, reduce effective pw
        effectivePw = pw * (
            (shape <= 0.5) +  // When shape <= 0.5: multiply by 1 (no change)
            ((shape > 0.5) * LinLin.ar(shape, 0.5, 1, 1, 0.5))  // When shape > 0.5: reduce proportionally
        );

        scaledPhase = LinLin.ar(phase, 0, 1, 0, 1/effectivePw).clip(0, 1);
        triangle = getTriangle.(scaledPhase, skew);
        sine = getSine.(triangle);
        blend = shape * 2;
        sineToTriangle = sine * (1 - blend.clip(0, 1)) + (triangle * blend.clip(0, 1));
        trapShape = (blend - 1).clip(0, 1);
        triangleToTrap = getTrapezoid.(triangle, trapShape);

        Select.ar(K2A.ar((blend < 1).asInteger), [triangleToTrap, sineToTriangle]);
    };

    // Parameters
    hz = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
    pow = OceanodeParameterLag.ar(\pow, 1, n, 0.1, 4, "vf", 1/30, true);
    phaseoffset = OceanodeParameterLag.ar(\offset, 0, n, 0, 1, "vf", 1/30, true);
    phasereset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
    skew = OceanodeParameterLag.ar(\skew, 0.5, n, 0, 1, "vf", 1/30, true);
    pw = OceanodeParameterLag.ar(\pw, 1, n, 0.01, 1, "vf", 1/30, true);
    shape = OceanodeParameterLag.ar(\shape, 0.5, n, 0, 1, "vf", 1/30, true) * 0.999;
    quant = OceanodeParameter.ar(\quant, 0, n, 0, 64, "vi");
	lev=OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

    // Phase calculation with reset capability
    phase = Phasor.ar(phasereset > 0.5, hz * SampleDur.ir, 0, 1) + phaseoffset;
    phase = phase.wrap(0, 1);

    // Generate morphable LFO
    lfo = getMultiLFO.(phase, skew, shape, pw);

    // Apply power shaping
    lfo = lfo.pow(pow);

    // Apply quantization
    lfo = Select.ar(K2A.ar(quant > 1), [
        lfo,
        (lfo * (quant - 1)).round / (quant - 1)
    ]);

    // Output
    Out.ar(OceanodeOutput.kr(\out), lfo*lev);
}, description: "Morphable Oscillator with improved pulse width control shape morphing skew power shaping quantization phase offset reset", category: "Source/Analog");
)