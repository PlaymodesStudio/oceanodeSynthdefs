(
~synthCreator.value("FMPulsar", {|n|
    var a, d, f;
    var t, overlap, carfreq, modfreq, mInd, amp, levels;
    
    // Base frequency from pitch
    f = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
    
    // Amplitude and levels
    amp = OceanodeParameterLag.ar(\preamp, 0.6, n, 0, 1, "vf", 1/30, true).clip(0, 1.0);  // Clip amp to prevent overload
    levels = OceanodeParameterLag.ar(\levels, 0.15, n, 0, 1, "vf", 1/30, true);
    
    // FM parameters
    carfreq = f * OceanodeParameterLag.ar(\carrier, 1.142857, n, 0, 32, "vf", 1/30, true);
    modfreq = carfreq * OceanodeParameterLag.ar(\modulator, 1.333333, n, 0, 32, "vf", 1/30, true);
    
    // Generate triggers for each channel
    t = Impulse.ar(f);
    
    // Calculate modulation index and overlap per channel - adjusted scaling
    mInd = amp.pow(3.5) * OceanodeParameterLag.ar(\modindex, 0.15, n, 0, 8, "vf", 1/30, true);
    overlap = 1.15 - amp.pow(0.55) * OceanodeParameterLag.ar(\overlap, 1, n, 0, 16, "vf", 1/30, true);
    d = overlap/f;
    
    // Process each channel individually
    a = n.collect { |i|
        var chan_sin = SinOsc.ar(f[i]) * 0.5;
        var chan_grain = GrainFM.ar(1, t[i], d[i], carfreq[i], modfreq[i], mInd[i]) * 0.5;
        var chan_mix = chan_sin + chan_grain;
        
        // Process channel
        chan_mix = LeakDC.ar(chan_mix * amp[i]);
        BLowPass4.ar(chan_mix, 1350, 1.0);
    };
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), a * levels);
    
}, description: "FM-based pulsar synthesis with grain control", category: "Source/Pulsar");
)