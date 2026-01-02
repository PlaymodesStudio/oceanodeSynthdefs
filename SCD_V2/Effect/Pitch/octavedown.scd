(
~synthCreator.value("OctaveDown", {|n|
    var source, upPhase, invPrevPhase, trig, alternatePhase, octaveDown, mix;

    // Input signal
    source = In.ar(OceanodeInput.kr(\in), n);
	mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf",  0.05, true);

    // Phase detection for zero crossings
    upPhase = InRange.ar(source, 0, inf);  // Detect positive values
    invPrevPhase = 1 - Delay1.ar(upPhase); // Detect when previous sample was negative

    // Trigger on zero crossings (positive slope)
    trig = upPhase * invPrevPhase;

    // Alternate phase to get octave down effect
    alternatePhase = ToggleFF.ar(trig).madd(2, -1);

    // Apply phase alternation and filter to remove higher harmonics
    octaveDown = LPF.ar(source * alternatePhase,
        OceanodeParameterLag.ar(\cutoff, 5000, n, 20, 20000, "vf", 0.05, true));

    // Mix between original and octave down sound
    octaveDown = XFade2.ar(
        source,
        octaveDown,
        mix * 2 - 1
    );

    // Apply output level with proper curve for natural level control
    octaveDown = octaveDown * OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

    // Output the signal
    Out.ar(OceanodeOutput.kr(\out), octaveDown);

}, description: "Octave down effect using phase inversion", category: "Effect/Pitch");
)