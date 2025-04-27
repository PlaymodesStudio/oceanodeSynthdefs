(
~synthCreator.value("OneShotSampler", {|n|
    var t, signal, spd, buf, start, gain;
    var env, attack, decay, sustain, release, curve;

    // Controls
    t = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    buf = OceanodeBuffer.kr(\bufnum);
    spd = OceanodeParameterLag.ar(\pitch, 0, n, -24, 24, "vf", 1/30, true).midiratio;
    start = OceanodeParameter.ar(\startpos, 0, n, 0, 1, "vf") * BufFrames.kr(buf);

    // ADSR envelope controls
    attack = OceanodeParameterLag.ar(\attack, 0.01, n, 0, 3, "vf", 1/30, true);
    decay = OceanodeParameterLag.ar(\decay, 0.1, n, 0, 3, "vf", 1/30, true);
    sustain = OceanodeParameterLag.ar(\sustain, 0.5, n, 0, 1, "vf", 1/30, true);
    release = OceanodeParameterLag.ar(\release, 0.5, n, 0.001, 5, "vf", 1/30, true);
    curve = OceanodeParameterLag.ar(\curve, -4, n, -8, 8, "vf", 1/30, true);

    // Process each channel individually for reliable trigger handling
    signal = Array.fill(n, {|chan|
        var snd, trig, envgen;

        // Convert any positive value to a trigger
        trig = Trig.ar(t[chan] > 0, 0.001);

        // Create envelope
        env = Env.adsr(attack[chan], decay[chan], sustain[chan], release[chan], 1, curve[chan]);

        // Apply envelope
        envgen = EnvGen.ar(env, trig);

        // Play the sample
        snd = PlayBuf.ar(
            numChannels: 1,
            bufnum: buf,
            rate: BufRateScale.kr(buf) * spd[chan],
            trigger: trig,
            startPos: start[chan],
            loop: 0,
            doneAction: 0
        );

        // Apply envelope and gain
        snd = snd * envgen * gain[chan];

        // DC filtering and limiting for cleaner output
        snd = LeakDC.ar(snd);
        snd = Limiter.ar(snd, 0.99);
    });

    // Output
    Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "One-shot sampler with ADSR envelope", category: "Source/Sampler");
)