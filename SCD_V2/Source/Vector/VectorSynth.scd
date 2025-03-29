(
~synthCreator.value("VectorSynth", {|n|
    var nearestEven, nearestOdd, vps;
    var freq, horizontal, vertical, amp, pmIndex, pmFreq, sig;
    
    // Main parameters
    freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true).midicps;
    horizontal = OceanodeParameterLag.ar(\horizontal, 0.3, n, 0.001, 0.999, "vf", 1/30, true);
    vertical = OceanodeParameterLag.ar(\vertical, 5.5, n, 1, 10, "vf", 1/30, true);
    amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    pmIndex = OceanodeParameterLag.ar(\pmindex, 4, n, 0, 16, "vf", 1/30, true);
    pmFreq = OceanodeParameterLag.ar(\pmpitch, 48, n, 12, 130, "vf", 1/30, true).midicps;
    
    // Helper functions
    nearestEven = { |val|
        var val_floor, val_ceil, res, distance;
        val_floor = val.floor;
        val_ceil = val.ceil;
        res = Select.ar(val % 2,
            [ val_floor, val_ceil ],
        );
        distance = (val - res).abs;
        [ res, distance ];
    };
    
    nearestOdd = { |val|
        var val_floor, val_ceil, res, distance;
        val_floor = val.floor;
        val_ceil = val.ceil;
        res = Select.ar(val + 1 % 2,
            [ val_floor, val_ceil ],
        );
        distance = (val - res).abs;
        [ res, distance ];
    };
    
    vps = { |trig, freq, horizontal, vertical, pmIndex, pmFreq|
        var vertical_even = nearestEven.(vertical);
        var vertical_odd = nearestOdd.(vertical);
        var cos, phasor, sig, phaseModulation;
        vertical = [vertical_even[0], vertical_odd[0]];
        phasor = Phasor.ar(Impulse.ar(trig), freq/2 * SampleDur.ir, horizontal.neg, 1-horizontal, horizontal.neg);
        phasor = phasor.bilin(0, horizontal.neg, 1-horizontal, vertical, 0, 1);

        // Phase modulation
        phaseModulation = SinOsc.ar(pmFreq) * pmIndex;
        cos = ((phasor + phaseModulation) * 2pi).cos.neg;

        sig = XFade2.ar(cos[0], cos[1], vertical_even[1] * 2 - 1);
        sig = LeakDC.ar(sig);
        sig;
    };
    
    // Generate the vector synthesis signal
    sig = vps.(0, freq, horizontal, K2A.ar(vertical), pmIndex, pmFreq);
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sig * amp);
    
}, description: "Vector synthesis oscillator with phase modulation", category: "Source/Vector");
)