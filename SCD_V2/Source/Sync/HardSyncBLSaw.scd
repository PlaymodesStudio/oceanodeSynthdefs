(
~synthCreator.value("HardSyncBLSaw", {|n|
    var syncFreq, sawFreq, maxRatio, minFreq;
    var maxDelay, sig, levels, buffer, baseWaveform, channelSig, delay, amplitude;
    
    // Parameters
    syncFreq = OceanodeParameterLag.ar(\syncpitch, 36, n, 0, 127, "vf", 1/30, true).midicps;
    sawFreq = OceanodeParameterLag.ar(\sawpitch, 60, n, 0, 127, "vf", 1/30, true).midicps;
    levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
    
    // Constants
    maxRatio = 20;
    minFreq = 10;
    maxDelay = 1 / minFreq;
    
    // Process each channel individually
    sig = n.collect { |i|
        // Create buffer with fixed sample rate (48000 is a common value)
        // Using SampleRate.ir() to get the actual sample rate at initialization time
        buffer = LocalBuf(SampleRate.ir() * maxDelay, 1);
        
        // Create base waveform for this channel
        baseWaveform = Saw.ar(syncFreq[i]);
        channelSig = 0; // Initialize channel signal
        
        // Apply the hardsync algorithm
        maxRatio.floor.do { |j|
            delay = j / sawFreq[i];
            amplitude = ((sawFreq[i] / syncFreq[i]) - j).clip(0, 1);
            channelSig = channelSig + (BufDelayL.ar(buffer, baseWaveform, delay) * amplitude);
        };
        
        // Apply level control and return the result
        channelSig * levels[i];
    };
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
    
}, description: "Band-limited hard sync sawtooth oscillator", category: "Source/Sync");
)