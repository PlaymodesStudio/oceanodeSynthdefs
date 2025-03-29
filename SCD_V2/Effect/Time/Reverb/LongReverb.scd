(
~synthCreator.value("LongReverb", {|n|
    var predel, revtime, lpf, hpf, mx, input_level;
    var dry, wet, temp, sig;
    
    // Control parameters
    predel = OceanodeParameterLag.ar(\predelay, 1, n, 0, 5, "vf", 1/30, true);
    revtime = OceanodeParameterLag.ar(\time, 4, n, 0.1, 20, "vf", 1/30, true);
    lpf = OceanodeParameterLag.ar(\lowpass, 100, n, 20, 127, "vf", 1/30, true).midicps;
    hpf = OceanodeParameterLag.ar(\hipass, 12, n, 0, 127, "vf", 1/30, true).midicps;
    mx = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 1/30, true);
    input_level = OceanodeParameterLag.ar(\inputlevel, 1, n, 0, 2, "vf", 1/30, true);
    
    // Input signal
    dry = In.ar(OceanodeInput.kr(\in), n);
    
    // Apply input level control
    temp = dry * input_level;
    
    // Apply predelay
    temp = DelayN.ar(temp, 1, predel);
    
    // Allpass chain - 32 allpass filters for a dense reverb
    32.do {
        temp = AllpassL.ar(temp, 0.05, {Rand(0.001, 0.05)}!n, revtime);
    };
    
    // Apply filters once per channel after the allpass chain
    wet = LPF.ar(temp, lpf);
    wet = HPF.ar(wet, hpf);
    
    // Mix dry and wet signals with dry/wet control
    sig = XFade2.ar(dry, wet, mx * 2 - 1);
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
    
}, description: "Long reverb with 32 allpass filters for dense reverberation", category: "Effect/Time/Reverb");
)