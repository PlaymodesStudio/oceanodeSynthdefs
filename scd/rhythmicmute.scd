(
SynthDef(\rhythmicmute, {
	arg in=0, out=0;
    var freq, threshold, signal, phasor, mutedSignal, reset;
	reset=\reset.kr(0!13);
	threshold=\pw.kr(0.5!13);
	freq=\hz.kr(1!13);

    signal = In.ar(in, 13);

    phasor = Phasor.ar(reset, freq / SampleRate.ir(), 0, 1, 0);

    mutedSignal = signal * (phasor <= threshold);

    // Output the processed signal
    Out.ar(out, mutedSignal);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

