(
~synthCreator.value("Recursive", {|n|
    // Main control parameters
    var amp, noiselo, noisehi, lag, freqlo, freqhi, freqmul, fbscale, fboffset, lowpass;
    var sig, fb, output, limited;

    // Internal calculation parameters - scaled by channel count
    var numOsc = (30 * (n/2)).floor.asInteger.max(30);  // Scale oscillator count based on channels
    var numTaps = (5 * (n/2)).floor.asInteger.max(5);   // Scale tap count based on channels
    var leakDC = 0.995;                                 // Fixed DC filtering amount
    var limiterLevel = 0.95;                            // Fixed limiter ceiling

    // Parameters definition
    amp = OceanodeParameter.ar(\amp, 0.5, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);
    noiselo = OceanodeParameter.ar(\noiselo, 0.1, n, 0.01, 5, "vf");
    noisehi = OceanodeParameter.ar(\noisehi, 2, n, 0.01, 10, "vf");
    lag = OceanodeParameter.ar(\lag, 0.1, n, 0.01, 1, "vf");
    freqlo = OceanodeParameter.ar(\freqlo, 0.2, n, 0.1, 20, "vf");
    freqhi = OceanodeParameter.ar(\freqhi, 1000, n, 20, 2000, "vf");
    freqmul = OceanodeParameter.ar(\freqmul, 1, n, 0.1, 10, "vf");
    fbscale = OceanodeParameter.ar(\fbscale, 1, n, 0, 2, "vf");
    fboffset = OceanodeParameter.ar(\fboffset, 0, n, -1, 1, "vf");
    lowpass = OceanodeParameter.ar(\lowpass, 12000, n, 100, 20000, "vf");

    // Create feedback structure
    fb = LocalIn.ar(numOsc);
    fb = LeakDC.ar(fb, leakDC);

    // Create oscillator network
    sig = Array.fill(numOsc, {
        var noiseRate, randMul, randOffset, freq, index, smoothIndex, feedbackSig, smoothPhase, osc;

        // Generate randomized control values without Changed.kr
        noiseRate = LFNoise0.kr(0.1).exprange(noiselo[0], noisehi[0]);
        randMul = LFNoise0.kr(0.1).range(0.0, 1.0);
        randOffset = LFNoise0.kr(0.1).range(0.0, numOsc);
        freq = LFNoise0.kr(0.1).exprange(freqlo[0], freqhi[0]);

        // Index into the feedback array with noise modulation
        index = (LFNoise0.kr(noiseRate) * randMul + randOffset).clip(0, numOsc-1);
        smoothIndex = Lag3.kr(index, lag[0]);
        feedbackSig = SelectX.ar(smoothIndex, fb) * fbscale[0] + fboffset[0];

        // Create oscillator with smoothed phase modulation
        smoothPhase = Lag.ar(feedbackSig, 0.001);
        osc = SinOsc.ar(freq * freqmul[0], smoothPhase);

        // Filter oscillator output
        LPF.ar(osc, lowpass[0])
    });

    // Send signals back into the feedback loop
    LocalOut.ar(LeakDC.ar(sig, leakDC));

    // Select taps from the oscillator network
    output = Array.fill(numTaps, {
        var readPos, smoothPos, audioPos;

        // Create smoothed position for reading from oscillator array
        readPos = LFNoise1.kr(1/numTaps).range(0, numOsc - numTaps - 1);
        smoothPos = Lag3.kr(readPos, lag[0] * 2);
        audioPos = K2A.ar(smoothPos);

        // Select from oscillator array
        SelectX.ar(audioPos, sig)
    });

    // Process each channel independently
    limited = n.collect({ |i|
        var chanSig, processed;

        // Distribute taps across channels with overlap
        chanSig = if(i < numTaps,
            output[i],
            SelectX.ar(i.linlin(0, n-1, 0, numTaps-0.001), output)
        );

        // Process channel signal
        processed = LeakDC.ar(chanSig, leakDC);
        processed = LPF.ar(processed, lowpass[i % n]);
        processed = Limiter.ar(processed, limiterLevel, 0.01);

        // Apply channel amplitude
        processed * amp[i]
    });

    // Send to output
    Out.ar(OceanodeOutput.kr(\out), limited);

}, description: "Selfreferential feedback network of oscillators creating complex timbres", category: "Source/Special");
)