d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\guttersynth, {
	arg out=0;
    var sig, freqs1, freqs2, pitch,pan;
    var mod, omega, damp, rate, gain, soften, gain1, gain2, q1, q2,dist;

    mod = \mod.kr(0.2); //0-10
    omega = \omega.kr(0.0002); //0.0001-1
    damp = \damp.kr(0.01);//0.0001-1
    rate = \rate.kr(0.03);//0-5
    gain = \gain.kr(1.4);//0-4
    soften = \soften.kr(1);//0-5
    gain1 = \gain1.kr(1.5);//0-2
    gain2 = \gain2.kr(1.5);//0-2
	dist=\distortionmethod.kr(1);//0-4
	freqs1=\freqs1.kr(20!24);
	freqs2=\freqs2.kr(25!24);
	q1=\q1.kr(10!24); //10-1000
	q2=\q2.kr(10!24); //10-1000
	pan=\pan.kr(0);

    sig = GutterSynth.ar(
        gamma:         mod,
        omega:         omega,
        c:             damp,
        dt:         rate,
        singlegain: gain,
        smoothing:  soften,
        togglefilters: 1,
		distortionmethod: dist,
        oversampling: 1,
        enableaudioinput: 0,
        audioinput: SinOsc.ar(90),
        gains1:     gain1,
        gains2:     gain2,
		freqs1:     freqs1,
        qs1:        q1,
        freqs2:     freqs2,
        qs2:        q2,
    );

    sig = Pan2.ar(sig, pan);
    sig = Limiter.ar(sig);

	Out.ar(out, sig);

}).writeDefFile(d);
)