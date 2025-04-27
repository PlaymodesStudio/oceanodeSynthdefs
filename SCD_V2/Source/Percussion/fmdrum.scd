(
~synthCreator.value("FMDrum", {|n|
	var sig, modSig, carrier, modulator, ampEnv, pitchEnv;
	var carFreq, modFreq, fmAmount, rmAmount;
	var polarity, pitchDecay, ampDecay, level, quad;
	var gate, t_gate, latchedAmp;

	// Gate parameter for triggering the drum - using float value
	// Keeping this exactly as in the working version - control rate
	gate = OceanodeParameter.kr(\gate, 0, n, 0, 1, "vf");
	t_gate = Trig.kr(gate > 0, 0.001); // Convert to trigger when value > 0

	// Latch the gate amplitude when triggered
	latchedAmp = Latch.kr(gate, t_gate);

	// Parameter definitions - ALL at control rate as in the working version
	carFreq = OceanodeParameter.kr(\pitch, 36, n, 24, 128, "vf");
	carFreq = carFreq.midicps; // Convert MIDI note to frequency

	modFreq = OceanodeParameter.kr(\modpitch, 60, n, 24, 96, "vf");
	modFreq = modFreq.midicps; // Convert MIDI note to frequency

	// Envelope and decay parameters
	ampDecay = OceanodeParameter.kr(\decay, 100, n, 10, 800, "vf");
	pitchDecay = OceanodeParameter.kr(\pitchdecay, 200, n, 10, 800, "vf");

	// Modulation parameters
	fmAmount = OceanodeParameter.kr(\fmamount, 0.5, n, 0, 20, "vf");
	rmAmount = OceanodeParameter.kr(\rmamount, 0.5, n, 0, 20, "vf");

	// Polarity control (positive or negative modulation)
	polarity = OceanodeParameterDropdown.kr(\polarity, 1, n, "Positive:Negative");

	// Level control
	level = OceanodeParameter.kr(\levels, 0.5, n, 0, 1, "vf").lincurve(0, 1, 0, 1, 4);

	// Quadratic factor for pitch envelope
	quad = OceanodeParameter.kr(\quadratic, 0, n, -1, 1, "vf");

	// Create envelopes - crucial for proper drum sound
	ampEnv = EnvGen.ar(
		Env.perc(0.001, ampDecay/1000, 1, -4),
		gate: t_gate,
		doneAction: 0
	);

	pitchEnv = EnvGen.ar(
		Env.perc(0.001, pitchDecay/1000, 1, -4),
		gate: t_gate,
		doneAction: 0
	);

	// Apply quadratic factor for pitch envelope (x^2 - 1 curve)
	pitchEnv = pitchEnv * (pitchEnv * 2 - 1) * quad;

	// FM implementation with lower oscillator feeding the upper one
	modulator = SinOsc.ar(modFreq, 0, pitchEnv * 8); // Amplify effect

	// Apply FM - note that we're modulating the carrier frequency directly
	// KEEPING THE ORIGINAL MULTIPLICATION APPROACH THAT WORKS
	carrier = SinOsc.ar(
		carFreq * (1 + (modulator * fmAmount)),
		0,
		ampEnv
	);

	// Apply ring modulation if needed
	sig = Mix([
		carrier,
		carrier * SinOsc.ar(modFreq, 0) * rmAmount
	]);

	// Apply polarity
	sig = Select.ar(polarity, [
		sig, // Positive
		sig * -1 // Negative
	]);

	// Apply output level AND latched gate amplitude
	sig = sig * level * latchedAmp;

	// Filter the output for a smoother sound
	sig = LPF.ar(sig, 8000);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "FM percussion with latched amplitude control", category: "Source/Percussion");
)