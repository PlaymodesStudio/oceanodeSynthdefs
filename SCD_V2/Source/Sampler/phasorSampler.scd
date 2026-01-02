(
~synthCreator.value("PhasorSampler", {|n|
    var ph;
    var buf, startPos, endPos, gain;
    var frames, startF, endF, lenF, posF;
    var interp, sig;

    // 1) Use same input style as startPos since that works
    ph = OceanodeParameterLag.ar(\ph, 0, n, 0, 1, "vf", 0, false);  // no lag for phase

    // 2) Buffer per voice
    buf = OceanodeParameter.kr(\bufnum, 0, n, 0, 1000, "vi");

    // 3) Normalized slice per voice
    startPos = OceanodeParameterLag.ar(\startpos, 0, n, 0, 1, "vf", 1/30, true);
    endPos   = OceanodeParameterLag.ar(\endpos,   1, n, 0, 1, "vf", 1/30, true);

    // 4) Gain
    gain = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);  // default 1 for testing

    // 5) Interpolation: 1 none, 2 linear, 4 cubic
    interp = OceanodeParameter.kr(\interp, 4, 1, 1, 4, "i");

    // --- Map phase -> frame position ---
    frames = BufFrames.kr(buf);
    startF = startPos * frames;
    endF   = endPos * frames;
    lenF   = (endF - startF).abs.max(1);
    posF = startF + (ph * lenF);

    // --- Read ---
    sig = BufRd.ar(1, buf, posF, 1, interp) * gain;

    Out.ar(OceanodeOutput.kr(\out), sig);
},
description: "Buffer reader driven by external 0..1 phasor. One channel per voice.",
category: "Source/Sampler");
)