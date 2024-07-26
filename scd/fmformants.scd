(
SynthDef(\fmformant13, {
    arg out = 0;
    var amp = \levels.kr(1!13, 1/30, fixedLag:true);
    var k, formants, bufnum, offset5, freqs, bws, amps;
    var vibrato, mod, quotient, xfades, evenCar, oddCar, sig;
    var vowel = \vowel.kr(1!13, 1/30, fixedLag:true); // 0-4
    var freq = \pitch.kr(36!13, 1/30, fixedLag:true).midicps;
    var index = \fmindex.kr(1.44!13, 1/30, fixedLag:true);
    var vibratoSpeed = \vibf.kr(6!13, 1/30, fixedLag:true);
    var vibratoDepth = \viba.kr(4!13, 1/30, fixedLag:true);

    k = "IEAOU".collectAs({ |chr| ("tenor" ++ chr).asSymbol }, Array);
    formants = k.collect { |id| FormantTable.at(id) };
    formants = formants.flop.collect(_.flop).flat;
    bufnum = LocalBuf(75, 1).set(formants);

    vibrato = SinOsc.kr(vibratoSpeed, mul: vibratoDepth);
    freq = freq + vibrato;

    offset5 = Array.series(5, 0, 5);

    sig = 13.collect { |i|
        var ch_freqs = BufRd.kr(1, bufnum, vowel[i] + offset5, loop: 0);
        var ch_bws = BufRd.kr(1, bufnum, vowel[i] + (offset5 + 25), loop: 0);
        var ch_amps = BufRd.kr(1, bufnum, vowel[i] + (offset5 + 50), loop: 0);

        mod = SinOsc.ar(freq[i]);
        mod = mod * index[i] * ch_bws;

        quotient = ch_freqs / freq[i];
        xfades = quotient.fold(0, 1);
        evenCar = SinOsc.ar(quotient.round(2) * freq[i], mod);
        oddCar = SinOsc.ar(((quotient + 1).round(2) - 1) * freq[i], mod);

        XFade2.ar(evenCar, oddCar, xfades * 2 - 1, ch_amps).sum * amp[i];
    };

    Out.ar(out, sig);
}).writeDefFile(d);
)
d = thisProcess.nowExecutingPath.dirname;



