(
SynthDef.new(\phasorar, {
	arg out=0;
	var min, max, beats, bpm, rate, sig;

	beats=\beats.kr(1!13);
	bpm=\bpm.kr(120);
	min=\min.kr(-1!13);
	max=\max.kr(1!13);
	//rate=operation to turn beats into rate for phasor

	sig=Phasor.ar(trig,rate,-1,1,0);

	Out.ar(out, sig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;

(
SynthDef.new(\phasorar, {
	arg out=0;
	var min, max, beats, bpm, rate, sig, cycledur, range;

	beats = \beats.kr(1!13);
	bpm = \bpm.kr(120);
	min = \min.kr(-1!13);
	max = \max.kr(1!13);

	// Calculate the cycle duration in seconds
	cycledur = beats * (60 / bpm);

	// Calculate the range the phasor needs to cover
	range = max - min;

	// Calculate the rate per sample
	rate = range / (cycledur * SampleRate.ir());

	// Create the Phasor signal
	sig = Phasor.ar(0, rate, min, max, 0);

	Out.ar(out, sig);
}).writeDefFile(d);
)