(
~synthCreator.value("JPReverb", {|n|
    var source, sig;
    var revtime, damp, size, early, low, mid, high, lowcut, highcut, modDepth, modFreq, mx;

    // Control parameters
    revtime = OceanodeParameterLag.ar(\time, 1, n, 0.1, 60, "vf", 1/30, true);
    damp = OceanodeParameterLag.ar(\damp, 0, n, 0, 1, "vf", 1/30, true);
    size = OceanodeParameterLag.ar(\size, 1, n, 0.5, 5, "vf", 1/30, true);
    early = OceanodeParameterLag.ar(\early, 0.7, n, 0, 1, "vf", 1/30, true);
    low = OceanodeParameterLag.ar(\lowtime, 1, n, 0.1, 10, "vf", 1/30, true);
    mid = OceanodeParameterLag.ar(\midtime, 1, n, 0.1, 10, "vf", 1/30, true);
    high = OceanodeParameterLag.ar(\hitime, 1, n, 0.1, 10, "vf", 1/30, true);
    lowcut = OceanodeParameterLag.ar(\lowcut, 200, n, 20, 10000, "vf", 1/30, true);
    highcut = OceanodeParameterLag.ar(\hicut, 5000, n, 1000, 20000, "vf", 1/30, true);
    modDepth = OceanodeParameterLag.ar(\moddepth, 0.1, n, 0, 1, "vf", 1/30, true);
    modFreq = OceanodeParameterLag.ar(\modfreq, 2, n, 0.1, 10, "vf", 1/30, true);
    mx = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 1/30, true);

    // Input signal
    source = In.ar(OceanodeInput.kr(\in), n);

    // Apply JPverb
    sig = JPverb.ar(
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

    // Mix dry and wet signals with dry/wet control
    sig = XFade2.ar(source, sig, mx * 2 - 1);

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "High quality reverb based on the JP algorithm", category: "Effect/Time/Reverb");
)
