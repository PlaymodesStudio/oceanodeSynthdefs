(
SynthDef(\dccorrection13, {
    arg in=0, out=0;
    var input, corrected;

    // Input signal from the specified bus - expecting 13 channels
    input = In.ar(in, 13);

    // Apply DC correction
    corrected = LeakDC.ar(input);

    // Output the DC corrected signal
    Out.ar(out, corrected);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
