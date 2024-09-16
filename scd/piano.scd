(
SynthDef(\piano, {
    arg out=0;
    var amp=\levels.kr(1), gate=\gate.tr(1), vel=\vel.kr(0.5), panpos=\pan.kr(0);
    var sig, pan;
    var sigmlen=\sigmlen.kr(8);

    sig = OteyPiano.ar(
        \pitch.kr(60).midicps, vel, gate,
        rmin: \rmin.kr(0.35), rmax:\rmax.kr(1),
        rampl: \rampl.kr(4), rampr:\rampr.kr(8),
        rcore:\rcore.kr(1),
        lmin:\lmin.kr(0.07), lmax:\lmax.kr(0.9),
        lampl:sigmlen.neg, lampr: sigmlen,
        rho:\rho.kr(0.1),
        e:\e.kr(1),
        zb:\zb.kr(0.3),
        zh:\zh.kr(0),
        mh:\mh.kr(1),
        k:\k.kr(0.05),
        alpha:\alpha.kr(2),
        p:\p.kr(0.2),
        hpos:\hpos.kr(0.3142),
        loss:\loss.kr(10.1),
        detune:\detune.kr(0.00003),
        hammer_type:\htype.kr(1)
    ) * EnvGen.ar(Env([0,0,0.5,0],[0,0.001,5.5],-4), gate);

    pan = Balance2.ar(sig, sig, panpos, amp);
    pan = LeakDC.ar(pan);
    pan = Limiter.ar(pan, 0.99);
    Out.ar(out, pan)
}).play;
)

x = Synth(\piano);

// Trigger a note
x.set(\gate, 1, \pitch, 36);

// Release the note
x.set(\gate, 0);

// Trigger another note
x.set(\gate, 1, \pitch, 60);

