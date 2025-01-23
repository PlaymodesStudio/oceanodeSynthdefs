(
SynthDef(\vectorsynth13, {
    arg out=0;
    var nearestEven, nearestOdd, vps;
    var freq = \pitch.kr(36!13, 1/30, fixedLag: true).midicps;
    var horizontal = \horizontal.kr(0.3!13, 1/30, fixedLag: true); // 0.001 to 0.99999
    var vertical = \vertical.kr(5.5!13, 1/30, fixedLag: true); // 1 to 10
    var amp = \levels.kr(1!13, 1/30, fixedLag: true);
    var pmIndex = \pmindex.kr(4!13, 1/30, fixedLag: true); // PM index (modulation depth)
    var pmFreq = \pmpitch.kr(48!13, 1/30, fixedLag: true).midicps;  // PM frequency
    var sig;

    nearestEven = {
        arg val;
        var val_floor, val_ceil, res, distance;
        val_floor = val.floor;
        val_ceil = val.ceil;
        res = Select.ar(val % 2,
            [ val_floor, val_ceil ],
        );
        distance = (val - res).abs;
        [ res, distance ];
    };
    nearestOdd = {
        arg val;
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

    sig = vps.(0, freq, horizontal, K2A.ar(vertical), pmIndex, pmFreq);
    Out.ar(out, sig * amp);
}).writeDefFile(d); // Note: changed .play() to .add()
)

(
SynthDef(\vectorsynth13b, {
    arg out=0;

    // Original control parameters
    var freq, skew, harm, amp, fbAmt, pmFreq, pmIndex, evenOdd;
    // New control parameters for features
    var useAntiAlias, useFormants, useInterpolation;
    // Signal processing variables
    var transferFunc, sig, fbSig;
    var phase, harm_even, harm_odd, pmod, sig_even, sig_odd, sig_orig;
    var phaseModulation;
    // Antialiasing variables
    var modPhase, b, c, suppressedSig;
    // Formant variables
    var formantRatio, formantFreq, formantPhase, sig1, sig2;
    // Interpolation variables
    var interpGain;

    // Original parameters
    freq = \pitch.kr(36!13, 1/30, fixedLag: true).midicps;
    skew = \skew.kr(0.5!13, 1/30, fixedLag: true);
    harm = \harm.kr(1.0!13, 1/30, fixedLag: true);
    amp = \levels.kr(0.5!13, 1/30, fixedLag: true);
    fbAmt = \feedback.kr(0!13, 1/30, fixedLag: true);
    pmFreq = \pmpitch.kr(48!13, 1/30, fixedLag: true).midicps;
    pmIndex = \pmindex.kr(0!13, 1/30, fixedLag: true);
    evenOdd = \evenodd.kr(0!13, 1/30, fixedLag: true);

    // New feature toggles (0 = off, 1 = on)
    useAntiAlias = \antialias.kr(1!13, 1/30, fixedLag: true);
    useFormants = \formants.kr(0!13, 1/30, fixedLag: true);
    useInterpolation = \interpolation.kr(0!13, 1/30, fixedLag: true);

    fbSig = LocalIn.ar(13);

    transferFunc = { |phase, skew|
        Select.ar(phase > skew, [
            phase / skew,
            1 - ((phase - skew) / (1 - skew))
        ]);
    };

    // Phase calculation with feedback and PM
    phaseModulation = SinOsc.ar(pmFreq) * pmIndex;
    phase = Phasor.ar(DC.ar(0), freq * SampleDur.ir) + (fbSig * fbAmt * 2pi) + phaseModulation;

    // Formant processing (when enabled)
    // From paper: ff/f0 = 2v - 1, where v >= 1.5
    formantRatio = (2 * (harm + 1.5) - 1); // Adding 1.5 to ensure v >= 1.5
    formantFreq = freq * formantRatio;
    formantPhase = Phasor.ar(DC.ar(0), formantFreq * SampleDur.ir);

    harm_even = harm.round(2);
    harm_odd = harm.round(2) - 1;

    pmod = transferFunc.(phase, skew);

    // Generate base signals
    sig_even = cos(phase + (pmod * (harm_even - skew)) * 2pi).neg;
    sig_odd = cos(phase + (pmod * (harm_odd - skew)) * 2pi).neg;
    sig_orig = cos(phase + (pmod * (harm - skew)) * 2pi).neg;

    // Basic signal selection
    sig = SelectX.ar(
        evenOdd.linlin(-1, 1, 0, 2),
        [sig_even, sig_orig, sig_odd]
    );

    // Antialiasing processing
    b = harm % 1;
    c = cos(2pi * b);
    suppressedSig = Select.ar(
        b <= 0.5,
        [
            (sig * (1 - c) - (1 - c)) * 0.5,
            (sig * (1 + c) + (1 - c)) * 0.5
        ]
    );

    // Apply antialiasing when enabled
    sig = SelectX.ar(
        useAntiAlias * (pmod > harm),
        [sig, suppressedSig]
    );

    // Formant processing
    sig1 = sig;
    // Generate formant signal with strong emphasis on formant frequency
    sig2 = cos(formantPhase * 2pi).neg *
           SinOsc.ar(freq) *  // Carrier
           (1 + cos(phase * formantRatio)); // Modulator

    interpGain = (formantRatio % 1);

    // Mix original and formant signals based on useFormants
    sig = SelectX.ar(
        useFormants,
        [
            sig1, // Original signal
            SelectX.ar(
                useInterpolation,
                [
                    sig2, // Pure formant signal
                    (1 - interpGain) * sig1 + (interpGain * sig2) // Interpolated
                ]
            )
        ]
    );

    // Final processing
    sig = LeakDC.ar(sig);
    LocalOut.ar(sig);

    Out.ar(out, sig * amp);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
