(
~synthCreator.value("Pluck", {|n|
	var freq, amp, trig, pos, invDec, highLoss, inharm, preLPF, lpf, att, rel, levels;
	var env, inp, son;

	// Control parameters
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true);
	trig = OceanodeParameter.kr(\trigg, 1, n, 0, 1, "vi");
	pos = OceanodeParameterLag.ar(\pos, 0.1, n, 0, 1, "vf", 1/30, true);
	invDec = OceanodeParameterLag.ar(\invdec, 1, n, 0, 10, "vf", 1/30, true);
	highLoss = OceanodeParameterLag.ar(\highloss, 3000, n, 0.1, 3000, "vf", 1/30, true);
	inharm = OceanodeParameterLag.ar(\inharm, 80, n, 0, 1000, "vf", 1/30, true);
	preLPF = OceanodeParameterLag.ar(\prelpf, 80, n, 0, 130, "vf", 1/30, true).midicps;
	lpf = OceanodeParameterLag.ar(\lpf, 90, n, 0, 130, "vf", 1/30, true).midicps;
	att = OceanodeParameterLag.ar(\att, 0.001, n, 0.001, 3, "vf", 1/30, true);
	rel = OceanodeParameterLag.ar(\rel, 0.0005, n, 0.0005, 10, "vf", 1/30, true);

	// Output level with proper curve scaling
	levels = OceanodeParameterLag.ar(\levels2, 1, n, 0, 1, "vf", 1/30, true);

	// Create envelope and trigger conditioning
	env = Env.new([0, 1, 1, 0], [att, 0.006, rel], [5, -5, -8]);
	trig = Trig1.ar(K2A.ar(trig), 0.035); // Minimum 35ms between triggers

	// Generate noise input with filtering
	inp = amp * LFClipNoise.ar(preLPF) * EnvGen.ar(env, trig, doneAction: 0);

	// Generate plucked string sound
	son = DWGPluckedStiff.ar(freq, amp, trig, pos, invDec, highLoss, inp, 1000, inharm);

	// Clean up and process the signal
	son = LeakDC.ar(son);
	son = LPF.ar(son, lpf);
	son = Limiter.ar(son, 0.95);
	son = Sanitize.ar(son);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), son * levels * 0.2);
}, description: "Physical model of a plucked string instrument", category: "Source/PhysicalModelling");
)