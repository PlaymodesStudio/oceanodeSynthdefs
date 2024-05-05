SynthDef(\stereopan78, {
	arg in=0, out=0;
	var signals, pannedSignals, mixedSignal;

	// Input signal from the specified bus - expecting 13 channels
	signals = In.ar(in, 78);

	// Panning for each channel - expecting 13 panning values
	pannedSignals = Array.fill(78, {|i|
		Pan2.ar(signals[i], \pan.kr(0, i).range(-1, 1))
	});

	// Mix all panned signals into a stereo output
	mixedSignal = Mix.new(pannedSignals);

	// Output
	Out.ar(out, mixedSignal);
}).writeDefFile(d);

(
SynthDef(\stereopan6, {
	arg in=0, out=0;
	var signals, pannedSignals, mixedSignal;

	// Input signal from the specified bus - expecting 13 channels
	signals = In.ar(in, 6);

	// Panning for each channel - expecting 13 panning values
	pannedSignals = Array.fill(6, {|i|
		Pan2.ar(signals[i], \pan.kr(0, i).range(-1, 1))
	});

	// Mix all panned signals into a stereo output
	mixedSignal = Mix.new(pannedSignals);

	// Output
	Out.ar(out, mixedSignal);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;