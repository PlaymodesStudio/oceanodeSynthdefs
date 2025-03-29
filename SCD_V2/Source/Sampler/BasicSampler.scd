(
~synthCreator.value("BasicSampler", {|n|
    var t, signal, spd, buf, bucle, start, gain;

    // Controls
    t = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    buf = OceanodeBuffer.kr(\bufnum);
    spd = OceanodeParameter.ar(\speed, 1, n, 0.25, 4, "vf");
    bucle = OceanodeParameter.kr(\loop, 0, n, 0, 1, "vi");
    start = OceanodeParameter.ar(\startpos, 0, n, 0, 1, "vf") * BufFrames.kr(buf);

    // Play the sample
    signal = PlayBuf.ar(1, buf, spd, t, start, bucle) * gain;
    
    Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Basic sample player with loop functionality", category: "Source/Sampler");
)