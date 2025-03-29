(
~synthCreator.value("FreeVerb", {|n|
    var mix, room, damp;
    var sig, verb;
    
    // Control parameters
    mix = OceanodeParameterLag.ar(\mix, 0.33, n, 0, 1, "vf", 1/30, true);
    room = OceanodeParameterLag.ar(\room, 0.5, n, 0, 1, "vf", 1/30, true);
    damp = OceanodeParameterLag.ar(\damp, 0.5, n, 0, 1, "vf", 1/30, true);
    
    // Input signal
    sig = In.ar(OceanodeInput.kr(\in), n);
    
    // Process each channel individually
    verb = n.collect { |i|
        FreeVerb.ar(
            sig[i],
            mix: mix[i],
            room: room[i],
            damp: damp[i]
        )
    };
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), verb);
    
}, description: "Simple reverb based on the Freeverb algorithm", category: "Effect/Time/Reverb");
)