(
~synthCreator.value("AutoWah", {|n|
    var source, sig, envFollower, filterFreq, rq;
    var sensitivity, attack, release, minFreq, maxFreq, resonance;
    var filterType, mix, direction;

    // Input signal
    source = In.ar(OceanodeInput.kr(\in), n);

    // AutoWah parameters
    sensitivity = OceanodeParameterLag.ar(\sensitivity, 0.5, n, 0.01, 1, "vf", 1/30, true);
    attack = OceanodeParameterLag.ar(\attack, 0.05, n, 0.001, 1, "vf", 1/30, true);
    release = OceanodeParameterLag.ar(\release, 0.2, n, 0.01, 2, "vf", 1/30, true);
    minFreq = OceanodeParameterLag.ar(\minfreq, 200, n, 20, 5000, "vf", 1/30, true);
    maxFreq = OceanodeParameterLag.ar(\maxfreq, 3000, n, 500, 10000, "vf", 1/30, true);
    resonance = OceanodeParameterLag.ar(\resonance, 0.5, n, 0.1, 1, "vf", 1/30, true);
    filterType = OceanodeParameterDropdown.kr(\filtertype, 0, n, "LowPass:BandPass:HighPass:Notch");
    direction = OceanodeParameterDropdown.kr(\direction, 0, n, "Up:Down");
    mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

    // Create envelope follower to track input amplitude
    envFollower = Amplitude.ar(source, attack, release);

    // Map envelope to filter frequency range with sensitivity control
    filterFreq = Select.kr(
        direction,
        [
            // Up direction - louder signal = higher frequency
            minFreq + ((maxFreq - minFreq) * (envFollower * sensitivity)),

            // Down direction - louder signal = lower frequency
            maxFreq - ((maxFreq - minFreq) * (envFollower * sensitivity))
        ]
    );

    // Calculate filter Q/RQ value (reciprocal Q) from resonance parameter
    // Higher resonance values = lower RQ values = sharper filter
    rq = (1 - resonance) * 0.9 + 0.1; // Maps 0-1 to 0.1-1.0

    // Apply selected filter type
    sig = Select.ar(
        filterType,
        [
            // LowPass
            RLPF.ar(source, filterFreq, rq),

            // BandPass
            BPF.ar(source, filterFreq, rq),

            // HighPass
            RHPF.ar(source, filterFreq, rq),

            // Notch (Band Reject)
            BRF.ar(source, filterFreq, rq)
        ]
    );

    // Mix dry and wet signals with dry/wet control
    sig = XFade2.ar(source, sig, mix * 2 - 1);

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Envelope-controlled filter effect", category: "Effect/Filter");
)