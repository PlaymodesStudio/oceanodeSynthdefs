(
~synthCreator.value("HardSync", {|n|
    var freq, syncFreqRatio, masterOsc, slaveOsc, sync, amp;
    
    // Parameters
    freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true).midicps;
    syncFreqRatio = OceanodeParameterLag.ar(\ratio, 1, n, 0.1, 10, "vf", 1/30, true);
    amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    
    // Generate oscillators
    masterOsc = Pulse.ar(freq, 0.5);
    slaveOsc = Saw.ar(freq * syncFreqRatio);
    
    // Apply hard sync
    sync = slaveOsc * (masterOsc < 0);
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sync * amp);
    
}, description: "Hard sync oscillator with sawtooth slave", category: "Source/Sync");
)