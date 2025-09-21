(
~synthCreator.value("PaulStretch", {|n|
    var buf, buf2, stretch, window, amp;
    var trigPeriod, sigL, sigR, chainL, chainR, trig, posL, posR, fftSize, sampleRateCorrection;

    // Controls
    buf = OceanodeBuffer.kr(\bufnum);
    buf2 = OceanodeBuffer.kr(\envbuf);
    stretch = OceanodeParameter.ar(\stretch, 50, n, 1, 200, "vf");
    window = OceanodeParameterDropdown.kr(\windowsize, 1, n, "0.1:0.25:0.5:1.0");
    amp = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

    // Sample rate correction
    sampleRateCorrection = BufSampleRate.kr(buf) / SampleRate.ir;

    // Convert dropdown selection to actual window size
    window = Select.kr(window, [0.1, 0.25, 0.5, 1.0]);

    // Calculating fft buffer size according to suggested window size
    fftSize = 2**floor(log2(window * BufSampleRate.kr(buf)));

    // Grain parameters
    // The grain is the exact length of the FFT window
    trigPeriod = fftSize / BufSampleRate.kr(buf);
    trig = Impulse.ar(1 / trigPeriod * sampleRateCorrection);

    posL = Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod / stretch));
    posR = Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod / stretch));

    // Extraction of 2 consecutive grains for left channel
    sigL = [
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, posL, 0, envbufnum: buf2),
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, posL + (trigPeriod / (2 * stretch)), 0, envbufnum: buf2)
    ] * amp;

    // Extraction of 2 consecutive grains for right channel
    sigR = [
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, posR, 1, envbufnum: buf2),
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, posR + (trigPeriod / (2 * stretch)), 1, envbufnum: buf2)
    ] * amp;

    // FFT processing for left channel
    sigL = sigL.collect({ |item|
        chainL = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
        chainL = PV_Diffuser(chainL, 1 - trig);
        IFFT(chainL, wintype: -1);
    });

    // FFT processing for right channel
    sigR = sigR.collect({ |item|
        chainR = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
        chainR = PV_Diffuser(chainR, 1 - trig);
        IFFT(chainR, wintype: -1);
    });

    // Reapply the grain envelope because the FFT phase randomization removes it
    sigL = sigL * PlayBuf.ar(1, buf2, (1 / trigPeriod) * sampleRateCorrection, loop: 1);
    sigR = sigR * PlayBuf.ar(1, buf2, (1 / trigPeriod) * sampleRateCorrection, loop: 1);

    // Delay second grain by half a grain length for superposition
    sigL[1] = DelayC.ar(sigL[1], trigPeriod / 2, trigPeriod / 2);
    sigR[1] = DelayC.ar(sigR[1], trigPeriod / 2, trigPeriod / 2);

    // Output stereo signal
    Out.ar(OceanodeOutput.kr(\out), [Mix.new(sigL), Mix.new(sigR)]);
}, description: "Extreme time stretching using the PaulStretch algorithm", category: "Source/Sampler");
)