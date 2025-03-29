(
~synthCreator.value("RichReverb", {|n|
	var send, predel, revtime, lpf, hpf, mx, temp, sig, dry, wet;
	var prime_offsets, actual_revtime;

	// Parameters with proper ranges from Synthdefs.json
	send = OceanodeParameterLag.ar(\send, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);
	predel = OceanodeParameterLag.ar(\predelay, 0.02, n, 0, 1, "vf", 1/30, true);
	revtime = OceanodeParameterLag.ar(\time, 4, n, 0.1, 20, "vf", 1/30, true);
	lpf = OceanodeParameterLag.ar(\lowpass, 90, n, 10, 120, "vf", 1/30, true).midicps;
	hpf = OceanodeParameterLag.ar(\hipass, 12, n, 10, 120, "vf", 1/30, true).midicps;
	mx = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);

	// Time calibration - scale the parameter to match perceived time
	actual_revtime = revtime * 4; // Compensate for perceived shorter time

	// Get input signal
	dry = In.ar(OceanodeInput.kr(\in), n);

	// Apply send level
	temp = dry * send;

	// Apply predelay
	temp = DelayN.ar(temp, 1, predel);

	// Prime number offsets for better diffusion
	prime_offsets = #[
		0.001, 0.003, 0.005, 0.007, 0.011, 0.013, 0.017, 0.019, 0.023,
		0.029, 0.031, 0.037, 0.041, 0.043, 0.047, 0.053, 0.059,
		0.061, 0.067, 0.071, 0.073, 0.079, 0.083, 0.089, 0.097,
		0.101, 0.103, 0.107, 0.109, 0.113, 0.127, 0.131
	];

	// Apply initial filtering
	temp = LPF.ar(temp, lpf);
	temp = HPF.ar(temp, hpf);

	// 32 allpass chain with prime number delays for smoother diffusion
	32.do { |i|
		var delay_time, scaled_time;

		// Use prime number offsets, but keep small to avoid big initial delay
		delay_time = 0.001 + (prime_offsets[i] * 0.1);

		// Scale allpass time based on total reverb time, but with a better formula
		// Shorter total time = shorter allpass time
		scaled_time = actual_revtime * (0.06 + (0.04 * i / 32));

		temp = AllpassL.ar(temp, 0.2, delay_time, scaled_time);

		// Apply progressive damping every 8 allpasses
		if (i % 8 == 7) {
			temp = LPF.ar(temp, lpf * 0.98);
		};
	};

	// Final filter stage
	wet = LPF.ar(temp, lpf * 0.9);
	wet = HPF.ar(wet, hpf * 1.1);

	// Normalize and prevent explosion
	wet = wet * 0.7;

	// Mix dry and wet signals with equal power crossfade
	sig = XFade2.ar(dry, wet, mx * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Classic spatial reverb with improved diffusion", category: "Effect/Time/Reverb");
)