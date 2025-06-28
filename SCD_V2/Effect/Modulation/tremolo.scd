(
~synthCreator.value("Tremolo", {|n|
    var signals, dry, trem, lfo, phase;
    var hz, amp, pow, mix, phaseoffset, phasereset, skew, shape, pw, invert;
    var getTriangle, getSine, getTrapezoid, getMultiLFO;

    // Define LFO functions
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
    hz = OceanodeParameterLag.ar(\hz, 5, n, 0, 20, "vf", 1/30, true);
    amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);
    pow = OceanodeParameterLag.ar(\pow, 1, n, 0.1, 4, "vf", 1/30, true);
    mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);
    phaseoffset = OceanodeParameterLag.ar(\offset, 0, n, 0, 1, "vf", 1/30, true);
    phasereset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");
    skew = OceanodeParameterLag.ar(\skew, 0.5, n, 0, 1, "vf", 1/30, true);
    shape = OceanodeParameterLag.ar(\shape, 0.5, n, 0, 1, "vf", 1/30, true) * 0.99999;
    pw = OceanodeParameterLag.ar(\pw, 1, n, 0.01, 1, "vf", 1/30, true);
    invert = OceanodeParameterLag.ar(\invert, 0, n, 0, 1, "vf", 1/30, true);

    // Input stage
    signals = In.ar(OceanodeInput.kr(\in), n);
    dry = signals;

    // Phase calculation
    phase = Phasor.ar(phasereset > 0.5, hz * SampleDur.ir, 0, 1) + phaseoffset;
    phase = phase.wrap(0, 1);

    // Generate LFO
    lfo = getMultiLFO.(phase, skew, shape, pw);

    // Apply inversion: blend between normal LFO and inverted LFO
    lfo = lfo * (1 - invert) + ((1 - lfo) * invert);

    // Apply tremolo effect
    trem = lfo.pow(pow) * amp;
    signals = signals * trem;

    // Mix dry and wet signals
    signals = XFade2.ar(dry, signals, mix * 2 - 1);

    // Output
    Out.ar(OceanodeOutput.kr(\out), signals);
}, description: "Tremolo effect with morphable LFO featuring pulse width control", category: "Effect/Modulation");
)