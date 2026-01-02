(
~synthCreator.value("SamplerStretch", {|n|
    var signal, spd, buf, buf2, gain, pos, reverse;
    var windowSize, overlaps, windowRandRatio, interp;

    // Controls
    gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);
    buf = OceanodeParameter.kr(\bufnum, 0, n, 0, 1000, "vi");
    buf2 = OceanodeBuffer.kr(\envbuf);
    spd = OceanodeParameterLag.ar(\pitch, 0, n, -24, 24, "vf", 1/30, true).midiratio;
    pos = OceanodeParameterLag.ar(\position, 0, n, 0, 1, "vf", 1/30, true);
    reverse = OceanodeParameter.kr(\reverse, 0, n, 0, 1, "vi");

    // Additional controls
    windowSize = OceanodeParameterLag.ar(\windowsize, 0.2, n, 0.01, 1, "vf", 1/30, true);
    overlaps = OceanodeParameter.kr(\overlaps, 8, n, 1, 16, "vi");
    windowRandRatio = OceanodeParameterLag.ar(\windowrand, 0, n, 0, 1, "vf", 1/30, true);
    interp = OceanodeParameterDropdown.kr(\interpolation, 2, n, "None:Linear:Cubic:Cubic Spline");

    // Calculate final freqScale, applying reverse if needed
    spd = spd * (1 - (2 * reverse)); // This will be -spd when reverse=1, and spd when reverse=0

    signal = Warp1.ar(
        numChannels: 1,
        bufnum: buf,
        pointer: pos,
        freqScale: spd,
        windowSize: windowSize,
        envbufnum: buf2,
        overlaps: overlaps,
        windowRandRatio: windowRandRatio,
        interp: interp
    ) * gain;

    Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Time-stretching sampler with granular capabilities", category: "Source/Sampler");
)
