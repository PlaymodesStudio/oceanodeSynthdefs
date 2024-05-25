// Load the buffer
g = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
SynthDef(\timeStretch, {
    arg out=0;
	var bufnum=0, stretch=5, overlaps=2, fftSize=16384;
    var chain, demand, pos, fftBuf, trig,offset;

	trig=\trig.kr(1);
	pos=\pos.kr(0);
	pos=pos*BufFrames.kr(0);

    // Allocate a local buffer for FFT processing
    fftBuf = LocalBuf(fftSize!overlaps);

    // Creating the chain with BufFFTTrigger
    chain = BufFFTTrigger(fftBuf, 1/overlaps, (0..(overlaps-1)), overlaps);

	pos=MouseX.kr(0,BufFrames.kr(0));

    // Processing the FFT chain
    chain = BufFFT_BufCopy(chain, bufnum, pos, BufRateScale.kr(bufnum));
    chain = BufFFT(chain);
    chain = PV_Diffuser(chain, chain > -1);

    // IFFT and envelope
    chain = Mix(BufIFFT(chain, 0)).dup * 0.8;

    // Outputting the audio
    Out.ar(out, chain);
}).add;
)

Synth(\timeStretch, [\bufnum, g.bufnum]);


g = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

(
SynthDef(\fftstretch, {
    arg out=0;
	var buf=0, overlaps=2, fftSize=16384;
    var chain, pos, fftBuf;

	pos=\pos.kr(0, 1/30, fixedLag: true);
	pos=pos*BufFrames.kr(0);

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
    Out.ar(out, chain);
}).writeDefFile(d);
)


d = thisProcess.nowExecutingPath.dirname;
