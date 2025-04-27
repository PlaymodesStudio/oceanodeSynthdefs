(
~synthCreator.value("GatedReverb", {|n|
    var source, wet, sig, env, envFollow, trig;
    var predelay, revtime, damp, size, early, low, mid, high;
    var lowcut, highcut, modDepth, modFreq, mx;
    var thresh, attack, hold, release, gateMonitor;
    var autoTrig, manualTrig, inputGain;

    // Input signal
    source = In.ar(OceanodeInput.kr(\in), n);

    // Input gain for better control
    inputGain = OceanodeParameterLag.ar(\g_inputgain, 1, n, 0, 4, "vf", 1/30, true);
    source = source * inputGain;

    // Gate control parameters
    thresh = OceanodeParameterLag.ar(\g_threshold, 0.1, n, 0.001, 1, "vf", 1/30, true);
    attack = OceanodeParameterLag.ar(\g_attack, 0.001, n, 0.001, 0.5, "vf", 1/30, true);
    hold = OceanodeParameterLag.ar(\g_hold, 0.2, n, 0.01, 2, "vf", 1/30, true);
    release = OceanodeParameterLag.ar(\g_release, 0.1, n, 0.01, 1, "vf", 1/30, true);
    autoTrig = OceanodeParameter.kr(\g_autotrig, 1, n, 0, 1, "vi");
    manualTrig = OceanodeParameter.kr(\g_manualtrig, 0, n, 0, 1, "vi");

    // Reverb parameters
    predelay = OceanodeParameterLag.ar(\predelay, 0.02, n, 0, 0.2, "vf", 1/30, true);
    revtime = OceanodeParameterLag.ar(\time, 3, n, 0.1, 60, "vf", 1/30, true);
    damp = OceanodeParameterLag.ar(\damp, 0.2, n, 0, 1, "vf", 1/30, true);
    size = OceanodeParameterLag.ar(\size, 1, n, 0.5, 5, "vf", 1/30, true);
    early = OceanodeParameterLag.ar(\early, 0.7, n, 0, 1, "vf", 1/30, true);
    low = OceanodeParameterLag.ar(\lowtime, 1, n, 0.1, 10, "vf", 1/30, true);
    mid = OceanodeParameterLag.ar(\midtime, 1, n, 0.1, 10, "vf", 1/30, true);
    high = OceanodeParameterLag.ar(\hitime, 1, n, 0.1, 10, "vf", 1/30, true);
    lowcut = OceanodeParameterLag.ar(\lowcut, 300, n, 20, 10000, "vf", 1/30, true);
    highcut = OceanodeParameterLag.ar(\hicut, 8000, n, 1000, 20000, "vf", 1/30, true);
    modDepth = OceanodeParameterLag.ar(\moddepth, 0.1, n, 0, 1, "vf", 1/30, true);
    modFreq = OceanodeParameterLag.ar(\modfreq, 2, n, 0.1, 10, "vf", 1/30, true);
    mx = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

    // Improved envelope follower for auto-triggering
    envFollow = Amplitude.ar(source, 0.001, 0.05);

    // Better trigger logic
    trig = Select.ar(
        autoTrig > 0,
        [
            K2A.ar(manualTrig),                           // Manual trigger only
            (envFollow > thresh) + K2A.ar(manualTrig > 0) // Auto + manual trigger
        ]
    );

    // Use Trig1 to ensure consistent trigger behavior
    trig = Trig1.ar(trig, 0.001);

    // Generate gate envelope with adjusted curve
    env = EnvGen.ar(
        Env.new(
            [0, 1, 1, 0],       // levels
            [attack, hold, release], // times
            [2, 0, -4]          // curves: fast attack, linear hold, exponential release
        ),
        trig,
        doneAction: 0
    );

    // Apply predelay to the source
    source = DelayN.ar(source, 0.2, predelay);

    // Apply JPverb with adjusted settings for gated reverb character
    wet = JPverb.ar(
        source,
        revtime,
        damp,
        size,
        early,
        modDepth,
        modFreq,
        low,
        mid,
        high,
        lowcut,
        highcut
    );

    // Apply the gate to the reverb signal
    wet = wet * env;

    // Attenuate the dry source to preserve the original input gain
    source = source / inputGain;

    // Mix dry and wet signals with dry/wet control
    sig = XFade2.ar(source, wet, mx * 2 - 1);

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Gated reverb effect inspired by Phil Collins", category: "Effect/Time/Reverb");
)