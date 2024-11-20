(
SynthDef(\peakfilter13, {
    arg out=0, in=0;
    var nch = 13;
    var out_level = \levels.kr(1!nch);
    var pitch = \pitch.kr(60!nch);
    var rq = \rq.kr(1!nch);
    var db = \db.kr(0!nch) * 60;
    var sig = In.ar(in, nch);
    sig = BPeakEQ.ar(sig, pitch.midicps, rq, db);
    sig = sig * out_level;
    Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
sms