(
~synthCreator.value("PluckResonator", {|n|
	var freq, amp, pos, trig, invDec, highLoss, inharm, preLPF, lpf, levels;
	var inp, son, rel;

	// Control parameters
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 130, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 1, n, 0, 1, "vf", 1/30, true);
	pos = OceanodeParameterLag.ar(\pos, 0.1, n, 0, 1, "vf", 1/30, true);
	trig = OceanodeParameter.kr(\trig, 0, n, 0, 1, "vf");  // Add trigger parameter
	invDec = OceanodeParameterLag.ar(\invdec, 1, n, 0, 10, "vf", 1/30, true);
	highLoss = OceanodeParameterLag.ar(\highloss, 3000, n, 0.1, 3000, "vf", 1/30, true);
	inharm = OceanodeParameterLag.ar(\inharm, 80, n, 0, 1000, "vf", 1/30, true);
	preLPF = OceanodeParameterLag.ar(\prelpf, 80, n, 0, 130, "vf", 1/30, true).midicps;
	lpf = OceanodeParameterLag.ar(\lpf, 90, n, 0, 130, "vf", 1/30, true).midicps;

	// Output level with proper curve scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Fixed release to prevent synth from being freed
	rel = 1000;

	// Process input signal
	inp = LPF.ar(In.ar(OceanodeInput.kr(\in), n), preLPF);

	// Generate plucked string sound using the input
	son = DWGPluckedStiff.ar(freq, amp, trig, pos, invDec, highLoss, inp, rel, inharm);

	// Apply filtering
	son = LPF.ar(son, lpf);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), son * levels * 0.2);
}, description: "Physical model of a plucked string excited by external audio input", category: "Source/PhysicalModelling");
)