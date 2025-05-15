(
~synthCreator.value("OneShotSampler", {|n|
    var t, k_trig, trigEdge, signal, spd, buf, start, gain, latchSpd;
    var env, attack, decay, sustain, release, curve;
    var latchedBuf, latchedStart, latchedSpd, finalSpd;

    // Controls
    t = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    trigEdge = Trig.kr(A2K.kr(t), 0.001);  // Edge detector for latching

    gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    buf = OceanodeBuffer.kr(\bufnum);
    spd = OceanodeParameterLag.ar(\pitch, 0, n, -24, 24, "vf", 1/30, true).midiratio;
    latchSpd = OceanodeParameter.kr(\latchspeed, 1, n, 0, 1, "vi"); // 0=false, 1=true
    start = OceanodeParameter.ar(\startpos, 0, n, 0, 1, "vf") * BufFrames.kr(buf);

    // ADSR envelope controls
    attack = OceanodeParameterLag.ar(\attack, 0.01, n, 0, 3, "vf", 1/30, true);
    decay = OceanodeParameterLag.ar(\decay, 0.1, n, 0, 3, "vf", 1/30, true);
    sustain = OceanodeParameterLag.ar(\sustain, 0.5, n, 0, 1, "vf", 1/30, true);
    release = OceanodeParameterLag.ar(\release, 0.5, n, 0.001, 5, "vf", 1/30, true);
    curve = OceanodeParameterLag.ar(\curve, -4, n, -8, 8, "vf", 1/30, true);

    // Latch values (only updates on the 0→1 edge)
    latchedBuf = Latch.kr(buf, trigEdge);
    latchedSpd = Latch.kr(spd, trigEdge);
    latchedStart = Latch.kr(start, trigEdge);

    // Decide whether to use latched speed or current speed
    finalSpd = Select.kr(latchSpd, [spd, latchedSpd]);

    // Process each channel individually for reliable trigger handling
    signal = Array.fill(n, {|chan|
        var snd, gate, envgen;

        // Use the trigger directly as a gate for the envelope
        // This ensures it stays open as long as the trigger is high
        gate = t[chan];

        // Create envelope using gate instead of trigger
        env = Env.adsr(attack[chan], decay[chan], sustain[chan], release[chan], 1, curve[chan]);

        // Apply envelope with gate signal
        envgen = EnvGen.ar(env, gate);

        // Play the sample with latched parameters
        snd = PlayBuf.ar(
            numChannels: 1,
            bufnum: latchedBuf,
            rate: BufRateScale.kr(latchedBuf) * finalSpd[chan],
            trigger: trigEdge[chan],  // Use edge for triggering sample
            startPos: latchedStart[chan],
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

}, description: "One-shot sampler with ADSR envelope and latching", category: "Source/Sampler");
)