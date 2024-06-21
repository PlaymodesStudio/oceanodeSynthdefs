(
SynthDef(\blur, {
	arg out,in;

	var blur=0, blurq=3, blurm=1;
    var signal, outsignal, frameSize, frameRate, frameTime, source, kernel, convolved;
    signal = In.ar(in, 2);

    frameSize = 2048;
    frameRate = s.sampleRate/frameSize;
    frameTime = frameRate.reciprocal;
    RandSeed.kr(Impulse.ar(frameRate*blurm),blur); // makes sure the noise repeats every frame
    kernel = WhiteNoise.ar() * LFGauss.ar(frameTime, 1/blurq); // my kernel is this repeated noise wrapped in a gaussian shape
    outsignal = Convolution.ar(signal, kernel, frameSize, 0.1);

    ReplaceOut.ar(out, outsignal);
}).add;
)

d = thisProcess.nowExecutingPath.dirname;
