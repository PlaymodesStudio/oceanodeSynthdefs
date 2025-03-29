(
~synthCreator.value("DWGClarinet", {|n|
	var freq, contour, amp, closePressure, slopeOpening, inverseDecay, hiLoss, vibA, vibF, levels;
	var env, vib, son;

	// Control parameters
	freq = OceanodeParameterLag.ar(\pitch, 60, n, 0, 128, "vf", 1/30, true).midicps;
	contour = OceanodeParameterLag.ar(\contour, 1, n, 0, 2, "vf", 1/30, true);
	amp = OceanodeParameterLag.ar(\amp, 0.5, n, 0, 1, "vf", 1/30, true);
	closePressure = OceanodeParameterLag.ar(\closepressure, 1, n, 0, 2, "vf", 1/30, true);
	slopeOpening = OceanodeParameterLag.ar(\slopeopening, 1.2, n, 0, 4, "vf", 1/30, true);
	inverseDecay = OceanodeParameterLag.ar(\inversedecay, 0.2, n, 0, 1, "vf", 1/30, true);
	hiLoss = OceanodeParameterLag.ar(\hiloss, 7, n, 0, 20, "vf", 1/30, true);
	vibA = OceanodeParameterLag.ar(\viba, 0.001, n, 0, 1, "vf", 1/30, true);
	vibF = OceanodeParameterLag.ar(\vibf, 4, n, 0, 10, "vf", 1/30, true);

	// Output level with proper curve scaling
	levels = OceanodeParameterLag.ar(\levels, 0, n, 0, 1, "vf", 1/30, true).lincurve(0, 1, 0, 1, 4);

	// Scale amplitude for better response
	amp = LinLin.kr(amp, 0, 1, 0.76, 1);

	// Create envelope and vibrato
	env = DC.ar(contour) * amp;
	vib = SinOsc.kr(vibF, 0, vibA, 1);

	// Generate clarinet sound
	son = DWGClarinet3.ar(Lag.kr(freq, 0) * vib, env, closePressure, slopeOpening, 1, 1000, inverseDecay, hiLoss);

	// Apply high-pass filter
	son = HPF.ar(son, 200);

	// Output
	Out.ar(OceanodeOutput.kr(\out), son * levels);
}, description: "Physical model of a clarinet instrument", category: "Source/PhysicalModelling");
)