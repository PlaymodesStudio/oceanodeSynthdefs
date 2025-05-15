(
~synthCreator.value("MultibandPanaz", {|n|
    var input, dry, bands, freqs, amps, pans, output, levels, finalOutput, mix, width;
    var numBands, scaling, minPitch, maxPitch;
    var freq, nextFreq, prevFreq, bandwidth, rq, bpf1, bpf2;

    // Number of bands equals number of channels
    numBands = n;
    scaling = 1/numBands.sqrt;  // Compensate for band summation
    minPitch = 0;  // 8.18 Hz in MIDI note 0
    maxPitch = 130;  // ~9.96 kHz in MIDI note 130

    // Get input signal and store original for dry/wet mix
    input = In.ar(OceanodeInput.kr(\in), n);
    dry = input;

    // Mix to mono for processing
    input = Mix(input) / n.max(1);

    // Get parameters
    amps = OceanodeParameterLag.ar(\amparray, 1, numBands, 0, 1, "vf", 1/30, true);
	pans = OceanodeParameterLag.ar(\panarray, 0, numBands, -1, 1, "vf", 1/30, true)+1;
    width = OceanodeParameterLag.ar(\width, 2, 1, 0, 5, "vf", 1/30, true);
    mix = OceanodeParameterLag.ar(\mix, 1, n, 0, 1, "vf", 1/30, true);

    // Calculate frequencies - distribute evenly across MIDI note range
    freqs = Array.fill(numBands, { |i|
        var pitch = minPitch + ((maxPitch - minPitch) * i / (numBands-1).max(1));
        pitch.midicps;  // Convert MIDI note to frequency
    });

    // Calculate optimal RQ values for each band to ensure proper coverage
    // Process through band-pass bank with panning
    bands = Array.fill(numBands, { |i|
        freq = freqs[i];

        // Calculate adjacent frequencies to determine bandwidth
        prevFreq = if(i > 0, { freqs[i-1] }, { freq * 0.75 });
        nextFreq = if(i < (numBands-1), { freqs[i+1] }, { freq * 1.33 });

        // Set bandwidth to cover the range between midpoints
        bandwidth = (nextFreq - prevFreq) * 0.9; // 10% overlap
        rq = bandwidth / freq;

        // Apply band-pass filtering - chained for steeper cutoff
        bpf1 = BPF.ar(input, freq, rq);
        bpf2 = BPF.ar(bpf1, freq, rq);

        // Pan the filtered signal
        PanAz.ar(n, bpf2 * amps[i], pans[i], 1, width)
    });

    // Mix all bands
    output = Mix(bands) * scaling;

    // Apply level control with proper dB scaling
    levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
    output = output * levels;

    // Apply dry/wet mix using XFade2
    finalOutput = Array.fill(n, { |i|
        XFade2.ar(dry[i], output[i], mix[i].linlin(0, 1, -1, 1))
    });

    // Output the signal
    Out.ar(OceanodeOutput.kr(\out), finalOutput);
}, description: "Multiband spectral panner with bands equal to channels", category: "Spatial/Panning");
)