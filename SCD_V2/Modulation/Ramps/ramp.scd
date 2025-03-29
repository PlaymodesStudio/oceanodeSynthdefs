(
~synthCreator.value("Ramp", {|n|
    var min, max, ms, sig, reset;
    // Basic LFO controls
    ms = OceanodeParameterLag.ar(\ms, 1000, n, 0.001, 100000, "vf", 1/30, true);
    min = OceanodeParameterLag.ar(\min, 0, n, -100, 100, "vf", 1/30, true);
    max = OceanodeParameterLag.ar(\max, 1, n, -100, 100, "vf", 1/30, true);
    reset = OceanodeParameter.ar(\reset, 0, n, 0, 1, "vi");

    // Calculate rate as 1/ms (seconds) for Sweep
    sig = Sweep.ar(reset, 1/(ms/1000));

    // Normalize the sweep (0-1) and scale to min-max range
    sig = sig.clip(0, 1) * (max - min) + min;

    // Output signal
    Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Ramp", category: "Modulation/Ramps");
)