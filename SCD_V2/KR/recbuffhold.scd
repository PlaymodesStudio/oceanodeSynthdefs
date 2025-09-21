(
File.mkdir(d ++ "/" ++ "recbufhold");

(1..16).do { |nCh|
    var name = ("recbufhold" ++ nCh).asSymbol;
    SynthDef(name, {
        arg in, buf, record = 0;
        var sig = In.ar(in, nCh);
        var phase;

        var bufFrames = BufFrames.kr(buf);
        var recordGate;

        // Phase advances only when recording
        phase = Phasor.ar(
            trig: record,
            rate: 1,
            start: 0,
            end: bufFrames,
            resetPos: 0
        );

        // Stop recording when buffer is full (phase >= bufFrames - 1)
        recordGate = record * (phase < (bufFrames - 1));

        BufWr.ar(sig * recordGate, buf, phase, loop: 0);

    }).writeDefFile(d ++ "/recbufhold");
    name.postln;
};

"✓ recbufhold SynthDefs escrits (simple version)".postln;
)

