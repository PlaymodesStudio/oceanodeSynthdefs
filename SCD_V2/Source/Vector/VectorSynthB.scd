(
~synthCreator.value("VectorSynthB", {|n|
    // Original control parameters
    var freq, skew, harm, amp, fbAmt, pmFreq, pmIndex, evenOdd;
    // New control parameters for features
    var useAntiAlias, useFormants, useInterpolation;
    // Signal processing variables
    var transferFunc, sig;
    var phase, harm_even, harm_odd, pmod, sig_even, sig_odd, sig_orig;
    var phaseModulation;
    // Antialiasing variables
    var b, c, suppressedSig;
    // Formant variables
    var formantRatio, formantFreq, formantPhase, sig1, sig2;
    // Interpolation variables
    var interpGain;
    // Feedback setup
    var fbSig;

    // Original parameters
    freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true).midicps;
    skew = OceanodeParameterLag.ar(\skew, 0.5, n, 0.001, 0.999, "vf", 1/30, true);
    harm = OceanodeParameterLag.ar(\harm, 1.0, n, 0, 1, "vf", 1/30, true);
    fbAmt = OceanodeParameterLag.ar(\feedback, 0.02, n, 0, 0.3, "vf", 1/30, true);
    pmFreq = OceanodeParameterLag.ar(\pmpitch, 48, n, 0, 127, "vf", 1/30, true).midicps;
    pmIndex = OceanodeParameterLag.ar(\pmindex, 0, n, 0, 10, "vf", 1/30, true);
    evenOdd = OceanodeParameterLag.ar(\evenodd, 0, n, -1, 1, "vf", 1/30, true);

    // New feature toggles (0 = off, 1 = on)
    useAntiAlias = OceanodeParameterLag.ar(\antialias, 1, n, 0, 1, "vf", 1/30, true);
    useFormants = OceanodeParameterLag.ar(\formants, 0, n, 0, 1, "vf", 1/30, true);
    useInterpolation = OceanodeParameterLag.ar(\interpolation, 0, n, 0, 1, "vf", 1/30, true);

    // Output level with proper curve for better control
    amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

    // Setup feedback - using array of proper size
    fbSig = LocalIn.ar(n);

    // Transfer function for the vector synthesis algorithm
    transferFunc = { |phaseIn, skewIn|
        Select.ar(phaseIn > skewIn, [
            phaseIn / skewIn,
            1 - ((phaseIn - skewIn) / (1 - skewIn))
        ]);
    };

    // Phase modulation
    phaseModulation = SinOsc.ar(pmFreq) * pmIndex;

    // Phase calculation with feedback and PM
    phase = Phasor.ar(0, freq * SampleDur.ir) + (fbSig * fbAmt * 2pi) + phaseModulation;

    // Calculate harmonics components
    harm_even = harm.round(2);
    harm_odd = harm.round(2) - 1;

    // Formant processing (when enabled)
    formantRatio = (2 * (harm + 1.5) - 1); // Ensure ratio >= 1.5
    formantFreq = freq * formantRatio;
    formantPhase = Phasor.ar(0, formantFreq * SampleDur.ir);

    // Process through transfer function
    pmod = transferFunc.(phase, skew);

    // Generate base signals with different harmonic content
    sig_even = cos(phase + (pmod * (harm_even - skew)) * 2pi).neg;
    sig_odd = cos(phase + (pmod * (harm_odd - skew)) * 2pi).neg;
    sig_orig = cos(phase + (pmod * (harm - skew)) * 2pi).neg;

    // Blend between even/odd harmonics based on evenOdd parameter
    sig = SelectX.ar(
        evenOdd.linlin(-1, 1, 0, 2),
        [sig_even, sig_orig, sig_odd]
    );

    // Antialiasing processing
    b = harm % 1;
    c = cos(2pi * b);

    // Suppress aliasing artifacts when enabled
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

    // Preserve original signal for formant processing
    sig1 = sig;

    // Generate formant signal with strong emphasis on formant frequency
    sig2 = cos(formantPhase * 2pi).neg *
        SinOsc.ar(freq) *  // Carrier
        (1 + cos(phase * formantRatio)); // Modulator

    // Interpolation gain between original and formant signals
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

    // Apply DC blocking
    sig = LeakDC.ar(sig);

    // Feedback for the next cycle
    LocalOut.ar(sig);

    // Output the final signal
    Out.ar(OceanodeOutput.kr(\out), sig * amp);

}, description: "Advanced vector synthesis with formants and antialiasing", category: "Source/Vector");
)