(
SynthDef(\channelshift13, { |in=0, out=0|
    var shift = \shift.kr(0);
    var sig, wrapped;
    var nch = 13;

    sig = In.ar(in, nch);
    wrapped = Array.fill(nch, { |i|
        var pos = (i + (shift * nch)) % nch;
        var frac = pos.frac;
        var idx1 = pos.floor % nch;
        var idx2 = pos.ceil % nch;

        Mix([
            Select.ar(idx1, sig) * (1 - frac),
            Select.ar(idx2, sig) * frac
        ])
    });

    Out.ar(out, wrapped);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
