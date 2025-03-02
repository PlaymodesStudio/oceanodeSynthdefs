d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\oteypiano, {
    arg out=0;
    var amp=\levels.kr(1), gate=\gate.kr(1), vel=\vel.kr(0.5), panpos=\pan.kr(0);
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
}).writeDefFile(d);
)

x = Synth(\piano);

// Trigger a note
x.set(\gate, 1, \pitch, 64);

// Release the note
x.set(\gate, 0);

// Trigger another note
x.set(\gate, 1, \pitch, 60);

(
SynthDef(\oteypiano13, {
    arg out=0;
    var amp=\levels.kr(0!13), gate=\gate.kr(0!13), vel=\vel.kr(0.5!13);
    var sig;
    var sigmlen=\sigmlen.kr(8!13);
    var env;

    // Envelope parameters with multichannel expansion
    var att = \att.kr(0.001!13);
    var dec = \dec.kr(0.001!13);
    var sus = \sus.kr(0.5!13);
    var rel = \rel.kr(5.5!13);
    var curve = \curve.kr(-4!13);

    // Use multichannel expansion - each parameter is an array of 13 values
    sig = OteyPianoStrings.ar(
        \pitch.kr(60!13).midicps, vel, gate,
        rmin: \rmin.kr(0.35!13), rmax: \rmax.kr(1!13),
        rampl: \rampl.kr(4!13), rampr: \rampr.kr(8!13),
        rcore: \rcore.kr(1!13),
        lmin: \lmin.kr(0.07!13), lmax: \lmax.kr(0.9!13),
        lampl: sigmlen.neg, lampr: sigmlen,
        rho: \rho.kr(0.1!13),
        e: \e.kr(1!13),
        zb: \zb.kr(0.3!13),
        zh: \zh.kr(0!13),
        mh: \mh.kr(1!13),
        k: \k.kr(0.05!13),
        alpha: \alpha.kr(2!13),
        p: \p.kr(0.2!13),
        hpos: \hpos.kr(0.3142!13),
        loss: \loss.kr(10.1!13),
        detune: \detune.kr(0.00003!13),
        hammer_type: \htype.kr(1!13)
    );

    // Create envelopes with controllable parameters
    env = EnvGen.ar(
        Env([0, 0, sus, 0], [att, dec, rel], curve),
        gate
    );

    // Apply envelope to the signal
    sig = sig * env;

    // Apply DC filtering and limiting to each channel
    sig = LeakDC.ar(sig);
    sig = Limiter.ar(sig, 0.9);

	sig = Select.ar(CheckBadValues.ar(sig, 0, 0) > 0, [sig, DC.ar(0)]);

    // Output all 13 channels to consecutive outputs
    Out.ar(out, sig * amp);
}).writeDefFile(d);
)