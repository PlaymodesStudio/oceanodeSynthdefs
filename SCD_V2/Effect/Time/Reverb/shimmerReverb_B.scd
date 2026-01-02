(
~synthCreator.value("ShimmerReverb_Feed", {|n|

	var input, source, diffused, reverbOut, pitchShifted, output;
	var fbArray, i, channel;
	var send, predelay, shimmer, feedback, diffusion, size, decay, color, modRate, modDepth, ratio, mix, level;
	var delayTimes, decayTimes, diffusionCoef;

	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true);
	predelay = OceanodeParameterLag.ar(\predelay, 0.1, n, 0, 1, "vf", 1/30, true);
	shimmer = OceanodeParameterLag.ar(\shimmer, 0.5, n, 0, 1, "vf", 1/30, true);
	feedback = OceanodeParameterLag.ar(\feedback, 0.3, n, 0, 1, "vf", 1/30, true);
	diffusion = 1-(OceanodeParameterLag.ar(\diffusion, 0.7, n, 0, 1, "vf", 1/30, true));
	size = OceanodeParameterLag.ar(\size, 0.5, n, 0.1, 1, "vf", 1/30, true);
	decay = OceanodeParameterLag.ar(\decay, 3, n, 0.1, 40, "vf", 1/30, true);
	color = OceanodeParameterLag.ar(\color, 0.5, n, 0, 1, "vf", 1/30, true);
	modDepth = OceanodeParameterLag.ar(\moddepth, 0.2, n, 0, 1, "vf", 1/30, true);
	modRate = OceanodeParameterLag.ar(\modrate, 0.3, n, 0.01, 5, "vf", 1/30, true);
	ratio = OceanodeParameterLag.kr(\ratio, 2, n, 0, 4, "vf", 1/30, true);
	mix = OceanodeParameterLag.ar(\mix, 0.5, n, 0, 1, "vf", 1/30, true);
	level = OceanodeParameterLag.ar(\level, 1, n, 0, 1, "vf", 1/30, true);

	// Input audio - properly handle n channels
	input = In.ar(OceanodeInput.kr(\in), n);
	source = input.asArray;

	// Apply send control to input and predelay
	input = input * send;
	input = DelayN.ar(input, 1, predelay);

	// Create feedback array to handle the shimmer feedback path
	fbArray = LocalIn.ar(n);

	// Create reverb input by mixing the original signal with the feedback
	input = input + (fbArray * feedback * shimmer);

	// DIFFUSION STAGE - simplified approach with fixed number of allpass filters
	diffused = input;

	// Fixed delay times modulated by size
	delayTimes = [0.0047, 0.0083, 0.011, 0.013, 0.0173, 0.023, 0.031, 0.043];
	decayTimes = [0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85] * decay;
	diffusionCoef = diffusion.linlin(0, 1, 0.2, 0.9);

	// Apply allpass diffusors in series
	delayTimes.do { |dt, idx|
		diffused = AllpassC.ar(
			diffused,
			0.2,
			dt * size.linexp(0.1, 0.9, 0.5, 2),
			decayTimes[idx % decayTimes.size] * diffusionCoef
		);
	};

	// Apply frequency coloration
	diffused = LPF.ar(diffused, color.linexp(0, 1, 1000, 18000));
	diffused = HPF.ar(diffused, color.linexp(0, 1, 80, 500));

	// Reverberation stage with simplified approach
	reverbOut = diffused;

	// PITCH SHIFTING STAGE - for the shimmer effect
	pitchShifted = PitchShift.ar(
		reverbOut,
		windowSize: 0.1,
		pitchRatio: ratio,
		pitchDispersion: 0.01,
		timeDispersion: 0.01
	);

	// Send the pitch-shifted signal back into the feedback loop
	LocalOut.ar(pitchShifted);

	// Mix dry and wet signal
	output = XFade2.ar(source, reverbOut, mix * 2 - 1);

	// Output with level control
	Out.ar(OceanodeOutput.kr(\out), output * level);

}, description: "Shimmer reverb with feedback path for infinite ascending shimmer", category: "Effect/Time/Reverb");
)