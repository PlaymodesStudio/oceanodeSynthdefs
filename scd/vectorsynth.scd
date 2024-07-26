(
SynthDef(\vectorsynth13, {
    arg out=0;
    var nearestEven, nearestOdd, vps;
    var freq = \pitch.kr(36!13, 1/30, fixedLag: true).midicps;
    var horizontal = \horizontal.kr(0.3!13, 1/30, fixedLag: true); // 0.001 to 0.99999
    var vertical = \vertical.kr(5.5!13, 1/30, fixedLag: true); // 1 to 10
    var amp = \levels.kr(1!13, 1/30, fixedLag: true);
    var pmIndex = \pmindex.kr(4!13, 1/30, fixedLag: true); // PM index (modulation depth)
    var pmFreq = \pmpitch.kr(48!13, 1/30, fixedLag: true).midicps;  // PM frequency
    var sig;

    nearestEven = {
        arg val;
        var val_floor, val_ceil, res, distance;
        val_floor = val.floor;
        val_ceil = val.ceil;
        res = Select.ar(val % 2,
            [ val_floor, val_ceil ],
        );
        distance = (val - res).abs;
        [ res, distance ];
    };
    nearestOdd = {
        arg val;
        var val_floor, val_ceil, res, distance;
        val_floor = val.floor;
        val_ceil = val.ceil;
        res = Select.ar(val + 1 % 2,
            [ val_floor, val_ceil ],
        );
        distance = (val - res).abs;
        [ res, distance ];
    };
    vps = { |trig, freq, horizontal, vertical, pmIndex, pmFreq|
        var vertical_even = nearestEven.(vertical);
        var vertical_odd = nearestOdd.(vertical);
        var cos, phasor, sig, phaseModulation;
        vertical = [vertical_even[0], vertical_odd[0]];
        phasor = Phasor.ar(Impulse.ar(trig), freq/2 * SampleDur.ir, horizontal.neg, 1-horizontal, horizontal.neg);
        phasor = phasor.bilin(0, horizontal.neg, 1-horizontal, vertical, 0, 1);

        // Phase modulation
        phaseModulation = SinOsc.ar(pmFreq) * pmIndex;
        cos = ((phasor + phaseModulation) * 2pi).cos.neg;

        sig = XFade2.ar(cos[0], cos[1], vertical_even[1] * 2 - 1);
        sig = LeakDC.ar(sig);
        sig;
    };

    sig = vps.(0, freq, horizontal, K2A.ar(vertical), pmIndex, pmFreq);
    Out.ar(out, sig * amp);
}).writeDefFile(d); // Note: changed .play() to .add()
)

d = thisProcess.nowExecutingPath.dirname;
