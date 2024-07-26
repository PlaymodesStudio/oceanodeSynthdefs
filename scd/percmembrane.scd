(
SynthDef(\percmembrane13, {
    arg out=0;
    var note = \pitch.kr(38!13);
    var amp = \levels.kr(1!13);
    var trigger = \trigger.tr(1!13);
    var tension = \tension.kr(0.5!13);
    var loss = \loss.kr(0.99!13);
    var dur = \duration.kr(1!13);
    var signal;

    signal = 13.collect { |i|
        var lossexp = LinLin.kr(loss[i], 0.0, 1.0, 0.9, 1.0);
        var excitation = EnvGen.kr(Env.perc, trigger[i], timeScale: 1, doneAction: 0) * PinkNoise.ar();
        var freq = note[i].midicps;
        var membraneSig = MembraneCircle.ar(excitation, tension[i] * (freq / 60.midicps), lossexp);
        membraneSig * EnvGen.ar(Env.perc, trigger[i], amp[i], 0, dur[i], doneAction: 0);
    };

    Out.ar(out, signal);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

// Test the synth
x = Synth(\percmembrane13);

// Trigger 2 channels
x.set(\trigger, [1,1]);
