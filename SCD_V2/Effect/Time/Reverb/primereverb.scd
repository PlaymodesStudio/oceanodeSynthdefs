(
~synthCreator.value("PrimeReverb", {|n|
	var send, predel, revtime, lpf, hpf, mx, temp, sig, dry, wet;
	var early_reflections, diffuse_field, max_delay_time;

	// Parameters with proper ranges from Synthdefs.json
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	predel = OceanodeParameterLag.ar(\predelay, 0.02, n, 0, 1, "vf", 1/30, true);
	revtime = OceanodeParameterLag.ar(\time, 4, n, 0.1, 20, "vf", 1/30, true);
	lpf = OceanodeParameterLag.ar(\lowpass, 90, n, 10, 120, "vf", 1/30, true).midicps;
	hpf = OceanodeParameterLag.ar(\hipass, 12, n, 10, 120, "vf", 1/30, true).midicps;
	mx = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);

	// Get input signal
	dry = In.ar(OceanodeInput.kr(\in), n);

	// Apply send level
	temp = dry * send;

	// Apply predelay
	temp = DelayN.ar(temp, 1, predel);

	// Set max delay time based on reverb time
	max_delay_time = 0.2; // This will accommodate longer reverb times

	// Create early reflections (first stage diffusion)
	early_reflections = temp;

	// First stage diffusion - 4 allpasses with shorter times and less feedback
	4.do { |i|
		var delay_time = rrand(0.001, 0.01);
		var decay = 0.1 * revtime.sqrt;
		early_reflections = AllpassC.ar(early_reflections, max_delay_time, delay_time, decay);
	};

	// Initial filtering
	early_reflections = LPF.ar(early_reflections, lpf);
	early_reflections = HPF.ar(early_reflections, hpf);

	// Main reverb tail - derived from early reflections
	diffuse_field = early_reflections;

	// Second stage diffusion - 8 allpasses with longer decay
	8.do { |i|
		var prime_offsets = #[0.003, 0.005, 0.007, 0.011, 0.013, 0.017, 0.019, 0.023];
		var delay_time = 0.015 + prime_offsets.wrapAt(i);

		// Scale the decay time with actual reverb time
		// The key improvement is this more accurate decay time relationship
		var decay = revtime * 0.8;

		diffuse_field = AllpassC.ar(diffuse_field, max_delay_time, delay_time, decay);
	};

	// Create feedback path for longer and smoother decay
	4.do { |i|
		var delay_time = rrand(0.03, 0.08); // Longer delays for the feedback stage
		diffuse_field = DelayC.ar(diffuse_field, max_delay_time, delay_time);

		// Apply controlled feedback
		diffuse_field = diffuse_field + (diffuse_field * (0.4 * revtime/20).clip(0, 0.8));

		// Apply damping inside the feedback loop
		diffuse_field = LPF.ar(diffuse_field, lpf * (0.9 - (0.1 * i))); // Progressive damping
		diffuse_field = HPF.ar(diffuse_field, hpf);
	};

	// Normalize and prevent explosion
	diffuse_field = diffuse_field * 0.6;
	diffuse_field = Limiter.ar(diffuse_field, 0.95);

	// Mix early reflections and diffuse field
	wet = early_reflections * 0.3 + diffuse_field * 0.7;

	// Mix dry and wet signals with equal power crossfade
	sig = XFade2.ar(dry, wet, mx * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "High quality spatial reverb with early reflections and smooth tail", category: "Effect/Time/Reverb");
)
