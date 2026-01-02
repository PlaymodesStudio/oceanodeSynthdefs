(
~synthCreator.value("HardSyncPulse", {|n|
    var freq, syncFreqRatio, masterOsc, slaveOsc, sync, amp;
    var pwMaster, pwSlave, preLPF, preQ;
    
    // Parameters
    freq = OceanodeParameterLag.ar(\pitch, 26, n, 0, 127, "vf", 1/30, true).midicps;
    syncFreqRatio = OceanodeParameterLag.ar(\ratio, 4, n, 0.1, 10, "vf", 1/30, true);
    amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
    
    // Pulse width parameters
    pwMaster = OceanodeParameterLag.ar(\pwmaster, 0.5, n, 0.01, 0.99, "vf", 1/30, true);
    pwSlave = OceanodeParameterLag.ar(\pwslave, 0.5, n, 0.01, 0.99, "vf", 1/30, true);
    
    // Filter parameters
    preLPF = OceanodeParameterLag.ar(\prelpf, 2000, n, 20, 20000, "vf", 1/30, true);
    preQ = OceanodeParameterLag.ar(\preq, 1, n, 0.1, 10, "vf", 1/30, true);
    
    // Generate oscillators
    masterOsc = Pulse.ar(freq, pwMaster);
    slaveOsc = RLPF.ar(
        Pulse.ar(freq * syncFreqRatio, pwSlave),
        preLPF,
        preQ.reciprocal // Convert Q to resonance (1/Q)
    );
    
    // Apply hard sync
    sync = slaveOsc * (masterOsc < 0);
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sync * amp);
    
}, description: "Hard sync oscillator with pulse waves and filtering", category: "Source/Sync");
)