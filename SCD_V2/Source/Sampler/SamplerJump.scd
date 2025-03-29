(
~synthCreator.value("SamplerJump", {|n|
    var t, signal, spd, buf, bucle, start, gain, ph, offset, numsamples;

    // Controls
    t = OceanodeParameter.ar(\trigger, 0, n, 0, 1, "vi");
    gain = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    buf = OceanodeBuffer.kr(\bufnum);
    spd = OceanodeParameter.ar(\speed, 1, n, 0.25, 4, "vf");
    bucle = OceanodeParameter.kr(\loop, 0, n, 0, 1, "vi");
    start = OceanodeParameter.ar(\startpos, 0, n, 0, 1, "vf") * BufFrames.kr(buf);
    offset = OceanodeParameter.ar(\offset, 0, n, -1, 1, "vf");
    
    // Calculate buffer parameters
    numsamples = BufFrames.kr(buf);
    offset = offset * numsamples;
    
    // Create phasor with offset
    ph = Wrap.ar(
        Phasor.ar(
            t, 
            BufRateScale.kr(buf) * spd, 
            start, 
            BufFrames.kr(buf)
        ) + offset, 
        0, 
        numsamples
    );
    
    // Read from buffer
    signal = BufRd.ar(1, buf, ph, bucle, 0) * gain;
    
    Out.ar(OceanodeOutput.kr(\out), signal);
}, description: "Sampler with offset jumping capability", category: "Source/Sampler");
)