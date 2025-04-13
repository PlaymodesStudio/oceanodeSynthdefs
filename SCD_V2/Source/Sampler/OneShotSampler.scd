(
~synthCreator.value("OneShotSampler", {|n|
    var t, signal, spd, buf, start, gain;
    var env, envgen, attack, decay, sustain, release, curve,trigAmp;

    // Controls
    t = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vf");
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

    // Latch the trigger amplitude value
     trigAmp = Latch.ar(t, t);

    // Create and apply envelope
    env = Env.adsr(attack, decay, sustain, release, 1, curve);
    envgen = EnvGen.kr(env, t) * trigAmp;

    // Play the sample with envelope
    signal = PlayBuf.ar(1, buf, spd, t, start, 0) * envgen * gain;

    Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "One-shot sampler with ADSR envelope", category: "Source/Sampler");
)