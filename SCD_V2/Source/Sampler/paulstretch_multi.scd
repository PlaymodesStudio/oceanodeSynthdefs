(
~synthCreator.value("PaulStretch", {|n|
    var buf, buf2, stretch, window, amp;
    var trigPeriod, sig, chain, trig, pos, fftSize;

    // Controls
    buf = OceanodeBuffer.kr(\bufnum);
    buf2 = OceanodeBuffer.kr(\envbuf);
    stretch = OceanodeParameter.ar(\stretch, 100, n, 1, 20000, "vf");
    window = OceanodeParameterDropdown.kr(\windowsize, 1, n, "0.1:0.25:0.5:1.0");
    amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

    // Convert dropdown selection to actual window size
    window = Select.kr(window, [0.1, 0.25, 0.5, 1.0]);

    // Calculating fft buffer size according to suggested window size
    fftSize = 2**floor(log2(window * SampleRate.ir));

    // Grain parameters
    // The grain is the exact length of the FFT window
    trigPeriod = fftSize / SampleRate.ir;
    trig = Impulse.ar(1 / trigPeriod);

    // Process each channel separately
    sig = Array.fill(n, {|i|
        var channelSig, processedSig;

        // Create two phase-displaced position streams for each channel
        pos = [
            Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod / stretch)),
            Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod / stretch))
        ];

        // Extract 2 consecutive grains for superposition
        channelSig = [
            GrainBuf.ar(1, trig, trigPeriod, buf, 1, pos[0], i, envbufnum: buf2),
            GrainBuf.ar(1, trig, trigPeriod, buf, 1, pos[1] + (trigPeriod / (2 * stretch)), i, envbufnum: buf2)
        ];

        // FFT processing for each grain
        processedSig = channelSig.collect({ |item, j|
            var fftChain;
            fftChain = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
            fftChain = PV_Diffuser(fftChain, 1 - trig);
            IFFT(fftChain, wintype: -1);
        });

        // Reapply the grain envelope
        processedSig = processedSig * PlayBuf.ar(1, buf2, 1 / (trigPeriod), loop: 1);

        // Delay second grain by half a grain length for superposition
        processedSig[1] = DelayC.ar(processedSig[1], trigPeriod / 2, trigPeriod / 2);

        // Mix the two grains
        Mix.new(processedSig) * amp;
    });

    // Output multichannel signal
    Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Extreme time stretching using the PaulStretch algorithm", category: "Source/Sampler");
)