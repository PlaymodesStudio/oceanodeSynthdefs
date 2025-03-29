(
~synthCreator.value("DelayFeed", {|n|
	var fb, del, sig, mx, dry, feedback, grainsz, pitchsh, delmod, modgain;
	
	// Parameters
	fb = OceanodeParameterLag.ar(\feed, 1, n, 0, 1, "vf", 1/30, true);
	del = OceanodeParameterLag.ar(\delay, 0.05, n, 0, 1, "vf", 1/30, true);
	mx = OceanodeParameterLag.ar(\mix, 0, n, 0, 1, "vf", 1/30, true);
	grainsz = OceanodeParameterLag.ar(\grainsize, 0.1, n, 0.01, 1, "vf", 1/30, true);
	pitchsh = OceanodeParameterLag.ar(\pitchshift, 0.5, n, 0.01, 4, "vf", 1/30, true);
	modgain = OceanodeParameterLag.ar(\delmodgain, 1, n, 0, 4, "vf", 1/30, true);
	
	// Create delay modulation
	delmod = ((LFNoise2.ar(0.3!n) * 1e-3) + (LFNoise2.ar(1!n) * 1e-4)) * modgain;
	
	// Input processing
	dry = In.ar(OceanodeInput.kr(\in), n);
	feedback = dry + LocalIn.ar(n);
	
	// Apply delay and pitch shifting
	feedback = DelayC.ar(feedback, 1, del + delmod);
	feedback = feedback + PitchShift.ar(feedback, grainsz, pitchsh);
	
	// Process feedback
	feedback = LeakDC.ar(feedback * fb);
	feedback = feedback.tanh;
	feedback = feedback * -15.dbamp;
	
	// Feedback loop
	LocalOut.ar(feedback);
	
	// Mix dry and wet signals
	sig = XFade2.ar(dry, feedback, mx*2-1);
	
	// Output
	Out.ar(OceanodeOutput.kr(\out), sig);
}, description: "Feedback delay with pitch shifting and modulation", category: "Effect/Time/Delay", variables: [], variableDimensions: []);
)