
d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\sitar13, {
    arg out = 0;
    var nch = 13;
    var freq = \pitch.kr(36!nch, 1/30, fixedLag:true).midicps,
        amp = \amp.kr(0.5!nch, 1/30, fixedLag:true),
        trig = \trigg.tr(0!nch),
        pos = \pos.kr(0.1!nch, 1/30, fixedLag:true),
        bw = \bandwidth.kr(1.03!nch, 1/30, fixedLag:true),
        hc1 = \dec1.kr(1!nch, 1/30, fixedLag:true),
        hc3 = \hiloss1.kr(100!nch, 1/30, fixedLag:true),
        hfreq = \lpf1.kr(102!nch, 1/30, fixedLag:true).midicps,
        vc1 = \dec2.kr(1!nch, 1/30, fixedLag:true),
        vc3 = \hiloss2.kr(100!nch, 1/30, fixedLag:true),
        vfreq = \lpf2.kr(102!nch, 1/30, fixedLag:true).midicps,
        dry = \dry.kr(0.5!nch, 1/30, fixedLag:true),
        wet = \wet.kr(0.5!nch, 1/30, fixedLag:true),
        att = \att.kr(0.001!nch, 1/30, fixedLag:true),
        rel = \rel.kr(0.03!nch, 1/30, fixedLag:true);

    var pluck, jawari, snd, gourd;

    // Pluck impulse
    pluck = HPF.ar(WhiteNoise.ar!nch, 400) * EnvGen.kr(Env.perc(att, rel, 0.5), trig);

    // Jawari (bridge) simulation
    jawari = LocalIn.ar(nch);
    jawari = A2K.kr(jawari);
    jawari = jawari.linexp(-1, 1, bw.reciprocal, bw);

    // String simulation (horizontal and vertical planes)
    snd = [
        DWGPlucked.ar(freq * jawari, pos: pos, c1: hc1, c3: hc3, release:1000, inp: LPF.ar(pluck, hfreq)),
        DWGPlucked.ar(freq * jawari, pos: pos, c1: vc1, c3: vc3, release:1000, inp: LPF.ar(pluck, vfreq))
    ].sum;

    LocalOut.ar(snd);

    // Gourd resonance simulation
    gourd = BPF.ar(snd, [90, 132, 280], [1.3, 0.9, 1.4], [0.9, 0.6, 0.7]).sum;

    // Mixing dry and wet signals
    snd = (snd * dry) + (gourd * wet);

    Out.ar(out, snd * amp);
}).writeDefFile(d);
)

dwgsound