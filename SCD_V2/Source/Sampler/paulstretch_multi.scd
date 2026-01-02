(
~synthCreator.value("PaulStretch", {|n|
    var buf, buf2, stretch, window, amp;
    var trigPeriod, sig, trig, pos, fftSize, sampleRateCorrection;
    var windowSizes, fftBuf, fftBuf2, chain1, chain2, processedSig, delayedSig;

    // Controls
    buf = OceanodeParameter.kr(\bufnum, 0, n, 0, 1000, "vi");
    buf2 = OceanodeBuffer.kr(\envbuf);
    stretch = OceanodeParameterLag.ar(\stretch, 100, n, 1, 20000, "vf", 1/30, true);
    window = OceanodeParameterDropdown.kr(\windowsize, 1, n, "0.1:0.25:0.5:1.0");
    amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);

    // Pre-calculate window sizes
    windowSizes = [0.1, 0.25, 0.5, 1.0];
    window = Select.kr(window, windowSizes);

    // Use first buffer for global calculations (assuming similar sample rates)
    sampleRateCorrection = BufSampleRate.kr(buf.asArray[0]) / SampleRate.ir;
    fftSize = 2**floor(log2(window.asArray[0] * BufSampleRate.kr(buf.asArray[0])));
    trigPeriod = fftSize / BufSampleRate.kr(buf.asArray[0]);
    trig = Impulse.ar(1 / trigPeriod * sampleRateCorrection);

    // Create position streams using multichannel expansion
    pos = [
        Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod / stretch)),
        Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod / stretch))
    ];

    // Process grains with multichannel expansion
    sig = [
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, pos[0], 2, envbufnum: buf2),
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, pos[1] + (trigPeriod / (2 * stretch)), 2, envbufnum: buf2)
    ];

    // Separate FFT buffers for each grain
    fftBuf = LocalBuf(fftSize);
    fftBuf2 = LocalBuf(fftSize);

    // FFT processing
    chain1 = FFT(fftBuf, sig[0], hop: 1.0, wintype: -1);
    chain1 = PV_Diffuser(chain1, 1 - trig);
    processedSig = IFFT(chain1, wintype: -1);

    chain2 = FFT(fftBuf2, sig[1], hop: 1.0, wintype: -1);
    chain2 = PV_Diffuser(chain2, 1 - trig);
    delayedSig = IFFT(chain2, wintype: -1);

    // Reapply envelope
    processedSig = processedSig * PlayBuf.ar(1, buf2, (1 / trigPeriod) * sampleRateCorrection, loop: 1);
    delayedSig = delayedSig * PlayBuf.ar(1, buf2, (1 / trigPeriod) * sampleRateCorrection, loop: 1);

    // Delay second grain
    delayedSig = DelayC.ar(delayedSig, trigPeriod / 2, trigPeriod / 2);

    // Mix and apply amplitude
    sig = (processedSig + delayedSig) * amp;

    // Output
    Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Extreme time stretching using the PaulStretch algorithm", category: "Source/Sampler");
)