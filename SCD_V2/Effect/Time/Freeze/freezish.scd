(
~synthCreator.value("Freezish", {|n|
    var source, sig, chain, numchans, trigger, mix;
    var buffers;
    var atkCoeff, dcyCoeff, useTimeControl, atkTime, dcyTime, hopSize;

    // All variables declared at beginning
    numchans = n;

    // Parameters with appropriate ranges
    trigger = OceanodeParameter.kr(\trigger, 0, n, 0, 1, "vi");
    mix = OceanodeParameter.ar(\mix, 0, n, 0, 1, "vf");

    // New parameters for PV_Freezish
    atkCoeff = OceanodeParameter.kr(\attackcoeff, 0.5, n, 0, 1, "vf"); // Changed default to 0.5
    dcyCoeff = OceanodeParameter.kr(\decaycoeff, 0.9, n, 0, 1, "vf");  // Changed default to 0.9

    // Time-based control parameters
    useTimeControl = OceanodeParameter.kr(\usetimecontrol, 0, n, 0, 1, "vi");
    atkTime = OceanodeParameter.kr(\attacktime, 0.01, n, 0.001, 5, "vf");
    dcyTime = OceanodeParameter.kr(\decaytime, 1.0, n, 0.001, 15, "vf"); // Changed default to 1.0

    // FFT parameters
    hopSize = OceanodeParameter.kr(\hopsize, 0.5, n, 0.25, 0.5, "vf");

    // Input signal
    source = In.ar(OceanodeInput.kr(\in), n);

    // Create a buffer for each channel
    buffers = LocalBuf(2048).dup(n);

    // Process each channel individually
    sig = n.collect { |i|
        var buf = buffers[i];
        var chan = source[i];
        var fftChain = FFT(buf, chan);

        // Use either coefficient-based or time-based control
        fftChain = Select.kr(useTimeControl[i], [
            // Direct coefficient control - these must be non-zero when trigger=1 to hear an effect
            PV_Freezish(fftChain,
                (atkCoeff[i] * trigger[i]).clip(0, 0.99),  // Clip to prevent exactly 1.0
                (dcyCoeff[i] * trigger[i]).clip(0, 0.99)   // Clip to prevent exactly 1.0
            ),
            // Time-based control - convert time to coefficient
            PV_Freezish(fftChain,
                (1 - (1/atkTime[i])).clip(0, 0.99) * trigger[i],  // Convert attack time to coefficient
                (1 - (1/dcyTime[i])).clip(0, 0.99) * trigger[i]   // Convert decay time to coefficient
            )
        ]);

        IFFT(fftChain);
    };

    // Ensure mix is working correctly
    sig = XFade2.ar(source, sig, (mix * 2 - 1).clip(-1, 1));

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Enhanced spectral freeze effect with nuanced control over attack and decay", category: "Effect/Time/Freeze");
)