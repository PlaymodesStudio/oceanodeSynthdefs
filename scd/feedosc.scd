(
SynthDef(\feedbackosc13, {
    arg out=0;

    // Control parameters for 13 channels
    var mainFreq = \mainpitch.kr(63 ! 13).midicps;  // Main oscillator frequency
    var mainFeedback = \mainfeed.kr(1 ! 13);  // Main oscillator feedback amount
    var freq = \pitch.kr(43 ! 13).midicps;  // Secondary oscillator frequency
    var feedback = \feed.kr(1 ! 13);  // Secondary oscillator feedback
    var width = \width.kr(0 ! 13);  // Width of secondary oscillator
    var freqMod = \freqmod.kr(500 ! 13);  // Frequency modulation amount
    var filterFreq = \lpf.kr(95 ! 13).midicps;  // Filter frequency
    var filterQ = \q.kr(1 ! 13);  // Filter resonance
    var levels = \levels.kr(0.2 ! 13);  // Output levels

    // Array to store each channel's output
    var signals = 13.collect({ |i|
        var w = [0, width[i] * 2pi];
        var buf = LocalBuf(1).clear;
        var buf2 = LocalBuf(1, 2).clear;

        // Main oscillator with feedback
        var osc = sin(
            LFSaw.ar(mainFreq[i]).range(0, 2pi) +
            (Dbufrd(buf) * mainFeedback[i])
        );
        var snd = Duty.ar(SampleDur.ir, 0, Dbufwr(osc, buf));

        // Secondary oscillator with feedback
        var osc2 = sin(
            LFSaw.ar(freq[i] + (snd * freqMod[i])).range(0, 2pi) +
            (Dbufrd(buf2) * feedback[i]) +
            w
        );
        var snd2 = Duty.ar(SampleDur.ir, 0, Dbufwr(osc2, buf2));

        // Filter and output
        DFM1.ar(snd2, filterFreq[i], filterQ[i]) * levels[i];
    });

    Out.ar(out, signals);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
