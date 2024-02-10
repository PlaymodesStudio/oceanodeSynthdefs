SynthDef(\moogfilter13, {
	arg in, out=0;
	var input, filtered;

	// Frequency for multiple voices - expecting 13 frequencies
	var freq=\pitch.kr(128!13).midicps.lag(0.1);

	// Q for multiple voices - expecting 13 Q values
	var q = \q.kr(0.2!13);

	// Mode for multiple voices - expecting 13 mode values
	var mode = \mode.kr(0!13);

	// Saturation for multiple voices - expecting 78 saturation values
	var saturation = \saturation.kr(0.95!13);

	// Input signal from the specified bus
	input = In.ar(in, 13);

	// BMoog filter - processing the input signal
	filtered = BMoog.ar(input, freq, q, mode, saturation);

	// Output
	Out.ar(out, filtered);
}).writeDefFile(d);


d = thisProcess.nowExecutingPath.dirname;