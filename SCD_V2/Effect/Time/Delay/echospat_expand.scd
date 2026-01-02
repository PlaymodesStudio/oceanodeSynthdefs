(
~synthCreator.value("EchoSpatExpand", {|n, variables|
    var filters, fb, del, cut, res, selfilt, sig, mx, dry, feedback, wet, send;
    var panPos, totalCycleTime, smoothRands, pattern, numSpeakers;

    // Get number of speakers from variables
    numSpeakers = variables[0];

    // Parameters with proper ranges from Synthdefs.json
    send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
    del = OceanodeParameterLag.ar(\delay, 0.2, n, 0.01, 2, "vf", 1/30, true);
    pattern = OceanodeParameter.kr(\pattern, 0, n, 0, 3, "vi");
    fb = OceanodeParameter.ar(\feed, 0.3, n, 0, 1, "vf");
    selfilt = OceanodeParameter.kr(\filtertype, 0, n, 0, 3, "vi");
    cut = OceanodeParameterLag.ar(\cutoff, 60, n, 12, 120, "vf", 1/30, true).midicps;
    res = OceanodeParameter.ar(\resonance, 0.2, n, 0, 1, "vf");
    mx = OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf");

    // Use the first delay value to set the timing
    totalCycleTime = del.at(0) * numSpeakers;

    // Create smooth random variations
    smoothRands = Array.fill(n, {|i|
        LFNoise2.kr(6.5/totalCycleTime, mul: 1, add: 1)
    });

    // Pan position patterns - now based on number of speakers
    panPos = Select.kr(pattern.at(0), [
        // Circular pattern
        Array.fill(n, {|i|
            LFSaw.kr(1/totalCycleTime, iphase: i/n).range(-1, 1)
        }),
        // Reverse circular
        Array.fill(n, {|i|
            LFSaw.kr(1/totalCycleTime, iphase: i/n).range(1, -1)
        }),
        // Star pattern
        Array.fill(n, {|i|
            var sawPhase = (LFSaw.kr(1/totalCycleTime, iphase: i/n) * numSpeakers).floor % numSpeakers;
            Select.kr(sawPhase, Array.fill(numSpeakers, {|j| -1 + ((j / (numSpeakers/2)) * 2)}))
        }),
        // Reverse star
        Array.fill(n, {|i|
            var sawPhase = (LFSaw.kr(1/totalCycleTime, iphase: i/n) * numSpeakers).floor % numSpeakers;
            Select.kr(sawPhase, Array.fill(numSpeakers, {|j| 1 - ((j / (numSpeakers/2)) * 2)}))
        })
    ]);

    // Audio processing
    dry = In.ar(OceanodeInput.kr(\in), n);
    feedback = LocalIn.ar(n);
    wet = fb * DelayC.ar(feedback, 2, del);

    // Spatial distribution across the specified number of speakers
    wet = Array.fill(n, {|i|
        PanAz.ar(numSpeakers, wet[i], panPos[i], orientation: 0.5)
    }).sum;

    // Filter selection
    filters = Select.ar(selfilt.at(0), [
        RLPF.ar(wet, cut, 1-res),
        RHPF.ar(wet, cut, 1-res),
        BPF.ar(wet, cut, 1-res),
        BPeakEQ.ar(wet, cut, 1, res*12)
    ]);

    // Apply feedback
    LocalOut.ar(filters + (dry * send));

    // Output with mix control - convert from input channels to output channels
    sig = XFade2.ar(dry, filters.flop.collect(Mix(_)), mx*2-1);
    Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Spatializing echo with variable speaker output", category: "Effect/Time/Delay", variables: ["NumSpeakers"], variableDimensions: [32]);
)