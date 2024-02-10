(
SynthDef(\membrane, {
	arg out=0;
	var p, excitation, signal, finalSig;

	// Tension - expecting an array for 78 voices
	var tension = \tension.kr(0.115!78);

	// Loss - expecting an array for 78 voices
	var loss = \loss.kr(2.9!78);
	var lossexp = LinLin.ar(loss, 0.0, 1.0, 0.9, 1.0);

	// Exciter Level - control the level of the excitation signal
	// Master Level - control the overall level of the final signal
	var exciterLevel = \exciterlevel.kr(0.3!78);
	var masterLevel = \masterlevel.kr(0.15!78);

	// Pitch for multiple voices - expecting 78 pitches
	p = \pitch.kr(22!78).midicps;

	// Excitation signal - Pink Noise
	excitation = PinkNoise.ar(exciterLevel);

	// Membrane synthesis - using MembraneCircle
	signal = MembraneCircle.ar(excitation, tension * (p / 60.midicps), lossexp);

	// Final signal - applying amplitude control
	finalSig = signal * masterLevel;

	// Output - 78 channels
	Out.ar(out, finalSig);
}).writeDefFile(d);
)

d = thisProcess.nowExecutingPath.dirname;
