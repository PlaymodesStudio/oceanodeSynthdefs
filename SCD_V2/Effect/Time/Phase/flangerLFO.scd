(
~synthCreator.value("FlangerLFO", {|n|
	var input, wet, depth, feedback, minDelay, maxDelay, rate, lfoShape, flangerSig, outSig, lfo,userdel;

	// Get input signal
	input = In.ar(OceanodeInput.kr(\in), n);

	// Parameters with proper ranges based on synthdefs.json
	wet = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 0.05, true);
	depth = OceanodeParameterLag.ar(\depth, 0.5, n, 0, 1, "vf", 0.05, true);
	feedback = OceanodeParameterLag.ar(\feedback, 0.5, n, 0, 1, "vf", 0.05, true);
	minDelay = OceanodeParameterLag.ar(\mindelay, 0.004, n, 0, 0.1, "vf", 0.05, true);
	maxDelay = OceanodeParameterLag.ar(\maxdelay, 0.01, n, 0, 0.1, "vf", 0.05, true);
	rate = OceanodeParameterLag.ar(\rate, 0.1, n, 0, 10, "vf", 0.05, true);
	userdel = OceanodeParameterLag.ar(\userdelay, 0, n, -1, 1, "vf", 0.05, true);

	// Dropdown for LFO shape
	lfoShape = OceanodeParameterDropdown.kr(\shape, 0, n, "Sine:Triangle:Saw:Square:SH:User");

	// Create the appropriate LFO based on shape selection
	lfo = Select.ar(lfoShape, [
		SinOsc.ar(rate),
		LFTri.ar(rate),
		LFSaw.ar(rate),
		LFPulse.ar(rate, 0, 0.5),
		LFNoise0.ar(rate),
		userdel
	]);

	// Scale the LFO to the delay time range
	lfo = lfo.range(minDelay, maxDelay);

	// Create the flanger effect with feedback
	flangerSig = DelayC.ar(
		input + (LocalIn.ar(n) * feedback),
		maxDelay + 0.01, // Add a small buffer
		lfo
	);

	// Send the processed signal back for feedback
	LocalOut.ar(flangerSig);

	// Mix dry and wet signals
	outSig = (input * (1 - wet)) + (flangerSig * wet);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), outSig);

}, description: "Flanger effect with variable LFO shape", category: "Effect/Phase");
)