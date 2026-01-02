(
~synthCreator.value("TankReverb", {|n|
    var input, src, indiffusion, localin, wet, signal;
    var sr = SampleRate.ir;
    var times, dtimes, delays;
    var earlydiffsize = 4;
    var tanksize = 4;
    var allpassChains, tanks, tankouts;
    var inputhpf, inputlpf, predelay, scaledelays, decay, decay1, damping, feedback;
    var tank0, tank1, tank2, tank3, tail, mix, send;

    // Parameters
    send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
    inputhpf = OceanodeParameter.ar(\inputhpf, 150, n, 20, 20000, "vf");
    inputlpf = OceanodeParameter.ar(\inputlpf, 0.5, n, 0, 1, "vf");
    predelay = OceanodeParameter.ar(\predelay, 0, n, 0, 0.1, "vf");
    scaledelays = OceanodeParameter.ar(\scaledelays, 1, n, 0.1, 2, "vf");
    indiffusion = OceanodeParameter.ar(\indiffusion, 0.05, n, 0, 1, "vf");
    decay = OceanodeParameter.ar(\decay, 0.5, n, 0, 5, "vf");
    decay1 = decay;
    damping = OceanodeParameter.ar(\damping, 0, n, 0, 1, "vf");
    feedback = OceanodeParameter.ar(\feedback, 0.5, n, 0, 1, "vf");
    // Convert tank mix values to arrays to match the number of channels
    tank0 = Array.fill(n, 0.25);
    tank1 = Array.fill(n, 0.25);
    tank2 = Array.fill(n, 0.25);
    tank3 = Array.fill(n, 0.25);
    tail = OceanodeParameter.ar(\tail, 1, n, 0, 2, "vf");
    mix = OceanodeParameter.ar(\mix, 0.5, n, 0, 1, "vf");

    // Get the input signal
    input = In.ar(OceanodeInput.kr(\in), n);

    // Input processing
    src = HPF.ar(input, inputhpf);
    src = OnePole.ar(src, inputlpf);
    src = DelayN.ar(src, 0.1, predelay);

    // Apply send level to the input - added from RichReverb example
    src = src * send;

    // Base delay times array
    times = [ 1447, 727, 613, 673, 1439, 2083, 2011, 1511, 1493, 1277, 2437, 2383, 2341, 997, 1061, 2039,
        1997, 1481, 1627, 1129, 743, 983, 1091, 907, 541, 2393, 1801, 2081, 1787, 1453, 977, 2311,
        691, 479, 2377, 1693, 1013, 1931, 1049, 2243, 839, 739, 1747, 601, 1823, 1123, 2467, 1297,
        1613, 1361, 2207, 593, 619, 1709, 449, 937 ];

    // Process each channel separately
    allpassChains = Array.fill(n, {|i|
        var processed = src[i];
        var chanTimes = times.rotate(i * (times.size.div(n)));
        var earlyTimes = Array.fill(earlydiffsize, {
            chanTimes.removeAt(chanTimes.minIndex) / sr;
        });

        // Early reflections
        earlydiffsize.do {|j|
            processed = AllpassN.ar(processed, earlyTimes[j], earlyTimes[j], indiffusion[i]);
        };

        processed
    });

    // Create LocalIn for feedback
    localin = LocalIn.ar(n);

    // Main reverb tanks
    tanks = Array.fill(n, {|i|
        var local = localin[i];
        var chanTimes = times.rotate(i * (times.size.div(n)));
        var delayTimes = Array.fill(3 * tanksize, {
            chanTimes.removeAt(chanTimes.minIndex) / sr * scaledelays[i];
        });

        var tankStages = Array.fill(tanksize, {|j|
            var dt0, dt1, dt2, idx;

            idx = j * 3;
            local = local + allpassChains[i];

            // Get delay times for this stage
            dt0 = delayTimes[idx];
            dt1 = delayTimes[idx + 1];
            dt2 = delayTimes[idx + 2];

            // Process through allpass and delay
            local = AllpassC.ar(local, dt0, dt0, decay[i]);
            local = AllpassC.ar(local, dt1, dt1, decay1[i]);
            local = DelayC.ar(local, dt2, dt2 - ((ControlDur.ir / tanksize) * LFNoise2.kr(0.3).range(0.9, 1)));
            local = OnePole.ar(local, damping[i]);

            local
        });

        tankStages
    });

    // Extract last stage for feedback
    tankouts = tanks.collect {|tank| tank[tanksize-1]};
    LocalOut.ar(tankouts * feedback);

    // Output mixing - using all tank stages
    wet = Array.fill(n, {|i|
        Mix.new([
            tanks[i][0] * tank0[i],
            tanks[i][1] * tank1[i],
            tanks[i][2] * tank2[i],
            tanks[i][3] * tank3[i]
        ])
    });

    wet = LeakDC.ar(wet);
    wet = wet * tail;

    // Final mix of dry and wet
    signal = XFade2.ar(input, wet, mix * 2 - 1);

    // Send to output
    Out.ar(OceanodeOutput.kr(\out), signal);

}, description: "Professional quality reverb with independent control of several stages and adjustable send level", category: "Effect/Time/Reverb");
)