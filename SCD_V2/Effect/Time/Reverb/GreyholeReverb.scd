(
~synthCreator.value("GreyholeReverb", {|n|
    var source, sig;
    var revtime, damp, size, diff, feed, modDepth, modFreq, mx, lowp, hip;
    
    // Control parameters
    revtime = OceanodeParameterLag.ar(\time, 1, n, 0, 60, "vf", 1/30, true);
    damp = OceanodeParameterLag.ar(\damp, 0, n, 0.5, 5, "vf", 1/30, true);
    size = OceanodeParameterLag.ar(\size, 1, n, 0, 1, "vf", 1/30, true);
    diff = OceanodeParameterLag.ar(\diff, 0.7, n, 0, 3, "vf", 1/30, true);
    feed = OceanodeParameterLag.ar(\feedback, 0.9, n, 0, 1, "vf", 1/30, true);
    modDepth = OceanodeParameterLag.ar(\moddepth, 0.1, n, 0, 1, "vf", 1/30, true);
    modFreq = OceanodeParameterLag.ar(\modfreq, 2, n, 0, 10, "vf", 1/30, true);
    mx = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 1/30, true);
    lowp = OceanodeParameterLag.ar(\lopass, 130, n, 20, 127, "vf", 1/30, true).midicps;
    hip = OceanodeParameterLag.ar(\hipass, 10, n, 0, 127, "vf", 1/30, true).midicps;
    
    // Input signal
    source = In.ar(OceanodeInput.kr(\in), n);
    
    // Apply Greyhole reverb
    sig = Greyhole.ar(
        source, 
        revtime, 
        damp, 
        size, 
        diff, 
        feed, 
        modDepth, 
        modFreq
    );
    
    // Apply filters
    sig = LPF.ar(sig, lowp);
    sig = HPF.ar(sig, hip);
    
    // Mix dry and wet signals with dry/wet control
    sig = XFade2.ar(source, sig, mx * 2 - 1);
    
    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
    
}, description: "Reverb based on the Greyhole algorithm with pitch shifting", category: "Effect/Time/Reverb");
)