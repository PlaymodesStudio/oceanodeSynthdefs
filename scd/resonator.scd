(
SynthDef(\resonator13, {
    arg in=0, out=0;
    var numChannels=13;
    var numVoices = 16;
    var baseFreq = \pitch_16.kr(36!numVoices, 1/30, fixedLag:true).midicps,
        fbGain = \fb_16.kr(0.998!numVoices, 1/30, fixedLag:true),
        lpCutoff = \lp_16.kr(60!numVoices, 1/30, fixedLag:true).midicps,
        mix = \mix.kr(1!numChannels, 1/30, fixedLag:true),
        amp = \levels.kr(1!numChannels, 1/30, fixedLag:true);
    var input=In.ar(in,numChannels);
    var maxDelayTime = 1/20;
    var voices, wet, output;

    output = Array.fill(numChannels, { |chanNum|
        var chan = input[chanNum];
        voices = Array.fill(numVoices, { |i|
            var delayTime = 1/baseFreq[i];
            var decayTime = -3 * delayTime / log(abs(fbGain[i]));
            var filtered;

            filtered = LPF.ar(
                CombC.ar(
                    chan,
                    maxdelaytime: maxDelayTime,
                    delaytime: delayTime,
                    decaytime: decayTime
                ),
                lpCutoff[i]
            );
            filtered
        });
        wet = Mix.ar(voices) / numVoices.sqrt;
        (chan * (1 - mix[chanNum])) + (wet * mix[chanNum]) * amp[chanNum];
    });
    Out.ar(out, LeakDC.ar(output));
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
