(
~synthCreator.value("Feedback", {|n|
	var snd, dry, ingain, pitchshift, mix;

	// Parameters
	ingain = OceanodeParameter.ar(\ingain, 1, n, 0, 1, "vf");
	pitchshift = OceanodeParameter.ar(\pitchshift, 0.5, n, 0.25, 2, "vf");
	mix = OceanodeParameter.ar(\mix, 1, n, 0, 1, "vf");

	// Input stage
	snd = In.ar(OceanodeInput.kr(\in), n);
	dry = snd;

	// Create feedback network
	snd = snd + LocalIn.ar(n);
	
	// Apply variable delay
	snd = DelayC.ar(snd, 0.2, n.collect {
		Rand(0.05, 0.2) + (LFNoise2.ar(0.3) * 1e-3) + (LFNoise2.ar(1) * 1e-4)
	});

	// Apply pitch shifting
	snd = snd + PitchShift.ar(snd, Rand(0.1, 0.2)!n, pitchshift)!n;
	
	// Clean up and process
	snd = LeakDC.ar(snd);
	snd = snd.tanh * ingain;
	
	// Send signal back to feedback loop
	LocalOut.ar(snd);

	// Apply level adjustment
	snd = snd * -15.dbamp;

	// Mix dry and wet signals
	snd = XFade2.ar(dry, snd, mix * 2 - 1);

	// Output
	Out.ar(OceanodeOutput.kr(\out), snd);
}, description: "Feedback network with delay and pitch shifting", category: "Source/Feedback");
)