(
SynthDef(\stereopan13, {
	arg in=0, out=0;
	var signals, pannedSignals, mixedSignal, pan;

	// Input signal from the specified bus - expecting 13 channels
	signals = In.ar(in, 13);
	pan=\pan.kr(0!13);
	// Panning for each channel - expecting 13 panning values
	pannedSignals = Array.fill(13, {|i|
		Pan2.ar(signals[i], pan[i])
	});

	// Mix all panned signals into a stereo output
	mixedSignal = Mix.new(pannedSignals);

	// Output
	Out.ar(out, mixedSignal);
}).writeDefFile(d);
)

(
SynthDef(\stereopan78, {
	arg in=0, out=0;
	var signals, pannedSignals, mixedSignal, pan;

	// Input signal from the specified bus - expecting 13 channels
	signals = In.ar(in, 78);
	pan=\pan.kr(0!78);
	// Panning for each channel - expecting 13 panning values
	pannedSignals = Array.fill(78, {|i|
		Pan2.ar(signals[i], pan[i])
	});

	// Mix all panned signals into a stereo output
	mixedSignal = Mix.new(pannedSignals);

	// Output
	Out.ar(out, mixedSignal);
}).writeDefFile(d);
)

(
SynthDef(\stereopan6, {
	arg in=0, out=0;
	var signals, pannedSignals, mixedSignal, pan;

	// Input signal from the specified bus - expecting 13 channels
	signals = In.ar(in, 6);
	pan=\pan.kr(0!6);
	// Panning for each channel - expecting 13 panning values
	pannedSignals = Array.fill(6, {|i|
		Pan2.ar(signals[i], pan[i])
	});

	// Mix all panned signals into a stereo output
	mixedSignal = Mix.new(pannedSignals);

	// Output
	Out.ar(out, mixedSignal);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;