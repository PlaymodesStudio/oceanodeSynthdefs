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

(
SynthDef(\graincloud13, {
    arg in = 0, out = 0, maxGrains = 64;
    var numChannels = 13;
    var input, circularBufs, writePos, bufFrames;
    var buf = \bufnum.kr(0);
    var amp = \levels.kr(1!numChannels, 1/30, fixedLag:true), delayTime = \delay.kr(1000!numChannels)/1000,
    grainDur = \graindur.kr(100!numChannels)/1000, pitch = \pitch.kr(0!numChannels), dryWet = \mix.kr(0.5!numChannels, 1/30, fixedLag: true);
    var trigger = \graintrig.kr(0!numChannels);
    var bufferSize = 16;
    var grainSynths;
    // Input
    input = In.ar(in, numChannels);
    // Circular buffer setup for each channel
    circularBufs = numChannels.collect {
        LocalBuf(SampleRate.ir * bufferSize, 1).clear;
    };
    bufFrames = BufFrames.kr(circularBufs[0]);
    writePos = Phasor.ar(0, 1, 0, bufFrames);
    // Write each channel to its own circular buffer
    numChannels.do { |i|
        BufWr.ar(input[i], circularBufs[i], writePos);
    };
    // Polyphonic grain synthesis for each channel
    grainSynths = numChannels.collect { |i|
        GrainBufJ.ar(
            numChannels: 1,
			trigger: trigger[i],
			dur: Demand.kr(trigger[i], 0, grainDur[i]),
            sndbuf: circularBufs[i],
			rate: Demand.kr(trigger[i], 0, pitch[i].midiratio),
			pos: Demand.kr(trigger[i], 0, (writePos - (Demand.kr(trigger[i], 0, delayTime[i]) * SampleRate.ir)) / bufFrames),
            interp: 2,
            envbufnum: buf,
            maxGrains: maxGrains
        );
    };
    // Mix dry and wet signals for each channel
    grainSynths = numChannels.collect { |i|
		XFade2.ar(input[i], grainSynths[i], dryWet[i] * 2 - 1);
    };
    // Output all channels
    Out.ar(out, grainSynths*amp);
}).writeDefFile(d);
)



d = thisProcess.nowExecutingPath.dirname;



/// per a crear envelopes
(
// Set up server
s.boot;

// Function to create and save envelope buffers
~createAndSaveEnvBuffer = { |envName, env, numSamples=1024, fileName|
    var buffer, signal;

    // Create a buffer
    buffer = Buffer.alloc(s, numSamples, 1);

    // Generate envelope signal
    signal = env.asSignal(numSamples);

    // Fill the buffer with the signal
    buffer.loadCollection(signal);

    // Write buffer to a WAV file
    buffer.write(fileName, "wav", "float");

    // Free the buffer after writing
    buffer.free;

    "Saved %: %".format(envName, fileName).postln;
};

// Wait for server to boot
s.waitForBoot({
    // Define different envelopes
    var envelopes = (
        sine: Env.sine,
        perc: Env.perc(0.05, 0.95),
        triangle: Env.triangle,
        bell: Env([0, 1, 0.3, 0], [0.05, 0.3, 0.65], [-4, -2, -4]),
        saw: Env([0, 1], [1], \linear),
        invertedSaw: Env([1, 0], [1], \linear),
        square: Env([0, 1, 1, 0], [0, 1, 0], \step),
        declickedSquare: Env([0, 1, 1, 0], [0.01, 0.98, 0.01], \sine)
    );

    // Create and save each envelope
    envelopes.keysValuesDo({ |name, env|
~createAndSaveEnvBuffer.(name, env, 1024, "/Users/santiagovilanova/Documents/SAMPLES/ENVS/env_%.wav".format(name));    });

    "All envelopes saved.".postln;
    s.quit;
});
)