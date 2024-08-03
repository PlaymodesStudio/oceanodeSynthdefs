(
SynthDef(\grainclouddelay, {
    arg in = 0, out = 0;
	var bufferSize=5;
	var amp = \levels.kr(1), delayTime = \delay.kr(1),
	trigRate = \trigrate.kr(10), grainDur =\graindur.kr(0.35), rate =\pitch.kr(0).midiratio, grainOffset = \grainoffset.kr(0.1), dryWet = \mix.kr(0.5);

    var input, circularBuf, writePos, readPos;
    var granulation, delayedSig, outputSig;
    var bufFrames, grainTrig;

    // Allocate buffer within the SynthDef
    circularBuf = LocalBuf(SampleRate.ir * bufferSize, 1).clear;
    bufFrames = BufFrames.kr(circularBuf);

    // Input
    input = In.ar(in, 1);

    // Write position and recording
    writePos = Phasor.ar(0, 1, 0, bufFrames);
    BufWr.ar(input, circularBuf, writePos);

    // Read position
    readPos = Wrap.ar(writePos - (delayTime * SampleRate.ir), 0, bufFrames);

    // Grain trigger
    grainTrig = Dust.kr(trigRate);

    // Granulation
    granulation = GrainBuf.ar(
        numChannels: 2,
        trigger: grainTrig,
        dur: grainDur,
        sndbuf: circularBuf,
        rate: rate,
        pos: (readPos + TRand.ar(0, grainOffset * SampleRate.ir, grainTrig)) / bufFrames,
        interp: 2,
        pan: TRand.ar(-0.5, 0.5, grainTrig)
    );

    delayedSig = granulation * amp;
    outputSig = XFade2.ar(input!2, delayedSig, dryWet * 2 - 1);

    // Output
    Out.ar(out, outputSig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

