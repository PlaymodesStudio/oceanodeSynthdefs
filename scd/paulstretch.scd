
(
SynthDef(\paulstretch2, {
    arg out = 0;
    var buf=\bufnum.kr(0), buf2=\bufnum2.kr(0), stretch = \stretch.kr(50), window = 0.25, amp = \amp.kr(1);
    var trigPeriod, sigL, sigR, chainL, chainR, trig, posL, posR, fftSize;

    // Calculating fft buffer size according to suggested window size
    fftSize = 2**floor(log2(window*SampleRate.ir));

    // Grain parameters
    // The grain is the exact length of the FFT window
    trigPeriod = fftSize/SampleRate.ir;
    trig = Impulse.ar(1/trigPeriod);
    posL = Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod/stretch));
    posR = Demand.ar(trig, 0, demandUGens: Dseries(0, trigPeriod/stretch));

    // Extraction of 2 consecutive grains for left channel
    sigL = [
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, posL, 0, envbufnum: buf2),
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, posL + (trigPeriod/(2*stretch)), 0, envbufnum: buf2)
    ] * amp;

    // Extraction of 2 consecutive grains for right channel
    sigR = [
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, posR, 1, envbufnum: buf2),
        GrainBuf.ar(1, trig, trigPeriod, buf, 1, posR + (trigPeriod/(2*stretch)), 1, envbufnum: buf2)
    ] * amp;

    // FFT magic for left channel
    sigL = sigL.collect({ |item, i|
        chainL = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
        chainL = PV_Diffuser(chainL, 1 - trig);
        item = IFFT(chainL, wintype: -1);
    });

    // FFT magic for right channel
    sigR = sigR.collect({ |item, i|
        chainR = FFT(LocalBuf(fftSize), item, hop: 1.0, wintype: -1);
        chainR = PV_Diffuser(chainR, 1 - trig);
        item = IFFT(chainR, wintype: -1);
    });

    // Reapply the grain envelope because the FFT phase randomization removes it
    sigL = sigL * PlayBuf.ar(1, buf2, 1/(trigPeriod), loop:1);
    sigR = sigR * PlayBuf.ar(1, buf2, 1/(trigPeriod), loop:1);

    // Delay second grain by half a grain length for superposition
    sigL[1] = DelayC.ar(sigL[1], trigPeriod/2, trigPeriod/2);
    sigR[1] = DelayC.ar(sigR[1], trigPeriod/2, trigPeriod/2);

    // Stereo output
    Out.ar(out, [Mix.new(sigL), Mix.new(sigR)]);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

