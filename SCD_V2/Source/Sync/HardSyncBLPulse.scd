(
~synthCreator.value("HardSyncBLPulse", {|n|
    var syncFreq, pulseFreq, maxRatio, minFreq;
    var maxDelay, sig, levels, pw, buffer, baseWaveform, channelSig, delay, amplitude;
    
    // Parameters
    syncFreq = OceanodeParameterLag.ar(\syncpitch, 36, n, 0, 127, "vf", 1/30, true).midicps;
    pulseFreq = OceanodeParameterLag.ar(\pulsepitch, 60, n, 0, 127, "vf", 1/30, true).midicps;
    levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    pw = OceanodeParameterLag.ar(\pw, 0.5, n, 0.01, 0.99, "vf", 1/30, true);
    
    // Constants
    maxRatio = 20;
    minFreq = 10;
    maxDelay = 1 / minFreq;
    
    // Process each channel individually
    sig = n.collect { |i|
        // Create buffer with SampleRate.ir() to get the actual sample rate at initialization time
        buffer = LocalBuf(SampleRate.ir() * maxDelay, 1);
        
        // Create base waveform for this channel
        baseWaveform = Pulse.ar(syncFreq[i], pw[i]);
        channelSig = 0; // Initialize channel signal
        
        // Apply the hardsync algorithm
        maxRatio.floor.do { |j|
            delay = j / pulseFreq[i];
            amplitude = ((pulseFreq[i] / syncFreq[i]) - j).clip(0, 1);
            channelSig = channelSig + (BufDelayL.ar(buffer, baseWaveform, delay) * amplitude);
        };
        
        // Apply level control and return the result
        channelSig * levels[i];
    };
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
    
}, description: "Band-limited hard sync pulse oscillator with pulse width control", category: "Source/Sync");
)