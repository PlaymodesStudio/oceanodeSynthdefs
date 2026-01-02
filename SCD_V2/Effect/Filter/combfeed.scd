(
~synthCreator.value("CombFeed", {|n|
	var input, output, feedbackSig, delayedSig, p, finalP, fb, drywet, vib, ing, vibf, viba, prelpf, postlpf, delayTime, maxDelayTime, fmin, send, mix;

	// Parameters
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 2, "vf", 1/30, true);
	p = OceanodeParameterLag.ar(\pitch, 48, n, 0, 128, "vf", 1/30, true);
	fb = OceanodeParameterLag.ar(\feedback, 0.5, n, -0.9999, 0.9999, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);

	// FM input parameter - same as SinOs
	fmin = OceanodeParameterLag.ar(\fm_in, 0, n, -1, 1, "vf", 1/30, true);

	// Vibrato parameters
	vibf = OceanodeParameter.ar(\vibf, 0, n, 0, 8, "vf");
	viba = OceanodeParameter.ar(\viba, 0, n, 0, 1, "vf");

	// Filter parameters (MIDI note numbers)
	prelpf = OceanodeParameterLag.ar(\prelpf, 130, n, 0, 130, "vf", 1/30, true);
	postlpf = OceanodeParameterLag.ar(\postlpf, 130, n, 0, 130, "vf", 1/30, true);


	// Input processing
	input = In.ar(OceanodeInput.kr(\in), n) * send;

	// Apply input gain and pre-filtering
	input = input;
	input = LPF.ar(input, prelpf.midicps);

	// Apply vibrato to pitch AND add FM input
	vib = SinOsc.ar(vibf, 0, viba, 0);
	finalP = (p + vib + fmin).midicps;

	// Calculate delay time with safety limits
	// Maximum delay time set to handle lowest frequency (about 20Hz)
	maxDelayTime = 0.05; // 50ms max delay for stability
	delayTime = (1 / finalP).clip(0.0001, maxDelayTime);

	// Get feedback signal from previous iteration (for feedback mode only)
	feedbackSig = LocalIn.ar(n);

	// Implementation of true feedforward/feedback
	output = Select.ar(fb >= 0, [
		// FEEDFORWARD MODE (fb < 0):
		// output = input + (fb_amount * delayed_input)
		// This creates notch filtering effects
		input + (DelayC.ar(input, maxDelayTime, delayTime) * fb.abs),

		// FEEDBACK MODE (fb >= 0):
		// output = input + delayed_feedback_signal
		// The feedback signal comes from LocalIn (previous delayed output)
		input + feedbackSig
	]);

	// For feedback mode: send delayed output back through LocalIn/LocalOut
	// For feedforward mode: send silence to break the feedback loop
	delayedSig = DelayC.ar(output, maxDelayTime, delayTime);

	LocalOut.ar(
		Select.ar(fb >= 0, [
			// Feedforward: no feedback signal
			DC.ar(0).dup(n),
			// Feedback: send delayed output * feedback amount
			delayedSig * fb
		])
	);

	// Post-processing with DC removal and filtering
	output = LeakDC.ar(output);
	output = LPF.ar(output, postlpf.midicps);

	// Apply soft limiting to prevent runaway feedback
	output = output.tanh;

	// Mix dry/wet using crossfade for smooth transitions
	output = XFade2.ar(input, output, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), output);
}, description: "High quality feedforward and feedback comb filter with interpolation and FM input", category: "Effect/Filter");
)