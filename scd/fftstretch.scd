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
}).writeDefFile(d);
)


d = thisProcess.nowExecutingPath.dirname;
