(
~synthCreator.value("Pulsar", {|n|
    var snd, freq, formantFreq, sineCycles, pulsaretPhase, window;
    var levels;
    
    // Main parameters
    freq = OceanodeParameterLag.ar(\freq, 10, n, 0, 1000, "vf", 1/30, true);
    formantFreq = OceanodeParameterLag.ar(\formantfreq, 1000, n, 0, 10000, "vf", 1/30, true);
    sineCycles = OceanodeParameter.ar(\cycles, 4, n, 1, 800, "vi");
    levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
    
    // Force scalar operation for consistent behavior across all channel counts
    // This is a more direct approach that ensures the same behavior regardless of channel count
    snd = n.collect { |i|
        var chan_freq = freq[i];
        var chan_formantFreq = formantFreq[i];
        var chan_sineCycles = sineCycles[i];
        var chan_level = levels[i];
        
        // Create a separate LFSaw for each channel but ensure they all start with the same phase
        var chan_pulsaretPhase = LFSaw.ar(chan_freq, iphase: 1).linlin(-1, 1, 0, 1) * chan_formantFreq / chan_freq;
        var chan_window = chan_pulsaretPhase.lincurve(0, 1, 1, 0, -4);
        
        // Generate the pulsar signal
        sin(chan_pulsaretPhase * 2pi * chan_sineCycles.floor) * 
        chan_window * 
        (chan_pulsaretPhase < 1) * 
        chan_level;
    };
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), snd);
    
}, description: "Basic pulsar synthesis oscillator", category: "Source/Pulsar");
)