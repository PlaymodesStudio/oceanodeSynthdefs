(
~synthCreator.value("SyncSaw", {|n|
    var freq, syncFreq, sig, levels;
    
    // Parameters
    freq = OceanodeParameterLag.ar(\pitch, 24, n, 0, 127, "vf", 1/30, true).midicps;
    syncFreq = OceanodeParameterLag.ar(\synchz, 440, n, 20, 10000, "vf", 1/30, true);
    levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    
    // Generate sync saw oscillator
    sig = SyncSaw.ar(freq, syncFreq);
    
    // Apply level control
    sig = sig * levels;
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
    
}, description: "Sync sawtooth oscillator with base and sync frequency control", category: "Source/Sync");
)