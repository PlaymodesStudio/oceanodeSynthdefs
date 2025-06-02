(
File.mkdir(d ++ "/" ++ "recbuf");

(1..24).do { |nCh|
    var name = ("recbuf" ++ nCh).asSymbol;
    SynthDef(name, {
        arg in, buf, record = 0;
        var sig = In.ar(in, nCh);
        var phase = Phasor.ar(record, 1, 0, BufFrames.kr(buf)); // avança només si record=1
        BufWr.ar(sig, buf, phase, loop: 0);
        // res a enviar a la sortida
    }).writeDefFile(d ++ "/recbuf");
    name.postln;
};

"✓ recbuf SynthDefs escrits".postln;
)