(
~synthCreator.value("EnvelopeFollower", {|n|
    var source, envSignal;
    var attack, release, floor, ceiling, curve;

    // Input signal
    source = In.ar(OceanodeInput.kr(\in), n);

    // Envelope follower parameters
    attack = OceanodeParameterLag.ar(\attack, 0.01, n, 0.001, 1, "vf", 1/30, true);
    release = OceanodeParameterLag.ar(\release, 0.1, n, 0.01, 2, "vf", 1/30, true);
    floor = OceanodeParameterLag.ar(\floor, 0, n, 0, 1, "vf", 1/30, true);
    ceiling = OceanodeParameterLag.ar(\ceiling, 1, n, 0, 1, "vf", 1/30, true);
    curve = OceanodeParameterLag.ar(\curve, 1, n, 0.1, 10, "vf", 1/30, true);

    // Create the envelope follower
    envSignal = Amplitude.ar(source, attack, release);

    // Scale the envelope to desired output range with curve shaping
    envSignal = floor + ((ceiling - floor) * (envSignal ** curve));

    // Output the envelope follower signal (0-1 range)
    Out.ar(OceanodeOutput.kr(\out), envSignal);

}, description: "Generates control signal from input amplitude", category: "Utilities/Analysis");
)