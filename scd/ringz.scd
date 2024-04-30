(
SynthDef(\ringz48, {

	arg in=0, out=0;
	var input, pitch, decayTime, ringzSignal, inputGain;

	// Input signal from the specified bus - expecting 78 channels
	inputGain = \inputgain.kr(0.01!48); // Named control for input gain, defaulting to 1
	input = In.ar(in, 48)*inputGain;

	// Frequency and decay time as control rate arrays
	pitch = \pitch.kr(48!48).midicps; // Control rate array for frequency, defaulting to 440 Hz
	decayTime = \decay.kr(1!48); // Control rate array for decay time, defaulting to 1 second

	// Apply the Ringz filter
	ringzSignal=Ringz.ar(input, pitch, decayTime);

	// Output
	Out.ar(out, ringzSignal);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\ringz78, {

	arg in=0, out=0;
	var input, pitch, decayTime, ringzSignal, inputGain;

	// Input signal from the specified bus - expecting 78 channels
	inputGain = \inputgain.kr(0.01!78); // Named control for input gain, defaulting to 1
	input = In.ar(in, 78)*inputGain;

	// Frequency and decay time as control rate arrays
	pitch = \pitch.kr(48!78).midicps; // Control rate array for frequency, defaulting to 440 Hz
	decayTime = \decay.kr(1!78); // Control rate array for decay time, defaulting to 1 second

	// Apply the Ringz filter
	ringzSignal = Ringz.ar(input, pitch, decayTime);

	// Output
	Out.ar(out, ringzSignal);

}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef(\ringz13, {

	arg in=0, out=0;
	var input, pitch, decayTime, ringzSignal, inputGain;

	// Input signal from the specified bus - expecting 78 channels
	inputGain = \inputgain.kr(0.01!13); // Named control for input gain, defaulting to 1
	input = In.ar(in, 13) * inputGain;

	// Frequency and decay time as control rate arrays
	pitch = \pitch.kr(48!13).midicps; // Control rate array for frequency
	decayTime = \decay.kr(1!13); // Control rate array for decay time, defaulting to 1 second

	// Apply the Ringz filter
	ringzSignal = Ringz.ar(input, pitch, decayTime);

	// Output
	Out.ar(out, ringzSignal);

}).writeDefFile(d);
)