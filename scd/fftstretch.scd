// Load the buffer
g = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
SynthDef(\fftstretch, {
    arg out=0;
	var buf=\bufnum.kr(0);
	var overlaps=2, fftSize=16384;
	var chain, pos, fftBuf, levels=\levels.kr(1!2, 1/30, fixedLag: true);

	pos=\pos.kr(0, 1/30, fixedLag: true);
	pos=pos*BufFrames.kr(buf);

    // Allocate a local buffer for FFT processing
    fftBuf = LocalBuf(fftSize!overlaps);

    // Creating the chain with BufFFTTrigger
    chain = BufFFTTrigger(fftBuf, 1/overlaps, (0..(overlaps-1)), overlaps);

    // Processing the FFT chain
    chain = BufFFT_BufCopy(chain, buf, pos, BufRateScale.kr(buf));
    chain = BufFFT(chain);
    chain = PV_Diffuser(chain, chain > -1);

    // IFFT and envelope
    chain = Mix(BufIFFT(chain, 0)).dup * 0.8;

    // Outputting the audio
    Out.ar(out, chain*levels);
}).draw;
)


d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\fftstretch2, {
    arg out=0;
    var buf=\bufnum.kr(0);
    var overlaps=2, fftSize=16384;
    var chain, pos, fftBuf, levels=\levels.kr(1!2, 1/30, fixedLag: true);
    pos=\pos.kr(0, 1/30, fixedLag: true);
    pos=pos*BufFrames.kr(buf);

    // Allocate a local buffer for FFT processing (2 channels)
    fftBuf = LocalBuf(fftSize!overlaps, 2);

    // Creating the chain with BufFFTTrigger (2 channels)
    chain = BufFFTTrigger(fftBuf, 1/overlaps, (0..(overlaps-1)), overlaps);

    // Processing the FFT chain (2 channels)
    chain = BufFFT_BufCopy(chain, buf, pos, BufRateScale.kr(buf));
    chain = BufFFT(chain);
    chain = PV_Diffuser(chain, chain > -1);

    // IFFT and envelope (2 channels)
    chain = BufIFFT(chain, 0) * 0.8;

    // Sum overlaps for each channel separately
    chain = chain.sum;

    // Outputting the stereo audio
    Out.ar(out, chain * levels);
}).writeDefFile(d);
)

(
SynthDef(\fftstretch2rate, {
    arg out=0;
    var buf=\bufnum.kr(0!2), overlaps=2, fftSize=16384;
    var chains, pos, fftBuf, levels=\levels.kr(1!2, 1/30, fixedLag: true);
    var rate = \rate.kr(1!2, 1/30, fixedLag: true);

    pos=\pos.kr(0!2, 1/30, fixedLag: true)*BufFrames.kr(buf);

    chains = 2.collect({ |i|
        var chain;
        fftBuf = LocalBuf(fftSize!overlaps);
        chain = BufFFTTrigger(fftBuf, 1/overlaps, (0..(overlaps-1)), overlaps);
        chain = BufFFT_BufCopy(chain, buf[i], pos[i], rate[i]*BufRateScale.kr(buf[i]));
        chain = BufFFT(chain);
        chain = PV_Diffuser(chain, chain > -1);
        Mix(BufIFFT(chain, 0)) * 0.8 * levels[i];
    });

    Out.ar(out, chains);
}).draw;
)

(
SynthDef(\fftstretch6, {
    arg out=0;
    var buf=\bufnum.kr(0), overlaps=2, fftSize=16384;
    var chains, pos, numChan=6;
    var levels=\levels.kr(1!numChan, 1/30, fixedLag: true);
    var rate = \rate.kr(1!numChan, 1/30, fixedLag: true);

    pos=\pos.kr(0!numChan, 1/30, fixedLag: true)*BufFrames.kr(buf);

    chains = Array.fill(numChan, { |i|
        var fftBuf = LocalBuf(fftSize!overlaps);
        var chain = BufFFTTrigger(fftBuf, 1/overlaps, [0,1], overlaps);
        chain = BufFFT_BufCopy(chain, buf, pos[i], rate[i]*BufRateScale.kr(buf));
        chain = BufFFT(chain);
        chain = PV_Diffuser(chain, 1);
        chain = BufIFFT(chain, 0);
        Mix.ar(chain) * 0.8 * levels[i];
    });

    Out.ar(out, chains);
}).writeDefFile(d);
)

//this one needs blocksize >=128
(
SynthDef(\fftstretch13, {
    arg out=0;
    var buf=\bufnum.kr(0), overlaps=2, fftSize=16384;
    var chains, pos, numChan=13;
    var levels=\levels.kr(1!numChan, 1/30, fixedLag: true);
    var rate = \rate.kr(1!numChan, 1/30, fixedLag: true);

    pos=\pos.kr(0!numChan, 1/30, fixedLag: true)*BufFrames.kr(buf);

    chains = Array.fill(numChan, { |i|
        var fftBuf = LocalBuf(fftSize!overlaps);
        var chain = BufFFTTrigger(fftBuf, 1/overlaps, [0,1], overlaps);
        chain = BufFFT_BufCopy(chain, buf, pos[i], rate[i]*BufRateScale.kr(buf));
        chain = BufFFT(chain);
        chain = PV_Diffuser(chain, 1);
        chain = BufIFFT(chain, 0);
        Mix.ar(chain) * 0.8 * levels[i];
    });

    Out.ar(out, chains);
}).writeDefFile(d);
)









