(
~synthCreator.value("Bow", {|n|
	var freq, amp, force, pos, invDec, highLoss, impedance, inharm, lpf, vibAmp, levels;
	var vib, son;

	// Control parameters with lag for smooth transitions
	freq = OceanodeParameterLag.ar(\pitch, 36, n, 0, 127, "vf", 1/30, true).midicps;
	amp = OceanodeParameterLag.ar(\amp, 1, n, 0, 1, "vf", 1/30, true);
	force = OceanodeParameterLag.ar(\force, 0.13, n, 0, 1, "vf", 1/30, true);
	pos = OceanodeParameterLag.ar(\pos, 0.1, n, 0, 1, "vf", 1/30, true);
	invDec = OceanodeParameterLag.ar(\invdec, 1, n, 0, 10, "vf", 1/30, true);
	highLoss = OceanodeParameterLag.ar(\highloss, 3000, n, 0.1, 8000, "vf", 1/30, true);
	inharm = OceanodeParameterLag.ar(\inharm, 80, n, 0, 1000, "vf", 1/30, true);
	impedance = OceanodeParameterLag.ar(\impedance, 0.55, n, 0.001, 32, "vf", 1/30, true);
	lpf = OceanodeParameterLag.ar(\lpf, 90, n, 0, 130, "vf", 1/30, true).midicps;
	vibAmp = OceanodeParameterLag.kr(\vibamp, 0.003, n, 0, 1, "vf", 1/30, true);

	// Output level control with proper curve scaling
	levels = OceanodeParameterLag.ar(\levels, 1, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Generate vibrato
	vib = Gendy1.kr(1, 1, 1, 1, 0.1, 4, mul: vibAmp, add: 1);

	// Generate bowed string sound
	son = DWGBowed.ar(freq * vib, amp, force, 1, pos, 0.1, invDec, highLoss, impedance, inharm);
	son = DWGSoundBoard.ar(son);

	// Enhance with resonances
	son = BPF.ar(son, 118, 1) + son;
	son = BPF.ar(son, 430, 1) + son;
	son = BPF.ar(son, 490, 1) + son;

	// Apply low pass filtering
	son = LPF.ar(son, lpf);

	// Clean up the signal
	son = LeakDC.ar(son);
	son = Limiter.ar(son);

	// Output the signal
	Out.ar(OceanodeOutput.kr(\out), son * levels);
}, description: "Physical model of a bowed string instrument", category: "Source/PhysicalModelling");
)