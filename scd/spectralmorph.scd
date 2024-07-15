(
SynthDef(\spectralmorph, {
	arg buf1, buf2, in, in2, out;
    var chain, chain2, cepsch, cepsch2, sig;
    var fftsize, fftbufc, fftbufm, cepbufc, cepbufm, envc, envm;
    fftsize = 2048;
    //fft buffers
    fftbufc = LocalBuf(fftsize);
    fftbufm = LocalBuf(fftsize);
    //cepstrum buffers
    cepbufc = LocalBuf(fftsize * 0.5);
    cepbufm = LocalBuf(fftsize * 0.5);
    //spectral envelope buffers
    envc = LocalBuf(fftsize);
    envm = LocalBuf(fftsize);
    // 1. STFT of signal
    // 2. smooth spectral envelope
    // get cepstrum of modulating signal
    in = PlayBuf.ar(1, buf1, BufRateScale.kr(buf1), 1, 0, 1);
    chain = FFT(fftbufc, in);
    cepsch = Cepstrum(cepbufm, chain);
    // get cepstrum of carrier signal
    in2 = PlayBuf.ar(1, buf2, BufRateScale.kr(buf2), 1, 0, 1);
    chain2 = FFT(fftbufm, in2);
    cepsch2 = Cepstrum(cepbufc, chain2);
    // PV_BrickWall can act as a low-pass filter, or here, as a wol-pass lifter...
    // ...in practical terms, produces a smoothed version of the spectrum
    // get smooth version of modulator
    cepsch = PV_BrickWall(cepsch, -0.95);
    ICepstrum(cepsch, envm);
    // get smoothed version of carrier
    cepsch2 = PV_BrickWall(cepsch2, -0.95);
    ICepstrum(cepsch2, envc);
    // 3. divide spectrum of each carrier frame by
    // smooth spectral envelope (to flatten)
    chain2 = chain2.pvcalc2(envc, fftsize, {|mags, phases, mags2, phases2|
        [mags / (mags2 + 1e-8), (phases - phases2).wrap2(-pi, pi)]
    }, frombin: 0, tobin: 256, zeroothers: 0);
    // 4. multiply flattened spectral carrier frame with smooth spectral envelope
    // of modulator
    chain2 = chain2.pvcalc2(envm, fftsize, {|mags, phases, mags2, phases2|
        [mags * mags2, (phases + phases2).wrap2(-pi, pi)]
    }, frombin: 0, tobin: 256, zeroothers: 0);

    sig = Pan2.ar(IFFT(chain2));
    sig = sig.sanitize;
    Out.ar(out, sig);
}).writeDefFile(d);
)