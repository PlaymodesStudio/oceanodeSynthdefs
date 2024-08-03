(
SynthDef(\grainCloudDelay, {
    | inBus = 0, outBus = 0, amp = 1, delayTime = 1,
      trigRate = 60, grainDur = 0.35, grainDurOff=0.5, rate = 1,
      grainOffset = 0.1, dryWet = 0.5, bufferSize = 5 |

    var input, circularBuf, writePos, readPos;
    var granulation, delayedSig, outputSig;
    var bufFrames, grainTrig;

    // Allocate buffer within the SynthDef
    circularBuf = LocalBuf(SampleRate.ir * bufferSize, 1).clear;
    bufFrames = BufFrames.kr(circularBuf);

    // Input
    input = In.ar(inBus, 1);

    // Write position and recording
    writePos = Phasor.ar(0, 1, 0, bufFrames);
    BufWr.ar(input, circularBuf, writePos);

    // Read position
    readPos = Wrap.ar(writePos - (delayTime * SampleRate.ir), 0, bufFrames);

    // Grain trigger
    grainTrig = Impulse.ar(trigRate);

    // Granulation
    granulation = GrainBuf.ar(
        numChannels: 2,
        trigger: grainTrig,
        dur: grainDur + TRand.ar(0, grainDurOff, grainTrig),
        sndbuf: circularBuf,
        rate: rate,
        pos: (readPos + TRand.ar(0, grainOffset * SampleRate.ir, grainTrig)) / bufFrames,
        interp: 2,
        pan: TRand.ar(-0.5, 0.5, grainTrig)
    );

    delayedSig = granulation * amp;
    outputSig = XFade2.ar(input!2, delayedSig, dryWet * 2 - 1);

    // Output
    Out.ar(outBus, outputSig);
}).add;
)

// Example usage:
(
// Load a sample
b = Buffer.read(s, "/Users/santiagovilanova/Desktop/GEN_DAW/locucioHistograms.wav");

// Create an audio bus for input
~inputBus = Bus.audio(s, 1);

// Input synth (playing the sample)
~input = {
    var sig = PlayBuf.ar(1, b, BufRateScale.kr(b), loop: 1);
    Out.ar(~inputBus, sig);
}.play;

// Graincloud delay synth
~grainDelay = Synth(\grainCloudDelay, [
    \inBus, ~inputBus,
    \outBus, 0,
    \delayTime, 0.25,
    \trigRate, 40,
    \grainDur, 0.20,
    \rate, 1,
    \grainOffset, 0.405,
    \dryWet, 0.5,
    \bufferSize, 10
]);
)

// Modifying parameters
~grainDelay.set(\delayTime, 0.15);
~grainDelay.set(\trigRate, 100);
~grainDelay.set(\grainDur, 0.05);
~grainDelay.set(\rate, 1.0);
~grainDelay.set(\grainOffset, 0.01);
~grainDelay.set(\dryWet, 0.7);

// Clean up
(
~grainDelay.free;
~input.free;
b.free;
)