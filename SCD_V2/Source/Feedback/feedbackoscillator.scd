(
~synthCreator.value("FeedbackOsc", {|n|
	var feedback, sig, allpassDelays;
	var phmod, ampmod, levels, pitch, pw, waveform;

	// Parameters with lag for smooth transitions
	phmod = OceanodeParameterLag.ar(\phfeed, 0.5, n, 0, 3, "vf", 1/30, true);
	ampmod = OceanodeParameterLag.ar(\amp, 1, n, 0, 6, "vf", 1/30, true);
	levels = OceanodeParameterLag.ar(\levels, 0.5, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	pitch = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	pw = OceanodeParameterLag.ar(\pw, 0.5, n, 0, 1, "vf", 1/30, true);

	// Waveform selection (0 = Sine, 1 = Saw, 2 = Pulse)
	waveform = OceanodeParameterDropdown.kr(\wavetype, 0, 1, "Sine:Saw:Pulse");

	// Pre-calculate allpass delay times
	allpassDelays = Array.fill(9, { Array.fill(n, { 0.2.rand + 0.1 }) });

	// Feedback loop
	feedback = LocalIn.ar(n);

	// Wave selection using different oscillators
	sig = Select.ar(waveform, [
		// Sine
		SinOsc.ar(pitch, feedback * phmod, ampmod),

		// Saw using SawDPW (or SawOS if available)
		Saw.ar(pitch + (feedback * phmod * 10), ampmod),

		// Pulse using PulseDPW (or SquareOS if available)
		Pulse.ar(pitch + (feedback * phmod * 10), pw, ampmod)
	]);

	// Soft clip to prevent extreme feedback
	sig = sig.tanh;

	// Apply cascade of allpass filters for complex feedback
	9.do { |i|
		sig = AllpassL.ar(sig, 0.3, allpassDelays[i], 5);
	};

	// Complete the feedback loop
	LocalOut.ar(sig);

	// Output with final tanh limiting and level control
	Out.ar(OceanodeOutput.kr(\out), levels * sig.tanh);
}, description: "Oscillator with phase feedback and multiple wave types", category: "Source/Feedback");
)