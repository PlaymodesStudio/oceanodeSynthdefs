d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\notch13, {
    arg out=0, in=0;
    var freq = \pitch.kr(90!13).midicps;
    var width = \width.kr(50!13);
    var stages = 6;
    var filterType = \type.kr(0!13);
    var signal, filtered;

    signal = In.ar(in, 13);

    filtered = 13.collect({ |i|
        var channelSignal = signal[i];
        var rq = width[i] / freq[i];  // Convert width to rq for BRF
        var safeWidth = min(width[i], freq[i] * 1.95);  // Ensure width doesn't exceed frequency
        var lowFreq = max(20, freq[i] - (safeWidth/2));  // Ensure lower frequency is at least 20 Hz
        var highFreq = freq[i] + (safeWidth/2);
        Select.ar(filterType[i], [
            // Cascaded BRF
            stages.collect({
                channelSignal = BRF.ar(channelSignal, freq[i], rq);
            }).last,

            // Butterworth
            BHiShelf.ar(
                BLowShelf.ar(channelSignal, lowFreq, 1, -6.dbamp),
                highFreq, 1, -6.dbamp
            )
        ]);
    });

    Out.ar(out, filtered);
}).writeDefFile(d);
)