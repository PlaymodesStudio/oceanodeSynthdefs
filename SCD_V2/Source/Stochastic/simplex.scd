(
~synthCreator.value("Perlin", {|n|
    var finalSig, offsetX, offsetY, offsetZ, freqScale;
    var hz, phase1, phase2, xfade, sig1, sig2;

    // Perlin specific parameters
    offsetX = OceanodeParameterLag.ar(\offsetx, 31.4, n, -100, 100, "vf", 1/30, true);
    offsetY = OceanodeParameterLag.ar(\offsety, -62.8, n, -100, 100, "vf", 1/30, true);
    offsetZ = OceanodeParameterLag.ar(\offsetz, 17.6, n, -100, 100, "vf", 1/30, true);
    freqScale = OceanodeParameterLag.ar(\freqscale, 0.2, n, 0.01, 50000, "vf", 1/30, true);

    // Frequency control in Hz
    hz = OceanodeParameterLag.ar(\pitch, 440, n, 0, 130, "vf", 1/30, true).midicps;

    // Create two overlapping phasors
    phase1 = Phasor.ar(0, hz * SampleDur.ir, 0, 1);
    phase2 = Phasor.ar(0, hz * SampleDur.ir, 0.5, 1, 0);

    // Create sinusoidal crossfade between the two phasors
    xfade = sin(phase1 * pi);

    // Generate Perlin noise for each phasor
    sig1 = Perlin3.ar(
        phase1 * freqScale + offsetX * 0.01,
        phase1 * freqScale + offsetY * 0.01,
        phase1 * freqScale + offsetZ * 0.01
    );

    sig2 = Perlin3.ar(
        phase2 * freqScale + offsetX * 0.01,
        phase2 * freqScale + offsetY * 0.01,
        phase2 * freqScale + offsetZ * 0.01
    );

    // Crossfade between the two signals
    finalSig = (sig1 * xfade) + (sig2 * (1 - xfade));

    // Apply level control with proper dB scaling
    finalSig = finalSig * OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

    // Output the signal
    Out.ar(OceanodeOutput.kr(\out), finalSig);
}, description: "Perlin noise oscillator with 3D movement through noise space and click-free looping", category: "Source/Noise");
)