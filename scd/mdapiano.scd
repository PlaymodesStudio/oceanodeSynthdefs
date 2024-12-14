(
SynthDef(\mdapiano13, {
    arg out=0;
    var freq = \pitch.kr(36 ! 13).midicps,
    gate = \gate.kr(0 ! 13),
    vel = \vel.kr(80 ! 13),
    decay = \decay.kr(0.8 ! 13),
    release = \release.kr(0.8 ! 13),
    random = \random.kr(0.1 ! 13),
    sustain = \sustain.kr(0 ! 13),
    hard = \hard.kr(0.8 ! 13),
    velhard = \velhard.kr(0.8 ! 13),
    muffle = \muffle.kr(0.8 ! 13),
    velmuff = \velmuff.kr(0.8 ! 13),
    velcurve = \velcurve.kr(0.8 ! 13),
    tune = \tune.kr(0.5 ! 13),
    levels = \levels.kr(0.1 ! 13);

    // Create 13 independent piano voices
    var signals = 13.collect({ |i|
        MdaPiano.ar(
            freq[i],
            gate[i],
            release: release[i],
            stereo: 0,  // mono output per channel
            sustain: sustain[i],
            random: random[i],
            decay: decay[i],
            hard: hard[i],
            velhard: velhard[i],
            muffle: muffle[i],
            velmuff: velmuff[i],
            vel: vel[i],
            velcurve: velcurve[i],
            tune: tune[i]
        ) * levels[i]
    });

    Out.ar(out, signals);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
