(
File.mkdir(d ++ "/bufalloc");

// Hybrid bufalloc: supports both fragment and circular modes
SynthDef(\bufalloc, {
    arg in = 0, buf = 0, record = 0, loop = 0;
    var sig = In.ar(in, 1);
    var shouldRecord = record > 0;
    var phase = Phasor.ar(shouldRecord, shouldRecord, 0, BufFrames.kr(buf), 0);
    BufWr.ar(sig, buf, phase, loop: loop > 0);
}).writeDefFile(d ++ "/bufalloc");

"✓ hybrid bufalloc SynthDef written".postln;
)