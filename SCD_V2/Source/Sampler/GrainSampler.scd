(
~synthCreator.value("GrainSampler", {|n|
    var t, signal, spd, buf, start, gain, dur, buf2;

    // Controls
    t = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    buf = OceanodeBuffer.kr(\bufnum);
	buf2 = OceanodeBuffer.kr(\envbuf);
    spd = OceanodeParameterLag.ar(\speed, 1, n, 0.25, 4, "vf",  1/30, true);
    start = OceanodeParameterLag.ar(\startpos, 0, n, 0, 1, "vf",  1/30, true);
    dur = OceanodeParameterLag.ar(\grainsize, 0.1, n, 0.01, 2, "vf",  1/30, true);

    // Create grain signal
    signal = GrainBuf.ar(
        numChannels: 1,
        trigger: t,
        dur: dur,
        sndbuf: buf,
        rate: spd,
        pos: start,
        interp: 2,
        pan: 0,
        envbufnum: buf2,
        maxGrains: 1024
    ) * gain;

    Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Basic granular sampler with trigger control", category: "Source/Sampler");
)

