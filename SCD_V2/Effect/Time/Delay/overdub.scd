(
~synthCreator.value("Overdub", {|n|
    var del, sig, mx, dry, feedback, send, dec;

    // Parameters
    del = OceanodeParameterLag.ar(\delay, 0.5, n, 0, 4, "vf", 0.4, true);
    mx = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 1/30, true);
    send = OceanodeParameterLag.ar(\send, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	dec=OceanodeParameterLag.ar(\decay, 100, n, 0, 100, "vf", 1/30, true);
    // Input processing
    dry = In.ar(OceanodeInput.kr(\in), n);

    // Create infinite feedback loop with CombC
    // Reset parameter controls feedback time - 0 clears the buffer
    feedback = CombC.ar(dry * send, 4, del, dec); //inf
    feedback = LeakDC.ar(feedback);
    feedback = feedback.tanh;

    // Mix dry and wet signals
    sig = XFade2.ar(dry, feedback, mx*2-1);

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Infinite feedback delay with reset control", category: "Effect/Time/Delay");
)