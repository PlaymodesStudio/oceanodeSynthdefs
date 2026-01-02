(
~synthCreator.value("FM2op", {|n|
	var p, amp, mR, cR, idx, fb, mod, car, sig;

	// Main parameters with lag for smooth changes
	p = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true).midicps;

	// Modulator and carrier ratio parameters
	mR = OceanodeParameterLag.kr(\mratio, 1, n, 0, 12, "vi", 1/30, true) +
		OceanodeParameterLag.kr(\mratiofine, 0, n, 0, 0.999, "vf", 1/30, true);

	cR = OceanodeParameterLag.kr(\cratio, 1, n, 0, 12, "vi", 1/30, true) +
		OceanodeParameterLag.kr(\cratiofine, 0, n, 0, 0.999, "vf", 1/30, true);

	// Modulation index and feedback amount
	idx = OceanodeParameterLag.ar(\index, 1, n, 0, 10, "vf", 1/30, true);
	fb = OceanodeParameterLag.kr(\mfeedback, 0, n, 0, 1, "vf", 1/30, true);

	// FM modulator with feedback
	mod = SinOscFB.ar(p * mR, fb, mul: p * mR * idx);

	// Carrier with different waveform options
	car = [
		SinOsc.ar(p * cR + mod),
		Saw.ar(p * cR + mod),
		LFTri.ar(p * cR + mod),
		Pulse.ar(p * cR + mod)
	];

	// Waveform selection
	sig = Select.ar(OceanodeParameterDropdown.kr(\mwave, 0, n, "Sine:Saw:Triangle:Pulse"), car);
	  
	// Apply level control with proper scaling
	sig = sig * OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Basic FM synth with multiple waveforms", category: "Source/FM");
)