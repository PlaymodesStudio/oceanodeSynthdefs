(
~synthCreator.value("Freeze", {|n|
	var source, sig, numchans, trigger, mix;
	var buffers;
	var attackTime, releaseTime, crossfade, laggedTrigger;

	// All variables must be declared at the beginning
	numchans = n;

	// Parameters with appropriate ranges
	trigger = OceanodeParameter.kr(\trigger, 0, n, 0, 1, "vi");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Add attack and release parameters for smooth crossfade
	attackTime = OceanodeParameter.ar(\attack, 0.1, n, 0.01, 2, "vf");
	releaseTime = OceanodeParameter.ar(\release, 0.1, n, 0.01, 2, "vf");

	// Input signal
	source = In.ar(OceanodeInput.kr(\in), n);

	// Create a buffer for each channel
	buffers = LocalBuf(8192).dup(n);

	// Create a smooth crossfade envelope for trigger transitions
	crossfade = n.collect { |i|
		EnvGen.kr(
			Env.asr(attackTime[i], 1, releaseTime[i], \sine),
			trigger[i]
		);
	};

	// Create lagged trigger that keeps freeze active during release
	laggedTrigger = n.collect { |i|
		// Fast attack, slow release
		trigger[i].lag(0, releaseTime[i]);
	};

	// Process each channel individually
	sig = n.collect { |i|
		var buf = buffers[i];
		var chan = source[i];
		var fftChain = FFT(buf, chan);

		// Use the lagged trigger for PV_Freeze to keep it active during release
		fftChain = PV_Freeze(fftChain, laggedTrigger[i]);

		// Convert back to audio
		IFFT(fftChain);
	};

	// Apply the crossfade envelope to smoothly transition between frozen and unfrozen states
	sig = n.collect { |i|
		// Use the crossfade to blend between dry and processed signal
		XFade2.ar(
			source[i],
			sig[i],
			crossfade[i].linlin(0, 1, -1, 1)
		);
	};

	// Apply the overall mix control
	sig = XFade2.ar(source, sig, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);

}, description: "Spectral freeze effect with smooth attack and release transitions", category: "Effect/Time/Freeze");
)