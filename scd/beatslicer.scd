// The beat slicer SynthDef
SynthDef(\beatSlicer, {
	arg out=0, bufnum=0;
	var sliceBuf=0, slice=0, rate=1, amp=0.5, pan=0;
    var sig, numFrames, startPos, endPos, phase, env;

    // Read slice positions
    startPos = BufRd.kr(1, sliceBuf, slice, loop: 1);
    endPos = BufRd.kr(1, sliceBuf, slice + 1, loop: 1);

    // Create a phase that loops between start and end of slice
    phase = Phasor.ar(
        trig: 1,
        rate: BufRateScale.kr(bufnum) * rate,
        start: startPos,
        end: endPos,
        resetPos: startPos
    );

    // Read the buffer with interpolation
    sig = BufRd.ar(
        numChannels: 2,
        bufnum: bufnum,
        phase: phase,
        loop: 1,
        interpolation: 4
    );

    // Apply envelope to avoid clicks
    env = EnvGen.kr(
        Env.asr(0.001, 1, 0.005),
        gate: 1,
        doneAction: 2
    );

    // Output processing
    sig = sig * env * amp;
    sig = Balance2.ar(sig[0], sig[1], pan);

    Out.ar(out, sig);
}).add;

// Example usage:

// Load your buffer
~buffer = Buffer.read(s, "/Users/santiagovilanova/Documents/SAMPLES/breaks/limelite1_95bpm.wav");

// Create a buffer for slice points
~slicePoints = Buffer(s);

// Analyze using FluidBufOnsetSlice
FluidBufOnsetSlice.processBlocking(s, ~buffer,
    indices: ~slicePoints,
    metric: 8,           // ComplexDev mode
    threshold: 0.2,      // Adjust sensitivity
    minSliceLength: 2,   // Minimum slice in hops
    filterSize: 3,       // Smoothing filter size
    windowSize: 512,     // Smaller window for better temporal precision
    hopSize: 128,        // Higher overlap for better detection
    action: {"Done slicing".postln;}
);

// Play individual slice
Synth(\beatSlicer, [
    \bufnum, ~buffer,
    \sliceBuf, ~slicePoints,
    \slice, 4  // First slice
]);

// Or sequence them
Pdef(\slicePattern,
    Pbind(
        \instrument, \beatSlicer,
        \bufnum, ~buffer,
        \sliceBuf, ~slicePoints,
        \slice, Pseq((0..7), inf),  // sequence through first 8 slices
        \dur, 0.25,
        \rate, 1,
        \amp, 0.5
    )
).play;
*/