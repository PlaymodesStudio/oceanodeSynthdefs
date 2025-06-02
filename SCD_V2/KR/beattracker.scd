File.mkdir(d ++ "/" ++ "beatTracker");

(1..~maxVoices).do({ arg n;
    var numChan = n;
    SynthDef.new(\beatTracker ++ numChan.asSymbol, {
        arg in, quarter, eighth, sixteenth, tempo;
        var input, fft, q, e, s, bpm;
        var qPulse = Array.newClear(numChan);
        var ePulse = Array.newClear(numChan);
        var sPulse = Array.newClear(numChan);
        var tempoBPM = Array.newClear(numChan);

        input = In.ar(in, numChan);

        numChan.do { |i|
            var ffti = FFT(LocalBuf(1024), input[i]);
            #q, e, s, bpm = BeatTrack.kr(ffti, 0);
            qPulse[i] = Decay.kr(q, 0.1);
            ePulse[i] = Decay.kr(e, 0.1);
            sPulse[i] = Decay.kr(s, 0.1);
            tempoBPM[i] = bpm * 60;
        };

        Out.kr(quarter, qPulse);
        Out.kr(eighth, ePulse);
        Out.kr(sixteenth, sPulse);
        Out.kr(tempo, tempoBPM);
    }).writeDefFile(d ++ "/beatTracker");
});
