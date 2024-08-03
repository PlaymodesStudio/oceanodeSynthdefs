(
SynthDef(\pulsar2, {
	arg out=0;
	var freq=\pitch.kr(36!13).midicps, grainFreq=\grainfreq.kr(1800!13), overlap=\overlap.kr(4!13), index=\index.kr(40!13), skew=\skew.kr(0.25!13), lfoFreq=\lfofreq.kr(1!13), lfoAmount=\lfoamp.kr(0.5!13),
	level=\levels.kr(1!13);
    var trig, phase, windowPhase, rectWindow, mod, sig;
    var measurePhase, measureSlope, accumulator, lfoPhase, transferFunc, lfo;

    // Main phase and slope
    measurePhase = (Phasor.ar(0, freq * SampleDur.ir) - SampleDur.ir).wrap(0, 1);
    measureSlope = (measurePhase - Delay1.ar(measurePhase)).wrap(-0.5, 0.5);

    // Accumulator for LFO
    accumulator = Duty.ar(SampleDur.ir, 0, Dseries(0, 1));
    lfoPhase = (measureSlope / lfoFreq * accumulator).wrap(0, 1);
    lfo = sin(lfoPhase * 2pi);

    // Pulsar synthesis
    trig = Impulse.ar(freq * (1 + (lfo * lfoAmount)));
    phase = Sweep.ar(trig, grainFreq);
    windowPhase = phase / overlap;
    rectWindow = windowPhase < 1;

    // Phase shaping function
    transferFunc = { |ph, sk|
        ph = ph.linlin(0, 1, sk.neg, 1 - sk);
        ph.bilin(0, sk.neg, 1 - sk, 0.5, 0, 1);
    };

    mod = cos(transferFunc.(windowPhase, skew) * 2pi).neg * 0.5 + 0.5;
    sig = SinOsc.ar(phase + (mod * (0.5 - skew) * index * overlap) * 2pi);
    sig = sig * rectWindow;

    Out.ar(out, sig*level);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;


(
x = Synth(\pulsarSynthWithLFO, [
    \freq, 800,
    \grainFreq, 800,
    \overlap, 4,
    \index, 4,
    \skew, 0.825,
	\lfoFreq, 10,
    \lfoAmount, 1.5
]);
)

x.set(\freq, 700);
x.set(\lfoFreq, 0.915);
x.set(\lfoAmount, 10.8);